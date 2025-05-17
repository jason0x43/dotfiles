---@meta
application = {}

---@class watcher
local watcher = {
  ---@return watcher
  start = function() end,

  ---@return watcher
  stop = function() end,
}

local app_watcher = {
  ---@param fn fun(name: string, evtType: string, app: hs.application): nil
  ---@return watcher
  new = function(fn) end,

  activated = '',
  deactivated = '',
  hidden = '',
  launched = '',
  launching = '',
  terminated = '',
  unhidden = '',
}

---@class hs.application
local Application = {
  ---Ativate this application
  ---@return nil
  activate = function() end,

  ---Return the name of this application
  ---@return string
  name = function() end,

  ---Return the main window of this application
  ---@return hs.window|nil
  mainWindow = function() end,

  ---Return the visible windows of this application
  ---@return hs.window[]
  visibleWindows = function() end,
}

---Return the application matching a given hint
---@param hint number|string pid, bundleID, or name
---@return hs.application|nil
application.get = function(hint) end

---Return all running applications
---@return hs.application[]
application.runningApplications = function() end

---Enable or disable using Spotlight for name searches
---@param enable boolean
application.enableSpotlightForNameSearches = function(enable) end

application.watcher = app_watcher

return application
