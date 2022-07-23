local wezterm = require("wezterm")
local os = require("os")
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
	local title = " " .. wezterm.truncate_right(tab_title, max_width - 2) .. " "

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

function TabName(title)
	local gui_window = _G.window
	local window = wezterm.mux.get_window(gui_window:window_id())
	for _, tab_info in ipairs(window:tabs_with_info()) do
		if tab_info.is_active then
			tab_info.tab:set_title(title)
			wezterm.log_info(
				"Changed title for tab " .. tostring(tab_info.tab:tab_id()) .. " to " .. tab_info.tab:get_title()
			)
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

-- Return an action callback for managing movement between panes
local move_action = function(dir)
	return wezterm.action_callback(function(window, pane)
		if pane:get_foreground_process_name():sub(-4) == "nvim" then
			-- Try to do the move in vim. If it doesn't work, do the move in
			-- wezterm.
			local result = run(
				"/opt/homebrew/bin/nvim --server /tmp/nvim-wt"
					.. pane:pane_id()
					.. ' --remote-expr \'v:lua.require("user.wezterm").go_'
					.. vim_dir_map[dir]
					.. "()' 2>&1"
			)
			if result ~= "" then
				return
			end
		end
		window:perform_action(act.ActivatePaneDirection(dir), pane)
	end)
end

local appearance = wezterm.gui.get_appearance()
local scheme = "light"
if appearance:find("Dark") then
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
		resize_pane = {
			{ key = "j", action = act.AdjustPaneSize({ "Down", 1 }) },
			{ key = "k", action = act.AdjustPaneSize({ "Up", 1 }) },
			{ key = "h", action = act.AdjustPaneSize({ "Left", 1 }) },
			{ key = "l", action = act.AdjustPaneSize({ "Right", 1 }) },
			{ key = "j", mods = "SHIFT", action = act.AdjustPaneSize({ "Down", 4 }) },
			{ key = "k", mods = "SHIFT", action = act.AdjustPaneSize({ "Up", 4 }) },
			{ key = "h", mods = "SHIFT", action = act.AdjustPaneSize({ "Left", 4 }) },
			{ key = "l", mods = "SHIFT", action = act.AdjustPaneSize({ "Right", 4 }) },
			{ key = "-", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
			{ key = "\\", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
			{ key = "Escape", action = act.PopKeyTable },
			{ key = "c", action = act.ActivateCopyMode },
			{ key = "c", mods = "CTRL", action = act.PopKeyTable },
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
		{
			key = "s",
			mods = "CTRL",
			action = act.ActivateKeyTable({
				name = "resize_pane",
				one_shot = false,
				until_unknown = true,
				replace_current = true,
			}),
		},
		{ key = "/", mods = "ALT", action = wezterm.action.ShowLauncher },
		{ key = "/", mods = "CMD", action = act.ShowDebugOverlay },
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
