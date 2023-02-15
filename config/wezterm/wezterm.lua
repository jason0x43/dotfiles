local wezterm = require("wezterm")
local util = require("util")
local action = require("action")
local scheme_config = require("scheme_config")
local active_scheme = require("active_scheme")
local wez_action = wezterm.action

-- Style the tabs
wezterm.on("format-tab-title", function(tab, _, _, _, hover, max_width)
	local colors = active_scheme.get()
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

	local left_decor = utf8.char(0xe0ba)
	local right_decor = utf8.char(0xe0b8)

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

-- Show an icon in the status area when a key table is active
wezterm.on("update-right-status", function(window)
	local status = ""
	if window:active_key_table() ~= nil then
		status = " "
	end
	window:set_right_status(status)
end)

-- Whenever the config is reloaded, update the color scheme
wezterm.on("window-config-reloaded", function(window)
	local cfg = window:effective_config()
	local color_scheme = cfg.color_scheme
	local scheme_cfg = scheme_config.get()

	if scheme_cfg.auto_switch then
		color_scheme = scheme_cfg[util.get_appearance()]
	end

	Scheme(color_scheme, window)
end)

-- Reload the them in any running neovim sessions
local function reload_neovim_theme()
	local homebrew_base = util.homebrew_base()
	local timeout = homebrew_base .. "/timeout"
	local nvim = homebrew_base .. "/nvim"

	local servers = util.splitlines(util.run({ homebrew_base .. "/nvr", "--serverlist" }))
	for _, server in ipairs(servers) do
		util.run({
			timeout,
			"0.2",
			nvim,
			"--server",
			server,
			"--remote-expr",
			"v:lua.require('user.themes.wezterm').apply()",
		})
		print('notified ' .. server)
	end
end

-- Set the color scheme
-- This function needs to be global to be called from the config-reloaded event
-- handler
function Scheme(name, window)
	if not window then
		---@diagnostic disable-next-line:undefined-field
		window = _G.window
	end

	if not name then
		local cfg = window:effective_config()
		return cfg.color_scheme
	end

	print('Setting scheme to "' .. name .. '"')
	local scheme = util.get_schemes(window)[name]
	if not scheme then
		print("Could not find scheme " .. name)
		return
	end

	local appearance = util.get_appearance()
	scheme_config.update({ [appearance] = name })
	active_scheme.save(name, scheme)

	local overrides = window:get_config_overrides() or {}
	overrides.color_scheme = name
	window:set_config_overrides(overrides)

	reload_neovim_theme()
end

-- Set a tab title from the debug overlay
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

-- Copy mode key bindings
local copy_mode = nil
if wezterm.gui then
	local copy_keys = {
		{
			key = "y",
			mods = "NONE",
			action = wez_action.Multiple({
				wez_action.CopyTo("ClipboardAndPrimarySelection"),
				wez_action.CopyMode("ClearPattern"),
				wez_action.CopyMode("Close"),
			}),
		},
		{
			key = "/",
			mods = "NONE",
			action = wez_action.Multiple({
				wez_action.CopyMode("ClearPattern"),
				wez_action.Search({ CaseSensitiveString = "" }),
			}),
		},
		{
			key = "n",
			mods = "NONE",
			action = wez_action.Multiple({
				wez_action.CopyMode("PriorMatch"),
				wez_action.CopyMode("ClearSelectionMode"),
			}),
		},
		{
			key = "N",
			mods = "SHIFT",
			action = wez_action.Multiple({
				wez_action.CopyMode("NextMatch"),
				wez_action.CopyMode("ClearSelectionMode"),
			}),
		},
		{
			key = "Escape",
			mods = "NONE",
			action = wez_action.Multiple({
				wez_action.CopyMode("ClearPattern"),
				wez_action.CopyMode("Close"),
			}),
		},
	}

	copy_mode = wezterm.gui.default_key_tables().copy_mode
	for _, v in ipairs(copy_keys) do
		table.insert(copy_mode, v)
	end
end

-- Search mode key bindings
local search_mode = nil
if wezterm.gui then
	local search_keys = {
		{
			key = "Enter",
			mods = "NONE",
			action = wez_action.Multiple({
				wez_action.ActivateCopyMode,
				wez_action.CopyMode("ClearSelectionMode"),
			}),
		},
		{
			key = "Escape",
			mods = "NONE",
			action = wez_action.Multiple({
				wez_action.CopyMode("ClearPattern"),
				wez_action.CopyMode("Close"),
			}),
		},
	}

	search_mode = wezterm.gui.default_key_tables().search_mode
	for _, v in ipairs(search_keys) do
		table.insert(search_mode, v)
	end
end

-- Return the config
local config = {}
if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.adjust_window_size_when_changing_font_size = false
config.color_scheme = util.get_appearance() == "dark" and scheme_config.dark or scheme_config.light
config.font_size = 13

-- disable ligatures
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }

