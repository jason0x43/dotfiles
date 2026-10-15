-- Move files received via AirDrop from ~/Downloads to ~/Desktop, and close the
-- Downloads Finder window that macOS opens for them.

local logger = hs.logger.new("airdrop", "info")

local HOME = os.getenv("HOME")
local DOWNLOADS = HOME .. "/Downloads"
local DESKTOP = HOME .. "/Desktop"

-- Delay before inspecting a new file, to let the transfer settle
local SETTLE_SECONDS = 1
-- How close in time a Downloads Finder window must be to an AirDrop arrival for
-- it to be considered AirDrop's window
local WINDOW_SECONDS = 5

---@type table<string, boolean>
local pending = {}
-- Time of the most recent AirDrop arrival
local lastAirDropAt = 0
---@type { win: hs.window, at: number }[]
local recentWindows = {}
-- The focused window of the most recently deactivated non-Finder app, used to
-- restore focus after AirDrop's Finder window steals it
---@type hs.window | nil
local previousWindow
---@type hs.application | nil
local previousApp

local FINDER = "com.apple.finder"

---Refocus the window that was active before Finder took over. With Stage
---Manager this also returns it to the center stage.
local function restoreFocus()
	if not previousApp or not previousApp:isRunning() then
		logger.i("No previous app to refocus")
		return
	end

	-- Skip if the user has since switched to some other app
	local front = hs.application.frontmostApplication()
	local frontID = front and front:bundleID()
	local previousID = previousApp:bundleID()
	if frontID ~= FINDER and frontID ~= previousID then
		logger.i("Not refocusing; frontmost app is " .. tostring(frontID))
		return
	end

	if previousWindow and previousWindow:application() then
		logger.i(
			"Refocusing " .. previousID .. " window: " .. previousWindow:title()
		)
		previousWindow:focus()
	else
		logger.i("Reactivating " .. tostring(previousID))
		previousApp:activate()
	end
end

---Return true if the file at path was received via AirDrop.
---@param path string
---@return boolean
local function isAirDrop(path)
	local quarantine = hs.fs.xattr.get(path, "com.apple.quarantine")
	if not quarantine then
		return false
	end
	-- Quarantine format is "flags;timestamp;agent;uuid"; AirDrop's agent is
	-- sharingd
	local agent = quarantine:match("^[^;]*;[^;]*;([^;]*)")
	return agent == "sharingd" or agent == "AirDrop"
end

---Return a path in dir for name that doesn't collide with an existing file,
---using Finder-style "name 2.ext" suffixes.
---@param dir string
---@param name string
---@return string
local function uniquePath(dir, name)
	local path = dir .. "/" .. name
	if not hs.fs.attributes(path, "mode") then
		return path
	end

	local base, ext = name:match("^(.+)(%.[^.]+)$")
	if not base then
		base, ext = name, ""
	end

	local n = 2
	repeat
		path = string.format("%s/%s %d%s", dir, base, n, ext)
		n = n + 1
	until not hs.fs.attributes(path, "mode")
	return path
end

---@param win hs.window
---@return boolean
local function isDownloadsWindow(win)
	return win:title() == "Downloads"
end

---Close Downloads Finder windows that opened near the last AirDrop arrival.
local function closeAirDropWindows()
	local now = hs.timer.secondsSinceEpoch()
	local remaining = {}
	local closed = false
	for _, entry in ipairs(recentWindows) do
		if math.abs(entry.at - lastAirDropAt) <= WINDOW_SECONDS then
			if isDownloadsWindow(entry.win) then
				logger.i("Closing AirDrop Downloads window")
				entry.win:close()
				closed = true
			end
		elseif now - entry.at <= WINDOW_SECONDS then
			table.insert(remaining, entry)
		end
	end
	recentWindows = remaining

	if closed then
		-- Give Finder a moment to settle before switching away from it
		hs.timer.doAfter(0.2, restoreFocus)
	end
end

---@param path string
local function processFile(path)
	pending[path] = nil

	if not hs.fs.attributes(path, "mode") or not isAirDrop(path) then
		return
	end

	local name = path:match("([^/]+)$")
	local dest = uniquePath(DESKTOP, name)
	local ok, err = os.rename(path, dest)
	if not ok then
		logger.e("Failed to move " .. path .. ": " .. tostring(err))
		return
	end

	logger.i("Moved AirDrop file to " .. dest)
	lastAirDropAt = hs.timer.secondsSinceEpoch()
	closeAirDropWindows()
end

---@param paths string[]
local function onDownloadsChanged(paths)
	for _, path in ipairs(paths) do
		-- Only consider direct children of Downloads, skipping hidden files
		local name = path:match("^" .. DOWNLOADS:gsub("%p", "%%%0") .. "/([^/]+)$")
		if name and name:sub(1, 1) ~= "." and not pending[path] then
			pending[path] = true
			hs.timer.doAfter(SETTLE_SECONDS, function()
				processFile(path)
			end)
		end
	end
end

---@param win hs.window
local function onFinderWindowCreated(win)
	-- Finder may not have set the title yet, so record every new window and
	-- check the title when deciding whether to close it
	table.insert(recentWindows, { win = win, at = hs.timer.secondsSinceEpoch() })
	hs.timer.doAfter(0.5, closeAirDropWindows)
end

-- hs.window.filter isn't used because loading it crashes in
-- hs.window.orderedWindowIDs on recent macOS versions

---@param app hs.application
---@return hs.uielement.watcher
local function watchFinder(app)
	local watcher = app:newWatcher(function(element, event)
		if event == hs.uielement.watcher.windowCreated then
			onFinderWindowCreated(element --[[@as hs.window]])
		end
	end)
	watcher:start({ hs.uielement.watcher.windowCreated })
	return watcher
end

if AirDrop then
	AirDrop.pathWatcher:stop()
	AirDrop.appWatcher:stop()
	if AirDrop.finderWatcher then
		AirDrop.finderWatcher:stop()
	end
end

AirDrop = {
	pathWatcher = hs.pathwatcher.new(DOWNLOADS, onDownloadsChanged):start(),
}

local finder = hs.application.get(FINDER)
if finder then
	AirDrop.finderWatcher = watchFinder(finder)
end

AirDrop.appWatcher = hs.application.watcher
	.new(function(_, event, app)
		if not app then
			return
		end
		local isFinder = app:bundleID() == FINDER
		if event == hs.application.watcher.deactivated and not isFinder then
			-- Ignore windowless apps, such as the system services involved in an
			-- AirDrop transfer, so they don't replace the user's window
			local win = app:focusedWindow() or app:mainWindow()
			if win then
				previousApp = app
				previousWindow = win
				logger.d(
					"Remembered "
						.. tostring(app:bundleID())
						.. " window: "
						.. win:title()
				)
			end
		elseif event == hs.application.watcher.launched and isFinder then
			-- Re-attach the Finder watcher if Finder is relaunched
			if AirDrop.finderWatcher then
				AirDrop.finderWatcher:stop()
			end
			AirDrop.finderWatcher = watchFinder(app)
		end
	end)
	:start()
