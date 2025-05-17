---@param service string
local function hassMediaRequest(service)
	hs.http.asyncPost(
		hs.settings.get("hass_url") .. "/api/events/mac_script",
		hs.json.encode({
			service = service,
			entity = "media_player." .. hs.settings.get("media_player"),
		}),
		{
			["Content-Type"] = "application/json",
			Authorization = "Bearer " .. hs.settings.get("hass_token"),
		},
		function() end
	)
end

local M = {}

---Load the next track
M.nextTrack = function()
	hassMediaRequest("media_player.media_next_track")
end

---Load the previous track
M.previousTrack = function()
	hassMediaRequest("media_player.media_previous_track")
end

---Turn up the volume
M.volumeUp = function()
	hassMediaRequest("media_player.volume_up")
end

---Turn down the volume
M.volumeDown = function()
	hassMediaRequest("media_player.volume_down")
end

---Toggle the player's play/pause state
M.playPause = function()
	hassMediaRequest("media_player.media_play_pause")
end

return M
