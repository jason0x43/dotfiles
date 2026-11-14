---@module "user.types.hammerspoon"

-- Menubar item for bcvpn, the containerized BCRV VPN
-- (~/Work/projects/bluecompass/bcvpn): shows the tunnel's state and connects
-- or disconnects it.

local util = require("util")

local REFRESH_INTERVAL_SECONDS = 10
local ICON_WIDTH = 18
local ICON_HEIGHT = 18

local disconnectedIcon = util
	.loadImage("vpn-disconnected.svg")
	:setSize({ h = ICON_HEIGHT, w = ICON_WIDTH })
local connectedIcon = util
	.loadImage("vpn-connected.svg")
	:setSize({ h = ICON_HEIGHT, w = ICON_WIDTH })
local connectingIcon = util
	.loadImage("vpn-connecting.svg")
	:setSize({ h = ICON_HEIGHT, w = ICON_WIDTH })

-- Connection states reported by `bcvpn status`.
local STATUS = {
	-- The vpn container isn't running (or Docker isn't reachable)
	STOPPED = "stopped",
	-- The container is running, but there's no IKE SA
	DOWN = "down",
	-- An IKE SA, but no tunnel
	AUTHENTICATED = "authenticated",
	CONNECTED = "connected",
}

local STATUS_LABELS = {
	[STATUS.STOPPED] = "Stopped",
	[STATUS.DOWN] = "Down",
	[STATUS.AUTHENTICATED] = "Authenticated (no tunnel)",
	[STATUS.CONNECTED] = "Connected",
}

---@class BcvpnState
---@field status string
---@field raw string
---@field lastUpdated integer

local M = {
	---@type BcvpnState | nil
	state = nil,
	---@type hs.menubar | nil
	menubar = nil,
	---@type hs.timer | nil
	timer = nil,
	---The running `bcvpn up`, `reconnect` or `down`
	---@type hs.task | nil
	activeTask = nil,
	---@type "up" | "down" | nil
	pendingAction = nil,
	---The running `bcvpn status`
	---@type hs.task | nil
	statusTask = nil,
}

---Run a bcvpn command through a login shell, so bcvpn, bun, docker and op
---resolve on $PATH. Runs asynchronously; `callback` gets the exit code and
---the combined output.
---@param args string
---@param callback fun(exitCode: integer, output: string)
---@return hs.task
local function bcvpn(args, callback)
	local task = hs.task.new("/bin/zsh", function(exitCode, stdout, stderr)
		callback(exitCode, (stdout or "") .. (stderr or ""))
	end, { "-l", "-c", "bcvpn " .. args })
	task:start()
	return task
end

---Parse the connection state from `bcvpn status` output.
---@param output string
---@return string
local function parseStatus(output)
	if output:find("CONNECTED", 1, true) then
		return STATUS.CONNECTED
	elseif output:find("AUTHENTICATED", 1, true) then
		return STATUS.AUTHENTICATED
	elseif output:find("DOWN", 1, true) then
		return STATUS.DOWN
	end

	-- "The vpn container isn't running", or bcvpn/Docker failed
	return STATUS.STOPPED
end

---Ensure the menubar item exists.
local function ensureMenubar()
	if M.menubar then
		return
	end

	M.menubar = hs.menubar.new()
	if not M.menubar then
		error("Failed to create bcvpn status menubar item")
	end
	M.menubar:setMenu(function()
		return M.buildMenu()
	end)
end

---Update the menubar icon and tooltip from the current state.
local function updateMenubar()
	ensureMenubar()

	local icon = disconnectedIcon
	if M.pendingAction == "up" then
		icon = connectingIcon
	elseif M.state and M.state.status == STATUS.CONNECTED then
		icon = connectedIcon
	end
	M.menubar:setIcon(icon)

	local label = M.state and STATUS_LABELS[M.state.status] or "Checking..."
	M.menubar:setTooltip("bcvpn: " .. label)
end

---Run `bcvpn status` in the background and update the menubar.
local function refresh()
	if M.statusTask then
		return
	end

	M.statusTask = bcvpn("status", function(_, output)
		M.statusTask = nil
		local trimmed = util.trim(output)
		M.state = {
			status = parseStatus(trimmed),
			raw = trimmed,
			lastUpdated = os.time(),
		}
		updateMenubar()
	end)
end

---Show the last line of a failed command's output.
---@param action string
---@param output string
local function notifyFailure(action, output)
	local lastLine = ""
	for line in output:gmatch("[^\n]+") do
		if util.trim(line) ~= "" then
			lastLine = util.trim(line)
		end
	end

	hs.notify
		.new({
			title = "bcvpn " .. action .. " failed",
			informativeText = lastLine ~= "" and lastLine or "See 'bcvpn logs'",
			withdrawAfter = 0,
		})
		:send()
end

---Run `bcvpn up`, `reconnect` or `down` in the background, then refresh.
---@param action "up" | "down"
local function runVpnCommand(action)
	local args = action
	-- `up` builds and starts the containers before connecting; when they're
	-- already running, `reconnect` just connects.
	if action == "up" and M.state and M.state.status ~= STATUS.STOPPED then
		args = "reconnect"
	end

	M.pendingAction = action
	updateMenubar()

	-- Hold the reference so the task isn't garbage-collected mid-run.
	M.activeTask = bcvpn(args, function(exitCode, output)
		M.activeTask = nil
		M.pendingAction = nil
		if exitCode ~= 0 then
			notifyFailure(args, output)
		end
		refresh()
	end)
end

---@return table
function M.buildMenu()
	local status = M.state and M.state.status
	local label = status and STATUS_LABELS[status] or "Checking..."
	local menu = {
		{ title = "bcvpn: " .. label, disabled = true },
	}

	if M.activeTask then
		table.insert(menu, {
			title = M.pendingAction == "up" and "Connecting..." or "Disconnecting...",
			disabled = true,
		})
	elseif status then
		table.insert(menu, {
			title = status == STATUS.CONNECTED and "Reconnect" or "Connect",
			fn = function()
				runVpnCommand("up")
			end,
		})

		if status ~= STATUS.STOPPED then
			table.insert(menu, {
				title = "Disconnect (stop containers)",
				fn = function()
					runVpnCommand("down")
				end,
			})
		end
	end

	return menu
end

updateMenubar()
refresh()
M.timer = hs.timer.doEvery(REFRESH_INTERVAL_SECONDS, refresh)

return M
