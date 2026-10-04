---@meta

local color = {}

---@param filename string
---@param params? { fuzziness: number, num_colors: number, max_width: number, max_height: number, min_brightness: number, max_brightness: number, threshold: number, min_contrast: number }
function color.extract_colors_from_image(filename, params) end

---@param h string | number
---@param s string | number
---@param l string | number
---@param a string | number
---@return _.wezterm.Color
function color.from_hsla(h, s, l, a) end

---@return table<string, _.wezterm.Palette>
function color.get_builtin_schemes() end

---@return _.wezterm.Palette
function color.get_default_colors() end

---@param gradient _.wezterm.Gradient
---@param num_colors number
---@return _.wezterm.Color[]
function color.gradient(gradient, num_colors) end

---@param file_name string
---@return _.wezterm.Palette, _.wezterm.ColorSchemeMetaData
function color.load_base16_scheme(file_name) end

---@param file_name string
---@return _.wezterm.Palette, _.wezterm.ColorSchemeMetaData
function color.load_scheme(file_name) end

---@param file_name string
---@return _.wezterm.Palette, _.wezterm.ColorSchemeMetaData
function color.load_terminal_sexy_scheme(file_name) end

---@param string string
---@return _.wezterm.Color
function color.parse(string) end

---@param colors _.wezterm.Palette
---@param metadata _.wezterm.ColorSchemeMetaData
---@param file_name string
function color.save_scheme(colors, metadata, file_name) end

return color
