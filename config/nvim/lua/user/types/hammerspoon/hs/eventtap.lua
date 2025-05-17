---@meta

---@class hs.eventtap.event.types
---@field nullEvent integer
---@field keyDown integer
---@field keyUp integer
---@field leftMouseDown integer
---@field leftMouseUp integer
local EventTapEventTypes = {}

---@class hs.eventtap.event
---@field getFlags fun(): table<string, boolean>
---@field getKeyCode fun(): number
---@field setFlags fun(self, table: table<string, boolean>): hs.eventtap.event
---@field setKeyCode fun(self, keycode: number): hs.eventtap.event
local Event = {
  ---@param self hs.eventtap.event
  ---@param app? hs.application
  ---@return hs.eventtap.event
  post = function(self, app) end
}

---@class event
---@field types hs.eventtap.event.types
local EventTapEvent = {
  ---@param eventType integer
  ---@param point hs.geometry.point
  ---@param modifiers? ('cmd'|'alt'|'shift'|'ctrl'|'fn')[]
  ---@return hs.eventtap.event
  newMouseEvent = function(eventType, point, modifiers) end
}

---@class hs.eventtap
---@field isEnabled fun(): boolean
---@field start fun(): hs.eventtap
---@field stop fun(): hs.eventtap
local EventTap = {}

eventtap = {}

---@param types integer[]
---@param fn fun(event: event): boolean|nil, table|nil
---@return hs.eventtap
eventtap.new = function(types, fn) end

eventtap.event = EventTapEvent

---@param modifiers table keyboard modifiers
---@param character string a character to be emitted
---@param delay? integer delay in microseconds
---@param application? hs.application app to send the keystroke to
---@return nil
eventtap.keyStroke = function(modifiers, character, delay, application) end

---@param point hs.geometry absolution position to click
---@param delay? integer delay in microseconds
---@return nil
eventtap.leftClick = function(point, delay) end

return eventtap
