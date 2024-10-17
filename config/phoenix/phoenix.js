/// <reference types="./phoenix" />

/** @typedef {import("./phoenix").Direction} Direction */

////////////////////////////////////////////////////////////////////////////////
//
// General setup
//

Phoenix.set({
	daemon: false,
	openAtLogin: true,
});

Event.on("willTerminate", () => {
	Storage.remove("lastPositions");
	Storage.remove("maxHeight");
});

// Event.on('mouseDidMove', focusWindowUnderMouse);

////////////////////////////////////////////////////////////////////////////////
//
// Constants
//

// Globals
const INCREMENT = 0.05;
const CONTROL_SHIFT = ["ctrl", "shift"];
const CONTROL_ALT_SHIFT = ["ctrl", "alt", "shift"];
const PADDING = 20;

const MODAL_TIMEOUT = 750;
const THIN_WIDTH = (1020 / 3840) * 1.4;

/** @type {number | null} */
let helpTimer = null;
/** @type {(() => void) | null} */
let helpCloser = null;

////////////////////////////////////////////////////////////////////////////////
//
// bindings
//

/** @type {[string, string, string[], () => unknown][]} */
const keys = [
	["Show help", "\\", CONTROL_SHIFT, () => showHelp()],

	["Move to NW corner", "q", CONTROL_SHIFT, () => moveTo("top-left")],
	["Move to NE corner", "w", CONTROL_SHIFT, () => moveTo("top-right")],
	["Move to SE corner", "s", CONTROL_SHIFT, () => moveTo("bottom-right")],
	["Move to SW corner", "a", CONTROL_SHIFT, () => moveTo("bottom-left")],
	["Move to left", "h", CONTROL_SHIFT, () => moveTo("left")],
	["Move to right", "l", CONTROL_SHIFT, () => moveTo("right")],
	["Move to top", "k", CONTROL_SHIFT, () => moveTo("top")],
	["Move to bottom", "j", CONTROL_SHIFT, () => moveTo("bottom")],
	["Move to center", "z", CONTROL_SHIFT, () => moveTo("center")],

	["Development layout", "space", CONTROL_SHIFT, () => autoLayout()],

	[
		"Fill NW quadrant",
		"q",
		CONTROL_ALT_SHIFT,
		() => fill("top-left", { width: 1 - THIN_WIDTH }),
	],
	[
		"Fill SW quadrant",
		"a",
		CONTROL_ALT_SHIFT,
		() => fill("bottom-left", { width: 1 - THIN_WIDTH }),
	],
	[
		"Fill SE quadrant",
		"s",
		CONTROL_ALT_SHIFT,
		() => fill("bottom-right", { width: THIN_WIDTH }),
	],
	[
		"Fill NE quadrant",
		"w",
		CONTROL_ALT_SHIFT,
		() => fill("top-right", { width: THIN_WIDTH }),
	],
	[
		"Fill left half",
		"h",
		CONTROL_ALT_SHIFT,
		() => fill("left", { width: 1 - THIN_WIDTH }),
	],
	[
		"Fill right half",
		"l",
		CONTROL_ALT_SHIFT,
		() => fill("right", { width: THIN_WIDTH }),
	],
	["Fill screen", "f", CONTROL_ALT_SHIFT, () => toggleFillScreen()],
	["Fill center", "z", CONTROL_ALT_SHIFT, () => center()],

	[
		"Increase height",
		"'",
		CONTROL_SHIFT,
		() => resize({ height: heightPercent(INCREMENT) }),
	],
	[
		"Decrease height",
		";",
		CONTROL_SHIFT,
		() => resize({ height: -heightPercent(INCREMENT) }),
	],
	[
		"Increase width",
		"]",
		CONTROL_SHIFT,
		() => resize({ width: widthPercent(INCREMENT) }),
	],
	[
		"Decrease width",
		"[",
		CONTROL_SHIFT,
		() => resize({ width: -widthPercent(INCREMENT) }),
	],

	["Move to right space", "right", CONTROL_SHIFT, () => moveToSpace("right")],
	["Move to left space", "left", CONTROL_SHIFT, () => moveToSpace("left")],

	[
		"Move to right display",
		"right",
		CONTROL_ALT_SHIFT,
		() => moveToScreen("right"),
	],
	[
		"Move to left display",
		"left",
		CONTROL_ALT_SHIFT,
		() => moveToScreen("left"),
	],
];

