local util = require("util")

local caffeinator = [[PATH="$HOME/.bun/bin:$PATH" "$HOME/.bun/bin/caffeinator"]]

local function isRunning()
	return hs.execute(caffeinator .. [[ list --label menu --label work]]) ~= ""
end

local function caffeinate()
	hs.execute(caffeinator .. [[ start --label menu -dimsu]])
end

local function decaffeinate()
	hs.execute(caffeinator .. [[ stop --label menu --label work]])
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
	watcher = hs.timer.doEvery(3, refreshMenuState),
}
