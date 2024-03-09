local wezterm = require("wezterm")
local action = wezterm.action
local action_callback = wezterm.action_callback
local util = require("user.util")

local M = {}

local vim_dir_map = {
	Up = "up",
	Down = "down",
	Left = "left",
	Right = "right",
}

-- Return an action callback for managing movement between panes
function M.move_action(dir)
	return action_callback(function(window, pane)
		local name = pane:get_foreground_process_name()
		local timeout = util.find_app("timeout")
		local nvim = util.find_app("nvim")

		if name ~= nil and pane:get_foreground_process_name():sub(-4) == "nvim" then
			-- Try to do the move in vim. If it doesn't work, do the move in
			-- wezterm. Use timeout because `nvim --remote-expr` will hang
			-- indefinitely if the messages area is focused in nvim.
			local result = util.run({
				timeout,
				"0.2",
				nvim,
				"--server",
				"/tmp/nvim-wt" .. pane:pane_id(),
				"--remote-expr",
				"v:lua.require('user.wezterm').go_" .. vim_dir_map[dir] .. "()",
			})
			if result ~= "" and not result:find("SIGTERM") then
				return
			end
		end
		window:perform_action(action.ActivatePaneDirection(dir), pane)
	end)
end

-- Return an action callback for cycling through changing color schemes
function M.change_scheme_action(dir)
	return action_callback(function(window)
		local config = window:effective_config()
		local schemes = util.get_schemes(window)
		local scheme_names = util.get_scheme_names(window)
		local appearance = util.get_appearance()

		-- Find the next or previous scheme in the list
		local current_scheme = config.color_scheme
		local scheme_name
		local index = 0
		for i, name in ipairs(scheme_names) do
			if name == current_scheme then
				index = i
				break
			end
		end

		local matches = function(name)
			local scheme = schemes[name]
			return (
				(appearance == "dark" and util.is_dark(scheme.background))
				or (appearance == "light" and not util.is_dark(scheme.background))
			) and name:find("(selenized)")
		end

		if dir == "next" then
			while true do
				index = index + 1
				if index > #scheme_names then
					index = 1
				end
				scheme_name = scheme_names[index]
				if matches(scheme_name) then
					break
				end
			end
		else
			while true do
				index = index - 1
				if index < 1 then
					index = #scheme_names
				end
				scheme_name = scheme_names[index]
				if matches(scheme_name) then
					break
				end
			end
		end

		if scheme_name == nil then
			scheme_name = scheme_names[1]
		end

		Scheme(scheme_name, window)
		print('Set scheme to "' .. scheme_name .. '"')
	end)
end

-- Return an action callback to switch to copy mode from the window op keytable
function M.copy_mode_action()
	return action_callback(function(window, pane)
		if window:active_key_table() == "window_ops" then
			window:perform_action(action.PopKeyTable, pane)
		end
		window:perform_action(action.ActivateCopyMode, pane)
	end)
end

-- Return an action callback to open a new split and exit window managment mode
function M.split_action(dir)
	return action_callback(function(window, pane)
		if window:active_key_table() == "window_ops" then
			window:perform_action(action.PopKeyTable, pane)
		end

		if dir == "vertical" then
			window:perform_action(action.SplitVertical({ domain = "CurrentPaneDomain" }), pane)
		else
			window:perform_action(action.SplitHorizontal({ domain = "CurrentPaneDomain" }), pane)
		end
	end)
end

return M
