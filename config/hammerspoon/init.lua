hs.loadSpoon("EmmyLua")

---@module "types"
---@module "user.types.hammerspoon"

local secrets = require("secrets")
local ui = require("ui")
local logger = hs.logger.new("init", "info")

secrets.init("secrets.json")

-- Use Spotlight when searching for app names
hs.application.enableSpotlightForNameSearches(true)

-- Speed up window animations
hs.window.animationDuration = 0

-- Reload the hammer spoon config when a config file changes
ConfigWatcher = hs.pathwatcher
	.new(hs.configdir, function(files)
		local doReload = false
		for _, file in pairs(files) do
			if file:sub(-4) == ".lua" or file:sub(-5) == ".json" then
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

-- Make the mouse more obvious
hs.hotkey.bind({ "ctrl", "shift" }, "m", ui.mouseHighlight)

require("caffeinate")
require("battery-status")
require("url-dispatcher")
require("keybinds")
--require("display-watcher")

hs.alert.show("Hammerspoon config loaded")
