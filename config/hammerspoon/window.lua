---@module "user.types.hammerspoon"

local const = require("const")
local util = require("util")

local logger = hs.logger.new("window", "info")

local M = {}

---Return the screen frame with edge padding
---@param screen hs.screen
---@return hs.geometry frame
local function getScreenFrame(screen)
	local frame = screen:frame()
	return hs.geometry.rect(
		frame.x + const.PADDING,
		frame.y + const.PADDING,
		frame.w - 2 * const.PADDING,
		frame.h - 2 * const.PADDING
	)
end

---Return the padded frame for a screen
---@param screen hs.screen
---@return hs.geometry
M.screenFrame = function(screen)
	return getScreenFrame(screen)
end

---Return true if Stage Manager is enabled.
---@return boolean
M.isStageManagerEnabled = function()
	local output =
		hs.execute("/usr/bin/defaults read com.apple.WindowManager GloballyEnabled")
	return util.trim(output) == "1"
end

---@param area 'left'|'right'|'center'
---@param options? {
---  window?: hs.window,
---  marginLeft?: number,
---  marginRight?: number,
---  marginTop?: number,
---  marginBottom?: number,
---  width?: number }
M.fill = function(area, options)
	options = options or {}

	local window = options.window or hs.window.focusedWindow()
	local width = options.width
	local marginTop = options.marginTop or 0
	local marginLeft = options.marginLeft or 0
	local marginRight = options.marginRight or 0
	local marginBottom = options.marginBottom or 0

	local screenFrame = getScreenFrame(window:screen())
	local winFrame = window:frame()

	if width ~= nil then
		if width < 0 then
			winFrame.w = screenFrame.w + width
		elseif width < 1 then
			winFrame.w = screenFrame.w * width
		else
			winFrame.w = width
		end
  else
    winFrame.w = screenFrame.w / 2
	end

	winFrame.h = screenFrame.h - marginTop - marginBottom
	winFrame.w = winFrame.w - marginLeft - marginRight - const.PADDING / 2

	-- x-coordinate
	if area == const.LEFT then
		winFrame.x = screenFrame.x
	elseif area == const.RIGHT then
		winFrame.x = screenFrame.x + (screenFrame.w - winFrame.w)
	else
		winFrame.x = screenFrame.x + (screenFrame.w / 2 - winFrame.w / 2)
	end

	-- y-coordinate
	winFrame.y = screenFrame.y + (screenFrame.h - winFrame.h) / 2

	winFrame.x = winFrame.x + marginLeft
	winFrame.y = winFrame.y + marginTop

	window:setFrame(winFrame)
end

---Move the focused window to an area
---@param area 'left'|'right'|'center'|'top-left'|'top-right'|'bottom-left'|'bottom-right'
---@param window? hs.window
---@return hs.window
M.moveTo = function(area, window)
	local win = window or hs.window.focusedWindow()
	local winFrame = win:frame()
	local screenFrame = getScreenFrame(win:screen())

	-- x coord
	if area == "left" or area == "top-left" or area == "bottom-left" then
		winFrame.x = screenFrame.x
	elseif area == "right" or area == "top-right" or area == "bottom-right" then
		winFrame.x = screenFrame.x + (screenFrame.w - winFrame.w)
	else
		winFrame.x = screenFrame.x + (screenFrame.w - winFrame.w) / 2
	end

	-- y coord
	if area == "left" or area == "top-left" or area == "bottom-left" then
		winFrame.x = screenFrame.x
	elseif area == "right" or area == "top-right" or area == "bottom-right" then
		winFrame.x = screenFrame.x + (screenFrame.w - winFrame.w)
	else
		winFrame.x = screenFrame.x + (screenFrame.w - winFrame.w) / 2
	end

	if area == "top" or area == "top-left" or area == "top-right" then
		winFrame.y = screenFrame.y
	elseif
		area == "bottom"
		or area == "bottom-left"
		or area == "bottom-right"
	then
		winFrame.y = screenFrame.y + (screenFrame.h - winFrame.h)
	else
		winFrame.y = screenFrame.y + (screenFrame.h - winFrame.h) / 2
	end

	win:setFrame(winFrame)
	return win
end

---Move the focused window to a space
---@param direction 'next'|'prev'
M.moveToSpace = function(direction)
	local win = hs.window.focusedWindow()
	local winId = win:id()
	if winId == nil then
		logger.w("Couldn't get ID of focused window")
		return
	end

	local origCursorPosition = hs.mouse.absolutePosition()
	local coords = win:frame()
	local dir = direction == "next" and "right" or "left"
	local target = hs.geometry.point(coords.x + 70, coords.y + 10)

	hs.eventtap.event
		.newMouseEvent(hs.eventtap.event.types.leftMouseDown, target)
		:post()

	hs.eventtap.keyStroke({ "ctrl", "fn" }, dir)

	hs.eventtap.event
		.newMouseEvent(hs.eventtap.event.types.leftMouseUp, target)
		:post()

	hs.mouse.absolutePosition(origCursorPosition)
end

---Resize the focused window. If width or height are <= 1, the value is treated
---as a percent.
---@param increment {width?: number, height?: number}
---@return nil
M.resize = function(increment)
	local win = hs.window.focusedWindow()
	local screenFrame = getScreenFrame(win:screen())
	local windowFrame = win:frame()

	if increment.width then
		local incrW = increment.width
		if increment.width <= 1 then
			incrW = util.round(screenFrame.w * increment.width)
		end

		local maxWidth = screenFrame.w - (windowFrame.x - screenFrame.x)
		local oldWidth = windowFrame.w
		local newWidth = math.min(windowFrame.w + incrW, maxWidth)
		windowFrame.w = newWidth
		windowFrame.x = windowFrame.x - (newWidth - oldWidth) / 2
	end

	if increment.height then
		local incrH = increment.height
		if increment.height <= 1 then
			incrH = util.round(screenFrame.h * increment.height)
		end

		local maxHeight = screenFrame.h - (windowFrame.y - screenFrame.y)
		local oldHeight = windowFrame.h
		local newHeight = math.min(windowFrame.h + incrH, maxHeight)
		windowFrame.h = newHeight
		windowFrame.y = windowFrame.y - (newHeight - oldHeight) / 2
	end

	win:setFrame(windowFrame)
end

return M
