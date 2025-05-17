---@meta

---@class hs.screen
local Screen = {
  ---Return the screen frame, without the dock and menu
  ---@return hs.geometry.rect
  frame = function() end,

  ---Return the screen frame, including the dock and menu
  ---@return hs.geometry
  fullFrame = function() end,

  ---Return the screen's name
  ---@return string
  name = function() end,
}

screen = {}

---Return all the screens
---@return hs.screen[]
screen.allScreens = function() end

---Return the screen with the currently focused window
---@return hs.screen
screen.mainScreen = function() end

return screen
