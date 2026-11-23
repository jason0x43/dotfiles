// Menubar item listing running pi agent sessions, from the heartbeat files
// they write to ~/.pi/agent/status. Choosing a session focuses its kitty
// window.

import { HOME, alert, isRecord, loadIcon, readJsonFile, run, truncate } from "./util";
import { createLogger } from "./log";

const logger = createLogger("pi-status");

const STATUS_DIR = `${HOME}/.pi/agent/status`;
const HEARTBEAT_STALE_SECONDS = 15;
const REFRESH_INTERVAL_SECONDS = 5;
const KITTEN = "/opt/homebrew/bin/kitten";
const FIND_KITTY_WINDOW = `${hs.appinfo.configDir}/scripts/find_kitty_window.sh`;

interface PiSession {
	pid: number;
	startedAt: number;
	running: boolean;
	busy: boolean;
	cwd: string;
	sessionFile?: string;
	sessionName?: string;
	displayName?: string;
	model?: string;
	modelProvider?: string;
	thinking?: string;
	updatedAt: number;
}

const hasKitty = hs.fs.exists(KITTEN);

const idleIcon = loadIcon("pi-idle.svg", 18);
const activeIcon = loadIcon("pi-active.svg", 18);

function sortKey(status: PiSession): string {
	return (status.sessionName ?? status.cwd ?? String(status.pid ?? "")).toLowerCase();
}

function collectStatuses(): PiSession[] {
	const names = hs.fs.list(STATUS_DIR) ?? [];
	const now = Date.now() / 1000;
	const statuses: PiSession[] = [];

	for (const name of names) {
		if (!name.endsWith(".json")) {
			continue;
		}

		const status = readJsonFile(`${STATUS_DIR}/${name}`);
		if (!isRecord(status)) {
			continue;
		}

		const updatedAtSeconds = Math.floor((Number(status.updatedAt) || 0) / 1000);
		if (updatedAtSeconds > 0 && now - updatedAtSeconds <= HEARTBEAT_STALE_SECONDS) {
			statuses.push(status as unknown as PiSession);
		}
	}

	// Busy sessions first, then by name
	statuses.sort((a, b) => {
		const aBusy = a.busy === true;
		const bBusy = b.busy === true;
		if (aBusy !== bBusy) {
			return aBusy ? -1 : 1;
		}
		const aName = sortKey(a);
		const bName = sortKey(b);
		return aName < bName ? -1 : aName > bName ? 1 : 0;
	});

	return statuses;
}

function getCwd(status: PiSession): string {
	const cwd = typeof status.cwd === "string" ? status.cwd : "";
	return truncate(cwd.startsWith(HOME) ? `~${cwd.slice(HOME.length)}` : cwd, 48);
}

function getTitle(status: PiSession): string {
	return truncate(status.sessionName ?? status.displayName, 48);
}

/** Find the ID of the kitty window containing a given process */
async function kittyWindowIdForPid(pid: number): Promise<string | null> {
	const result = await run(FIND_KITTY_WINDOW, [String(pid)]);
	const windowId = result.stdout.trim();
	if (result.exitCode !== 0 || windowId === "") {
		return null;
	}
	return windowId;
}

/** Focus the kitty window containing a given process */
async function focusKittyWindow(pid: number): Promise<void> {
	const windowId = await kittyWindowIdForPid(pid);
	if (!windowId) {
		alert(`Couldn't find kitty window for pid ${pid}`);
		return;
	}

	const result = await run(KITTEN, [
		"@",
		"focus-window",
		"--match",
		`id:${windowId}`,
		"--to",
		"unix:/tmp/kitty.sock",
	]);
	if (result.exitCode !== 0) {
		alert(`Couldn't focus pi session for pid ${pid}`);
		logger.e(result.stdout + result.stderr);
		return;
	}

	hs.application.matchingName("kitty")?.activate();
}

function buildMenu(statuses: PiSession[]): Record<string, unknown>[] {
	if (statuses.length === 0) {
		return [{ title: "No pi sessions", disabled: true }];
	}

	const items: Record<string, unknown>[] = [];
	for (const status of statuses) {
		const busyMark = status.busy ? "●" : "○";
		items.push({
			title: `${busyMark} ${getCwd(status)}`,
			fn: () => focusKittyWindow(status.pid),
			disabled: !hasKitty,
		});

		// If the session has a title, add it under the main menu item
		const title = getTitle(status);
		if (title.length > 0) {
			items.push({ title: `    ${title}`, disabled: true });
		}

		items.push({ title: "-" });
	}

	// Remove the last divider
	items.pop();

	return items;
}

const menubar = hs.menubar.create(true);
menubar.setTooltip("pi session status");

/** Refresh the menubar item and menu */
function refresh(): void {
	const statuses = collectStatuses();

	if (statuses.length === 0) {
		if (menubar.isVisible()) {
			menubar.hide();
		}
		return;
	}

	menubar.setIcon(statuses.some((status) => status.busy) ? activeIcon : idleIcon);
	menubar.setMenu(buildMenu(statuses));
	if (!menubar.isVisible()) {
		menubar.show();
	}
}

refresh();

// The timer alone catches sessions going stale, and the status directory
// appearing after load; the watcher makes changes show up promptly.
export const watcher = hs.fs.isDirectory(STATUS_DIR)
	? hs.fs.createPathWatcher(STATUS_DIR).setCallback(refresh).start()
	: null;
export const timer = hs.timer.doEvery(REFRESH_INTERVAL_SECONDS, refresh);
