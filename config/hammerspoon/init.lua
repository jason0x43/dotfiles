---@module "types"
---@module "user.types.hammerspoon"

local window = require("window")
local const = require("const")
local settings = require("settings")
local ui = require("ui")
local media = require("media")
local logger = hs.logger.new("init", "info")

---@param windows hs.window[]
---@param appNames string[]
---@return hs.window[]
local function getWindows(windows, appNames)
	return hs.fnutils.ifilter(windows, function(win)
		local app = win:application():name()
		return hs.fnutils.contains(appNames, app)
	end)
end

settings.init("settings.json")

hs.application.enableSpotlightForNameSearches(true)

-- Speed up window animations
hs.window.animationDuration = 0

-- Layout the active display
hs.hotkey.bind({ "ctrl", "shift" }, "space", function()
	local windows = hs.window.visibleWindows()
	local terminalWins =
		getWindows(windows, { "kitty", "Ghostty", "WezTerm", "Terminal.app" })
	local browserWins =
		getWindows(windows, { "Safari", "Wavebox", "Google Chrome", "Firefox" })
	local mailWins = getWindows(windows, { "Mail" })
	local simWins = getWindows(windows, { "Simulator" })
	local emuWins = getWindows(windows, { "qemu-system-aarch64" })
	local messagesWins = getWindows(windows, { "Messages" })
	local slackWins = getWindows(windows, { "Slack" })
	local gptWins = getWindows(windows, { "ChatGPT" })

	-- If Stage Manager is enabled, assume only the built-in display is in use.
	-- Otherwise, assume the external display is in use.
	if window.isStageManagerEnabled() then
		for _, win in ipairs(terminalWins) do
			window.fill("center", { window = win, width = 1000 })
		end

		for _, win in ipairs(browserWins) do
			window.fill("center", { window = win, width = -300 })
		end

		for _, win in ipairs(mailWins) do
			window.fill("center", { window = win, width = -300 })
		end

		for _, win in ipairs(gptWins) do
			local screenFrame = win:screen():frame()
			win:setSize({ w = 600, h = screenFrame.h * 0.7 })
			window.moveTo("right", win)
		end

		for _, win in ipairs(simWins) do
			window.moveTo("center", win)
		end

		for _, win in ipairs(emuWins) do
			window.moveTo("center", win)
		end
	else
		if #browserWins > 0 then
			if #terminalWins > 0 then
				-- if #simWins + #emuWins > 0 then
				-- 	for _, win in ipairs(browserWins) do
				-- 		window.fill("left", {
				-- 			window = win,
				-- 			width = 1570,
				-- 			marginLeft = 370,
				-- 		})
				-- 	end
				-- 	for _, win in ipairs(simWins) do
				-- 		window.moveTo("top-left", win)
				-- 	end
				-- 	for _, win in ipairs(emuWins) do
				-- 		window.moveTo("bottom-left", win)
				-- 	end
				-- 	for _, win in ipairs(terminalWins) do
				-- 		window.fill("right", { window = win, width = const.THIN_WIDTH })
				-- 	end
				-- else
          logger.i("using non-emu sizing")
					for _, win in ipairs(browserWins) do
						window.fill("left", { window = win, width = 1 - const.TERM_WIDTH })
					end
					for _, win in ipairs(terminalWins) do
						window.fill("right", { window = win, width = const.TERM_WIDTH })
					end
				-- end
			else
				for _, win in ipairs(browserWins) do
					window.fill("center", { window = win })
				end
			end
		else
			for _, win in ipairs(terminalWins) do
				window.fill("center", { window = win, width = 1200 })
			end
		end

		if #messagesWins > 0 then
			window.fill("left", { window = messagesWins[1], width = 0.4 })
		end

		if #slackWins > 0 then
			if #messagesWins > 0 then
				window.fill("right", { window = slackWins[1], width = -80 })
			else
				window.fill("center", { window = slackWins[1] })
			end
		end

		local chatWins = getWindows(windows, { "Chat" })
		if #chatWins > 0 then
			window.fill("right", { window = chatWins[1], width = 600 })
		end
	end
end)

