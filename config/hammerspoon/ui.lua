local M = {}

---@type hs.timer | nil
MouseCircleTimer = nil

---@param def Partial<hs.drawing.color>
---@returns hs.drawing.color
local function asColor(def)
	local color = def
	---@cast color hs.drawing.color
	return color
end

local defaultColor = asColor({ hex = "#ff0000", alpha = 1 })

---@param point hs.geometry
---@param size number
---@param color? hs.drawing.color
---@returns hs.drawing | nil
local function circleAround(point, size, color)
  if point.x == nil or point.y == nil then
    return
  end

	local radius = size / 2
	---@type hs.drawing | nil
	local circle = hs.drawing.circle(
		hs.geometry.rect(point.x - radius, point.y - radius, size, size)
	)
	if not circle then
		return
	end

	color = color or defaultColor
	circle:setStrokeColor(color)
	circle:setFill(false)
	circle:setStrokeWidth(5)
	return circle
end

---Highlight the mouse pointer position
---@return nil
M.mouseHighlight = function()
	---@type hs.geometry
	local mousePoint = hs.mouse.absolutePosition()

	local circles = {
		circleAround(mousePoint, 200, asColor({ hex = "#ff0000", alpha = 1 })),
		circleAround(mousePoint, 150, asColor({ hex = "#ff0000", alpha = 0.8 })),
		circleAround(mousePoint, 100, asColor({ hex = "#ff0000", alpha = 0.6 })),
		circleAround(mousePoint, 60, asColor({ hex = "#ff0000", alpha = 0.4 })),
		circleAround(mousePoint, 20, asColor({ hex = "#ff0000", alpha = 0.2 })),
	}
	local index = 1

	local circle = circles[index]
	if circle then
		circle:show()
	end

	local function keepGoing()
		return index <= #circles
	end

	local function renderCircle()
		circle = circles[index]
		if circle then
			circle:delete()
		end

		index = index + 1
    circle = circles[index]
    if circle then
      circle:show()
    end
	end

	hs.timer.doWhile(keepGoing, renderCircle, 0.07)
end

return M
