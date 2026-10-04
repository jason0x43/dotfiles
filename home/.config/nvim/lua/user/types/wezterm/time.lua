---@meta

local time = {}

---@param interval_seconds number
---@param callback fun(): any
function time.call_after(interval_seconds, callback) end

---@return _.wezterm.Time
function time.now() end

---@param str string
---@param format string
---@return _.wezterm.Time
function time.parse(str, format) end

---@param str string
---@return _.wezterm.Time
function time.parse_rfc3339(str) end

return time
