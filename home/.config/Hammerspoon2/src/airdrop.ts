// Move files received via AirDrop from ~/Downloads to ~/Desktop, and close the
// Downloads Finder window that macOS opens for them.

import { createLogger } from "./log";
import { HOME } from "./util";

const logger = createLogger("airdrop");

const DOWNLOADS = `${HOME}/Downloads`;
const DESKTOP = `${HOME}/Desktop`;
const FINDER = "com.apple.finder";

// Delay before inspecting a new file, to let the transfer settle
const SETTLE_SECONDS = 1;
// How close in time a Downloads Finder window must be to an AirDrop arrival
// for it to be considered AirDrop's window
const WINDOW_SECONDS = 5;

const pending = new Set<string>();
// Time of the most recent AirDrop arrival
let lastAirDropAt = 0;
let recentWindows: { element: HSAXElement; at: number }[] = [];
// The focused window of the most recently deactivated non-Finder app, used to
// restore focus after AirDrop's Finder window steals it
let previousWindow: HSWindow | null = null;
let previousApp: HSApplication | null = null;

const now = () => hs.timer.secondsSinceEpoch();

/**
 * Refocus the window that was active before Finder took over. With Stage
 * Manager this also returns it to the center stage.
 */
function restoreFocus(): void {
	if (!previousApp || !previousApp.isRunning) {
		logger.i("No previous app to refocus");
		return;
	}

	// Skip if the user has since switched to some other app
	const frontID = hs.application.frontmost()?.bundleID;
	const previousID = previousApp.bundleID;
	if (frontID !== FINDER && frontID !== previousID) {
		logger.i(`Not refocusing; frontmost app is ${frontID}`);
		return;
	}

	if (previousWindow?.application) {
		logger.i(`Refocusing ${previousID} window: ${previousWindow.title}`);
		previousWindow.focus();
	} else {
		logger.i(`Reactivating ${previousID}`);
		previousApp.activate();
	}
}

/** Return true if the file at path was received via AirDrop. */
function isAirDrop(path: string): boolean {
	const quarantine = hs.fs.xattrGet(path, "com.apple.quarantine");
	if (!quarantine) {
		return false;
	}
	// Quarantine format is "flags;timestamp;agent;uuid"; AirDrop's agent is
	// sharingd
	const agent = quarantine.split(";")[2];
	return agent === "sharingd" || agent === "AirDrop";
}

/**
 * Return a path in dir for name that doesn't collide with an existing file,
 * using Finder-style "name 2.ext" suffixes.
 */
function uniquePath(dir: string, name: string): string {
	let path = `${dir}/${name}`;
	if (!hs.fs.exists(path)) {
		return path;
	}

	const match = name.match(/^(.+)(\.[^.]+)$/);
	const base = match ? match[1] : name;
	const ext = match ? match[2] : "";

	for (let n = 2; ; n++) {
		path = `${dir}/${base} ${n}${ext}`;
		if (!hs.fs.exists(path)) {
			return path;
		}
	}
}

/** Close a Finder window, given its accessibility element. */
function closeFinderWindow(element: HSAXElement): boolean {
	const finder = hs.application.matchingBundleID(FINDER);
	const win = finder?.allWindows.find((w) => w.axElement().isEqualToElement(element));
	if (win) {
		return win.close();
	}

	const closeButton = element.attributeValue("AXCloseButton") as HSAXElement | null;
	return closeButton?.performAction("AXPress") ?? false;
}

/** Close Downloads Finder windows that opened near the last AirDrop arrival. */
function closeAirDropWindows(): void {
	const time = now();
	const remaining: typeof recentWindows = [];
	let closed = false;

	for (const entry of recentWindows) {
		if (Math.abs(entry.at - lastAirDropAt) <= WINDOW_SECONDS) {
			if (entry.element.title === "Downloads") {
				logger.i("Closing AirDrop Downloads window");
				closed = closeFinderWindow(entry.element) || closed;
			}
		} else if (time - entry.at <= WINDOW_SECONDS) {
			remaining.push(entry);
		}
	}
	recentWindows = remaining;

	if (closed) {
		// Give Finder a moment to settle before switching away from it
		hs.timer.doAfter(0.2, restoreFocus);
	}
}

function processFile(path: string): void {
	pending.delete(path);

	if (!hs.fs.exists(path) || !isAirDrop(path)) {
		return;
	}

	const name = path.slice(path.lastIndexOf("/") + 1);
	const dest = uniquePath(DESKTOP, name);
	if (!hs.fs.move(path, dest)) {
		logger.e(`Failed to move ${path}: ${hs.fs.lastError?.message}`);
		return;
	}

	logger.i(`Moved AirDrop file to ${dest}`);
	lastAirDropAt = now();
	closeAirDropWindows();
}

function onDownloadsChanged(paths: string[]): void {
	for (const path of paths) {
		// Only consider direct children of Downloads, skipping hidden files
		if (!path.startsWith(`${DOWNLOADS}/`)) {
			continue;
		}
		const name = path.slice(DOWNLOADS.length + 1);
		if (name === "" || name.includes("/") || name.startsWith(".") || pending.has(path)) {
			continue;
		}

		pending.add(path);
		hs.timer.doAfter(SETTLE_SECONDS, () => processFile(path));
	}
}

function onFinderWindowCreated(_notification: string, element: HSAXElement): void {
	// Finder may not have set the title yet, so record every new window and
	// check the title when deciding whether to close it
	recentWindows.push({ element, at: now() });
	hs.timer.doAfter(0.5, closeAirDropWindows);
}

const WINDOW_CREATED = hs.ax.notificationTypes.windowCreated ?? "AXWindowCreated";

function watchFinder(app: HSApplication): void {
	const element = app.axElement();
	if (!element) {
		logger.w("Couldn't get Finder's accessibility element");
		return;
	}
	try {
		hs.ax.on(element, WINDOW_CREATED, onFinderWindowCreated);
	} catch (err) {
		logger.e(`Couldn't watch Finder windows: ${err}`);
	}
}

export const watcher = hs.fs
	.createPathWatcher(DOWNLOADS)
	.setCallback(onDownloadsChanged)
	.start();

const finder = hs.application.matchingBundleID(FINDER);
if (finder) {
	watchFinder(finder);
}

hs.application.on("didDeactivate", (app) => {
	if (!app || app.bundleID === FINDER) {
		return;
	}
	// Ignore windowless apps, such as the system services involved in an
	// AirDrop transfer, so they don't replace the user's window
	const win = app.focusedWindow ?? app.mainWindow;
	if (win) {
		previousApp = app;
		previousWindow = win;
		logger.d(`Remembered ${app.bundleID} window: ${win.title}`);
	}
});

// Re-attach the Finder watcher if Finder is relaunched
hs.application.on("didLaunch", (app) => {
	if (app?.bundleID === FINDER) {
		watchFinder(app);
	}
});
