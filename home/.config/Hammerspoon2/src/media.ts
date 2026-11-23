// Home Assistant media player controls, plus Music.app volume controls.

import { hassToken, hassUrl, settings } from "./settings";
import { createLogger } from "./log";

const logger = createLogger("media");

function hassMediaRequest(service: string): void {
	const token = hassToken();
	if (!token || !settings.media_player) {
		logger.w("Missing hass_token or media_player setting");
		return;
	}

	hs.http
		.post(
			`${hassUrl()}/api/events/mac_script`,
			JSON.stringify({
				service,
				entity: `media_player.${settings.media_player}`,
			}),
			{
				"Content-Type": "application/json",
				Authorization: `Bearer ${token}`,
			},
		)
		.then((response) => {
			if (response.status < 200 || response.status >= 300) {
				logger.w(`${service} returned HTTP ${response.status}`);
			}
		});
}

/** Load the next track */
export const nextTrack = () => hassMediaRequest("media_player.media_next_track");

/** Load the previous track */
export const previousTrack = () => hassMediaRequest("media_player.media_previous_track");

/** Turn up the volume */
export const volumeUp = () => hassMediaRequest("media_player.volume_up");

/** Turn down the volume */
export const volumeDown = () => hassMediaRequest("media_player.volume_down");

/** Toggle the player's play/pause state */
export const playPause = () => hassMediaRequest("media_player.media_play_pause");

// hs.itunes is gone in Hammerspoon 2, so these drive Music.app directly. Like
// v1's hs.itunes.volumeUp/volumeDown, they step the volume by 5.

function changeMusicVolume(delta: number): void {
	hs.osascript.applescript(`
		if application "Music" is running then
			tell application "Music" to set sound volume to (sound volume + ${delta})
		end if
	`);
}

export const musicVolumeUp = () => changeMusicVolume(5);
export const musicVolumeDown = () => changeMusicVolume(-5);
