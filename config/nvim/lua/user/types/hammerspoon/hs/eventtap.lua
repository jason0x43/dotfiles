---@meta

---@class eventtap.event.types
---@field nullEvent integer
---@field keyDown integer
---@field keyUp integer
local eventtapEventTypes = {}

---@class hs.eventtap.event
local event = {
  ---@return table<string, boolean>
  getFlags = function() end,

  ---@return number
  getKeyCode = function() end,

  ---@param table table<string, boolean>
  ---@return hs.eventtap.event
  setFlags = function(self, table) end,

  ---@param keycode number
  ---@return hs.eventtap.event
  setKeyCode = function(self, keycode) end,
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

  event = eventtapEvent,

  ---@param modifiers table keyboard modifiers
  ---@param character string a character to be emitted
  ---@param delay? integer delay in microseconds
  ---@param application? hs.application app to send the keystroke to
  ---@return nil
  keyStroke = function(modifiers, character, delay, application) end,
}