for (const binding of keys) {
	Key.on(binding[1], binding[2], binding[3]);
}

////////////////////////////////////////////////////////////////////////////////
//
// Helper functions
//

/**
 * @param {string} command
 * @param {string[]} args
 * @returns Promise<TaskResult>
 */
async function run(command, args) {
	return new Promise((resolve) => {
		Task.run(command, args, (result) => {
			resolve(result);
		});
	});
}

/**
 * Return true if Stage Manager is enabled
 *
 * @returns Promise<boolean>
 */
async function isStageManagerEnabled() {
	const result = await run("/usr/bin/defaults", [
		"read",
		"com.apple.WindowManager",
		"GloballyEnabled",
	]);
	return result.output.trim() === "1";
}

/**
 * Get the windows for an app in a space
 *
 * This is much, much more efficient than using Space.windows and finding the
 * ones belonging to particular apps.
 *
 * @param {string} appName
 * @param {Space} space
 */
function getWindowsInSpace(appName, space) {
	const app = App.get(appName);
	if (!app) {
		return [];
	}

	const wins = app.windows();

	return wins.filter((win) => win.spaces().find((s) => s.isEqual(space)));
}

/**
 * Layout a browser and terminal in a screen for development
 */
async function autoLayout() {
	const space = Space.active();
	if (space.isFullScreen()) {
		Phoenix.log("Skipping layout because app is full screen");
		return;
	}

	const terminalWins = [
		...getWindowsInSpace("kitty", space),
		...getWindowsInSpace("WezTerm", space),
	];

	const browserWins = [
		...getWindowsInSpace("Safari", space),
		...getWindowsInSpace("Wavebox", space),
		...getWindowsInSpace("Google Chrome", space),
		...getWindowsInSpace("Firefox", space),
	];

	if (await isStageManagerEnabled()) {
		for (const win of terminalWins) {
			fill("center", { window: win, width: 750 });
		}

		const slackWins = getWindowsInSpace("Slack", space);
		const hassWins = getWindowsInSpace("Home Assistant", space);
		const mailWins = getWindowsInSpace("Mail", space);
		const dtWins = getWindowsInSpace("DEVONthink 3", space);
		const movieWins = getWindowsInSpace("iMovie", space);

		for (const win of [
			...browserWins,
			...slackWins,
			...hassWins,
			...mailWins,
			...dtWins,
			...movieWins,
		]) {
			fill("center", { window: win, width: -300 });
		}

		const simWins = getWindowsInSpace("Simulator", space);
		const messagesWins = getWindowsInSpace("Messages", space);
		for (const win of [...simWins, ...messagesWins]) {
			moveTo("center", win);
		}
	} else {
		const browserWins = [
			...getWindowsInSpace("Safari", space),
			...getWindowsInSpace("Wavebox", space),
			...getWindowsInSpace("Google Chrome", space),
			...getWindowsInSpace("Firefox", space),
		];

		if (browserWins.length > 0 && terminalWins.length > 0) {
			for (const window of browserWins) {
				fill("left", { window, width: 1 - THIN_WIDTH });
			}
			for (const window of terminalWins) {
				fill("right", { window, width: THIN_WIDTH });
			}
		} else if (browserWins.length > 0) {
			for (const window of browserWins) {
				fill("center", { window });
			}
		}

		const reederWins = getWindowsInSpace("Reeder", space);
		if (reederWins.length === 1) {
			moveTo("center", reederWins[0]);
		}

		const waveboxWins = getWindowsInSpace("Wavebox", space);
		if (waveboxWins.length === 1) {
			const messagesWins = getWindowsInSpace("Messages", space);

			if (messagesWins.length > 0) {
				fill("left", { window: messagesWins[0], width: 0.32 });
				fill("right", { window: waveboxWins[0], width: -90 });
			} else {
				fill("center", { window: waveboxWins[0] });
			}
		}

		const messagesWins = getWindowsInSpace("Messages", space);
		const slackWins = getWindowsInSpace("Slack", space);

		if (messagesWins.length === 1) {
			fill("left", { window: messagesWins[0], width: 0.4 });
		}

		if (slackWins.length === 1) {
			if (messagesWins.length > 0) {
				fill("right", { window: slackWins[0], width: -84 });
			} else {
				fill("center", { window: slackWins[0] });
			}
		}

		const chatWins = getWindowsInSpace("Chat", space);
		Phoenix.log(`>>> found ${chatWins.length} chat wins`);
		if (chatWins.length === 1) {
			fill("right", { window: chatWins[0], width: 0.58 });
		}
	}
}

