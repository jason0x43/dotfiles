// Settings loaded from settings.json in the config directory. This replaces
// the v1 config's copying of settings.json into hs.settings: the file is read
// once, at load time, and its values are exported directly.

import { createLogger } from "./log";

const logger = createLogger("settings");

export interface WorkUrl {
	/** A regular expression matched (unanchored) against the URL */
	pattern: string;
	/** If set, the rule only applies to URLs opened from apps whose name matches this regular expression */
	app?: string;
}

export interface Settings {
	workUrls?: WorkUrl[];
	hass_token?: string;
	hassToken?: string;
	hass_url?: string;
	media_player?: string;
}

function load(): Settings {
	const path = `${hs.appinfo.configDir}/settings.json`;
	if (!hs.fs.exists(path)) {
		return {};
	}

	const content = hs.fs.read(path, 0, 0);
	if (!content) {
		logger.w(`Couldn't read ${path}`);
		return {};
	}

	try {
		return JSON.parse(content) as Settings;
	} catch (err) {
		logger.e(`Couldn't parse ${path}: ${err}`);
		return {};
	}
}

export const settings: Settings = load();

export function hassUrl(): string {
	return settings.hass_url ?? "https://homeassistant.local";
}

export function hassToken(): string | undefined {
	return settings.hassToken ?? settings.hass_token;
}
