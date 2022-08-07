local wezterm = require("wezterm")
local io = require("io")
local act = wezterm.action
local left_decor = utf8.char(0xe0ba)
local right_decor = utf8.char(0xe0b8)
local color_schemes = {
	light = {
		tab_bar = {
			background = "#cbc3ab",
			active_tab = {
				bg_color = "#fbf3db",
				fg_color = "#53676d",
			},
			inactive_tab = {
				bg_color = "#ebe3cb",
				fg_color = "#83878d",
			},
			new_tab = {
				bg_color = "#cbc3ab",
				fg_color = "#cbc3ab",
			},
		},
		foreground = "#53676d",
		background = "#fbf3db",
		cursor_bg = "#d2212d",
		cursor_fg = "#fbf3db",
		ansi = {
			"#e9e4d0",
			"#d2212d",
			"#489100",
			"#ad8900",
			"#0072d4",
			"#ca4898",
			"#009c8f",
			"#909995",
		},
		brights = {
			"#cfcebe",
			"#cc1729",
			"#428b00",
			"#a78300",
			"#006dce",
			"#c44392",
			"#00978a",
			"#3a4d53",
		},
		indexed = {
			[16] = "#fbf3db",
			[17] = "#53676d",
			[18] = "#c25d1e",
			[19] = "#bc5819",
			[20] = "#8762c6",
			[21] = "#825dc0",
		},
		selection_fg = "none",
		selection_bg = "#cfcebe",
	},
	dark = {
		tab_bar = {
			background = "#3b3b3b",
			active_tab = {
				bg_color = "#181818",
				fg_color = "#dedede",
			},
			inactive_tab = {
				bg_color = "#252525",
				fg_color = "#777777",
			},
			new_tab = {
				bg_color = "#3b3b3b",
				fg_color = "#3b3b3b",
			},
		},
		foreground = "#b9b9b9",
		background = "#181818",
		cursor_bg = "#ed4a46",
		cursor_fg = "#181818",
		ansi = {
			"#252525",
			"#ed4a46",
			"#70b433",
			"#dbb32d",
			"#368aeb",
			"#eb6eb7",
			"#3fc5b7",
			"#777777",
		},
		brights = {
			"#3b3b3b",
			"#ff5e56",
			"#83c746",
			"#efc541",
			"#4f9cfe",
			"#ff81ca",
			"#56d8c9",
			"#dedede",
		},
		indexed = {
			[16] = "#181818",
			[17] = "#b9b9b9",
			[18] = "#e67f43",
			[19] = "#fa9153",
			[20] = "#a580e2",
			[21] = "#b891f5",
		},
		selection_fg = "none",
		selection_bg = "#3b3b3b",
	},
}

wezterm.on("format-tab-title", function(tab, _, _, config, hover, max_width)
	local colors = config.colors
	if colors == nil then
		return
	end

	local background = colors.tab_bar.inactive_tab.bg_color
	local foreground = colors.tab_bar.inactive_tab.fg_color

	if tab.is_active or hover then
		background = colors.tab_bar.active_tab.bg_color
		foreground = colors.tab_bar.active_tab.fg_color
	end

	local edge_background = colors.tab_bar.background
	local edge_foreground = background

	local tab_title = tab.tab_title
	if tab_title == nil or #tab_title == 0 then
		tab_title = tab.active_pane.title
	end

	-- ensure that the titles fit in the available space,
	-- and that we have room for the edges.
	local title = " " .. wezterm.truncate_right(tab_title, max_width - 4) .. " "

	return {
		{ Background = { Color = edge_background } },
		{ Foreground = { Color = edge_foreground } },
		{ Text = left_decor },
		{ Background = { Color = background } },
		{ Foreground = { Color = foreground } },
		{ Text = title },
		{ Background = { Color = edge_background } },
		{ Foreground = { Color = edge_foreground } },
		{ Text = right_decor },
	}
end)

wezterm.on("update-right-status", function(window)
	local status = ""
	if window:active_key_table() ~= nil then
		status = " "
	end
	window:set_right_status(status)
end)

-- Set a tab title
function Title(title)
	---@diagnostic disable-next-line:undefined-field
	local gui_window = _G.window
	local window = wezterm.mux.get_window(gui_window:window_id())
	for _, tab_info in ipairs(window:tabs_with_info()) do
		if tab_info.is_active then
			tab_info.tab:set_title(title)
			break
		end
	end
end

-- Run a command, return the output.
local run = function(cmd)
	local f = assert(io.popen(cmd, "r"))
	local s = assert(f:read("*a"))
	f:close()
	s = s:gsub("^%s+", "")
	s = s:gsub("%s+$", "")
	s = s:gsub("[\n\r]+", " ")
	return s
end

local vim_dir_map = {
	Up = "up",
	Down = "down",
	Left = "left",
	Right = "right",
}

local timeout = '/opt/homebrew/bin/timeout'
local nvim = '/opt/homebrew/bin/nvim'

