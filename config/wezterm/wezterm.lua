local wezterm = require("wezterm") --[[@as WezTerm]]
local util = require("user.util")
local action = require("user.action")
local act = wezterm.action
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

-- Don't change window size when changing font size
config.adjust_window_size_when_changing_font_size = false

config.window_frame = {
    font = wezterm.font({ family = "Roboto", weight = "Bold" }),
    font_size = 12.0,
}

---@param bg string
---@param fg string
---@return _.wezterm.TabBarColor
local function tab_cfg(bg, fg)
    return {
        bg_color = bg,
        fg_color = fg,
        intensity = "Normal",
        italic = false,
        underline = "None",
        strikethrough = false,
    }
end

-- Set color scheme basd on system appearance
if util.get_appearance() == "dark" then
    -- Dark theme
    config.window_frame.active_titlebar_bg = "#333333"
    config.colors = {
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
        background = "#181818",
        brights = {
            "#505050",
            "#ff5e56",
            "#83c746",
            "#efc541",
            "#4f9cfe",
            "#ff81ca",
            "#56d8c9",
            "#dedede",
        },
        foreground = "#b9b9b9",
        selection_bg = "#3b3b3b",
        selection_fg = "none",
        indexed = {
            [16] = "#e67f43",
            [17] = "#fa9153",
            [18] = "#a580e2",
            [19] = "#b891f5",
        },
        tab_bar = {
            background = "#181818",
            active_tab = tab_cfg("#181818", "#dedede"),
            inactive_tab = tab_cfg("#2b2b2b", "#777777"),
            inactive_tab_hover = tab_cfg("#202020", "#777777"),
            new_tab = tab_cfg("#333333", "#ffffff"),
            new_tab_hover = tab_cfg("#202020", "#ffffff"),
        },
    }
else
    -- Light theme
    config.window_frame.active_titlebar_bg = "#dddddd"
    config.colors = {
        ansi = {
            "#ebebeb",
            "#d6000c",
            "#1d9700",
            "#c49700",
            "#0064e4",
            "#dd0f9d",
            "#00ad9c",
            "#878787",
        },
        background = "#ffffff",
        brights = {
            "#cdcdcd",
            "#bf0000",
            "#008400",
            "#af8500",
            "#0054cf",
            "#c7008b",
            "#009a8a",
            "#282828",
        },
        foreground = "#474747",
        selection_fg = "none",
        selection_bg = "#cdcdcd",
        indexed = {
            [16] = "#d04a00",
            [17] = "#ba3700",
            [18] = "#7f51d6",
            [19] = "#6b40c3",
        },
        tab_bar = {
            background = "#ffffff",
            inactive_tab_edge = "#dddddd",
            active_tab = tab_cfg("#ffffff", "#474747"),
            inactive_tab = tab_cfg("#dddddd", "#474747"),
            inactive_tab_hover = tab_cfg("#eeeeee", "#474747"),
            new_tab = tab_cfg("#dddddd", "#474747"),
            new_tab_hover = tab_cfg("#eeeeee", "#474747"),
        },
    }
end

-- Use a smaller font when stage manager is active
config.font_size = util.is_stage_manager_active() and 12 or 13

-- Disable ligatures
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }

