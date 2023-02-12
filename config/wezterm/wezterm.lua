local wezterm = require("wezterm")
local io = require("io")
local action = wezterm.action
local action_callback = wezterm.action_callback

-- Load JSON data from a file
local function load_json(file)
	local f = assert(io.open(file, "r"))
	local text = assert(f:read("*a"))
	f:close()
	return wezterm.json_parse(text)
end

-- Save JSON data a file
local function save_json(data, file)
	local f = assert(io.open(file, "w"))
	f:write(wezterm.json_encode(data))
	f:close()
end

-- A file that the active scheme is read from and written to. This is only used
-- if scheme_config.auto_switch is false
local scheme_file = wezterm.home_dir .. "/.local/share/wezterm/scheme.json"

-- A file that the active color palette will be saved to. This file is used by
-- other applications such as neovim.
local palette_file = wezterm.home_dir .. "/.local/share/wezterm/colors.json"

-- Save the current scheme name to a file
local function save_scheme(name)
	save_json({ name = name }, scheme_file)
end

-- Save the current scheme name to a file
local function load_scheme()
	local data = load_json(scheme_file)
	if data ~= nil then
		return data.name
	end
end


-- Save a wezterm scheme to a flat palette JSON file
local function save_colors(name, scheme)
	local bg = wezterm.color.parse(scheme.background)
	local _, _, l, _ = bg:hsla()

	local type = 'iterm2'
	if name:find('(base16)') then
		type = 'base16'
	elseif name:find('(terminal.sexy)') then
		type = 'terminal.sexy'
	elseif name:find('(Gogh)') then
		type = 'gogh'
	elseif name:find('(selenized)') then
		type = 'selenized'
	end

	-- Create the scheme data that will be written to the theme file for other
	-- apps to use
	local scheme_json = {
		name = name,
		is_dark = l < 0.5,
		type = type,

		color00 = scheme.ansi[1],
		color01 = scheme.ansi[2],
		color02 = scheme.ansi[3],
		color03 = scheme.ansi[4],
		color04 = scheme.ansi[5],
		color05 = scheme.ansi[6],
		color06 = scheme.ansi[7],
		color07 = scheme.ansi[8],

		color08 = scheme.brights[1],
		color09 = scheme.brights[2],
		color10 = scheme.brights[3],
		color11 = scheme.brights[4],
		color12 = scheme.brights[5],
		color13 = scheme.brights[6],
		color14 = scheme.brights[7],
		color15 = scheme.brights[8],

		bg = scheme.background,
		fg = scheme.foreground
	}

	if scheme.indexed ~= nil then
		for idx, color in pairs(scheme.indexed) do
			scheme_json['color' .. idx] = color
		end
	end

	save_json(scheme_json, palette_file)
end

-- Scheme handling options. These are local to this config, and aren't used by
-- Wezterm itself.
local scheme_config = {
	light = "Selenized Light (selenized)",
	dark = "Selenized Black (selenized)",
	default = "Selenized Light (selenized)",
	auto_switch = true,
}

local left_decor = utf8.char(0xe0ba)
local right_decor = utf8.char(0xe0b8)

-- Split a multiline string into a table
local function splitlines(str)
	local lines = {}
	for s in str:gmatch("[^\r\n]+") do
		table.insert(lines, s)
	end
	return lines
end

-- Trim a string
local function trim(str)
	return str:gsub("^%s*(.-)%s*$", "%1")
end

-- Run a command, return the output.
local function run(cmd)
	local _, stdout, stderr = wezterm.run_child_process(cmd)
	local out
	if stdout and stderr then
		out = stdout .. " " .. stderr
	elseif stdout then
		out = stdout
	else
		out = stderr
	end
	return trim(out)
end

-- Determine the brew command prefix
local arch = run({ "arch" })
local homebrew_base = "/opt/homebrew/bin"
if arch == "i386" then
	homebrew_base = "/usr/local/bin"
end

local timeout = homebrew_base .. "/timeout"
local nvim = homebrew_base .. "/nvim"

