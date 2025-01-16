local wezterm = require("wezterm")
local util = require("user.util")
local action = require("user.action")
local wez_action = wezterm.action
local resurrect =
    wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")

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

-- Return the config
local config = wezterm.config_builder()

config.adjust_window_size_when_changing_font_size = false
config.color_scheme = util.get_appearance() == "dark"
        and "Selenized Black (selenized)"
    or "Selenized White (selenized)"

-- Use a smaller font when stage manager is active
config.font_size = util.is_stage_manager_active() and 12 or 13

-- Disable ligatures
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }

config.key_tables = {
    copy_mode = util.merge(wezterm.gui.default_key_tables().copy_mode, {
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
    }),

    search_mode = util.merge(wezterm.gui.default_key_tables().search_mode, {
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
    }),

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
        {
            key = "s",
            mods = "",
            action = resurrect.window_state.save_window_action(),
        },
        {
            key = "r",
            mods = "",
            action = wezterm.action_callback(function(win, pane)
                resurrect.fuzzy_load(win, pane, function(id, _)
                    -- match before '/'
                    local type = string.match(id, "^([^/]+)")
                    -- match after '/'
                    id = string.match(id, "([^/]+)$")
                    -- remove file extension
                    id = string.match(id, "(.+)%..+$")

                    local opts = {
                        relative = true,
                        restore_text = true,
                        on_pane_restore = resurrect.tab_state.default_on_pane_restore,
                    }

                    if type == "workspace" then
                        local state = resurrect.load_state(id, "workspace")
                        resurrect.workspace_state.restore_workspace(state, opts)
                    elseif type == "window" then
                        local state = resurrect.load_state(id, "window")
                        resurrect.window_state.restore_window(
                            pane:window(),
                            state,
                            opts
                        )
                    elseif type == "tab" then
                        local state = resurrect.load_state(id, "tab")
                        resurrect.tab_state.restore_tab(pane:tab(), state, opts)
                    end
                end)
            end),
        },
        {
            key = "t",
            mods = "",
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
    },
}

config.keys = {
    { key = "j", mods = "CTRL", action = action.move_action("Down") },
    { key = "k", mods = "CTRL", action = action.move_action("Up") },
    { key = "h", mods = "CTRL", action = action.move_action("Left") },
    { key = "l", mods = "CTRL", action = action.move_action("Right") },
    { key = "t", mods = "CMD", action = wez_action.SpawnTab("DefaultDomain") },
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
config.font = wezterm.font("JetBrainsMonoNL NF")

config.send_composed_key_when_left_alt_is_pressed = true

config.default_prog = { "/opt/homebrew/bin/fish", "-l" }

return config
