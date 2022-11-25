local wezterm = require("wezterm")
local io = require("io")
local act = wezterm.action

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

-- Load custom schemes from a JSON file
local function load_schemes(file)
	local schemes = load_json(file)
	for _, scheme in pairs(schemes.schemes) do
		-- JSON can't use numeric keys, but the scheme `indexed` property requires
		-- numeric keys
		if scheme.indexed ~= nil then
			local indexed = {}
			for key, value in pairs(scheme.indexed) do
				indexed[tonumber(key)] = value
			end
			scheme.indexed = indexed
		end
	end
	return schemes
end

-- A file that the active scheme is read from and written to. This is only used
-- if scheme_config.auto_switch is false
local scheme_file = wezterm.home_dir .. "/.local/share/wezterm/colors.json"

-- Save a flat palette JSON file
local function load_dynamic_scheme()
	local file = io.open(scheme_file, "r")
	if file ~= nil then
		local text = assert(file:read("*a"))
		file:close()
		return wezterm.json_parse(text)
	end
end

-- Save a wezterm scheme to a flat palette JSON file
local function save_dynamic_scheme(scheme, name)
	local bg = wezterm.color.parse(scheme.background)
	local _, _, l, _ = bg:hsla()

	-- Create the scheme data that will be written to the theme file for other
	-- apps to use
	local scheme_json = {
		name = name,
		is_dark = l < 0.5,

		bg_0 = scheme.background,
		fg_0 = scheme.foreground,

		bg_1 = scheme.ansi[1],
		red = scheme.ansi[2],
		green = scheme.ansi[3],
		yellow = scheme.ansi[4],
		blue = scheme.ansi[5],
		magenta = scheme.ansi[6],
		cyan = scheme.ansi[7],
		dim_0 = scheme.ansi[8],

		bg_2 = scheme.brights[1],
		br_red = scheme.brights[2],
		br_green = scheme.brights[3],
		br_yellow = scheme.brights[4],
		br_blue = scheme.brights[5],
		br_magenta = scheme.brights[6],
		br_cyan = scheme.brights[7],
		fg_1 = scheme.brights[8],

		orange = scheme.indexed[18] or scheme.ansi[2],
		violet = scheme.indexed[20] or scheme.ansi[5],
		br_orange = scheme.indexed[19] or scheme.brights[2],
		br_violet = scheme.indexed[21] or scheme.brights[5],
	}

	save_json(scheme_json, scheme_file)
end

-- Load schemes from a JSON file rather than using the TOML files implicitly
-- understood by Wezterm. These schemes can also be loaded and used by nvim and
-- other clients.
local schemes = load_schemes(wezterm.home_dir ..
	"/.config/wezterm/colors/schemes.json")
local color_schemes = schemes.schemes

