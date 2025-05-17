---@meta

---@class hs.timer
local Timer = {
  ---Start this timer
  ---@return nil
  start = function() end,

  ---Stop this timer
  ---@return nil
  stop = function() end,
}

timer = {}

---Call a function after a delay
---@param sec integer number of seconds to wait before calling the function
---@param fn fun():nil
---@return hs.timer
timer.doAfter = function(sec, fn) end

---Call a function repeatedly while a predicate is true
---@param predicateFn fun():nil
---@param actionFn fun():nil
---@param checkInterval? number
---@return hs.timer
timer.doWhile = function(predicateFn, actionFn, checkInterval) end

return timer
