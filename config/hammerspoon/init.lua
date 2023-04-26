local logger = hs.logger.new("init", "info")

-- Relative Directions
local LEFT = "left"
local RIGHT = "right"

local THIN_WIDTH = (1020 / 3840) * 1.6

local PADDING = 10

---Return true if a list contains an item
---@param list any[]
---@param value any
---@return boolean
local function contains(list, value)
  for _, v in ipairs(list) do
    if v == value then
      return true
    end
  end
  return false
end

---Trim whitespace from a string.
---@param str string
local function trim(str)
  return str:match("^()%s*$") and "" or str:match("^%s*(.*%S)")
end

---Return true if Stage Manager is enabled.
---@return boolean
local function isStageManagerEnabled()
  local output =
    hs.execute("/usr/bin/defaults read com.apple.WindowManager GloballyEnabled")
  return trim(output) == "1"
end

---Get the window IDs for an app in a space.
---@param appName string
---@param spaceId integer
---@return hs.window[]
local function getWindowsInSpace(appName, spaceId)
  local app = hs.application.get(appName)
  if app == nil then
    logger.i("App " .. appName .. " not found")
    return {}
  end

  local ids = hs.spaces.windowsForSpace(spaceId)

  ---@type hs.window[]
  local spaceWinIds = {}

  local appWindows = app:visibleWindows()
  for _, win in ipairs(appWindows) do
    if contains(ids, win:id()) then
      spaceWinIds[#spaceWinIds + 1] = win
    end
  end

  return spaceWinIds
end

---@param frame hs.geometry
---@return hs.geometry
local function padScreenFrame(frame)
  return hs.geometry.rect(
    frame.x + PADDING,
    frame.y + PADDING,
    frame.w - 2 * PADDING,
    frame.h - 2 * PADDING
  )
end

---@param window hs.window
---@return hs.geometry
local function getScreenFrame(window)
  local frame = window:screen():frame()
  return padScreenFrame(frame)
end

---@param area 'left'|'right'
---@param options { window?: hs.window, portion?: number, width?: number, widthMinus?: number }
local function fill(area, options)
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
  if area == LEFT or area == RIGHT then
    bounds.h = screenFrame.h
    bounds.w = width
  end

  frame.h = bounds.h
  frame.w = bounds.w

  if isLargeScreen then
    if area == LEFT or area == RIGHT then
      frame.h = frame.h * 0.95
      frame.w = frame.w * 0.95
    end
  end

  -- x-coordinate
  if area == LEFT then
    frame.x = screenFrame.x + (bounds.w - frame.w) / 2
  elseif area == RIGHT then
    frame.x = screenFrame.x
      + (screenFrame.w - bounds.w)
      + (bounds.w - frame.w - PADDING) / 2
  end

  -- y-coordinate
  if area == LEFT or area == RIGHT then
    frame.y = screenFrame.y + (screenFrame.h - frame.h) / 2
  end

  window:setFrame(frame)
end

---Autolayout the current screen.
---@return nil
local function autolayout()
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

  local browserWins = getWindowsInSpace("Safari", space)
  local termWins = getWindowsInSpace("WezTerm", space)

  if #browserWins == 1 and #termWins == 1 then
    fill(LEFT, { window = browserWins[1], portion = 1 - THIN_WIDTH })
    fill(RIGHT, { window = termWins[1], portion = THIN_WIDTH })
    return
  end
end

-- Reload the hammer spoon config when a config file changes
hs.pathwatcher
  .new(hs.configdir, function(files)
    local doReload = false
    for _, file in pairs(files) do
      if file:sub(-4) == ".lua" then
        doReload = true
        break
      end
    end
    if doReload then
      hs.reload()
    end
  end)
  :start()

hs.hotkey.bind({ "ctrl", "shift" }, "space", function()
  autolayout()
end)

hs.alert.show("Hammerspoon config loaded")