/**
 * Add icon space to a screen frame
 *
 * @param {Rectangle} frame
 */
function addIconSpace(frame) {
	return {
		...frame,
		width: frame.width - 90,
	};
}

/**
 * Center a window on the screen and make it take up a large portion of the screen
 *
 * @param {Window} [window]
 */
function center(window = Window.focused()) {
	const screenFrame = getScreenFrame(window);
	const isLargeScreen = screenFrame.width > 2000;
	const widthScale = isLargeScreen ? 0.6 : 0.8;
	const heightScale = isLargeScreen ? 0.8 : 0.9;

	window.setSize({
		width: Math.round(screenFrame.width * widthScale),
		height: Math.round(screenFrame.height * heightScale),
	});

	moveTo("center");
}

/**
 * Return the bottom left coordinate in frame2 that will center frame1 within
 * it
 *
 * @param {Rectangle} frame1
 * @param {Rectangle} [frame2]
 */
function centerFrame(frame1, frame2) {
	frame2 = frame2 || getScreenFrame();
	const x = frame2.x + Math.round(frame2.width / 2 - frame1.width / 2);
	const y = frame2.y + Math.round(frame2.height / 2 - frame1.height / 2);
	return { x, y };
}

/**
 * Fill an area of the screen
 *
 * @param {string} anchor
 * @param {{
 *   window?: Window,
 *   width?: number,
 * }} options
 */
function fill(anchor, options = {}) {
	const window = options.window ?? Window.focused();
	if (!window) {
		return;
	}

	let screenFrame = getScreenFrame(window);
	const frame = window.frame();

	let width = screenFrame.width / 2;

	if (options.width > 1) {
		width = options.width;
	} else if (options.width > 0) {
		width = screenFrame.width * options.width;
	} else if (options.width < 0) {
		width = screenFrame.width + options.width;
	}

	// size
	switch (anchor) {
		case "top-left":
		case "top-right":
		case "bottom-left":
		case "bottom-right":
			frame.height = screenFrame.height / 2 - 0.5 * PADDING;
			frame.width = width - PADDING;
			break;
		case "left":
		case "right":
			frame.height = screenFrame.height;
			frame.width = width - PADDING;
			break;
		case "center":
			frame.height = screenFrame.height;
			frame.width = width;
			break;
	}

	// x-coordinate
	switch (anchor) {
		case "top-left":
		case "bottom-left":
		case "left":
			frame.x = screenFrame.x;
			break;
		case "center":
			frame.x = screenFrame.x + (screenFrame.width - frame.width) / 2;
			break;
		case "top-right":
		case "bottom-right":
		case "right":
			frame.x =
				screenFrame.x +
				(screenFrame.width - frame.width)  - PADDING / 2;
			break;
	}

	// y-coordinate
	switch (anchor) {
		case "top-left":
		case "top-right":
			frame.y = screenFrame.y;
			break;
		case "right":
		case "left":
		case "center":
			frame.y = screenFrame.y + (screenFrame.height - frame.height) / 2;
			break;
		case "bottom-right":
		case "bottom-left":
			frame.y = screenFrame.y + frame.height + PADDING;
			break;
	}

	window.setFrame(frame);
}

/**
 * Move focus to the closest neighbor in a given direction
 *
 * @param {string} direction
 * @param {Window} [window]
 */
function focusNeighbor(direction, window = Window.focused()) {
	const neighbors = window.neighbors(direction);
	for (const n of neighbors) {
		if (n.isVisible()) {
			n.focus();
			break;
		}
	}
}

/**
 * Indicate whether two frames are equal
 *
 * @param {Rectangle} frame1
 * @param {Rectangle} frame2
 */
function framesEqual(frame1, frame2) {
	if (!frame1 && !frame2) {
		return true;
	}
	if (!frame1 || !frame2) {
		return false;
	}
	return (
		frame1.x == frame2.x &&
		frame1.y == frame2.y &&
		frame1.width == frame2.width &&
		frame1.height == frame2.height
	);
}

