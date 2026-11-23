import { INCREMENT, MOVE_STEP, TERM_WIDTH } from "./const";
import * as media from "./media";
import * as window from "./window";

function bind(
	mods: string[],
	key: string,
	pressed: () => void,
	repeat: (() => void) | null = null,
): void {
	if (!hs.hotkey.bind(mods, key, pressed, null, repeat)) {
		console.warn(`[keybinds] Couldn't bind ${[...mods, key].join("+")}`);
	}
}

function getWindows(windows: HSWindow[], appNames: string[]): HSWindow[] {
	return windows.filter((win) => {
		const name = win.application?.name;
		return name != null && appNames.includes(name);
	});
}

async function layoutDisplay(): Promise<void> {
	const windows = hs.window.visibleWindows();
	const terminalWins = getWindows(windows, ["kitty", "Ghostty", "WezTerm", "Terminal"]);
	const browserWins = getWindows(windows, ["Safari", "Wavebox", "Google Chrome", "Firefox"]);
	const mailWins = getWindows(windows, ["Mail"]);
	const simWins = getWindows(windows, ["Simulator"]);
	const emuWins = getWindows(windows, ["qemu-system-aarch64"]);
	const messagesWins = getWindows(windows, ["Messages"]);
	const slackWins = getWindows(windows, ["Slack"]);
	const gptWins = getWindows(windows, ["ChatGPT"]);
	const chatWins = getWindows(windows, ["Google Chat"]);

	if (await window.isStageManagerEnabled()) {
		for (const win of terminalWins) {
			window.fill("center", { window: win, width: 1000 });
		}

		for (const win of [...browserWins, ...mailWins]) {
			window.fill("center", { window: win, width: -300 });
		}

		for (const win of gptWins) {
			const screen = win.screen;
			if (screen) {
				win.size = new HSSize(600, screen.frame.h * 0.7);
				window.moveTo("right", win);
			}
		}

		for (const win of [...simWins, ...emuWins]) {
			window.moveTo("center", win);
		}
		return;
	}

	if (browserWins.length > 0) {
		if (terminalWins.length > 0) {
			for (const win of browserWins) {
				window.fill("left", { window: win, width: 1 - TERM_WIDTH });
			}
			for (const win of terminalWins) {
				window.fill("right", { window: win, width: TERM_WIDTH });
			}
		} else {
			for (const win of browserWins) {
				window.fill("center", { window: win });
			}
		}
	} else {
		for (const win of terminalWins) {
			window.fill("center", { window: win, width: 1200 });
		}
	}

	if (messagesWins.length > 0) {
		window.fill("left", { window: messagesWins[0], width: 0.4 });
	}

	if (slackWins.length > 0) {
		if (messagesWins.length > 0) {
			window.fill("right", { window: slackWins[0], width: -80 });
		} else {
			window.fill("center", { window: slackWins[0] });
		}
	}

	if (chatWins.length > 0) {
		window.fill("right", { window: chatWins[0], width: 600 });
	}
}

// Layout the active display
bind(["ctrl", "shift"], "space", () => {
	layoutDisplay().catch((err) => console.error(`[keybinds] Layout failed: ${err}`));
});

// Move the active window to the center of the display
bind(["ctrl", "shift"], "z", () => {
	window.moveTo("center");
});

// Resize the active window to 70% x 80% of the display and center it
bind(["ctrl", "shift", "alt"], "z", () => {
	const win = hs.window.focusedWindow();
	const screen = win?.screen;
	if (!win || !screen) {
		return;
	}
	const frame = screen.frame;
	win.size = new HSSize(frame.w * 0.7, frame.h * 0.8);
	window.moveTo("center", win);
});

// Make the active window fill the display
bind(["ctrl", "alt", "shift"], "f", () => {
	const win = hs.window.focusedWindow();
	const screen = win?.screen;
	if (win && screen) {
		win.frame = window.screenFrame(screen);
	}
});

// Move the active window a step in a vim direction, repeating while held
const offsets: Record<string, [number, number]> = {
	h: [-MOVE_STEP, 0],
	j: [0, MOVE_STEP],
	k: [0, -MOVE_STEP],
	l: [MOVE_STEP, 0],
};
for (const [key, [dx, dy]] of Object.entries(offsets)) {
	const move = () => window.moveBy(dx, dy);
	bind(["ctrl", "shift"], key, move, move);
}

// Fill the left side of the display with the active window
bind(["ctrl", "alt", "shift"], "h", () => window.fill("left"));

// Fill the right side of the display with the active window
bind(["ctrl", "alt", "shift"], "l", () => window.fill("right"));

// Move the focused window one space to the right
bind(["ctrl", "shift"], "right", () => {
	window.moveToSpace("next");
});

// Move the focused window one space to the left
bind(["ctrl", "shift"], "left", () => {
	window.moveToSpace("prev");
});

// Move the focused window one screen to the right
bind(["ctrl", "alt", "shift"], "right", () => window.moveToScreen("east"));

// Move the focused window one screen to the left
bind(["ctrl", "alt", "shift"], "left", () => window.moveToScreen("west"));

// Make the current window thinner
bind(["ctrl", "shift"], "[", () => window.resize({ width: -INCREMENT }));

// Make the current window wider
bind(["ctrl", "shift"], "]", () => window.resize({ width: INCREMENT }));

// Make the current window shorter
bind(["ctrl", "shift"], ";", () => window.resize({ height: -INCREMENT }));

// Make the current window taller
bind(["ctrl", "shift"], "'", () => window.resize({ height: INCREMENT }));

// Reload the Hammerspoon config
bind(["ctrl", "shift"], "r", () => hs.reload());

// Home Assistant media player bindings
bind(["ctrl", "alt", "shift", "cmd"], "up", media.volumeUp);
bind(["ctrl", "alt", "shift", "cmd"], "down", media.volumeDown);
bind(["ctrl", "alt", "shift", "cmd"], "space", media.playPause);
bind(["ctrl", "alt", "shift", "cmd"], "right", media.nextTrack);
bind(["ctrl", "alt", "shift", "cmd"], "left", media.previousTrack);

// Music media player bindings
bind(["ctrl", "shift", "cmd"], "up", media.musicVolumeUp);
bind(["ctrl", "shift", "cmd"], "down", media.musicVolumeDown);
