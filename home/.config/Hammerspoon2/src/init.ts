import { createLogger } from "./log";
import { mouseHighlight } from "./ui";
import { alert, run, shellQuote } from "./util";

const logger = createLogger("init");
const CONFIG_DIR = hs.appinfo.configDir;

// Let the hs2 command-line tool talk to this config
hs.ipc.start();

// Notifications don't appear until they've been allowed. This only prompts
// once.
hs.permissions.requestNotifications().then((granted) => {
	if (!granted) {
		logger.w("Notifications aren't allowed; bcvpn and URL warnings won't appear");
	}
});

// Rebuild the config when a TypeScript source changes, and reload it when the
// compiled output, settings or icons change. (Running `npm run watch` instead
// also works: its output triggers the reload.)

let buildTimer: HSTimer | null = null;
let reloadTimer: HSTimer | null = null;

async function build(): Promise<void> {
	logger.i("Rebuilding Hammerspoon config");
	const result = await run("/bin/zsh", [
		"-l",
		"-c",
		`cd ${shellQuote(CONFIG_DIR)} && ./node_modules/.bin/tsc`,
	]);
	if (result.exitCode !== 0) {
		const output = (result.stdout + result.stderr).trim();
		logger.e(`Build failed:\n${output}`);
		alert(`Config build failed:\n${output.split("\n")[0]}`, 5);
	}
}

function schedule(timer: HSTimer | null, action: () => void): HSTimer {
	timer?.stop();
	return hs.timer.doAfter(0.5, action);
}

// The config's files may be symlinks into a dotfiles repo with the same
// layout. Edits to them are reported at their real paths, so the repo copy is
// watched too.
const realInitJs = hs.fs.pathToAbsolute(`${CONFIG_DIR}/init.js`);
const LINKED_DIR = realInitJs ? realInitJs.slice(0, realInitJs.lastIndexOf("/")) : CONFIG_DIR;
const watchedDirs = LINKED_DIR === CONFIG_DIR ? [CONFIG_DIR] : [CONFIG_DIR, LINKED_DIR];

function relativePath(path: string): string | null {
	for (const dir of watchedDirs) {
		if (path.startsWith(`${dir}/`)) {
			return path.slice(dir.length + 1);
		}
	}
	return null;
}

function onConfigChanged(paths: string[]): void {
	let doBuild = false;
	let doReload = false;

	for (const path of paths) {
		const rel = relativePath(path);
		if (rel === null || rel.startsWith("node_modules/")) {
			continue;
		}
		if (rel.startsWith("src/") && rel.endsWith(".ts")) {
			doBuild = true;
		} else if (
			(rel.startsWith("compiled/") && rel.endsWith(".js")) ||
			rel === "init.js" ||
			rel === "settings.json" ||
			(rel.startsWith("icons/") && rel.endsWith(".svg"))
		) {
			doReload = true;
		}
	}

	if (doBuild) {
		buildTimer = schedule(buildTimer, () => {
			build();
		});
	}
	if (doReload) {
		reloadTimer = schedule(reloadTimer, () => {
			logger.i("Reloading Hammerspoon config");
			hs.reload();
		});
	}
}

export const configWatchers = watchedDirs.map((dir) =>
	hs.fs.createPathWatcher(dir).setCallback(onConfigChanged).start(),
);

// Make the mouse more obvious
hs.hotkey.bind(["ctrl", "shift"], "m", mouseHighlight);

// Load the features. Each module sets itself up when it's first required;
// they're required here rather than imported so that they load after the
// config watcher starts, and so that one failing doesn't stop the others.
const failed: string[] = [];
function load(name: string): void {
	try {
		require(`./${name}`);
	} catch (err) {
		failed.push(name);
		logger.e(`Failed to load ${name}: ${err}`);
	}
}

load("caffeinate");
load("battery-status");
load("url-dispatcher");
load("keybinds");
// load("display-watcher");
load("pi-status");
load("bcvpn-status");
load("airdrop");
load("jira-monitor");

if (failed.length > 0) {
	alert(`Hammerspoon config loaded with errors in: ${failed.join(", ")}`, 5);
} else {
	alert("Hammerspoon config loaded");
}
