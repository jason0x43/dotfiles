local const = require("const")
local util = require("util")

local logger = hs.logger.new("window", "info")

local M = {}

---Return true if Stage Manager is enabled.
---@return boolean
local function isStageManagerEnabled()
  local output =
    hs.execute("/usr/bin/defaults read com.apple.WindowManager GloballyEnabled")
  return util.trim(output) == "1"
end

---@param frame hs.geometry
---@return hs.geometry
local function padScreenFrame(frame)
  return hs.geometry.rect(
    frame.x + const.PADDING,
    frame.y + const.PADDING,
    frame.w - 2 * const.PADDING,
    frame.h - 2 * const.PADDING
  )
end

---@param window hs.window
---@return hs.geometry
local function getScreenFrame(window)
  local frame = window:screen():frame()
  return padScreenFrame(frame)
end

---Get a delta frame between a window and its screen
---@param win hs.window
---@return hs.geometry
local function getDeltaFrame(win)
  local frame = win:frame()
  local screen = getScreenFrame(win)

  return hs.geometry.rect(
    screen.x - frame.x,
    screen.y - frame.y,
    screen.w - frame.w,
    screen.h - frame.h
  )
end

---Get the window IDs for an app in a space.
---@param appNames string|string[]
---@param spaceId integer
---@return hs.window[]
local function getWindowsInSpace(appNames, spaceId)
  ---@type hs.window[]
  local spaceWins = {}

  ---@type string[]
  local appNamesArr = {}
  if type(appNames) == "string" then
    appNamesArr = { appNames }
  else
    appNamesArr = appNames
  end

  for _, appName in pairs(appNamesArr) do
    local app = hs.application.get(appName)
    if app == nil then
      logger.i("App " .. appName .. " not found")
      return {}
    end

    local ids = hs.spaces.windowsForSpace(spaceId)

    local appWindows = app:visibleWindows()
    for _, win in ipairs(appWindows) do
      if util.contains(ids, win:id()) then
        spaceWins[#spaceWins + 1] = win
      end
    end
  end

  return spaceWins
end

---@param area 'left'|'right'|'center'
---@param options { window?: hs.window, portion?: number, width?: number, widthMinus?: number }
M.fill = function(area, options)
  local window = options.window or hs.window.focusedWindow()
  local width = options.width or 0
  local portion = options.portion
  local widthMinus = options.widthMinus

  local screenFrame = getScreenFrame(window)
  local isLargeScreen = screenFrame.w > 2000
  local frame = window:frame()

  if portion then
    width = screenFrame.w * portion
  elseif widthMinus then
    width = screenFrame.w - widthMinus
  end

  if width == nil then
    width = screenFrame.w / 2
  end

  logger.d("windowFrame: " .. hs.inspect(frame))
  logger.d("screenFrame: " .. hs.inspect(screenFrame))

  ---@type {h: number, w: number, x: number, y: number}
  local bounds = {}

  -- size
  if area == const.LEFT or area == const.RIGHT then
    bounds.h = screenFrame.h
    bounds.w = width
  end

  frame.h = bounds.h
  frame.w = bounds.w

  if isLargeScreen then
    if area == const.LEFT or area == const.RIGHT then
      frame.h = frame.h * 0.95
      frame.w = frame.w * 0.95
    end
  end

  -- x-coordinate
  if area == const.LEFT then
    frame.x = screenFrame.x + (bounds.w - frame.w) / 2
  elseif area == const.RIGHT then
    frame.x = screenFrame.x
      + (screenFrame.w - bounds.w)
      + (bounds.w - frame.w - const.PADDING) / 2
  end

  -- y-coordinate
  if area == const.LEFT or area == const.RIGHT then
    frame.y = screenFrame.y + (screenFrame.h - frame.h) / 2
  end

  window:setFrame(frame)
end

---Move a window to an area
---@param area 'left'|'right'|'center'
---@param win? hs.window
M.moveTo = function(area, win)
  win = win or hs.window.focusedWindow()
  local delta = getDeltaFrame(win)
  local frame = win:frame()
  local screenFrame = getScreenFrame(win)

  -- x-coordinate
  if area == const.NW or area == const.SW then
    frame.x = screenFrame.x
  elseif area == const.NE or area == const.SE then
    frame.x = screenFrame.x + delta.w
  elseif area == const.CENTER then
    frame.x = screenFrame.x + delta.w / 2
  end

  -- y-coordinate
  if area == const.NW or area == const.NE then
    frame.y = screenFrame.y
  elseif area == const.SE or area == const.SW then
    frame.y = screenFrame.y + delta.h
  elseif area == const.CENTER then
    frame.y = screenFrame.y + delta.h / 2
  end

  logger.i("Setting frame to " .. hs.inspect(frame))
  win:setFrame(frame)
end

---Resize the focused window
---@param increment {width?: integer, height?: integer}
---@param win? hs.window
---@return nil
M.resize = function(increment, win)
  win = win or hs.window.focusedWindow()
	local screenFrame = getScreenFrame(win)
	local windowFrame = win:frame()

	if increment.width then
		local maxWidth = screenFrame.w - (windowFrame.x - screenFrame.x)
		local oldWidth = windowFrame.w
		local newWidth = math.min(windowFrame.w + increment.width, maxWidth)
		windowFrame.w = newWidth;
		windowFrame.x = windowFrame.x - (newWidth - oldWidth) / 2
  end

	if increment.height then
		local maxHeight = screenFrame.h - (windowFrame.y - screenFrame.y)
		local oldHeight = windowFrame.h
		local newHeight = math.min(
			windowFrame.h + increment.height,
			maxHeight
		)
		windowFrame.h = newHeight
		windowFrame.y = windowFrame.y - (newHeight - oldHeight) / 2
  end

	win:setFrame(windowFrame)
end

---Return x% of the screen width in pixels
---@param percent number
---@param win? hs.window
---@return integer
M.widthPercent = function(percent, win)
  win = win or hs.window.focusedWindow()
	local screenFrame = getScreenFrame(win)
	return util.round(screenFrame.w * percent)
end

---Return x% of the screen height in pixels
---@param percent number
---@param win? hs.window
---@return integer
M.heightPercent = function(percent, win)
  win = win or hs.window.focusedWindow()
	local screenFrame = getScreenFrame(win)
	return util.round(screenFrame.h * percent)
end

---Layout the current screen.
---@return nil
M.layout = function()
  local space = hs.spaces.activeSpaceOnScreen()
  local spaceType = hs.spaces.spaceType(space)

  if spaceType == "fullscreen" then
    logger.i("Skipping layout because app is full screen")
    return
  end

  if isStageManagerEnabled() then
    logger.d("SM enabled")
  else
    logger.d("SM not enabled")
  end

  local browserWins = getWindowsInSpace({ "Safari", "Wavebox" }, space)
  local termWins = getWindowsInSpace("WezTerm", space)

  if #browserWins == 1 and #termWins == 1 then
    M.fill(
      const.LEFT,
      { window = browserWins[1], portion = 1 - const.THIN_WIDTH }
    )
    M.fill(const.RIGHT, { window = termWins[1], portion = const.THIN_WIDTH })
    return
  end

  local waveboxWins = getWindowsInSpace("Wavebox", space)
  if #waveboxWins == 1 then
    local messagesWins = getWindowsInSpace("Messages", space)
    if #messagesWins > 0 then
      M.fill(const.LEFT, { window = messagesWins[1], portion = 0.32 })
      M.fill(const.RIGHT, { window = waveboxWins[1], widthMinus = 90 })
    else
      M.fill(const.CENTER, { window = waveboxWins[1] })
    end
  end
end

return M
