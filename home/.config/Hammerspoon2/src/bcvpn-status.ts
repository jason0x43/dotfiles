// Menubar item for bcvpn, a containerized work VPN (the `bcvpn` command on
// $PATH): shows the tunnel's state and connects or disconnects it.

import { loadIcon, notify, run, runDetached } from "./util";

const REFRESH_INTERVAL_SECONDS = 10;
const ICON_SIZE = 18;

const disconnectedIcon = loadIcon("vpn-disconnected.svg", ICON_SIZE);
const connectedIcon = loadIcon("vpn-connected.svg", ICON_SIZE);

// While connecting or disconnecting, the shield's fill pulses: the outline
// stays solid while the fill fades from full to PULSE_MIN_ALPHA and back,
// once every PULSE_FRAMES * PULSE_INTERVAL_SECONDS.
const PULSE_FRAMES = 16;
const PULSE_INTERVAL_SECONDS = 0.1;
const PULSE_MIN_ALPHA = 0.15;

/**
 * Render the pulse frames. Both icons have the same outline and the connected
 * one adds the fill, so each frame is the disconnected icon (just the outline)
 * with the connected icon drawn over it at the frame's opacity: the outline
 * stays solid and only the fill fades.
 */
function makePulseFrames(): HSImage[] {
	// Draw at 2x so the frames stay sharp on Retina displays, then give them
	// the icon's point size.
	const scale = 2;
	const canvas = hs.canvas.create({ x: 0, y: 0, w: ICON_SIZE * scale, h: ICON_SIZE * scale });
	canvas.appendElements([
		{ type: "image", image: disconnectedIcon, imageScaling: "scaleToFit" },
		{ type: "image", image: connectedIcon, imageScaling: "scaleToFit" },
	]);

	const frames: HSImage[] = [];
	for (let i = 0; i < PULSE_FRAMES; i++) {
		const cos = Math.cos((2 * Math.PI * i) / PULSE_FRAMES);
		canvas.setElementAttribute(
			1,
			"imageAlpha",
			PULSE_MIN_ALPHA + ((1 - PULSE_MIN_ALPHA) * (1 + cos)) / 2,
		);
		const frame = canvas.imageFromCanvas();
		if (frame) {
			frame.size = new HSSize(ICON_SIZE, ICON_SIZE);
			frame.template = true;
			frames.push(frame);
		}
	}
	canvas.destroy();

	return frames;
}

const pulseFrames = makePulseFrames();

/** Connection states reported by `bcvpn status`. */
export enum Status {
	/** The vpn container isn't running (or Docker isn't reachable) */
	Stopped = "stopped",
	/** The container is running, but there's no IKE SA */
	Down = "down",
	/** An IKE SA, but no tunnel */
	Authenticated = "authenticated",
	Connected = "connected",
}

const STATUS_LABELS: Record<Status, string> = {
	[Status.Stopped]: "Stopped",
	[Status.Down]: "Down",
	[Status.Authenticated]: "Authenticated (no tunnel)",
	[Status.Connected]: "Connected",
};

export interface BcvpnState {
	status: Status;
	raw: string;
	lastUpdated: Date;
}

type Action = "up" | "down";

export const state = {
	current: null as BcvpnState | null,
	/** The running `bcvpn up`, `reconnect` or `down` */
	pendingAction: null as Action | null,
	/** Whether a `bcvpn status` is running */
	checkingStatus: false,
	/** Steps the pulse animation while a command runs */
	pulseTimer: null as HSTimer | null,
};

/**
 * Run a bcvpn command through a login shell, so bcvpn, bun, docker and op
 * resolve on $PATH. Resolves with the exit code and the combined output.
 *
 * Commands that may read from 1Password run as a launchd job (`detached`):
 * macOS won't let `op` reach the 1Password app when Hammerspoon 2 launched
 * it, because Hammerspoon 2 can't access 1Password's group container.
 */
async function bcvpn(
	args: string,
	{ detached = false } = {},
): Promise<{ exitCode: number; output: string }> {
	const command = `bcvpn ${args}`;
	const result = detached
		? await runDetached(command)
		: await run("/bin/zsh", ["-l", "-c", command]);
	return { exitCode: result.exitCode, output: result.stdout + result.stderr };
}

