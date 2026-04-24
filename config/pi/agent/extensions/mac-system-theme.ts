/**
 * Syncs pi theme with ~/.local/share/theme.
 */

import { type FSWatcher, watch } from "node:fs";
import { readFile } from "node:fs/promises";
import { homedir } from "node:os";
import { basename, dirname, join } from "node:path";
import { getAgentDir } from "@mariozechner/pi-coding-agent";
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

type ThemeSettings = {
	light: string;
	dark: string;
};

// Watch the theme file for system appearance updates
const themeFilePath = join(homedir(), ".local", "share", "theme");
const themeDirPath = dirname(themeFilePath);
const themeFileName = basename(themeFilePath);

// Read extension settings from a settings file
const settingsFile = join(getAgentDir(), "mac-system-theme.settings.json");
const settingsFileName = basename(settingsFile);
let settings: ThemeSettings | null = null;

async function getSettings(): Promise<ThemeSettings> {
	if (settings) {
		return settings;
	}

	try {
		const s = JSON.parse(await readFile(settingsFile, "utf8"));
		if (s.dark && s.light) {
			return s;
		}
	} catch {
		// ignore
	}

	return { light: 'light', dark: 'dark' };
}

async function getTheme(): Promise<string> {
	const settings = await getSettings();
  let theme = settings.light;

  try {
    const content = (await readFile(themeFilePath, "utf8"))
      .trim()
      .toLowerCase();
    if (content === "dark") {
      theme = settings.dark;
    }
  } catch {
    // ignore
  }

  return theme;
}

type SessionContext = {
  ui: {
    setTheme: (theme: string) => void;
  };
};

export default function (pi: ExtensionAPI) {
  let themeWatcher: FSWatcher | null = null;
  let settingsWatcher: FSWatcher | null = null;
  let currentTheme: string | null = null;

  const syncTheme = async (ctx: SessionContext) => {
    const newTheme = await getTheme();
    if (newTheme !== currentTheme) {
      currentTheme = newTheme;
      ctx.ui.setTheme(newTheme);
    }
  };

  pi.on("session_start", async (_event, ctx: SessionContext) => {
    await syncTheme(ctx);

    themeWatcher = watch(
      themeDirPath,
      { encoding: "utf8" },
      async (_eventType: string, filename: string | null) => {
        if (filename === themeFileName) {
					await syncTheme(ctx);
				}
      },
    );

    settingsWatcher = watch(
      getAgentDir(),
      { encoding: "utf8" },
      async (_eventType: string, filename: string | null) => {
        if (filename === settingsFileName) {
					settings = null;
					await syncTheme(ctx);
				}
      },
    );
  });

  pi.on("session_shutdown", () => {
    if (themeWatcher) {
      themeWatcher.close();
      themeWatcher = null;
		}
    if (settingsWatcher) {
      settingsWatcher.close();
      settingsWatcher = null;
    }
  });
}
