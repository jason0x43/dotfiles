local wezterm = require("wezterm")
local util = require("user.util")
local action = require("user.action")
local scheme_config = require("user.scheme_config")
local active_scheme = require("user.active_scheme")
local session = require("user.session")
local wez_action = wezterm.action

local is_stage_manager = util.run({
    "defaults",
    "read",
    "com.apple.WindowManager",
    "GloballyEnabled",
}) == "1"

-- Style the tabs
wezterm.on("format-tab-title", function(tab, _, _, _, _, max_width)
    local tab_title = tab.tab_title
    if tab_title == nil or #tab_title == 0 then
        tab_title = tab.active_pane.title
    end

    -- ensure that the titles fit in the available space,
    -- and that we have room for the edges.
    local title = "  "
        .. wezterm.truncate_right(tab_title, max_width - 4)
        .. "  "

    return {
        { Text = title },
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
---@param appearance string
local function reload_neovim_theme(appearance)
    local homebrew_base = util.homebrew_base()
    local timeout = homebrew_base .. "/timeout"
    local nvim = homebrew_base .. "/nvim"

    local servers =
        util.splitlines(util.run({ homebrew_base .. "/nvr", "--serverlist" }))
    for _, server in ipairs(servers) do
        util.run({
            timeout,
            "0.2",
            nvim,
            "--server",
            server,
            "--remote-expr",
            "v:lua.require('user.themes.wezterm').set_background('"
                .. appearance
                .. "')",
        })
        print("notified " .. server)
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

    reload_neovim_theme(appearance)
end

-- Set a tab title from the debug overlay
function Title(title)
    ---@diagnostic disable-next-line:undefined-field
    local gui_window = _G.window
    local window = wezterm.mux.get_window(gui_window:window_id())
    if window then
        for _, tab_info in ipairs(window:tabs_with_info()) do
            if tab_info.is_active then
                tab_info.tab:set_title(title)
                break
            end
        end
    end
end

-- Copy mode key bindings
local copy_mode = wezterm.gui.default_key_tables().copy_mode
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
        {
            key = "q",
            mods = "NONE",
            action = wez_action.Multiple({
                wez_action.CopyMode("ClearPattern"),
                wez_action.CopyMode("Close"),
            }),
        },
    }

    for _, v in ipairs(copy_keys) do
        table.insert(copy_mode, v)
    end
end

-- Search mode key bindings
local search_mode = wezterm.gui.default_key_tables().search_mode
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
config.color_scheme = util.get_appearance() == "dark" and scheme_config.dark
    or scheme_config.light

if is_stage_manager then
    config.font_size = 12
else
    config.font_size = 13
end

-- disable ligatures
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }

config.hide_tab_bar_if_only_one_tab = true

config.key_tables = {
    copy_mode = copy_mode,

    search_mode = search_mode,

    window_ops = {
        { key = "j", mods = "", action = action.move_action("Down") },
        { key = "k", mods = "", action = action.move_action("Up") },
        { key = "h", mods = "", action = action.move_action("Left") },
        { key = "l", mods = "", action = action.move_action("Right") },
        {
            key = "j",
            mods = "SHIFT",
            action = wez_action.AdjustPaneSize({ "Down", 4 }),
        },
        {
            key = "k",
            mods = "SHIFT",
            action = wez_action.AdjustPaneSize({ "Up", 4 }),
        },
        {
            key = "h",
            mods = "SHIFT",
            action = wez_action.AdjustPaneSize({ "Left", 4 }),
        },
        {
            key = "l",
            mods = "SHIFT",
            action = wez_action.AdjustPaneSize({ "Right", 4 }),
        },
        {
            key = "m",
            mods = "",
            action = wez_action.PaneSelect({ mode = "SwapWithActive" }),
        },
        { key = "-", mods = "", action = action.split_action("vertical") },
        { key = "\\", mods = "", action = action.split_action("horizontal") },
        { key = "|", mods = "", action = action.split_action("horizontal") },
        { key = "Escape", mods = "", action = wez_action.PopKeyTable },
        { key = "c", mods = "", action = action.copy_mode_action() },
        { key = "c", mods = "CTRL", action = wez_action.PopKeyTable },
        { key = "q", mods = "", action = wez_action.QuickSelect },
        { key = "z", mods = "", action = wez_action.TogglePaneZoomState },
        {
            key = "w",
            mods = "",
            action = wez_action.CloseCurrentPane({ confirm = true }),
        },
    },
}