/** Parse the connection state from `bcvpn status` output. */
function parseStatus(output: string): Status {
	if (output.includes("CONNECTED")) {
		return Status.Connected;
	} else if (output.includes("AUTHENTICATED")) {
		return Status.Authenticated;
	} else if (output.includes("DOWN")) {
		return Status.Down;
	}

	// "The vpn container isn't running", or bcvpn/Docker failed
	return Status.Stopped;
}

/** Start pulsing the icon, if it isn't already. */
function startPulse(): void {
	if (state.pulseTimer || pulseFrames.length === 0) {
		return;
	}

	let frame = 0;
	menubar.setIcon(pulseFrames[frame]);
	state.pulseTimer = hs.timer.doEvery(PULSE_INTERVAL_SECONDS, () => {
		frame = (frame + 1) % pulseFrames.length;
		menubar.setIcon(pulseFrames[frame]);
	});
}

function stopPulse(): void {
	state.pulseTimer?.stop();
	state.pulseTimer = null;
}

function pendingLabel(): string {
	return state.pendingAction === "up" ? "Connecting..." : "Disconnecting...";
}

function statusLabel(): string {
	return state.current ? STATUS_LABELS[state.current.status] : "Checking...";
}

/** Update the menubar icon and tooltip from the current state. */
function updateMenubar(): void {
	let label: string;
	if (state.pendingAction) {
		// Status refreshes can land mid-command; startPulse leaves a running
		// animation alone so it doesn't jump back to the first frame.
		startPulse();
		label = pendingLabel();
	} else {
		stopPulse();
		menubar.setIcon(
			state.current?.status === Status.Connected ? connectedIcon : disconnectedIcon,
		);
		label = statusLabel();
	}

	menubar.setTooltip(`bcvpn: ${label}`);
}

/** Run `bcvpn status` in the background and update the menubar. */
async function refresh(): Promise<void> {
	if (state.checkingStatus) {
		return;
	}

	state.checkingStatus = true;
	try {
		const { output } = await bcvpn("status");
		const trimmed = output.trim();
		state.current = {
			status: parseStatus(trimmed),
			raw: trimmed,
			lastUpdated: new Date(),
		};
		updateMenubar();
	} finally {
		state.checkingStatus = false;
	}
}

/** Show the last line of a failed command's output. */
function notifyFailure(action: string, output: string): void {
	const lines = output
		.split("\n")
		.map((line) => line.trim())
		.filter((line) => line !== "");
	const lastLine = lines[lines.length - 1];
	console.error(`[bcvpn-status] bcvpn ${action} failed:\n${output.trim()}`);
	notify(`bcvpn ${action} failed`, lastLine ?? "See 'bcvpn logs'");
}

/** Run `bcvpn up`, `reconnect` or `down` in the background, then refresh. */
async function runVpnCommand(action: Action): Promise<void> {
	// `up` builds and starts the containers before connecting; when they're
	// already running, `reconnect` just connects.
	let args: string = action;
	if (action === "up" && state.current && state.current.status !== Status.Stopped) {
		args = "reconnect";
	}

	state.pendingAction = action;
	updateMenubar();

	const { exitCode, output } = await bcvpn(args, { detached: true });
	state.pendingAction = null;
	if (exitCode !== 0) {
		notifyFailure(args, output);
	}
	// The pulse continues until the refreshed status updates the menubar
	refresh();
}

function buildMenu(): Record<string, unknown>[] {
	const status = state.current?.status;
	const items: Record<string, unknown>[] = [{ title: `bcvpn: ${statusLabel()}`, disabled: true }];

	if (state.pendingAction) {
		items.push({ title: pendingLabel(), disabled: true });
	} else if (status) {
		items.push({
			title: status === Status.Connected ? "Reconnect" : "Connect",
			fn: () => runVpnCommand("up"),
		});

		if (status !== Status.Stopped) {
			items.push({
				title: "Disconnect (stop containers)",
				fn: () => runVpnCommand("down"),
			});
		}
	}

	return items;
}

const menubar = hs.menubar.create();
menubar.setMenu(buildMenu);

updateMenubar();
refresh();

export const timer = hs.timer.doEvery(REFRESH_INTERVAL_SECONDS, () => {
	refresh();
});
