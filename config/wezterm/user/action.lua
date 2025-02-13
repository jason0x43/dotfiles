local wezterm = require("wezterm") --[[@as WezTerm]]
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

---Return an action callback for managing movement between panes
---@param dir 'Up' | 'Down' | 'Left' | 'Right'
function M.move_action(dir)
    return action_callback(function(window, pane)
        local name = pane:get_foreground_process_name()
        local nvim = util.find_app("nvim")

        if
            nvim ~= nil
            and name ~= nil
            and pane:get_foreground_process_name():sub(-4) == "nvim"
        then
            -- Try to do the move in vim. If it doesn't work, do the move in
            -- wezterm. Use timeout because `nvim --remote-expr` will hang
            -- indefinitely if the messages area is focused in nvim.
            local result = util.run({
                nvim,
                "--server",
                "/tmp/nvim-wt" .. pane:pane_id(),
                "--remote-expr",
                "v:lua.require('user.terminal').focus('"
                    .. vim_dir_map[dir]
                    .. "')",
            })
            if result ~= "" and not result:find("SIGTERM") then
                return
            end
        end

        window:perform_action(action.ActivatePaneDirection(dir), pane)
    end)
end

---Return an action callback to switch to copy mode from the window op keytable
---@return _.wezterm._CallbackAction
function M.copy_mode_action()
    return action_callback(function(window, pane)
        if window:active_key_table() == "window_ops" then
            window:perform_action(action.PopKeyTable, pane)
        end
        window:perform_action(action.ActivateCopyMode, pane)
    end)
end

---Return an action callback to open a new split and exit window managment mode
---@param dir 'vertical' | 'horizontal'
---@return _.wezterm._CallbackAction
function M.split_action(dir)
    return action_callback(function(window, pane)
        if window:active_key_table() == "window_ops" then
            window:perform_action(action.PopKeyTable, pane)
        end

        if dir == "vertical" then
            window:perform_action(
                action.SplitVertical({ domain = "CurrentPaneDomain" }),
                pane
            )
        else
            window:perform_action(
                action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
                pane
            )
        end
    end)
end

return M
