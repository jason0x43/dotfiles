---@meta

---@class hs.application.watcher
local watcher = {
  ---@return hs.application.watcher
  start = function() end,

  ---@return hs.application.watcher
  stop = function() end,
}

---@class application.watcher
local appwatcher = {
  ---@param fn fun(name: string, evtType: string, app: hs.application): nil
  ---@return hs.application.watcher
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
local application = {
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

---@class application
return {
  ---Return the application matching a given hint
  ---@param hint number|string pid, bundleID, or name
  ---@return hs.application|nil
  get = function(hint) end,

  ---Return all running applications
  ---@return hs.application[]
  runningApplications = function() end,

  ---Enable or disable using Spotlight for name searches
  ---@param enable boolean
  enableSpotlightForNameSearches = function(enable) end,

  watcher = appwatcher,
}
