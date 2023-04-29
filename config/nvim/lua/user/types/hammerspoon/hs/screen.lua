---@meta

---@class hs.screen
local screen = {
  ---Return the screen frame, without the dock and menu
  ---@return hs.geometry
  frame = function() end,

  ---Return the screen frame, including the dock and menu
  ---@return hs.geometry
  fullFrame = function() end,

  ---Return the screen's name
  ---@return string
  name = function() end,
}

---@class screen
return {
  ---Return all the screens
  ---@return hs.screen[]
  allScreens = function() end,

  ---Return the screen with the currently focused window
  ---@return hs.screen
  mainScreen = function() end,
}
