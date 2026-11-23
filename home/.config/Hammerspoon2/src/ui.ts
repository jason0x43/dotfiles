// Circles of decreasing size, drawn one after another
const CIRCLES: { size: number; alpha: number }[] = [
	{ size: 200, alpha: 1 },
	{ size: 150, alpha: 0.8 },
	{ size: 100, alpha: 0.6 },
	{ size: 60, alpha: 0.4 },
	{ size: 20, alpha: 0.2 },
];
const STROKE_WIDTH = 5;
const STEP_SECONDS = 0.07;

/** Highlight the mouse pointer position with a shrinking red circle. */
export function mouseHighlight(): void {
	const mouse = hs.mouse.absolutePosition();
	const primary = hs.screen.primary();
	if (mouse.x === undefined || mouse.y === undefined || !primary) {
		return;
	}

	// Canvas windows use unflipped coordinates (y = 0 at the bottom of the
	// primary screen), while the mouse position is flipped (y = 0 at the top).
	const box = CIRCLES[0].size + STROKE_WIDTH;
	const canvas = hs.canvas.create({
		x: mouse.x - box / 2,
		y: primary.fullFrame.h - mouse.y - box / 2,
		w: box,
		h: box,
	});
	canvas
		.levelValue(hs.canvas.windowLevels.overlay ?? hs.canvas.windowLevels.floating)
		.behavior("canJoinAllSpaces")
		.ignoreMouseEvents(true);

	let index = 0;
	const render = () => {
		const { size, alpha } = CIRCLES[index];
		canvas.replaceElements([
			{
				type: "circle",
				action: "stroke",
				center: { x: box / 2, y: box / 2 },
				radius: size / 2,
				strokeColor: { red: 1, green: 0, blue: 0, alpha },
				strokeWidth: STROKE_WIDTH,
			},
		]);
	};

	render();
	canvas.show();

	const timer = hs.timer.doEvery(STEP_SECONDS, () => {
		index++;
		if (index >= CIRCLES.length) {
			timer.stop();
			canvas.destroy();
			return;
		}
		render();
	});
}
