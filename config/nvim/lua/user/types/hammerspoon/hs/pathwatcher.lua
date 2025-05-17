---@meta

---@class hs.pathwatcher
local PathWatcher = {
  ---@return hs.pathwatcher
  start = function() end,

  ---@return nil
  stop = function() end,
}

pathwatcher = {}

---@param path string the path to watch
---@param fn fun(paths: string[], flagTables: table): nil
---@return hs.pathwatcher
pathwatcher.new = function(path, fn) end

return pathwatcher
