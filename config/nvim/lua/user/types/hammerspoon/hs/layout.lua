---@meta

---@class layout
---@field left25 hs.geometry
---@field left30 hs.geometry
---@field left50 hs.geometry
---@field left70 hs.geometry
---@field left75 hs.geometry
---@field maximized hs.geometry
---@field right25 hs.geometry
---@field right30 hs.geometry
---@field right50 hs.geometry
---@field right70 hs.geometry
---@field right75 hs.geometry
return {
  ---Apply a layout to applications/windows
  ---@param table {[1]: string|hs.application|nil, [2]: string|hs.window|(fun():hs.window)|nil, [3]: string|hs.screen|(fun():hs.screen)|nil, [4]: hs.geometry|(fun(win: hs.window):hs.geometry), [5]: hs.geometry|(fun(win: hs.window):hs.geometry), [6]: hs.geometry|(fun(win: hs.window):hs.geometry)}
  ---@param windowTitleComparator? fun(windowTitle: string, layoutWindowTitle: string, options?: {absolute_x: boolean, absolute_y: boolean}): boolean
  apply = function(table, windowTitleComparator) end
}
