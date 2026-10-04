---@meta

local gui = {}

---@return table<string, _.wezterm.KeyBinding[]>
function gui.default_key_tables() end

---@return _.wezterm.KeyBinding[]
function gui.default_keys() end

---@return _.wezterm.GpuInfo[]
function gui.enumerate_gpus() end

---@return _.wezterm.Appearance
function gui.get_appearance() end

---@param window_id number
---@return _.wezterm.Window | nil
function gui.gui_window_for_mux_window(window_id) end

---@return _.wezterm.Window[]
function gui.gui_windows() end

---@return { active: _.wezterm.ScreenInformation, by_name: table<string, _.wezterm.ScreenInformation>, main: _.wezterm.ScreenInformation, origin_x: number, origin_y: number, virtual_height: number, virtual_width: number }
function gui.screens() end

return gui
