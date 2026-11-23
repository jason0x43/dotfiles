import { PADDING } from "./const";
import { createLogger } from "./log";
import { run } from "./util";

const logger = createLogger("window");

export type Area = "left" | "right" | "center";
export type MoveArea =
	| Area
	| "top"
	| "bottom"
	| "top-left"
	| "top-right"
	| "bottom-left"
	| "bottom-right";

/** Return a screen's usable frame, inset by the edge padding. */
export function screenFrame(screen: HSScreen): HSRect {
	const frame = screen.frame;
	return new HSRect(
		frame.x + PADDING,
		frame.y + PADDING,
		frame.w - 2 * PADDING,
		frame.h - 2 * PADDING,
	);
}

/** Return true if Stage Manager is enabled. */
export async function isStageManagerEnabled(): Promise<boolean> {
	const result = await run("/usr/bin/defaults", [
		"read",
		"com.apple.WindowManager",
		"GloballyEnabled",
	]);
	return result.stdout.trim() === "1";
}

/** Enable or disable Stage Manager. */
export async function setStageManagerEnabled(enabled: boolean): Promise<void> {
	await run("/usr/bin/defaults", [
		"write",
		"com.apple.WindowManager",
		"GloballyEnabled",
		"-bool",
		enabled ? "true" : "false",
	]);
}

export interface FillOptions {
	window?: HSWindow | null;
	marginLeft?: number;
	marginRight?: number;
	marginTop?: number;
	marginBottom?: number;
	/**
	 * A negative width is that many points less than the screen width; a width
	 * below 1 is a fraction of the screen width; otherwise it's in points.
	 * Defaults to half the screen.
	 */
	width?: number;
}

/** Make a window fill the full height of an area of its screen. */
export function fill(area: Area, options: FillOptions = {}): void {
	const win = options.window ?? hs.window.focusedWindow();
	const screen = win?.screen;
	if (!win || !screen) {
		return;
	}

	const { width } = options;
	const marginTop = options.marginTop ?? 0;
	const marginLeft = options.marginLeft ?? 0;
	const marginRight = options.marginRight ?? 0;
	const marginBottom = options.marginBottom ?? 0;

	const sf = screenFrame(screen);

	let w: number;
	if (width === undefined) {
		w = sf.w / 2;
	} else if (width < 0) {
		w = sf.w + width;
	} else if (width < 1) {
		w = sf.w * width;
	} else {
		w = width;
	}

	const h = sf.h - marginTop - marginBottom;
	w = w - marginLeft - marginRight - PADDING / 2;

	let x: number;
	if (area === "left") {
		x = sf.x;
	} else if (area === "right") {
		x = sf.x + (sf.w - w);
	} else {
		x = sf.x + (sf.w / 2 - w / 2);
	}

	const y = sf.y + (sf.h - h) / 2;

	win.frame = new HSRect(x + marginLeft, y + marginTop, w, h);
}

/** Move a window (the focused one by default) to an area of its screen. */
export function moveTo(area: MoveArea, window?: HSWindow | null): HSWindow | null {
	const win = window ?? hs.window.focusedWindow();
	const frame = win?.frame;
	const screen = win?.screen;
	if (!win || !frame || !screen) {
		return null;
	}

	const sf = screenFrame(screen);

	let x: number;
	if (area === "left" || area === "top-left" || area === "bottom-left") {
		x = sf.x;
	} else if (area === "right" || area === "top-right" || area === "bottom-right") {
		x = sf.x + (sf.w - frame.w);
	} else {
		x = sf.x + (sf.w - frame.w) / 2;
	}

	let y: number;
	if (area === "top" || area === "top-left" || area === "top-right") {
		y = sf.y;
	} else if (area === "bottom" || area === "bottom-left" || area === "bottom-right") {
		y = sf.y + (sf.h - frame.h);
	} else {
		y = sf.y + (sf.h - frame.h) / 2;
	}

	win.frame = new HSRect(x, y, frame.w, frame.h);
	return win;
}

/**
 * Move the focused window by an offset in points, stopping at the padded
 * screen edges. Only the axes being moved along are limited.
 */
export function moveBy(dx: number, dy: number): void {
	const win = hs.window.focusedWindow();
	const frame = win?.frame;
	const screen = win?.screen;
	if (!win || !frame || !screen) {
		return;
	}

	const sf = screenFrame(screen);
	let { x, y } = frame;

	if (dx !== 0) {
		const maxX = sf.x + sf.w - frame.w;
		x = Math.max(sf.x, Math.min(frame.x + dx, maxX));
	}

	if (dy !== 0) {
		const maxY = sf.y + sf.h - frame.h;
		y = Math.max(sf.y, Math.min(frame.y + dy, maxY));
	}

	win.position = new HSPoint(x, y);
}

/**
 * Move the focused window to the next or previous space on its screen, and
 * follow it there.
 */
export async function moveToSpace(direction: "next" | "prev"): Promise<void> {
	const win = hs.window.focusedWindow();
	const screen = win?.screen;
	const current = screen?.currentSpace;
	if (!win || !screen || !current) {
		logger.w("Couldn't find the focused window's space");
		return;
	}

	const spaces = screen.spaces;
	const index = spaces.findIndex((space) => space.id === current.id);
	const target = spaces[direction === "next" ? index + 1 : index - 1];
	if (index === -1 || !target) {
		return;
	}

	try {
		await win.moveToSpace(target);
	} catch (err) {
		logger.e(`Couldn't move window to space ${target.id}: ${err}`);
		return;
	}

	// Switch to the space the way ctrl-arrow does (faster than target.goto(),
	// which goes through Mission Control), then refocus the window there.
	hs.eventtap.keyStroke(["ctrl", "fn"], direction === "next" ? "right" : "left");
	hs.timer.doAfter(0.4, () => win.focus());
}

/**
 * Move the focused window to the adjacent screen, keeping its position and
 * size relative to the screen.
 */
export function moveToScreen(direction: "east" | "west"): void {
	const win = hs.window.focusedWindow();
	const frame = win?.frame;
	const screen = win?.screen;
	if (!win || !frame || !screen) {
		return;
	}

	const target = direction === "east" ? screen.toEast() : screen.toWest();
	if (!target) {
		return;
	}

	win.frame = frame.toUnitRect(screen.frame).fromUnitRect(target.frame);
}

/**
 * Resize the focused window, keeping it centered. Values <= 1 are treated as
 * a fraction of the screen size; larger values are in points.
 */
export function resize(increment: { width?: number; height?: number }): void {
	const win = hs.window.focusedWindow();
	const frame = win?.frame;
	const screen = win?.screen;
	if (!win || !frame || !screen) {
		return;
	}

	const sf = screenFrame(screen);
	let { x, y, w, h } = frame;

	if (increment.width !== undefined) {
		let incrW = increment.width;
		if (incrW <= 1) {
			incrW = Math.round(sf.w * incrW);
		}

		const maxWidth = sf.w - (x - sf.x);
		const newWidth = Math.min(w + incrW, maxWidth);
		x = x - (newWidth - w) / 2;
		w = newWidth;
	}

	if (increment.height !== undefined) {
		let incrH = increment.height;
		if (incrH <= 1) {
			incrH = Math.round(sf.h * incrH);
		}

		const maxHeight = sf.h - (y - sf.y);
		const newHeight = Math.min(h + incrH, maxHeight);
		y = y - (newHeight - h) / 2;
		h = newHeight;
	}

	win.frame = new HSRect(x, y, w, h);
}
