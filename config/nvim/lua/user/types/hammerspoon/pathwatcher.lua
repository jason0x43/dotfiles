---@meta

---@class hs.pathwatcher
local pathwatcher = {
  ---@return hs.pathwatcher
  start = function() end,

  ---@return nil
  stop = function() end
}

---@class pathwatcher
return {
  ---@param path string the path to watch
  ---@param fn fun(paths: string[], flagTables: table): nil
  ---@return hs.pathwatcher
  new = function(path, fn) end
}