config.key_tables = {
    copy_mode = util.merge(wezterm.gui.default_key_tables().copy_mode, {
        {
            key = "y",
            mods = "NONE",
            action = act.Multiple({
                act.CopyTo("ClipboardAndPrimarySelection"),
                act.CopyMode("ClearPattern"),
                act.CopyMode("Close"),
            }),
        },
        {
            key = "/",
            mods = "NONE",
            action = act.Multiple({
                act.CopyMode("ClearPattern"),
                act.Search({ CaseSensitiveString = "" }),
            }),
        },
        {
            key = "n",
            mods = "NONE",
            action = act.Multiple({
                act.CopyMode("PriorMatch"),
                act.CopyMode("ClearSelectionMode"),
            }),
        },
        {
            key = "N",
            mods = "SHIFT",
            action = act.Multiple({
                act.CopyMode("NextMatch"),
                act.CopyMode("ClearSelectionMode"),
            }),
        },
        {
            key = "Escape",
            mods = "NONE",
            action = act.Multiple({
                act.CopyMode("ClearPattern"),
                act.CopyMode("Close"),
            }),
        },
        {
            key = "q",
            mods = "NONE",
            action = act.Multiple({
                act.CopyMode("ClearPattern"),
                act.CopyMode("Close"),
            }),
        },
    }),

    search_mode = util.merge(wezterm.gui.default_key_tables().search_mode, {
        {
            key = "Enter",
            mods = "NONE",
            action = act.Multiple({
                act.ActivateCopyMode,
                act.CopyMode("ClearSelectionMode"),
            }),
        },
        {
            key = "Escape",
            mods = "NONE",
            action = act.Multiple({
                act.CopyMode("ClearPattern"),
                act.CopyMode("Close"),
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
            action = act.AdjustPaneSize({ "Down", 4 }),
        },
        {
            key = "k",
            mods = "SHIFT",
            action = act.AdjustPaneSize({ "Up", 4 }),
        },
        {
            key = "h",
            mods = "SHIFT",
            action = act.AdjustPaneSize({ "Left", 4 }),
        },
        {
            key = "l",
            mods = "SHIFT",
            action = act.AdjustPaneSize({ "Right", 4 }),
        },
        {
            key = "m",
            mods = "",
            action = act.PaneSelect({ mode = "SwapWithActive" }),
        },
        { key = "-", mods = "", action = action.split_action("vertical") },
        { key = "\\", mods = "", action = action.split_action("horizontal") },
        { key = "|", mods = "", action = action.split_action("horizontal") },
        { key = "Escape", mods = "", action = act.PopKeyTable },
        { key = "c", mods = "", action = action.copy_mode_action() },
        { key = "c", mods = "CTRL", action = act.PopKeyTable },
        { key = "q", mods = "", action = act.QuickSelect },
        { key = "z", mods = "", action = act.TogglePaneZoomState },
        {
            key = "w",
            mods = "",
            action = act.CloseCurrentPane({ confirm = true }),
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
            action = wezterm.action_callback(function(window, pane)
                window:perform_action(act.PopKeyTable, pane)
                window:perform_action(
                    act.PromptInputLine({
                        description = "Tab name",
                        action = wezterm.action_callback(
                            function(win, _, line)
                                -- line will be `nil` if they hit escape without entering anything
                                -- An empty string if they just hit enter
                                -- Or the actual line of text they wrote
                                if line then
                                    win:active_tab():set_title(line)
                                end
                            end
                        ),
                    }),
                    pane
                )
            end),
        },
    },
}

config.keys = {
    { key = "j", mods = "CTRL", action = action.move_action("Down") },
    { key = "k", mods = "CTRL", action = action.move_action("Up") },
    { key = "h", mods = "CTRL", action = action.move_action("Left") },
    { key = "l", mods = "CTRL", action = action.move_action("Right") },
    { key = "t", mods = "CMD", action = act.SpawnTab("DefaultDomain") },
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
    {
        key = "LeftArrow",
        mods = "SHIFT",
        action = act.ActivateTabRelative(-1),
    },
    {
        key = "RightArrow",
        mods = "SHIFT",
        action = act.ActivateTabRelative(1),
    },
    {
        key = "LeftArrow",
        mods = "CMD|SHIFT",
        action = act.MoveTabRelative(-1),
    },
    {
        key = "RightArrow",
        mods = "CMD|SHIFT",
        action = act.MoveTabRelative(1),
    },
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
        action = act.ShowLauncherArgs({
            flags = "FUZZY|COMMANDS|LAUNCH_MENU_ITEMS",
        }),
    },
    { key = "/", mods = "CMD", action = act.ShowDebugOverlay },

    -- Turn off the default CMD-d action
    {
        key = "d",
        mods = "CTRL",
        action = wezterm.action.DisableDefaultAssignment,
    },
}

config.scrollback_lines = 20000

config.term = "wezterm"

-- Reduce window padding
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

-- Allow alt+key bindings to work when the left alt key is pressed. The right
-- alt key will compose keys (to produce special characters).
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = true

-- Always show the cursor as the reverse of the cell's text color, ignoring the
-- fg and bg colors in the theme.
config.force_reverse_video_cursor = true

local shells = wezterm.glob("/opt/homebrew/bin/fish")
if #shells == 1 then
    config.default_prog = { "/opt/homebrew/bin/fish", "-l" }
end

return config
