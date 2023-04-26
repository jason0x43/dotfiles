---@meta

---@class eventtap.event.types
---@field nullEvent integer
---@field keyDown integer
---@field keyUp integer
local eventtapEventTypes = {}

---@class hs.eventtap.event
local event = {
  ---@return number
  getKeyCode = function() end,
}

---@class eventtap.event
local eventtapEvent = {
  types = eventtapEventTypes,
}

---@class hs.eventtap
local eventtap = {
  ---@return boolean
  isEnabled = function() end,

  ---@return hs.eventtap
  start = function() end,

  ---@return hs.eventtap
  stop = function() end,
}

---@class eventtap
return {
  ---@param types integer[]
  ---@param fn fun(event: hs.eventtap.event): boolean|nil, table|nil
  ---@return hs.eventtap
  new = function(types, fn) end,

  event = eventtapEvent
}