/**
 * Get a delta frame between a window and its screen
 *
 * @param {Window} [window]
 */
function getDeltaFrame(window = Window.focused()) {
	const frame = window.frame();
	const screen = getScreenFrame(window);

	return {
		x: screen.x - frame.x,
		y: screen.y - frame.y,
		width: screen.width - frame.width,
		height: screen.height - frame.height,
	};
}

/**
 * Parent frame
 *
 * @param {Window} [window]
 */
function getScreenFrame(window = Window.focused()) {
	const screenFrame = window.screen().flippedVisibleFrame();
	return padScreenFrame(screenFrame);
}

/**
 * Get a percent of the screen height
 *
 * @param {number} percent
 * @param {Window} [window]
 */
function heightPercent(percent, window = Window.focused()) {
	const screen = getScreenFrame(window);
	return Math.round(screen.height * percent);
}

/**
 * Move to top, bottom, left, right, center, NW, NE, SE, SW
 *
 * @param {Direction} direction
 * @param {Window} [window]
 */
function moveTo(direction, window = Window.focused()) {
	const delta = getDeltaFrame(window);
	const frame = window.frame();
	const screenFrame = getScreenFrame(window);

	// x-coordinate
	switch (direction) {
		case "left":
		case "top-left":
		case "bottom-left":
			frame.x = screenFrame.x;
			break;
		case "right":
		case "top-right":
		case "bottom-right":
			frame.x = screenFrame.x + delta.width;
			break;
		case "top":
		case "bottom":
		case "center":
			frame.x = screenFrame.x + delta.width / 2;
			break;
	}

	// y-coordinate
	switch (direction) {
		case "top":
		case "top-left":
		case "top-right":
			frame.y = screenFrame.y;
			break;
		case "bottom":
		case "bottom-right":
		case "bottom-left":
			frame.y = screenFrame.y + delta.height;
			break;
		case "left":
		case "right":
		case "center":
			frame.y = screenFrame.y + delta.height / 2;
			break;
	}

	Phoenix.log(`Setting frame to ${JSON.stringify(frame)}`);
	window.setFrame(frame);
}

/**
 * Move a window to the screen to the left or right
 *
 * @param {string} direction
 * @param {Window} [window]
 */
function moveToScreen(direction, window = Window.focused()) {
	const screen = window.screen();
	const newScreen = direction === "right" ? screen.next() : screen.previous();
	if (screen === newScreen) {
		return;
	}

	const screenFrame = padScreenFrame(screen.flippedVisibleFrame());
	const newScreenFrame = padScreenFrame(newScreen.flippedVisibleFrame());
	const windowFrame = window.frame();

	Phoenix.log(`-------------------------------------------`);
	Phoenix.log(`screenFrame: ${JSON.stringify(screenFrame)}`);
	Phoenix.log(`newScreenFrame: ${JSON.stringify(newScreenFrame)}`);
	Phoenix.log(`windowFrame: ${JSON.stringify(windowFrame)}`);

	const widthRatio = newScreenFrame.width / screenFrame.width;
	const heightRatio = newScreenFrame.height / screenFrame.height;

	const width = Math.round(windowFrame.width * widthRatio);
	const height = Math.round(windowFrame.height * heightRatio);
	const x = Math.round(
		newScreenFrame.x + (windowFrame.x - screenFrame.x) * widthRatio,
	);
	const y = Math.round(
		newScreenFrame.y + (windowFrame.y - screenFrame.y) * heightRatio,
	);
	const newWindowFrame = { x, y, width, height };

	// Moving between screens in a single operation doesn't work reliably, so do
	// the operations one at a time
	if (
		newWindowFrame.height > windowFrame.height ||
		newWindowFrame.width > windowFrame.width
	) {
		// New window is bigger -- move first
		window.setTopLeft(newWindowFrame);
		window.setSize(newWindowFrame);
	} else {
		// New window is smaller -- shrink it first
		window.setSize(newWindowFrame);
		window.setTopLeft(newWindowFrame);
	}
}

/**
 * Move a window to the space to the left or right
 *
 * @param {string} direction
 * @param {Window} [window]
 */
