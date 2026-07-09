---@module "user.types.hammerspoon"

local util = require("util")

local SCVPN_COMMAND = os.getenv("HOME") .. "/.dotfiles/bin/scvpn"
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

-- Possible connection states reported by `scvpn status`.
local STATUS = {
	DOWN = "down",
	RUNNING = "running",
	AUTHENTICATED = "authenticated",
	CONNECTED = "connected",
}

---@class VpnState
---@field status string
---@field raw string
---@field lastUpdated integer | nil

local M = {
	---@type VpnState | nil
	state = nil,
	---@type hs.menubar | nil
	menubar = nil,
	---@type hs.timer | nil
	timer = nil,
	---@type hs.task | nil
	activeTask = nil,
	---@type "up" | "down" | nil
	pendingAction = nil,
}

---Parse the connection state from a `scvpn` output line.
---@param output string
---@return string
local function parseStatus(output)
	if type(output) ~= "string" then
		return STATUS.DOWN
	end

	if output:find("ipsec is not running", 1, true) then
		return STATUS.DOWN
	elseif output:find("CONNECTED", 1, true) then
		return STATUS.CONNECTED
	elseif
		output:find("AUTHENTICATED", 1, true)
		or output:find("ESTABLISHED", 1, true)
	then
		return STATUS.AUTHENTICATED
	end

	return STATUS.RUNNING
end

---Run `scvpn` (status) and update the menubar accordingly.
local function refresh()
	-- `scvpn` shells out to `op`, `swanctl`, `pgrep`, etc.; load the
	-- user's login shell environment so those resolve on $PATH.
	local output = hs.execute(SCVPN_COMMAND, true)
	if type(output) ~= "string" then
		output = ""
	end

	local trimmed = util.trim(output)
	local status = parseStatus(trimmed)

	if
		M.pendingAction == "up"
		and status ~= STATUS.AUTHENTICATED
		and status ~= STATUS.RUNNING
	then
		M.pendingAction = nil
	elseif M.pendingAction == "down" and status == STATUS.DOWN then
		M.pendingAction = nil
	end

	M.state = {
		status = status,
		raw = trimmed,
		lastUpdated = os.time(),
	}

	if status == STATUS.DOWN then
		if M.menubar then
			M.menubar:delete()
			M.menubar = nil
		end
		return
	end

	if not M.menubar then
		M.menubar = hs.menubar.new()
		if not M.menubar then
			error("Failed to create SCVPN status menubar item")
		end
		M.menubar:setTooltip("SCVPN status")
		M.menubar:setMenu(function()
			return M.buildMenu()
		end)
	end

	local icon = disconnectedIcon
	if status == STATUS.CONNECTED then
		icon = connectedIcon
	elseif M.pendingAction == "up" then
		icon = connectingIcon
	end

	M.menubar:setIcon(icon)
end

---Run `scvpn up` or `scvpn down` in the background, then refresh.
---
---`scvpn` relies on the user's $PATH (for `swanctl`, `pgrep`, etc.), so
---we launch it through a login shell (`/bin/zsh -l -c`) to load the
---profile. `hs.task` runs async so the menubar doesn't block while
---strongSwan negotiates.
---@param argument string  "up" to connect, "down" to disconnect.
local function runVpnCommand(argument)
	local shellCommand = string.format("%s %s", SCVPN_COMMAND, argument)

	local task = hs.task.new("/bin/zsh", function()
		M.activeTask = nil
		-- Give strongSwan a moment to settle, then re-poll status.
		hs.timer.doAfter(1, refresh)
	end, { "-l", "-c", shellCommand })

	M.pendingAction = argument
  refresh()

	-- Hold the reference so the task isn't garbage-collected mid-run.
	M.activeTask = task
	task:start()
end

---Toggle the VPN based on the current state.
---CONNECTED -> disconnect; AUTHENTICATED -> connect.
local function toggleVpn()
	if M.state.status == STATUS.CONNECTED then
		runVpnCommand("down")
	elseif
		M.state.status == STATUS.AUTHENTICATED or M.state.status == STATUS.RUNNING
	then
		runVpnCommand("up")
	end
end

---@return table
function M.buildMenu()
	local menu = {
		{ title = "VPN Status", disabled = true },
	}

	if M.state then
		local label
		if M.activeTask then
			label = M.pendingAction == "up" and "Connecting..." or "Working..."
		elseif M.state.status == STATUS.CONNECTED then
			label = "Disconnect"
		elseif
			M.state.status == STATUS.AUTHENTICATED
			or M.state.status == STATUS.RUNNING
		then
			label = "Connect"
		else
			label = "Disconnected"
		end

		table.insert(menu, {
			title = label,
			fn = M.activeTask and nil or toggleVpn,
		})
	end

	return menu
end

refresh()
M.timer = hs.timer.doEvery(REFRESH_INTERVAL_SECONDS, refresh)

return M
