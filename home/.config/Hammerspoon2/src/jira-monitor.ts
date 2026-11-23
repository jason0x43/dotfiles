// Menubar item listing Jira issues with activity I haven't seen yet, from the
// status file the jira-monitor daemon writes.

import { HOME, isRecord, loadIcon, readJsonFile, truncate } from "./util";

// jira-monitor writes status next to its cache under the state dir.
const STATUS_DIR = `${HOME}/.local/state/jira-monitor`;
const STATUS_PATH = `${STATUS_DIR}/status.json`;
// Shared with the Hammerspoon 1 config, so seen issues stay seen
const STATE_DIR = `${HOME}/.local/state/hammerspoon`;
const STATE_PATH = `${STATE_DIR}/jira-monitor.json`;
const REFRESH_INTERVAL_SECONDS = 60;
const ICON_SIZE = 18;
const REASON_ICON_SIZE = 14;
const SUMMARY_MAX = 56;

type JiraRelevantReason = "assignment" | "unassignment" | "mention" | "comment" | "update";

interface JiraStatusIssue {
	key: string;
	summary: string;
	status: string;
	url: string;
	assigneeAccountId: string | null;
	categories: string[];
	lastRelevantEventId: string;
	lastRelevantAt: string;
	lastRelevantReason: JiraRelevantReason;
}

const notifyIcon = loadIcon("jira-notify.svg", ICON_SIZE);

function loadReasonIcon(name: string): HSImage | undefined {
	try {
		return loadIcon(name, REASON_ICON_SIZE, true);
	} catch {
		return undefined;
	}
}

/** Icons keyed by lastRelevantReason (what caused the issue to surface). */
const reasonIcons: Record<JiraRelevantReason, HSImage | undefined> = {
	comment: loadReasonIcon("jira-reason-comment.svg"),
	mention: loadReasonIcon("jira-reason-mention.svg"),
	assignment: loadReasonIcon("jira-reason-assignment.svg"),
	unassignment: loadReasonIcon("jira-reason-unassignment.svg"),
	update: loadReasonIcon("jira-reason-update.svg"),
};

const reasonTooltips: Record<JiraRelevantReason, string> = {
	comment: "New comment",
	mention: "Mentioned",
	assignment: "Assigned",
	unassignment: "Unassigned",
	update: "Updated",
};

const state = {
	/** Issues from status.json (all tracked). */
	allIssues: [] as JiraStatusIssue[],
	/** Unseen subset shown in the menu. */
	issues: [] as JiraStatusIssue[],
	/** Map of issue key -> lastRelevantEventId value that was marked seen. */
	seen: {} as Record<string, string>,
};

/** True for event ids published by the daemon (`comment:123`, `history:456`). */
function isEventId(value: string): boolean {
	return /^[A-Za-z0-9]+:/.test(value);
}

function loadState(): void {
	const saved = readJsonFile(STATE_PATH);
	const seen: Record<string, string> = {};
	if (isRecord(saved) && isRecord(saved.seen)) {
		for (const [key, eventId] of Object.entries(saved.seen)) {
			// Drop pre-migration entries keyed on ISO timestamps.
			if (typeof eventId === "string" && isEventId(eventId)) {
				seen[key] = eventId;
			}
		}
	}
	state.seen = seen;
}

function saveState(): void {
	hs.fs.mkdir(STATE_DIR);
	hs.fs.write(STATE_PATH, JSON.stringify({ seen: state.seen }, null, 2));
}

/** Parse a daemon ISO-8601 UTC timestamp to epoch seconds. */
function parseIsoUtc(iso: string): number | null {
	const m = iso.match(/^(\d+)-(\d+)-(\d+)T(\d+):(\d+):(\d+)/);
	if (!m) {
		return null;
	}
	const [y, mo, d, h, mi, s] = m.slice(1).map(Number);
	return Date.UTC(y, mo - 1, d, h, mi, s) / 1000;
}

/** Compact relative age for menu titles (e.g. "3w", "2d", "5h"). */
function formatAge(iso: string | null | undefined): string {
	if (typeof iso !== "string" || iso === "") {
		return "";
	}

	const eventTime = parseIsoUtc(iso);
	if (eventTime === null) {
		return "";
	}

	const ageSec = Math.max(0, Date.now() / 1000 - eventTime);
	const day = 86400;

	if (ageSec < 60) return "now";
	if (ageSec < 3600) return `${Math.floor(ageSec / 60)}m`;
	if (ageSec < day) return `${Math.floor(ageSec / 3600)}h`;
	if (ageSec < day * 14) return `${Math.floor(ageSec / day)}d`;
	if (ageSec < day * 60) return `${Math.floor(ageSec / (day * 7))}w`;
	return `${Math.floor(ageSec / (day * 30))}mo`;
}

