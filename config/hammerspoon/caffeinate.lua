local util = require("util")

---@return hs.menubar
local function createMenu()
	local menu = hs.menubar.new()
	if not menu then
		error("Failed to create menubar item")
	end
	return menu
end

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

-- Add a caffeine menubar icon
Caffeine = {}

local function refreshMenuState()
	local running = isRunning()
	Caffeine.menu:setIcon(running and icon_filled or icon_empty)
	Caffeine.menu:setMenu({
		{
			title = running and "Decaffeinate" or "Caffeinate",
			fn = function()
				if Caffeine.running then
					decaffeinate()
				else
					caffeinate()
				end

				hs.timer.doAfter(0.1, refreshMenuState)
			end,
		},
	})
end

Caffeine.menu = createMenu()
refreshMenuState()

-- Poll for caffeinate status; not the most efficient, but flexible
Caffeine.watcher = hs.timer.doEvery(2, refreshMenuState)
