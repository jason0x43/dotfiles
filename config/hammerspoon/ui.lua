local M = {}

---@type hs.timer | nil
MouseCircleTimer = nil

---@param point hs.geometry.point
---@param size number
---@param color? hs.drawing.color
local function circleAround(point, size, color)
  local radius = size / 2
  local circle = hs.drawing.circle(
    hs.geometry.rect(point.x - radius, point.y - radius, size, size)
  )
  color = color or { hex = "#ff0000", alpha = 1 }
  circle:setStrokeColor(color)
  circle:setFill(false)
  circle:setStrokeWidth(5)
  return circle
end

---Highlight the mouse pointer position
---@return nil
M.mouseHighlight = function()
  local mousepoint = hs.mouse.absolutePosition()

  local circles = {
    circleAround(mousepoint, 200, { hex = "#ff0000", alpha = 1 }),
    circleAround(mousepoint, 150, { hex = "#ff0000", alpha = 0.8 }),
    circleAround(mousepoint, 100, { hex = "#ff0000", alpha = 0.6 }),
    circleAround(mousepoint, 60, { hex = "#ff0000", alpha = 0.4 }),
    circleAround(mousepoint, 20, { hex = "#ff0000", alpha = 0.2 }),
  }
  local index = 1

  circles[index]:show()

  local function keepGoing()
    return index <= #circles
  end

  local function renderCircle()
    circles[index]:delete()
    index = index + 1
    if index <= #circles then
      circles[index]:show()
    end
  end

  hs.timer.doWhile(keepGoing, renderCircle, 0.07)
end

return M
