local logger = hs.logger.new("init", "info")

-- Relative Directions
local LEFT = "left"
local RIGHT = "right"
local CENTER = "center"
local NW = "nw"
local NE = "ne"
local SW = "sw"
local SE = "se"

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
      if contains(ids, win:id()) then
        spaceWins[#spaceWins + 1] = win
      end
    end
  end

  return spaceWins
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

---@param area 'left'|'right'|'center'
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

---Move a window to an area
---@param area 'left'|'right'|'center'
---@param win? hs.window
local function moveTo(area, win)
  win = win or hs.window.focusedWindow()
  local delta = getDeltaFrame(win)
  local frame = win:frame()
  local screenFrame = getScreenFrame(win)

  -- x-coordinate
  if area == NW or area == SW then
    frame.x = screenFrame.x
  elseif area == NE or area == SE then
    frame.x = screenFrame.x + delta.w
  elseif area == CENTER then
    frame.x = screenFrame.x + delta.w / 2
  end

  -- y-coordinate
  if area == NW or area == NE then
    frame.y = screenFrame.y
  elseif area == SE or area == SW then
    frame.y = screenFrame.y + delta.h
  elseif area == CENTER then
    frame.y = screenFrame.y + delta.h / 2
  end

  logger.i("Setting frame to " .. hs.inspect(frame))
  win:setFrame(frame)
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

  local browserWins = getWindowsInSpace({ "Safari", "Wavebox" }, space)
  local termWins = getWindowsInSpace("WezTerm", space)

  if #browserWins == 1 and #termWins == 1 then
    fill(LEFT, { window = browserWins[1], portion = 1 - THIN_WIDTH })
    fill(RIGHT, { window = termWins[1], portion = THIN_WIDTH })
    return
  end

  local waveboxWins = getWindowsInSpace("Wavebox", space)
  if #waveboxWins == 1 then
    local messagesWins = getWindowsInSpace("Messages", space)
    if #messagesWins > 0 then
      fill(LEFT, { window = messagesWins[1], portion = 0.32 })
      fill(RIGHT, { window = waveboxWins[1], widthMinus = 90 })
    else
      fill(CENTER, { window = waveboxWins[1] })
    end
  end
end

-- Layout the active display
hs.hotkey.bind({ "ctrl", "shift" }, "space", function()
  autolayout()
end)

-- Move the active window to the center of the display
hs.hotkey.bind({ "ctrl", "shift" }, "z", function()
  moveTo(CENTER)
end)

-- Reload the Hammerspoon config
hs.hotkey.bind({ "ctrl", "shift" }, "r", function()
  hs.reload()
end)

-- Send ctrl-space for escape to hide the Raycast window without navigating
local raycastEscape = hs.hotkey.new({}, "escape", function()
  -- ctrl-space must be sent to the system rather than a specific app
  hs.eventtap.keyStroke({ "ctrl" }, "space", 0)
end)

-- Send escape for cmd-w to let cmd-w pop Raycast's navigation stack
local raycastCmdW = hs.hotkey.new({ "cmd" }, "w", function()
  -- cmd-w needs to be sent to a specific app
  local app = hs.window.focusedWindow():application()
  hs.eventtap.keyStroke({}, "escape", 0, app)
end)

-- Watch for the Raycast popup to en/disable the Raycast hotkey overrides
if raycastEscape == nil or raycastCmdW == nil then
  hs.alert.show("Error creating Raycast hotkeys")
else
  RaycastFilter = hs.window.filter
    .new(false)
    :setAppFilter("Raycast", { allowRoles = "AXSystemDialog" })
    :subscribe(hs.window.filter.windowVisible, function()
      raycastEscape:enable()
      raycastCmdW:enable()
    end)
    :subscribe(hs.window.filter.windowNotVisible, function()
      raycastEscape:disable()
      raycastCmdW:disable()
    end)
end

-- Reload the hammer spoon config when a config file changes
ConfigWatcher = hs.pathwatcher
  .new(hs.configdir, function(files)
    local doReload = false
    for _, file in pairs(files) do
      if file:sub(-4) == ".lua" then
        doReload = true
        break
      end
    end
    if doReload then
      logger.i("Reloading Hammerspoon config")
      hs.reload()
    end
  end)
  :start()

hs.alert.show("Hammerspoon config loaded")