function moveToSpace(direction, window) {
	window = window || Window.focused();
	if (!window) {
		return;
	}

	const space = Space.active();
	if (!space) {
		return;
	}

	const targetSpace = direction == "right" ? space.next() : space.previous();
	if (!targetSpace) {
		return;
	}

	targetSpace.moveWindows([window]);
	window.focus();
}

/**
 * Apply padding to a screen frame
 *
 * @param {Rectangle} frame
 */
function padScreenFrame(frame) {
	return {
		x: frame.x + PADDING,
		y: frame.y + PADDING,
		width: frame.width - 2 * PADDING,
		height: frame.height - 2 * PADDING,
	};
}

/**
 * Resize by value, maintaining center
 *
 * @param {{ width?: number, height?: number }} increment
 * @param {Window} [window]
 */
async function resize(increment, window = Window.focused()) {
	const screenFrame = getScreenFrame(window);
	const windowFrame = window.frame();

	if (increment.width) {
		const maxWidth = screenFrame.width - (windowFrame.x - screenFrame.x);
		const oldWidth = windowFrame.width;
		const newWidth = Math.min(
			windowFrame.width + increment.width,
			maxWidth,
		);
		windowFrame.width = newWidth;
		windowFrame.x -= (newWidth - oldWidth) / 2;
	}

	if (increment.height) {
		const maxHeight = screenFrame.height - (windowFrame.y - screenFrame.y);
		const oldHeight = windowFrame.height;
		const newHeight = Math.min(
			windowFrame.height + increment.height,
			maxHeight,
		);
		windowFrame.height = newHeight;
		windowFrame.y -= (newHeight - oldHeight) / 2;
	}

	window.setFrame(windowFrame);
}

/**
 * Show help
 */
function showHelp() {
	if (helpCloser != null) {
		clearTimeout(helpTimer);
		helpTimer = setTimeout(helpCloser, MODAL_TIMEOUT);
		return;
	}

	/** @param {[string, string, string[], () => unknown][]} modalKeys */
	function makeModal(modalKeys) {
		const lines = [];
		for (const key of modalKeys) {
			lines.push(`${key[2].join("+")}+${key[1]} - ${key[0]}`);
		}
		const text = lines.join("\n");
		return Modal.build({ weight: 20, text });
	}

	const leftKeys = keys.slice(0, Math.ceil(keys.length / 2));
	const rightKeys = keys.slice(leftKeys.length);

	const leftModal = makeModal(leftKeys);
	const rightModal = makeModal(rightKeys);

	const leftFrame = leftModal.frame();
	const leftOrigin = centerFrame(leftFrame);
	leftOrigin.x -= Math.round(leftFrame.width / 2 + PADDING / 2);
	leftModal.origin = leftOrigin;

	const rightFrame = rightModal.frame();
	const rightOrigin = centerFrame(rightFrame);
	rightOrigin.x += Math.round(rightFrame.width / 2 + PADDING / 2);
	rightModal.origin = rightOrigin;

	leftModal.show();
	rightModal.show();

	helpCloser = () => {
		leftModal.close();
		rightModal.close();
		helpCloser = null;
		helpTimer = null;
	};

	helpTimer = setTimeout(helpCloser, MODAL_TIMEOUT);
}

/**
 * Toggle a window between filling the screen and its original size
 *
 * @param {Window} [window]
 */
function toggleFillScreen(window = Window.focused()) {
	const windowId = window.hash();
	const lastPositions =
		/** @type {{ [key: number]: Rectangle }} */ (
			Storage.get("lastPositions")
		) ?? {};
	const windowFrame = window.frame();
	const screenFrame = getScreenFrame();

	if (!framesEqual(windowFrame, screenFrame)) {
		Phoenix.log("Filling center");
		lastPositions[windowId] = { ...windowFrame };
		Storage.set("lastPositions", lastPositions);
		fill("center", { window });
	} else if (lastPositions[windowId]) {
		window.setFrame(lastPositions[windowId]);
	}
}

/**
 * Get a percent of the screen width
 *
 * @param {number} percent
 * @param {Window} [window]
 */
function widthPercent(percent, window = Window.focused()) {
	const screenFrame = getScreenFrame(window);
	return Math.round(screenFrame.width * percent);
}
