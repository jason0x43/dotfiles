---@meta

fnutils = {}

---Check if a table contains an object
---@param tbl table
---@param value any
---@return boolean
fnutils.find = function(tbl, value) end

---Find an matching item in a table
---@param tbl table
---@param fn fun(item: any): boolean
---@return any | nil
fnutils.find = function(tbl, fn) end

---Filter a table
---@param tbl table
---@param fn fun(item: any): boolean
---@return table
fnutils.filter = function(tbl, fn) end

---Filter a list-like table
---@generic T
---@param tbl T[]
---@param fn fun(item: T): boolean
---@return T[]
fnutils.ifilter = function(tbl, fn) end

return fnutils
