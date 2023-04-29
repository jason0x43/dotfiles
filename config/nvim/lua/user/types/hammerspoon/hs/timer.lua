---@meta

---@class hs.timer
local timer = {
  ---Start this timer
  ---@return nil
  start = function() end,

  ---Stop this timer
  ---@return nil
  stop = function() end,
}

---@class timer
return {
  ---Call a function after a delay
  ---@param sec integer number of seconds to wait before calling the function
  ---@param fn fun():nil
  ---@return hs.timer
  doAfter = function(sec, fn) end,

  ---Call a function repeatedly while a predicate is true
  ---@param predicateFn fun():nil 
  ---@param actionFn fun():nil
  ---@param checkInterval? number
  ---@return hs.timer
  doWhile = function(predicateFn, actionFn, checkInterval) end,
}
