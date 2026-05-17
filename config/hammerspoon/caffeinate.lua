local util = require("util")

local function isRunning()
	return hs.execute("pgrep -x caffeinate") ~= ""
end

local function caffeinate()
	hs.execute(
		[[sh -c '/usr/bin/nohup /usr/bin/caffeinate -dimsu >/dev/null 2>&1 &']]
	)
end

local function decaffeinate()
	hs.execute("pkill -x caffeinate")
end

local icon_empty = util
	.loadImage(os.getenv("HOME") .. "/.config/hammerspoon/pot-empty.svg")
	:setSize({ h = 18, w = 18 })
local icon_filled = util
	.loadImage(os.getenv("HOME") .. "/.config/hammerspoon/pot-filled.svg")
	:setSize({ h = 18, w = 18 })

local menubar = hs.menubar.new()
---@cast menubar hs.menubar

local function refreshMenuState()
	local running = isRunning()
	menubar:setIcon(running and icon_filled or icon_empty)
	menubar:setMenu({
		{
			title = running and "Decaffeinate" or "Caffeinate",
			fn = function()
				if running then
					decaffeinate()
				else
					caffeinate()
				end

				hs.timer.doAfter(0.1, refreshMenuState)
			end,
		},
	})
end

refreshMenuState()

-- Use a global variable to store state
Caffeine = {
  menu = menubar,
  -- Poll for caffeinate status; not the most efficient, but flexible
  watcher = hs.timer.doEvery(3, refreshMenuState)
}
