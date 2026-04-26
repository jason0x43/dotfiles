local util = require('util')

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

local empty_img =
	util.loadImage(os.getenv("HOME") .. "/.config/hammerspoon/pot-empty.svg")
local filled_img =
	util.loadImage(os.getenv("HOME") .. "/.config/hammerspoon/pot-filled.svg")

-- Add a caffeine menubar icon
Caffeine = {
  ---@type boolean
	running = false,
	icon_empty = empty_img:setSize({ h = 18, w = 18 }),
	icon_filled = filled_img:setSize({ h = 18, w = 18 }),
}

local function refreshMenuState()
	Caffeine.running = isRunning()
	Caffeine.menu:setIcon(
		Caffeine.running and Caffeine.icon_filled or Caffeine.icon_empty
	)
	Caffeine.menu:setMenu({
		{
			title = Caffeine.running and "Decaffeinate" or "Caffeinate",
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