config.keys = {
    { key = "j", mods = "CTRL", action = action.move_action("Down") },
    { key = "k", mods = "CTRL", action = action.move_action("Up") },
    { key = "h", mods = "CTRL", action = action.move_action("Left") },
    { key = "l", mods = "CTRL", action = action.move_action("Right") },
    { key = "t", mods = "CMD", action = wez_action.SpawnTab("DefaultDomain") },
    {
        key = "t",
        mods = "CTRL|SHIFT",
        action = wez_action.PromptInputLine({
            description = "Tab name",
            action = wezterm.action_callback(function(window, _, line)
                -- line will be `nil` if they hit escape without entering anything
                -- An empty string if they just hit enter
                -- Or the actual line of text they wrote
                if line then
                    window:active_tab():set_title(line)
                end
            end),
        }),
    },
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
    {
        key = "LeftArrow",
        mods = "SHIFT",
        action = wez_action.ActivateTabRelative(-1),
    },
    {
        key = "RightArrow",
        mods = "SHIFT",
        action = wez_action.ActivateTabRelative(1),
    },
    {
        key = "LeftArrow",
        mods = "CMD|SHIFT",
        action = wez_action.MoveTabRelative(-1),
    },
    {
        key = "RightArrow",
        mods = "CMD|SHIFT",
        action = wez_action.MoveTabRelative(1),
    },
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
        action = wez_action.ShowLauncherArgs({
            flags = "FUZZY|COMMANDS|LAUNCH_MENU_ITEMS",
        }),
    },
    { key = "/", mods = "CMD", action = wez_action.ShowDebugOverlay },
    {
        key = "<",
        mods = "CMD|SHIFT|CTRL",
        action = action.change_scheme_action("prev"),
    },
    {
        key = ">",
        mods = "CMD|SHIFT|CTRL",
        action = action.change_scheme_action("next"),
    },
    {
        key = "s",
        mods = "CMD|CTRL",
        action = session.save(),
    },

    -- Turn off the default CMD-d action
    {
        key = "d",
        mods = "CTRL",
        action = wezterm.action.DisableDefaultAssignment,
    },
}

config.scrollback_lines = 20000
config.term = "wezterm"
config.use_fancy_tab_bar = false

config.window_decorations = "RESIZE"

config.window_padding = {
    left = 4,
    right = 4,
    top = 4,
    bottom = 4,
}

-- Disable hyperlinks
config.mouse_bindings = {
    -- Change the default click behavior so that it only selects
    -- text and doesn't open hyperlinks
    {
        event = { Up = { streak = 1, button = "Left" } },
        mods = "NONE",
        action = wezterm.action.CompleteSelection("PrimarySelection"),
    },

    -- and make CTRL-Click open hyperlinks
    {
        event = { Up = { streak = 1, button = "Left" } },
        mods = "CTRL",
        action = wezterm.action.OpenLinkAtMouseCursor,
    },

    -- Disable the 'Down' event of CTRL-Click to avoid weird program behaviors
    {
        event = { Down = { streak = 1, button = "Left" } },
        mods = "CTRL",
        action = wezterm.action.Nop,
    },
}

-- Specify a font with built-in symbols. If Wezterm uses a fallback font for
-- symbols, it aligns using the font baseline rather than centering the glyphs.
-- https://github.com/wez/wezterm/issues/2818
config.font = wezterm.font("JetBrainsMonoNL Nerd Font")

config.send_composed_key_when_left_alt_is_pressed = true

-- This cast is needed for other config files to end up using the proper WezTerm
-- types rather than the type of the value returned by this file
---@cast config WezTerm

return config
