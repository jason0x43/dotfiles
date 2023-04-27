---@meta

---@class hs.logger
local logger = {
  ---Log an info message
  ---@param ... string message strings
  ---@return nil
  i = function(...) end,

  ---Log a debug message
  ---@param ... string message strings
  ---@return nil
  d = function(...) end,
}

---@class logger
return {
  ---@param id string identifier
  ---@param loglevel? 'nothing'|'error'|'warning'|'info'|'debug'|'verbose'|0|1|2|3|4|5
  ---@return hs.logger
  new = function(id, loglevel) end
}
