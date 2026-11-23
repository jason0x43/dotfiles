// Control which applications URLs load in. This replaces v1's URLDispatcher
// Spoon: Hammerspoon 2 registers as the default http/https handler and routes
// each URL by the rules below.

import { state as bcvpnState, Status as BcvpnStatus } from "./bcvpn-status";
import { createLogger } from "./log";
import { settings } from "./settings";
import { HOME, notify, run } from "./util";

const logger = createLogger("url-dispatcher");

const DEFAULT_BROWSER = "com.apple.Safari";

// Work URLs open in a separate Chrome instance that sends everything through
// the bcvpn proxy (the containerized work VPN; see bcvpn-status.ts and
// /Applications/Chrome Work.app). It has its own user data directory because
// Chrome only reads --proxy-server when an instance starts.
const VPN_CHROME_DIR = `${HOME}/Library/Application Support/Google/Chrome-Work`;
const VPN_PROXY = "http://127.0.0.1:8888";

interface Rule {
	/** Matched (unanchored) against the URL */
	pattern: RegExp;
	/** If set, only URLs opened from an app whose name matches apply */
	app?: RegExp;
	open: (url: string) => void;
}

/** Warn when bcvpn isn't connected, since pages won't load until it is. */
function warnIfVpnDown(): void {
	const status = bcvpnState.current?.status;
	if (status && status !== BcvpnStatus.Connected) {
		notify(
			"bcvpn isn't connected",
			"Work links open in VPN Chrome, which can't load pages until bcvpn connects.",
		);
	}
}

/**
 * Open a URL in the VPN Chrome. If it's running, Chrome hands the URL to it;
 * otherwise this starts it with the proxy flags. `open` makes launchd, not
 * Hammerspoon, the parent of a newly started Chrome.
 */
function openInVpnChrome(url: string): void {
	warnIfVpnDown();
	run("/usr/bin/open", [
		"-na",
		"Google Chrome",
		"--args",
		`--user-data-dir=${VPN_CHROME_DIR}`,
		`--proxy-server=${VPN_PROXY}`,
		"--no-first-run",
		"--no-default-browser-check",
		url,
	]).then((result) => {
		if (result.exitCode !== 0) {
			logger.e(`Couldn't open ${url} in VPN Chrome: ${result.stderr}`);
		}
	});
}

function openWith(bundleID: string): (url: string) => void {
	return (url) => {
		if (!hs.urlevent.openURLWithBundle(url, bundleID)) {
			logger.e(`Couldn't open ${url} with ${bundleID}`);
		}
	};
}

function compile(pattern: string): RegExp | undefined {
	try {
		return new RegExp(pattern);
	} catch (err) {
		logger.e(`Invalid pattern ${pattern}: ${err}`);
		return undefined;
	}
}

const rules: Rule[] = [];

for (const entry of settings.workUrls ?? []) {
	const pattern = compile(entry.pattern);
	const app = entry.app === undefined ? undefined : compile(entry.app);
	if (pattern && (entry.app === undefined || app)) {
		rules.push({ pattern, app, open: openInVpnChrome });
	}
}

rules.push({ pattern: /.*/, open: openWith(DEFAULT_BROWSER) });

/** Unwrap Slack's redirect links. */
function decodeSlackRedirect(url: string): string {
	const match = url.match(/^https:\/\/slack\.redir\.net\/.*url=(.*)/);
	if (!match) {
		return url;
	}
	try {
		return decodeURIComponent(match[1]);
	} catch {
		return match[1];
	}
}

// The most recently activated app other than Hammerspoon 2. macOS activates
// Hammerspoon 2 when it hands it a URL (as the default browser), so by then
// the app the link was clicked in is no longer frontmost.
let lastActiveApp: HSApplication | null = null;

function isHammerspoon(app: HSApplication | null): boolean {
	return app?.bundleID === hs.appinfo.bundleIdentifier;
}

{
	const front = hs.application.frontmost();
	if (!isHammerspoon(front)) {
		lastActiveApp = front;
	}
}

hs.application.on("didActivate", (app) => {
	if (app && !isHammerspoon(app)) {
		lastActiveApp = app;
	}
});

/**
 * Name the app that opened a URL. Hammerspoon 2 doesn't pass the sender's PID
 * (it's -1), so fall back to the app that was active before the URL arrived.
 */
function senderAppName(senderPID: number): string {
	const sender = senderPID > 0 ? hs.application.fromPID(senderPID) : null;
	if (sender) {
		return sender.name ?? "";
	}

	const front = hs.application.frontmost();
	return (isHammerspoon(front) ? lastActiveApp : front)?.name ?? "";
}

function dispatch(fullURL: string, senderPID: number): void {
	const url = decodeSlackRedirect(fullURL);
	const senderApp = senderAppName(senderPID);
	logger.d(`Dispatching ${url} from '${senderApp}' (sender PID ${senderPID})`);

	for (const rule of rules) {
		if (rule.app && !rule.app.test(senderApp)) {
			continue;
		}
		if (rule.pattern.test(url)) {
			rule.open(url);
			return;
		}
	}
}

hs.urlevent.httpCallback = (_scheme, _host, _params, fullURL, senderPID) => {
	dispatch(fullURL, senderPID);
};

// Make Hammerspoon 2 the default browser so it receives http(s) URLs. macOS
// asks for confirmation the first time.
for (const scheme of ["http", "https"]) {
	const handler = hs.urlevent.getDefaultHandler(scheme);
	if (handler?.toLowerCase() !== hs.appinfo.bundleIdentifier.toLowerCase()) {
		hs.urlevent.setDefaultHandler(scheme, hs.appinfo.bundleIdentifier);
	}
}
