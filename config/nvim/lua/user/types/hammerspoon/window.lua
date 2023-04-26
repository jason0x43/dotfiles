---@meta

---@class hs.window
local window = {
  ---Return the window's frame
  ---@return hs.geometry
  frame = function() end,

  ---Return the window's ID
  ---@return integer|nil
  id = function() end,

  ---Return the screen containing the window
  ---@return hs.screen
  screen = function() end,

  ---Set the frame of the window
  ---@param self hs.window
  ---@param frame hs.geometry
  ---@return hs.window
  setFrame = function(self, frame) end
}

---@class window
return {
  ---Return the currently focused window
  ---@return hs.window
  focusedWindow = function() end,
}