-- Return an action callback for managing movement between panes
local move_action = function(dir)
	return wezterm.action_callback(function(window, pane)
		if pane:get_foreground_process_name():sub(-4) == "nvim" then
			-- Try to do the move in vim. If it doesn't work, do the move in
			-- wezterm. Use timeout because `nvim --remote-expr` will hang
			-- indefinitely if the messages area is focused in nvim.
			local result = run(
				timeout .. " 0.2 " .. nvim .. " --server /tmp/nvim-wt"
				.. pane:pane_id()
				.. ' --remote-expr \'v:lua.require("user.wezterm").go_'
				.. vim_dir_map[dir]
				.. "()' 2>&1"
			)
			if result ~= "" and not result:find('SIGTERM') then
				return
			end
		end
		window:perform_action(act.ActivatePaneDirection(dir), pane)
	end)
end

local copy_mode_action = function()
	return wezterm.action_callback(function(window, pane)
		if window:active_key_table() == "window_ops" then
			window:perform_action(act.PopKeyTable, pane)
		end
		window:perform_action(act.ActivateCopyMode, pane)
	end)
end

local save_win_state = function(window)
	local data = {}

	local windows = {}
	for _, win in ipairs(wezterm.mux.all_windows()) do
		local gui_win = win:gui_window()
		local dims = gui_win:get_dimensions()

		local tabs = {}
		for _, tab in ipairs(win:tabs()) do
			local panes = {}
			for _, pane in ipairs(tab:panes_with_info()) do
				table.insert(panes, {
					top = pane.top,
					left = pane.left,
					width = pane.width,
					height = pane.height,
				})
			end
			table.insert(tabs, {
				id = tab:tab_id(),
				panes = panes
			})
		end

		table.insert(windows, {
			id = win:window_id(),
			width = dims.pixel_width,
			height = dims.pixel_height,
			tabs = tabs
		})
	end

	data.windows = windows

	local filename = wezterm.home_dir .. "/.local/share/wezterm/win_state.json"
	local file = assert(io.open(filename, "w"))
	file:write(wezterm.json_encode(data))
	file:close()
end

local scheme = "light"
if wezterm.gui.get_appearance():find("Dark") then
	scheme = "dark"
end