-- Style the tabs
wezterm.on("format-tab-title", function(tab, _, _, config, hover, max_width)
	local colors = config.color_schemes[config.color_scheme]
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

-- Show an icon in the status area when a key table is active
wezterm.on("update-right-status", function(window)
	local status = ""
	if window:active_key_table() ~= nil then
		status = " "
	end
	window:set_right_status(status)
end)

-- Whenever the config is reloaded, update the color scheme file
wezterm.on("window-config-reloaded", function(window)
	local cfg = window:effective_config()
	local color_scheme = cfg.color_scheme

	if scheme_config.auto_switch then
		if wezterm.gui.get_appearance():find("Dark") then
			color_scheme = scheme_config.dark
		else
			color_scheme = scheme_config.light
		end
	end

	Scheme(color_scheme, window)
end)

-- Reload the them in any running neovim sessions
local function reload_neovim_theme()
	local appearance = "light"
	if wezterm.gui.get_appearance():find("Dark") then
		appearance = "dark"
	end

	local servers = splitlines(run({ homebrew_base .. "/nvr", "--serverlist" }))
	for _, server in ipairs(servers) do
		print("Reloading Neovim theme for " .. server)
		run({
			timeout,
			"0.2",
			nvim,
			"--server",
			server,
			"--remote-expr",
			"v:lua.require('user.themes.wezterm.').apply('" .. appearance .. "')",
		})
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

	local config = window:effective_config()
	local schm = wezterm.color.get_builtin_schemes()[name]
	if not schm then
		schm = config.color_schemes[name]
	end

	if not schm then
		print('could not find scheme ' .. name)
		return
	end

	local overrides = window:get_config_overrides() or {}

	-- Add tab bar colors for schemes that don't already have them
	if not schm.tab_bar then
		schm.tab_bar = {
			background = schm.brights[1],
			active_tab = {
				bg_color = schm.background,
				fg_color = schm.brights[8],
			},
			inactive_tab = {
				bg_color = schm.ansi[1],
				fg_color = schm.ansi[8],
			},
			new_tab = {
				bg_color = schm.brights[1],
				fg_color = schm.brights[1],
			},
		}

		if not overrides.color_schemes then
			overrides.color_schemes = {}
		end
		overrides.color_schemes[name] = schm
		print("Added tab bar colors to " .. name)
	end

	save_colors(name, schm)
	save_scheme(name)

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

local vim_dir_map = {
	Up = "up",
	Down = "down",
	Left = "left",
	Right = "right",
}

-- Return an action callback for managing movement between panes
local function move_action(dir)
	return action_callback(function(window, pane)
		local name = pane:get_foreground_process_name()
		if name ~= nil and pane:get_foreground_process_name():sub(-4) == "nvim" then
			-- Try to do the move in vim. If it doesn't work, do the move in
			-- wezterm. Use timeout because `nvim --remote-expr` will hang
			-- indefinitely if the messages area is focused in nvim.
			local result = run({
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
local function change_scheme_action(dir)
	return action_callback(function(window)
		local config = window:effective_config()

		local schms = config.color_schemes
		for name, _ in pairs(wezterm.color.get_builtin_schemes()) do
			table.insert(schms, name)
		end

		table.sort(schms)

		-- Find the next or previous scheme in the list
		local current_scheme = config.color_scheme
		local scheme_name
		local index = 0
		for i, name in ipairs(schms) do
			if name == current_scheme then
				index = i
				break
			end
		end

		if dir == "next" then
			while true do
				index = index + 1
				if index > #schms then
					index = 1
				end
				scheme_name = schms[index]
				-- if scheme_name:find('(base16)') then
					break
				-- end
			end
		else
			while true do
				index = index - 1
				if index < 1 then
					index = #schms
				end
				scheme_name = schms[index]
				-- if scheme_name:find('(base16)') then
					break
				-- end
			end
		end

		if scheme_name == nil then
			scheme_name = schms[1]
		end

		Scheme(scheme_name, window)
		print('Set scheme to "' .. scheme_name .. '"')
	end)
end

-- Return an action callback to switch to copy mode from the window op keytable
local function copy_mode_action()
	return action_callback(function(window, pane)
		if window:active_key_table() == "window_ops" then
			window:perform_action(action.PopKeyTable, pane)
		end
		window:perform_action(action.ActivateCopyMode, pane)
	end)
end

-- Return an action callback to open a new split and exit window managment mode
local function split_action(dir)
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

-- Save the window state to a JSON file (WIP)
local function save_win_state()
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
				panes = panes,
			})
		end

		table.insert(windows, {
			id = win:window_id(),
			width = dims.pixel_width,
			height = dims.pixel_height,
			tabs = tabs,
		})
	end

	data.windows = windows

	local filename = wezterm.home_dir .. "/.local/share/wezterm/win_state.json"
	save_json(data, filename)
end

-- The name of the active color scheme
local color_scheme = scheme_config.light

if scheme_config.auto_switch then
	-- Switch between light and dark themes based on the system theme
	if wezterm.gui.get_appearance():find("Dark") then
		color_scheme = scheme_config.dark
	end
else
	-- Check for a theme file
	local theme = load_scheme()
	if theme ~= nil then
		color_scheme = theme.name
	end
end

-- Copy mode key bindings
local copy_mode = nil
if wezterm.gui then
	local copy_keys = {
		{
			key = "y",
			mods = "NONE",
			action = action.Multiple({
				action.CopyTo("ClipboardAndPrimarySelection"),
				action.CopyMode("ClearPattern"),
				action.CopyMode("Close"),
			}),
		},
		{
			key = "/",
			mods = "NONE",
			action = action.Multiple({
				action.CopyMode("ClearPattern"),
				action.Search({ CaseSensitiveString = "" }),
			}),
		},
		{
			key = "n",
			mods = "NONE",
			action = action.Multiple({
				action.CopyMode("PriorMatch"),
				action.CopyMode("ClearSelectionMode"),
			}),
		},
		{
			key = "N",
			mods = "SHIFT",
			action = action.Multiple({
				action.CopyMode("NextMatch"),
				action.CopyMode("ClearSelectionMode"),
			}),
		},
		{
			key = "Escape",
			mods = "NONE",
			action = action.Multiple({
				action.CopyMode("ClearPattern"),
				action.CopyMode("Close"),
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
			action = action.Multiple({
				action.ActivateCopyMode,
				action.CopyMode("ClearSelectionMode"),
			}),
		},
		{
			key = "Escape",
			mods = "NONE",
			action = action.Multiple({
				action.CopyMode("ClearPattern"),
				action.CopyMode("Close"),
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
config.color_scheme = color_scheme
config.font_size = 13

-- disable ligatures
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }

config.hide_tab_bar_if_only_one_tab = true

config.key_tables = {
	copy_mode = copy_mode,

	search_mode = search_mode,

	window_ops = {
		{ key = "j", action = move_action("Down") },
		{ key = "k", action = move_action("Up") },
		{ key = "h", action = move_action("Left") },
		{ key = "l", action = move_action("Right") },
		{ key = "j", mods = "SHIFT", action = action.AdjustPaneSize({ "Down", 4 }) },
		{ key = "k", mods = "SHIFT", action = action.AdjustPaneSize({ "Up", 4 }) },
		{ key = "h", mods = "SHIFT", action = action.AdjustPaneSize({ "Left", 4 }) },
		{ key = "l", mods = "SHIFT", action = action.AdjustPaneSize({ "Right", 4 }) },
		{ key = "m", action = action.PaneSelect({ mode = "SwapWithActive" }) },
		{ key = "-", action = split_action("vertical") },
		{ key = "\\", action = split_action("horizontal") },
		{ key = "|", action = split_action("horizontal") },
		{ key = "Escape", action = action.PopKeyTable },
		{ key = "c", action = copy_mode_action() },
		{ key = "c", mods = "CTRL", action = action.PopKeyTable },
		{ key = "q", action = action.QuickSelect },
		{ key = "z", action = action.TogglePaneZoomState },
		{ key = "w", action = action.CloseCurrentPane({ confirm = true }) },
	},
}

config.keys = {
	{ key = "j", mods = "CTRL", action = move_action("Down") },
	{ key = "k", mods = "CTRL", action = move_action("Up") },
	{ key = "h", mods = "CTRL", action = move_action("Left") },
	{ key = "l", mods = "CTRL", action = move_action("Right") },
	{ key = "t", mods = "CTRL", action = action.SpawnTab("DefaultDomain") },
	{
		key = "\\",
		mods = "CMD|CTRL",
		action = action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "-",
		mods = "CMD|CTRL",
		action = action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{ key = "LeftArrow", mods = "SHIFT", action = action.ActivateTabRelative(-1) },
	{ key = "RightArrow", mods = "SHIFT", action = action.ActivateTabRelative(1) },
	{ key = "LeftArrow", mods = "CMD|SHIFT", action = action.MoveTabRelative(-1) },
	{ key = "RightArrow", mods = "CMD|SHIFT", action = action.MoveTabRelative(1) },
	{
		key = "s",
		mods = "CTRL",
		action = action.ActivateKeyTable({
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
		action = action.ShowLauncherArgs({ flags = "FUZZY|COMMANDS|LAUNCH_MENU_ITEMS" }),
	},
	{ key = "/", mods = "CMD", action = action.ShowDebugOverlay },
	{
		key = "s",
		mods = "CMD|CTRL",
		action = action_callback(save_win_state),
	},
	{ key = "<", mods = "CMD|SHIFT|CTRL", action = change_scheme_action("prev") },
	{ key = ">", mods = "CMD|SHIFT|CTRL", action = change_scheme_action("next") },
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
