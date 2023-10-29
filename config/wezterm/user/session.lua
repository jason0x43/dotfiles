local wezterm = require("wezterm")
local action_callback = wezterm.action_callback
local util = require("user.util")

local layout_file = wezterm.home_dir .. "/.local/share/wezterm/layout.json"

local M = {}

M.save = function()
  return action_callback(function()
    local layout = { windows = {} }
    for _, win in ipairs(wezterm.gui.gui_windows()) do
      local dim = win:get_dimensions()
      local wjson = {
        id = win:window_id(),
        width = dim.pixel_width,
        height = dim.pixel_height,
        tabs = {},
      }
      layout.windows[#layout.windows + 1] = wjson

      for _, tab in ipairs(win:mux_window():tabs_with_info()) do
        local tjson = {
          id = tab.tab:tab_id(),
          title = tab.tab:get_title(),
          active = tab.is_active,
          panes = {},
        }
        wjson.tabs[#wjson.tabs + 1] = tjson

        local panes = tab.tab:panes_with_info()
        for _, pane in ipairs(panes) do
          local pane_dim = pane.pane:get_dimensions()
          print('pane_dim: ' .. wezterm.json_encode(pane_dim))

          local pjson = {
            id = pane.pane:pane_id(),
            process = pane.pane:get_foreground_process_name(),
            cwd = pane.pane:get_current_working_dir(),
            title = pane.pane:get_title(),
            text = pane.pane:get_text_from_region(
              0,
              pane_dim.cols,
              pane_dim.scrollback_top,
              pane_dim.scrollback_top + pane_dim.scrollback_rows
            ),
            active = pane.is_active,
          }
          tjson.panes[#tjson.panes + 1] = pjson
        end
      end
    end

    util.save_json(layout, layout_file)
  end)
end

return M
