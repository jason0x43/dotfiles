---@meta

---@alias EventCallback fun(win: hs.window, app: string, event: string): nil
---
---@alias FilterTable
---| { visible?: boolean, currentSpace?: boolean, fullscreen?: boolean, hasTitlebar?: boolean, focused?: boolean, activeApplication?: boolean, allowTitles?: number|string|string[], rejectTitles?: string|string[], allowRegions?: hs.geometry|hs.geometry[], rejectRegions?: hs.geometry|hs.geometry[], allowScreens?: number|string|hs.geometry, rejectScreens?: number|string|hs.geometry, allowRoles?: string|string[] }

---@class hs.window.filter
local filter = {
  ---@param appname string
  ---@param filter boolean|nil|FilterTable
  ---@return hs.window.filter
  setAppFilter = function(self, appname, filter) end,

  ---Subscribe to one or more events
  ---@param event string|string[]|table<string, EventCallback> events to subscribe to
  ---@param fn EventCallback|EventCallback[] callback(s) for events
  ---@param immediate? boolean whether to trigger the callback immediately
  ---@return hs.window.filter
  subscribe = function(self, event, fn, immediate) end,
}

---@class window.filter
---@field windowVisible string
---@field windowNotVisible string
local winfilter = {
  ---@param fn nil|boolean|string|string[]|table|fun(win: hs.window):boolean
  ---@param logname? string
  ---@param loglevel? string
  ---@return hs.window.filter
  new = function(fn, logname, loglevel) end,
}

---@class hs.window
local window = {
  ---Return the application that the window belongs to
  ---@return hs.application|nil
  application = function() end,

  ---Center this window on the screen,
  ---@return hs.window
  centerOnScreen = function() end,

  ---Focus this window
  ---@return hs.window
  focus = function() end,

  ---Return the window's frame
  ---@return hs.geometry
  frame = function() end,

  ---Return the window's ID
  ---@return integer|nil
  id = function() end,

  ---Move this window one screen to the right
  ---@return hs.window
  moveOneScreenEast = function() end,

  ---Move this window one screen to the left
  ---@return hs.window
  moveOneScreenWest = function() end,

  ---Return the screen containing the window
  ---@return hs.screen
  screen = function() end,

  ---Set the frame of the window
  ---@param self hs.window
  ---@param frame hs.geometry
  ---@return hs.window
  setFrame = function(self, frame) end,

  ---Set the size of this window
  ---@param size hs.geometry
  ---@return hs.window
  setSize = function(self, size) end,

  ---Get the size of this window
  ---@return hs.geometry
  size = function() end,

  ---Return the subrole of the window
  ---@return string
  subrole = function() end,

  ---Return the number of tabs in the window
  ---@return integer|nil
  tabCount = function() end,

  ---Return the window's title
  ---@return string
  title = function() end,
}

---@class window
---@field filter window.filter
return {
  ---Return the currently focused window
  ---@return hs.window
  focusedWindow = function() end,

  ---Return all visible windows
  ---@return hs.window[]
  visibleWindows = function() end,
}
