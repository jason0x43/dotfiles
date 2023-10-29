---@meta

---@class WezTerm
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

  ---@param callback _.wezterm.ActionCallback
  ---@return _.wezterm._CallbackAction
  action_callback = function(callback) end,

  ---@param path string
  add_to_config_reload_watch_list = function(path) end,

  ---@param args string[]
  background_child_process = function(args) end,

  ---@return _.wezterm.BatteryInfo[]
  battery_info = function() end,

  ---@param string string
  ---@return number
  column_width = function(string) end,

  ---@return _.wezterm.ConfigBuilder
  config_builder = function() end,

  ---@return _.wezterm.HyperlinkRule[]
  default_hyperlink_rules = function() end,

  ---@return _.wezterm.SshDomain[]
  default_ssh_domains = function() end,

  ---@return _.wezterm.WslDomain[]
  default_wsl_domains = function() end,

  ---@param event_name string
  ---@param ... any
  ---@return boolean
  emit = function(event_name, ...) end,

  ---@param ssh_config_file_name? string
  ---@return table<string, string>
  enumerate_ssh_hosts = function(ssh_config_file_name) end,

  ---@param family string
  ---@param attributes? _.wezterm.FontAttributes
  ---@return _.wezterm._Font
  ---@overload fun(attributes: _.wezterm.FontAttributesExtended): _.wezterm._Font
  font = function(family, attributes) end,

  ---@param families string[]
  ---@param attributes? _.wezterm.FontAttributes
  ---@return _.wezterm._Font
  ---@overload fun(attributes: (string | _.wezterm.FontFallbackAttributesExtended)[]): _.wezterm._Font
  font_with_fallback = function(families, attributes) end,

  ---@param format_items _.wezterm.FormatItem[]
  ---@return string
  format = function(format_items) end,

  ---@return table<string, _.wezterm.Palette>
  get_builtin_color_schemes = function() end,

  ---@param pattern string
  ---@param relative_to? string
  ---@return string[]
  glob = function(pattern, relative_to) end,

  ---@param gradient _.wezterm.Gradient
  ---@param num_colors number
  ---@return _.wezterm.Color[]
  gradient_colors = function(gradient, num_colors) end,

  ---@param name string
  ---@return boolean
  has_action = function(name) end,

  ---@return string
  hostname = function() end,

  ---@param value any
  ---@return string
  json_encode = function(value) end,

  ---@param arg string
  ---@param ... any
  log_error = function(arg, ...) end,

  ---@param arg string
  ---@param ... any
  log_info = function(arg, ...) end,

  ---@param arg string
  ---@param ... any
  log_warn = function(arg, ...) end,

  ---@overload fun(event_name: 'format-tab-title', callback: fun(tab: _.wezterm.TabInformation, tabs: _.wezterm.TabInformation[], panes: _.wezterm.PaneInformation, config: table, hover: boolean, max_width: integer): string | _.wezterm.FormatItem[]): nil
  ---@overload fun(event_name: 'update-right-status', callback: fun(window: _.wezterm.Window, pane: _.wezterm.Pane): nil): nil
  ---@overload fun(event_name: 'window-config-reloaded', callback: fun(window: _.wezterm.Window, pane: _.wezterm.Pane): nil): nil
  on = function(event_name, callback) end,

  ---@param path_or_url string
  ---@param application? string
  open_with = function(path_or_url, application) end,

  ---@param string string
  ---@param min_width number
  ---@return string
  pad_left = function(string, min_width) end,

  ---@param string string
  ---@param min_width number
  ---@return string
  pad_right = function(string, min_width) end,

  ---@param table _.wezterm.MouseBindingBase
  ---@return _.wezterm.MouseBinding ...
  ---@overload fun(table: _.wezterm.KeyBindingBase): _.wezterm.KeyBinding ...
  permute_any_mods = function(table) end,

  ---@param table _.wezterm.MouseBindingBase
  ---@return _.wezterm.MouseBinding ...
  ---@overload fun(table: _.wezterm.KeyBindingBase): _.wezterm.KeyBinding ...
  permute_any_or_no_mods = function(table) end,

  ---@param path string
  ---@return string[]
  read_dir = function(path) end,

  reload_configuration = function() end,

  ---@param args string[]
  ---@return boolean, string, string
  run_child_process = function(args) end,

  ---@return boolean
  running_under_wsl = function() end,

  ---@param args string[]
  ---@return string
  shell_join_args = function(args) end,

  ---@param line string
  ---@return string|string[]
  shell_quote_arg = function(line) end,

  ---@param milliseconds number
  sleep_ms = function(milliseconds) end,

  ---@param str string
  ---@return string[]
  split_by_newlines = function(str) end,

  ---@param format string
  ---@return string
  strftime = function(format) end,

  ---@param format string
  ---@return string
  strftime_utc = function(format) end,

  ---@param string string
  ---@param min_width number
  ---@return string
  truncate_left = function(string, min_width) end,

  ---@param string string
  ---@param min_width number
  ---@return string
  truncate_right = function(string, min_width) end,

  ---@param str string
  ---@return string
  utf16_to_utf8 = function(str) end,
}

return wezterm
