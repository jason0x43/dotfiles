// Turn Stage Manager off when more than one display is connected, and on when
// there's only one.

import { alert } from "./util";
import * as window from "./window";

let updateDebounceTimer: HSTimer | null = null;

function updateStageManager(): void {
	updateDebounceTimer?.stop();
	updateDebounceTimer = hs.timer.doAfter(1, async () => {
		updateDebounceTimer = null;

		const screenCount = hs.screen.all().length;
		const enabled = await window.isStageManagerEnabled();

		if (screenCount > 1 && enabled) {
			alert("Disabling Stage Manager");
			await window.setStageManagerEnabled(false);
		} else if (screenCount === 1 && !enabled) {
			alert("Enabling Stage Manager");
			await window.setStageManagerEnabled(true);
		}
	});
}

// Update Stage Manager state on display layout changes
hs.screen.on("change", updateStageManager);

// Update Stage Manager state when the MacBook wakes
hs.power.on("systemDidWake", updateStageManager);
hs.power.on("screensDidWake", updateStageManager);
