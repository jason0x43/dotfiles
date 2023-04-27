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
  setFrame = function(self, frame) end,

  ---Return the subrole of the window
  ---@return string
  subrole = function() end,
}

---@class window
---@field filter window.filter
return {
  ---Return the currently focused window
  ---@return hs.window
  focusedWindow = function() end,
}