-- Scheme handling options. These are local to this config, and aren't used by
-- Wezterm itself.
local scheme_config = {
	light = schemes.light,
	dark = schemes.dark,
	default = schemes.light,
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

	local overrides = window:get_config_overrides() or {}

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
		print("Setting override for " .. name)
	end

	if not scheme_config.auto_switch then
		save_dynamic_scheme(schm, name)
	end

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
	return wezterm.action_callback(function(window, pane)
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
		window:perform_action(act.ActivatePaneDirection(dir), pane)
	end)
end

-- Return an action callback for cycling through changing color schemes
local function change_scheme_action(dir)
	return wezterm.action_callback(function(window)
		local config = window:effective_config()

		local schms = config.color_schemes
		for name, _ in pairs(wezterm.color.get_builtin_schemes()) do
			table.insert(schms, name)
		end

		table.sort(schms)

		-- Find the next or previous scheme in the list
		local current_scheme = config.color_scheme
		local scheme_name
		local index
		if dir == "next" then
			for i, name in ipairs(schms) do
				if name == current_scheme then
					index = i + 1
					if index > #schms then
						index = 1
					end
					scheme_name = schms[index]
					break
				end
			end
		else
			for i = #schms, 1, -1 do
				if schms[i] == current_scheme then
					index = i - 1
					if index < 1 then
						index = #schms
					end
					scheme_name = schms[index]
					break
				end
			end
		end

		if scheme_name == nil then
			scheme_name = schms[1]
		end

		print('Setting scheme to "' .. scheme_name)
		Scheme(scheme_name, window)
	end)
end

-- Return an action callback to switch to copy mode from the window op keytable
local function copy_mode_action()
	return wezterm.action_callback(function(window, pane)
		if window:active_key_table() == "window_ops" then
			window:perform_action(act.PopKeyTable, pane)
		end
		window:perform_action(act.ActivateCopyMode, pane)
	end)
end

-- Return an action callback to open a new split and exit window managment mode
local function split_action(dir)
	return wezterm.action_callback(function(window, pane)
		if window:active_key_table() == "window_ops" then
			window:perform_action(act.PopKeyTable, pane)
		end

		if dir == "vertical" then
			window:perform_action(act.SplitVertical({ domain = "CurrentPaneDomain" }),
				pane)
		else
			window:perform_action(act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
				pane)
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
	local theme = load_dynamic_scheme()
	if theme ~= nil then
		color_scheme = theme.name
	end
end

-- Return the config
return {
	adjust_window_size_when_changing_font_size = false,

	color_scheme = color_scheme,

	color_schemes = color_schemes,

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
			{ key = "j", action = move_action("Down") },
			{ key = "k", action = move_action("Up") },
			{ key = "h", action = move_action("Left") },
			{ key = "l", action = move_action("Right") },
			{ key = "j", mods = "SHIFT", action = act.AdjustPaneSize({ "Down", 4 }) },
			{ key = "k", mods = "SHIFT", action = act.AdjustPaneSize({ "Up", 4 }) },
			{ key = "h", mods = "SHIFT", action = act.AdjustPaneSize({ "Left", 4 }) },
			{ key = "l", mods = "SHIFT", action = act.AdjustPaneSize({ "Right", 4 }) },
			{ key = "m", action = act.PaneSelect({ mode = "SwapWithActive" }) },
			{ key = "-", action = split_action("vertical") },
			{ key = "\\", action = split_action("horizontal") },
			{ key = "|", action = split_action("horizontal") },
			{ key = "Escape", action = act.PopKeyTable },
			{ key = "c", action = copy_mode_action() },
			{ key = "c", mods = "CTRL", action = act.PopKeyTable },
			{ key = "z", action = act.TogglePaneZoomState },
			{ key = "w", action = wezterm.action.CloseCurrentPane({ confirm = true }) },
		},
	},

	keys = {
		{ key = "j", mods = "CTRL", action = move_action("Down") },
		{ key = "k", mods = "CTRL", action = move_action("Up") },
		{ key = "h", mods = "CTRL", action = move_action("Left") },
		{ key = "l", mods = "CTRL", action = move_action("Right") },
		{ key = "t", mods = "CTRL", action = act.SpawnTab("DefaultDomain") },
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
		{
			key = "/",
			mods = "ALT",
			action = wezterm.action.ShowLauncherArgs({ flags = "FUZZY|COMMANDS|LAUNCH_MENU_ITEMS" }),
		},
		{ key = "/", mods = "CMD", action = act.ShowDebugOverlay },
		{
			key = "s",
			mods = "CMD|CTRL",
			action = wezterm.action_callback(save_win_state),
		},
		{ key = "<", mods = "CMD|SHIFT|CTRL", action = change_scheme_action("prev") },
		{ key = ">", mods = "CMD|SHIFT|CTRL", action = change_scheme_action("next") },
	},

	scrollback_lines = 20000,

	term = "wezterm",

	use_fancy_tab_bar = false,

	window_padding = {
		left = 4,
		right = 4,
		top = 4,
		bottom = 4,
	},
}
