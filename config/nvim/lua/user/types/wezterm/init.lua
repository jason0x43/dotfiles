---@meta

local wezterm = {
  ---@module 'wezterm.color'
  color = {},

  ---@module 'wezterm.gui'
  gui = {},

  ---@module 'wezterm.mux'
  mux = {},

  ---@module 'wezterm.procinfo'
  procinfo = {},

  ---@module 'wezterm.time'
  time = {},

  ---@type table<string, any>
  GLOBAL = {},

  ---@type _.wezterm.KeyAssignment
  action = {},

  ---@type string
  config_dir = '',

  ---@type string
  config_file = '',

  ---@type string
  executable_dir = '',

  ---@type string
  home_dir = '',

  ---@type table<string, string>
  nerdfonts = {},

  ---@type string
  target_triple = '',

  ---@type string
  version = '',
}

---@param callback _.wezterm.ActionCallback
---@return _.wezterm._CallbackAction
function wezterm.action_callback(callback) end

---@param path string
function wezterm.add_to_config_reload_watch_list(path) end

---@param args string[]
function wezterm.background_child_process(args) end

---@return _.wezterm.BatteryInfo[]
function wezterm.battery_info() end

---@param string string
---@return number
function wezterm.column_width(string) end

---@return _.wezterm.ConfigBuilder
function wezterm.config_builder() end

---@return _.wezterm.HyperlinkRule[]
function wezterm.default_hyperlink_rules() end

---@return _.wezterm.SshDomain[]
function wezterm.default_ssh_domains() end

---@return _.wezterm.WslDomain[]
function wezterm.default_wsl_domains() end

---@param event_name string
---@param ... any
---@return boolean
function wezterm.emit(event_name, ...) end

---@param ssh_config_file_name? string
---@return table<string, string>
function wezterm.enumerate_ssh_hosts(ssh_config_file_name) end

---@param family string
---@param attributes? _.wezterm.FontAttributes
---@return _.wezterm._Font
---@overload fun(attributes: _.wezterm.FontAttributesExtended): _.wezterm._Font
function wezterm.font(family, attributes) end

---@param families string[]
---@param attributes? _.wezterm.FontAttributes
---@return _.wezterm._Font
---@overload fun(attributes: (string | _.wezterm.FontFallbackAttributesExtended)[]): _.wezterm._Font
function wezterm.font_with_fallback(families, attributes) end

---@param format_items _.wezterm.FormatItem[]
---@return string
function wezterm.format(format_items) end

---@return table<string, _.wezterm.Palette>
function wezterm.get_builtin_color_schemes() end

---@param pattern string
---@param relative_to? string
---@return string[]
function wezterm.glob(pattern, relative_to) end

---@param gradient _.wezterm.Gradient
---@param num_colors number
---@return _.wezterm.Color[]
function wezterm.gradient_colors(gradient, num_colors) end

---@param name string
---@return boolean
function wezterm.has_action(name) end

---@return string
function wezterm.hostname() end

---@param value any
---@return string
function wezterm.json_encode(value) end

---@param string string
---@return any
function wezterm.json_encode(string) end

---@param arg string
---@param ... any
function wezterm.log_error(arg, ...) end

---@param arg string
---@param ... any
function wezterm.log_info(arg, ...) end

---@param arg string
---@param ... any
function wezterm.log_warn(arg, ...) end

---@overload fun(event_name: 'format-tab-title', callback: fun(tab: _.wezterm.TabInformation, tabs: _.wezterm.TabInformation[], panes: _.wezterm.PaneInformation, config: table, hover: boolean, max_width: integer): string | _.wezterm.FormatItem[]): nil
---@overload fun(event_name: 'update-right-status', callback: fun(window: _.wezterm.Window, pane: _.wezterm.Pane): nil): nil
---@overload fun(event_name: 'window-config-reloaded', callback: fun(window: _.wezterm.Window, pane: _.wezterm.Pane): nil): nil
function wezterm.on(event_name, callback) end

---@param path_or_url string
---@param application? string
function wezterm.open_with(path_or_url, application) end

---@param string string
---@param min_width number
---@return string
function wezterm.pad_left(string, min_width) end

---@param string string
---@param min_width number
---@return string
function wezterm.pad_right(string, min_width) end

---@param table _.wezterm.MouseBindingBase
---@return _.wezterm.MouseBinding ...
---@overload fun(table: _.wezterm.KeyBindingBase): _.wezterm.KeyBinding ...
function wezterm.permute_any_mods(table) end

---@param table _.wezterm.MouseBindingBase
---@return _.wezterm.MouseBinding ...
---@overload fun(table: _.wezterm.KeyBindingBase): _.wezterm.KeyBinding ...
function wezterm.permute_any_or_no_mods(table) end

---@param path string
---@return string[]
function wezterm.read_dir(path) end

function wezterm.reload_configuration() end

---@param args string[]
---@return boolean, string, string
function wezterm.run_child_process(args) end

---@return boolean
function wezterm.running_under_wsl() end

---@param args string[]
---@return string
function wezterm.shell_join_args(args) end

---@param string string
---@return string
function wezterm.shell_quote_arg(string) end

---@param line string
---@return string[]
function wezterm.shell_quote_arg(line) end

---@param milliseconds number
function wezterm.sleep_ms(milliseconds) end

---@param str string
---@return string[]
function wezterm.split_by_newlines(str) end

---@param format string
---@return string
function wezterm.strftime(format) end

---@param format string
---@return string
function wezterm.strftime_utc(format) end

---@param string string
---@param min_width number
---@return string
function wezterm.truncate_left(string, min_width) end

---@param string string
---@param min_width number
---@return string
function wezterm.truncate_right(string, min_width) end

---@param str string
---@return string
function wezterm.utf16_to_utf8(str) end

return wezterm