return {
	color_schemes = color_schemes,

	color_scheme = scheme,

	colors = {
		tab_bar = color_schemes[scheme].tab_bar,
	},

	font_size = 13,

	-- disable ligatures
	harfbuzz_features = { "calt=0", "clig=0", "liga=0" },

	hide_tab_bar_if_only_one_tab = true,

	key_tables = {
		copy_mode = {
			{ key = "c", mods = "CTRL", action = act.CopyMode("Close") },
			{ key = "g", mods = "CTRL", action = act.CopyMode("Close") },
			{ key = "q", mods = "NONE", action = act.CopyMode("Close") },
			{ key = "Escape", mods = "NONE", action = act.CopyMode("Close") },

			{ key = "h", mods = "NONE", action = act.CopyMode("MoveLeft") },
			{ key = "j", mods = "NONE", action = act.CopyMode("MoveDown") },
			{ key = "k", mods = "NONE", action = act.CopyMode("MoveUp") },
			{ key = "l", mods = "NONE", action = act.CopyMode("MoveRight") },

			{ key = "LeftArrow", mods = "NONE", action = act.CopyMode("MoveLeft") },
			{ key = "DownArrow", mods = "NONE", action = act.CopyMode("MoveDown") },
			{ key = "UpArrow", mods = "NONE", action = act.CopyMode("MoveUp") },
			{ key = "RightArrow", mods = "NONE", action = act.CopyMode("MoveRight") },

			{ key = "RightArrow", mods = "ALT", action = act.CopyMode("MoveForwardWord") },
			{ key = "f", mods = "ALT", action = act.CopyMode("MoveForwardWord") },
			{ key = "Tab", mods = "NONE", action = act.CopyMode("MoveForwardWord") },
			{ key = "w", mods = "NONE", action = act.CopyMode("MoveForwardWord") },

			{ key = "LeftArrow", mods = "ALT", action = act.CopyMode("MoveBackwardWord") },
			{ key = "b", mods = "ALT", action = act.CopyMode("MoveBackwardWord") },
			{ key = "Tab", mods = "SHIFT", action = act.CopyMode("MoveBackwardWord") },
			{ key = "b", mods = "NONE", action = act.CopyMode("MoveBackwardWord") },

			{ key = "0", mods = "NONE", action = act.CopyMode("MoveToStartOfLine") },
			{ key = "Enter", mods = "NONE", action = act.CopyMode("MoveToStartOfNextLine") },

			{ key = "$", mods = "NONE", action = act.CopyMode("MoveToEndOfLineContent") },
			{ key = "$", mods = "SHIFT", action = act.CopyMode("MoveToEndOfLineContent") },
			{ key = "^", mods = "NONE", action = act.CopyMode("MoveToStartOfLineContent") },
			{ key = "^", mods = "SHIFT", action = act.CopyMode("MoveToStartOfLineContent") },
			{ key = "m", mods = "ALT", action = act.CopyMode("MoveToStartOfLineContent") },

			{ key = " ", mods = "NONE",
				action = act.CopyMode({ SetSelectionMode = "Cell" }) },
			{ key = "v", mods = "NONE",
				action = act.CopyMode({ SetSelectionMode = "Cell" }) },
			{ key = "V", mods = "NONE",
				action = act.CopyMode({ SetSelectionMode = "Line" }) },
			{ key = "V", mods = "SHIFT",
				action = act.CopyMode({ SetSelectionMode = "Line" }) },
			{ key = "v", mods = "CTRL",
				action = act.CopyMode({ SetSelectionMode = "Block" }) },

			{ key = "G", mods = "NONE", action = act.CopyMode("MoveToScrollbackBottom") },
			{ key = "G", mods = "SHIFT", action = act.CopyMode("MoveToScrollbackBottom") },
			{ key = "g", mods = "NONE", action = act.CopyMode("MoveToScrollbackTop") },

			{ key = "H", mods = "NONE", action = act.CopyMode("MoveToViewportTop") },
			{ key = "H", mods = "SHIFT", action = act.CopyMode("MoveToViewportTop") },
			{ key = "M", mods = "NONE", action = act.CopyMode("MoveToViewportMiddle") },
			{ key = "M", mods = "SHIFT", action = act.CopyMode("MoveToViewportMiddle") },
			{ key = "L", mods = "NONE", action = act.CopyMode("MoveToViewportBottom") },
			{ key = "L", mods = "SHIFT", action = act.CopyMode("MoveToViewportBottom") },

			{ key = "o", mods = "NONE", action = act.CopyMode("MoveToSelectionOtherEnd") },
			{ key = "O", mods = "NONE",
				action = act.CopyMode("MoveToSelectionOtherEndHoriz") },
			{ key = "O", mods = "SHIFT",
				action = act.CopyMode("MoveToSelectionOtherEndHoriz") },

			{ key = "PageUp", mods = "NONE", action = act.CopyMode("PageUp") },
			{ key = "PageDown", mods = "NONE", action = act.CopyMode("PageDown") },

			{
				key = "y",
				action = act.Multiple({
					act.CopyTo("ClipboardAndPrimarySelection"),
					act.CopyMode("Close"),
				}),
			},

			{ key = "u", mods = "CTRL", action = act.CopyMode("PageUp") },
			{ key = "b", mods = "CTRL", action = act.CopyMode("PageUp") },
			{ key = "f", mods = "CTRL", action = act.CopyMode("PageDown") },
		},

		window_ops = {
			{ key = "j", action = act.AdjustPaneSize({ "Down", 1 }) },
			{ key = "k", action = act.AdjustPaneSize({ "Up", 1 }) },
			{ key = "h", action = act.AdjustPaneSize({ "Left", 1 }) },
			{ key = "l", action = act.AdjustPaneSize({ "Right", 1 }) },
			{ key = "j", mods = "SHIFT", action = act.AdjustPaneSize({ "Down", 4 }) },
			{ key = "k", mods = "SHIFT", action = act.AdjustPaneSize({ "Up", 4 }) },
			{ key = "h", mods = "SHIFT", action = act.AdjustPaneSize({ "Left", 4 }) },
			{ key = "l", mods = "SHIFT", action = act.AdjustPaneSize({ "Right", 4 }) },
			{ key = "m", action = act.PaneSelect({ mode = "SwapWithActive" }) },
			{ key = "-", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
			{ key = "\\", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
			{ key = "Escape", action = act.PopKeyTable },
			{ key = "c", action = copy_mode_action() },
			{ key = "c", mods = "CTRL", action = act.PopKeyTable },
			{ key = "w", action = wezterm.action.CloseCurrentPane({ confirm = true }) },
		},
	},

	keys = {
		{ key = "j", mods = "CTRL", action = move_action("Down") },
		{ key = "k", mods = "CTRL", action = move_action("Up") },
		{ key = "h", mods = "CTRL", action = move_action("Left") },
		{ key = "l", mods = "CTRL", action = move_action("Right") },
		{
			key = "\\",
			mods = "CMD|CTRL",
			action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
		},
		{
			key = "-",
			mods = "CMD|CTRL",
			action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
		},
		{ key = "LeftArrow", mods = "SHIFT", action = act.ActivateTabRelative(-1) },
		{ key = "RightArrow", mods = "SHIFT", action = act.ActivateTabRelative(1) },
		{ key = "LeftArrow", mods = "CMD|SHIFT", action = act.MoveTabRelative(-1) },
		{ key = "RightArrow", mods = "CMD|SHIFT", action = act.MoveTabRelative(1) },
		{
			key = "s",
			mods = "CTRL",
			action = act.ActivateKeyTable({
				name = "window_ops",
				one_shot = false,
				timeout_milliseconds = 1000,
				until_unknown = true,
				replace_current = true,
			}),
		},
		{ key = "/", mods = "ALT", action = wezterm.action.ShowLauncher },
		{ key = "/", mods = "CMD", action = act.ShowDebugOverlay },
		{
			key = "s",
			mods = "CMD|CTRL",
			action = wezterm.action_callback(save_win_state),
		},
	},

	term = "wezterm",

	use_fancy_tab_bar = false,

	window_padding = {
		left = 4,
		right = 4,
		top = 4,
		bottom = 4,
	},
}