config.hide_tab_bar_if_only_one_tab = true

config.key_tables = {
	copy_mode = copy_mode,

	search_mode = search_mode,

	window_ops = {
		{ key = "j", action = action.move_action("Down") },
		{ key = "k", action = action.move_action("Up") },
		{ key = "h", action = action.move_action("Left") },
		{ key = "l", action = action.move_action("Right") },
		{ key = "j", mods = "SHIFT", action = wez_action.AdjustPaneSize({ "Down", 4 }) },
		{ key = "k", mods = "SHIFT", action = wez_action.AdjustPaneSize({ "Up", 4 }) },
		{ key = "h", mods = "SHIFT", action = wez_action.AdjustPaneSize({ "Left", 4 }) },
		{ key = "l", mods = "SHIFT", action = wez_action.AdjustPaneSize({ "Right", 4 }) },
		{ key = "m", action = wez_action.PaneSelect({ mode = "SwapWithActive" }) },
		{ key = "-", action = action.split_action("vertical") },
		{ key = "\\", action = action.split_action("horizontal") },
		{ key = "|", action = action.split_action("horizontal") },
		{ key = "Escape", action = wez_action.PopKeyTable },
		{ key = "c", action = action.copy_mode_action() },
		{ key = "c", mods = "CTRL", action = wez_action.PopKeyTable },
		{ key = "q", action = wez_action.QuickSelect },
		{ key = "z", action = wez_action.TogglePaneZoomState },
		{ key = "w", action = wez_action.CloseCurrentPane({ confirm = true }) },
	},
}

config.keys = {
	{ key = "j", mods = "CTRL", action = action.move_action("Down") },
	{ key = "k", mods = "CTRL", action = action.move_action("Up") },
	{ key = "h", mods = "CTRL", action = action.move_action("Left") },
	{ key = "l", mods = "CTRL", action = action.move_action("Right") },
	{ key = "t", mods = "CTRL", action = wez_action.SpawnTab("DefaultDomain") },
	{
		key = "\\",
		mods = "CMD|CTRL",
		action = wez_action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "-",
		mods = "CMD|CTRL",
		action = wez_action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{ key = "LeftArrow", mods = "SHIFT", action = wez_action.ActivateTabRelative(-1) },
	{ key = "RightArrow", mods = "SHIFT", action = wez_action.ActivateTabRelative(1) },
	{ key = "LeftArrow", mods = "CMD|SHIFT", action = wez_action.MoveTabRelative(-1) },
	{ key = "RightArrow", mods = "CMD|SHIFT", action = wez_action.MoveTabRelative(1) },
	{
		key = "s",
		mods = "CTRL",
		action = wez_action.ActivateKeyTable({
			name = "window_ops",
			one_shot = false,
			timeout_milliseconds = 1000,
			until_unknown = true,
			replace_current = true,
		}),
	},
	{
		key = "/",
		mods = "ALT",
		action = wez_action.ShowLauncherArgs({ flags = "FUZZY|COMMANDS|LAUNCH_MENU_ITEMS" }),
	},
	{ key = "/", mods = "CMD", action = wez_action.ShowDebugOverlay },
	{ key = "<", mods = "CMD|SHIFT|CTRL", action = action.change_scheme_action("prev") },
	{ key = ">", mods = "CMD|SHIFT|CTRL", action = action.change_scheme_action("next") },
}

config.scrollback_lines = 20000
config.term = "wezterm"
config.use_fancy_tab_bar = false

config.window_padding = {
	left = 4,
	right = 4,
	top = 4,
	bottom = 4,
}

return config