function isUnseen(issue: JiraStatusIssue): boolean {
	return state.seen[issue.key] !== issue.lastRelevantEventId;
}

/**
 * Prune seen entries for keys no longer present in status, then persist.
 * Only call after a successful status parse — never with an empty/failed
 * read, or a mid-write of status.json will wipe seen state and resurface
 * everything.
 */
function pruneSeen(issues: JiraStatusIssue[]): void {
	if (issues.length === 0) {
		return;
	}

	const present = new Set(issues.map((issue) => issue.key));
	let changed = false;
	for (const key of Object.keys(state.seen)) {
		if (!present.has(key)) {
			delete state.seen[key];
			changed = true;
		}
	}

	if (changed) {
		saveState();
	}
}

function markSeen(issue: JiraStatusIssue): void {
	state.seen[issue.key] = issue.lastRelevantEventId;
	saveState();
}

function markAllSeen(): void {
	let changed = false;
	for (const issue of state.allIssues) {
		if (state.seen[issue.key] !== issue.lastRelevantEventId) {
			state.seen[issue.key] = issue.lastRelevantEventId;
			changed = true;
		}
	}
	if (changed) {
		saveState();
	}
}

function issueTitle(issue: JiraStatusIssue): string {
	const summary = truncate(issue.summary, SUMMARY_MAX);
	const age = formatAge(issue.lastRelevantAt);
	if (summary !== "" && age !== "") {
		return `${issue.key}  ${summary}  · ${age}`;
	} else if (summary !== "") {
		return `${issue.key}  ${summary}`;
	} else if (age !== "") {
		return `${issue.key}  · ${age}`;
	}
	return issue.key;
}

function buildMenu(): Record<string, unknown>[] {
	const items: Record<string, unknown>[] = state.issues.map((issue) => {
		const reason = issue.lastRelevantReason;
		const icon = reasonIcons[reason];
		const tooltip = reasonTooltips[reason];
		return {
			title: issueTitle(issue),
			...(icon ? { icon } : {}),
			...(tooltip ? { tooltip } : {}),
			fn: () => {
				if (typeof issue.url === "string" && issue.url !== "") {
					hs.urlevent.openURL(issue.url);
				}
				markSeen(issue);
				refresh();
			},
		};
	});

	items.push({ title: "-" });
	items.push({
		title: "Clear All",
		fn: () => {
			markAllSeen();
			refresh();
		},
	});

	return items;
}

const menubar = hs.menubar.create(true);
menubar.setTooltip("Jira monitor");
menubar.setIcon(notifyIcon);
menubar.setMenu(buildMenu);

export function refresh(): void {
	const status = readJsonFile(STATUS_PATH);
	// status.json is written in place; a pathwatcher tick mid-write can yield
	// invalid JSON. Keep the previous menu and seen map in that case.
	if (!isRecord(status) || !Array.isArray(status.issues)) {
		return;
	}

	const allIssues = status.issues.filter(
		(issue): issue is JiraStatusIssue =>
			isRecord(issue) &&
			typeof issue.key === "string" &&
			typeof issue.lastRelevantEventId === "string" &&
			issue.lastRelevantEventId !== "",
	);

	pruneSeen(allIssues);
	state.allIssues = allIssues;
	state.issues = allIssues.filter(isUnseen);

	if (state.issues.length === 0) {
		if (menubar.isVisible()) {
			menubar.hide();
		}
	} else if (!menubar.isVisible()) {
		menubar.show();
	}
}

/** Debounce pathwatcher callbacks so we read after the daemon finishes writing. */
let refreshDebounce: HSTimer | null = null;

function scheduleRefresh(): void {
	refreshDebounce?.stop();
	refreshDebounce = hs.timer.doAfter(0.4, () => {
		refreshDebounce = null;
		refresh();
	});
}

hs.fs.mkdir(STATUS_DIR);
hs.fs.mkdir(STATE_DIR);
loadState();
refresh();

export const watcher = hs.fs.createPathWatcher(STATUS_DIR).setCallback(scheduleRefresh).start();
// The pathwatcher alone can miss writes (sleep/wake, coalesced FSEvents,
// mid-write reads that bail). Poll periodically so unseen issues still
// surface.
export const timer = hs.timer.doEvery(REFRESH_INTERVAL_SECONDS, refresh);
