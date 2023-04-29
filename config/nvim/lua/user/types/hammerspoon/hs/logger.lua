---@meta

---@class hs.logger
local logger = {
  ---Log an info message
  ---@param ... string message strings
  ---@return nil
  i = function(...) end,

  ---Log a formatted info message
  ---@param fmt string format string
  ---@param ... any format values
  ---@return nil
  f = function(fmt, ...) end,

  ---Log a debug message
  ---@param ... string message strings
  ---@return nil
  d = function(...) end,

  ---Log a formatted debug message
  ---@param fmt string format string
  ---@param ... any format values
  ---@return nil
  df = function(fmt, ...) end,

  ---Log an error message
  ---@param ... string message strings
  ---@return nil
  e = function(...) end,

  ---Log a formatted error message
  ---@param fmt string format string
  ---@param ... any format values
  ---@return nil
  ef = function(fmt, ...) end,

  ---Log a warning message
  ---@param ... string message strings
  ---@return nil
  w = function(...) end,

  ---Log a formatted warning message
  ---@param fmt string format string
  ---@param ... any format values
  ---@return nil
  wf = function(fmt, ...) end,
}

---@class logger
return {
  ---@param id string identifier
  ---@param loglevel? 'nothing'|'error'|'warning'|'info'|'debug'|'verbose'|0|1|2|3|4|5
  ---@return hs.logger
  new = function(id, loglevel) end
}
