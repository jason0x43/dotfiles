// Menubar toggle for caffeinator's "menu" keep-awake session.

import { HOME, loadIcon, shell } from "./util";

const CAFFEINATOR = `PATH="${HOME}/.bun/bin:$PATH" "${HOME}/.bun/bin/caffeinator"`;
// Poll for caffeinate status; not the most efficient, but flexible
const REFRESH_INTERVAL_SECONDS = 3;

const iconEmpty = loadIcon("pot-empty.svg", 18);
const iconFilled = loadIcon("pot-filled.svg", 18);

const menubar = hs.menubar.create();
menubar.setIcon(iconEmpty);

let refreshing = false;

async function isRunning(): Promise<boolean> {
	const result = await shell(`${CAFFEINATOR} list --label menu --label work`);
	return result.stdout !== "";
}

async function refreshMenuState(): Promise<void> {
	if (refreshing) {
		return;
	}
	refreshing = true;

	try {
		const running = await isRunning();
		menubar.setIcon(running ? iconFilled : iconEmpty);
		menubar.setMenu([
			{
				title: running ? "Decaffeinate" : "Caffeinate",
				fn: async () => {
					if (running) {
						await shell(`${CAFFEINATOR} stop --label menu --label work`);
					} else {
						await shell(`${CAFFEINATOR} start --label menu -dimsu`);
					}
					hs.timer.doAfter(0.1, refreshMenuState);
				},
			},
		]);
	} finally {
		refreshing = false;
	}
}

refreshMenuState();

export const timer = hs.timer.doEvery(REFRESH_INTERVAL_SECONDS, refreshMenuState);