-- Move the active window to the center of the display
hs.hotkey.bind({ "ctrl", "shift" }, "z", function()
	window.moveTo("center")
end)

-- Move the active window to the center of the display
hs.hotkey.bind({ "ctrl", "shift", "alt" }, "z", function()
	local win = hs.window.focusedWindow()
	local frame = win:screen():frame()
	win:setSize({ w = frame.w * 0.7, h = frame.h * 0.8 })
	window.moveTo("center")
end)

-- Make the active window fill the display
hs.hotkey.bind({ "ctrl", "alt", "shift" }, "f", function()
	local win = hs.window.focusedWindow()
	local frame = window.screenFrame(win:screen())
	win:setFrame(frame)
end)

-- Move the active window to the left side of the display
hs.hotkey.bind({ "ctrl", "shift" }, "h", function()
	window.moveTo("left")
end)

-- Fill the left side of the display with the active window
hs.hotkey.bind({ "ctrl", "alt", "shift" }, "h", function()
	window.fill("left")
end)

-- Move the active window to the right side of the display
hs.hotkey.bind({ "ctrl", "shift" }, "l", function()
	window.moveTo("right")
end)

-- Fill the right side of the display with the active window
hs.hotkey.bind({ "ctrl", "alt", "shift" }, "l", function()
	window.fill("right")
end)

-- Move the focus window one space to the right
hs.hotkey.bind({ "ctrl", "shift" }, "right", function()
	window.moveToSpace("next")
end)

-- Move the focus window one space to the left
hs.hotkey.bind({ "ctrl", "shift" }, "left", function()
	window.moveToSpace("prev")
end)

-- Move the focus window one screen to the right
hs.hotkey.bind({ "ctrl", "alt", "shift" }, "right", function()
	hs.window.focusedWindow():moveOneScreenEast()
end)

-- Move the focused window one screen to the left
hs.hotkey.bind({ "ctrl", "alt", "shift" }, "left", function()
	hs.window.focusedWindow():moveOneScreenWest()
end)

-- Make the current window thinner
hs.hotkey.bind({ "ctrl", "shift" }, "[", function()
	window.resize({ width = -const.INCREMENT })
end)

-- Make the current window wider
hs.hotkey.bind({ "ctrl", "shift" }, "]", function()
	window.resize({ width = const.INCREMENT })
end)

-- Make the current window shorter
hs.hotkey.bind({ "ctrl", "shift" }, ";", function()
	window.resize({ height = -const.INCREMENT })
end)

-- Make the current window taller
hs.hotkey.bind({ "ctrl", "shift" }, "'", function()
	window.resize({ height = const.INCREMENT })
end)

-- Reload the Hammerspoon config
hs.hotkey.bind({ "ctrl", "shift" }, "r", hs.reload)

-- Home Assistant media player bindings
hs.hotkey.bind({ "ctrl", "alt", "shift", "cmd" }, "up", media.volumeUp)
hs.hotkey.bind({ "ctrl", "alt", "shift", "cmd" }, "down", media.volumeDown)
hs.hotkey.bind({ "ctrl", "alt", "shift", "cmd" }, "space", media.playPause)
hs.hotkey.bind({ "ctrl", "alt", "shift", "cmd" }, "right", media.nextTrack)
hs.hotkey.bind({ "ctrl", "alt", "shift", "cmd" }, "left", media.previousTrack)

-- Reload the hammer spoon config when a config file changes
ConfigWatcher = hs.pathwatcher
	.new(hs.configdir, function(files)
		local doReload = false
		for _, file in pairs(files) do
			if file:sub(-4) == ".lua" then
				doReload = true
				break
			end
		end
		if doReload then
			logger.i("Reloading Hammerspoon config")
			hs.reload()
		end
	end)
	:start()

hs.hotkey.bind({ "ctrl", "shift" }, "m", ui.mouseHighlight)

hs.alert.show("Hammerspoon config loaded")
