---@meta

---@class hs.hotkey
local hotkey = {
  delete = function() end,
  disable = function() end,
  enable = function() end
}

---@class hotkey
return {
  ---@param mods string|table a table or string containing keyboard modifiers
  ---@param key string|number a string containing the name of a key or a keycode
  ---@param message string a string containing an alert message
  ---@param pressedfn function|nil called when the hotkey is pressed
  ---@param releasedfn function|nil called when the hotkey is released
  ---@param repeatfn function|nil called when the hotkey is repeating
  ---@return hs.hotkey
  ---@overload fun(mods: string|table, key: string|number, pressedfn: function|nil, releasedfn: function|nil, repeatfn: function|nil): hs.hotkey
  ---@overload fun(mods: string|table, key: string|number, message: string, pressedfn: function|nil, releasedfn: function|nil, repeatfn: function|nil): hs.hotkey
  bind = function (mods, key, message, pressedfn, releasedfn, repeatfn) end
}
