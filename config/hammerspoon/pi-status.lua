---@module "user.types.hammerspoon"

local util = require("util")

local STATUS_DIR = os.getenv("HOME") .. "/.pi/agent/status"
local HEARTBEAT_STALE_SECONDS = 15
local REFRESH_INTERVAL_SECONDS = 5

---@class PiSession
---@field pid integer
---@field startedAt integer
---@field running boolean
---@field busy boolean
---@field cwd string
---@field sessionFile? string
---@field sessionName? string
---@field displayName? string
---@field model? string
---@field modelProvider? string
---@field thinking? string
---@field updatedAt integer

local hasKitty = hs.fs.attributes("/opt/homebrew/bin/kitten") ~= nil

local menubar = hs.menubar.new()
---@cast menubar hs.menubar

if not menubar then
	error("Failed to create pi status menubar item")
end

---@param path string
---@return table | nil
local function readStatusFile(path)
	local file = io.open(path, "r")
	if not file then
		return nil
	end

	local content = file:read("*a")
	file:close()

	if type(content) ~= "string" or content == "" then
		return nil
	end

	return hs.json.decode(content)
end

---@return PiSession[]
local function collectStatuses()
	local statuses = {}
	local now = os.time()

	local iter, dirObj = hs.fs.dir(STATUS_DIR)
	if not iter then
		return statuses
	end

	for name in iter, dirObj do
		if name ~= "." and name ~= ".." and name:sub(-5) == ".json" then
			local path = STATUS_DIR .. "/" .. name
			local status = readStatusFile(path)
			if type(status) == "table" then
				local updatedAtSeconds =
					math.floor((tonumber(status.updatedAt) or 0) / 1000)
				local isFresh = updatedAtSeconds > 0
					and (now - updatedAtSeconds) <= HEARTBEAT_STALE_SECONDS

				if isFresh then
					table.insert(statuses, status)
				end
			end
		end
	end

	table.sort(statuses, function(a, b)
		local aBusy = a.busy == true
		local bBusy = b.busy == true
		if aBusy ~= bBusy then
			return aBusy
		end

		local aName = (a.sessionName or a.cwd or tostring(a.pid or "")):lower()
		local bName = (b.sessionName or b.cwd or tostring(b.pid or "")):lower()
		return aName < bName
	end)

	return statuses
end

---@param value string | nil
---@param max integer
---@return string
local function truncate(value, max)
	if type(value) ~= "string" or value == "" then
		return ""
	end
	if #value <= max then
		return value
	end
	return value:sub(1, max - 1) .. "…"
end

---@param status PiSession
---@return string
local function getCwd(status)
	local cwd = status.cwd
	cwd = cwd:gsub("^" .. os.getenv("HOME"), "~")
	return truncate(cwd, 48)
end

---@param status PiSession
---@return string
local function getTitle(status)
	local label = status.sessionName or status.displayName
	return truncate(label, 48)
end

---Find the ID of the kitty window containing a given process
---@param pid integer
---@return string | nil
local function kittyWindowIdForPid(pid)
	local command = "./find_kitty_window.sh " .. pid
	local output, _, _, rc = hs.execute(command)
	if rc ~= 0 or type(output) ~= "string" then
		return nil
	end

	local windowId = output:gsub("%s+$", "")
	if windowId == "" then
		return nil
	end
	return windowId
end

---Focus the kitty window containing a given process
---@param pid number
local function focusKittyWindow(pid)
	local windowId = kittyWindowIdForPid(pid)
	if not windowId then
		hs.alert.show(string.format("Couldn't find kitty window for pid %s", pid))
		return
	end

	local command = string.format(
		"/opt/homebrew/bin/kitten @ focus-window --match id:%s --to unix:/tmp/kitty.sock 2>&1",
		windowId
	)
	local output, _, _, rc = hs.execute(command)
	if rc ~= 0 then
		hs.alert.show(string.format("Couldn't focus pi session for pid %s", pid))
		print(output)
		return
	end

	local app = hs.application.find("kitty")
	if app then
		app:activate()
	end
end

---Build the status items for the menubar menu
---@param statuses PiSession[]
local function buildMenu(statuses)
	local menu = {}

	if #statuses == 0 then
		table.insert(menu, { title = "No pi sessions", disabled = true })
		return menu
	end

	for _, status in ipairs(statuses) do
		local busyMark = status.busy and "●" or "○"
		table.insert(menu, {
			title = string.format("%s %s", busyMark, getCwd(status)),
			fn = function()
				focusKittyWindow(status.pid)
			end,
			disabled = not hasKitty,
		})

		-- If the session has a title, add it under the main menu item
		local title = getTitle(status)
		if #title > 0 then
			table.insert(menu, {
				title = "    " .. title,
				disabled = true,
			})
		end

		-- Insert a divider
		table.insert(menu, { title = "-" })
	end

	-- Remove the last divider
	table.remove(menu, #menu)

	return menu
end

local idleIcon = util
	.loadImage(os.getenv("HOME") .. "/.config/hammerspoon/pi-status-idle.svg")
	:setSize({ h = 18, w = 18 })
local activeIcon = util
	.loadImage(os.getenv("HOME") .. "/.config/hammerspoon/pi-status-active.svg")
	:setSize({ h = 18, w = 18 })

---Refresh the menubar item and menu
local function refresh()
	local statuses = collectStatuses()
	local busyCount = 0
	for _, status in ipairs(statuses) do
		if status.busy then
			busyCount = busyCount + 1
		end
	end

	if busyCount > 0 then
		menubar:setIcon(activeIcon)
	else
		menubar:setIcon(idleIcon)
	end

	menubar:setTooltip("pi session status")
	menubar:setMenu(buildMenu(statuses))
end

refresh()

-- Use a global variable to store state
PiStatus = {
	menubar = menubar,
	watcher = hs.pathwatcher.new(STATUS_DIR, refresh),
	timer = hs.timer.doEvery(REFRESH_INTERVAL_SECONDS, refresh)
}

PiStatus.watcher:start()
