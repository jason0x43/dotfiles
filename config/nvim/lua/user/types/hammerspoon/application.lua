---@meta

---@class hs.application
local application = {
  ---@return hs.window[]
  visibleWindows = function() end,
}

---@class application
return {
  ---Return the application matching a given hint
  ---@param hint number|string pid, bundleID, or name
  ---@return hs.application|nil
  get = function(hint) end
}
