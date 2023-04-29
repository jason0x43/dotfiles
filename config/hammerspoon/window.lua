local const = require("const")
local util = require("util")

local logger = hs.logger.new("window", "info")

local M = {}

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

---Return the first matching window in a given app
---@param winTitle string
---@param negative? boolean
---@return fun(appName:string):hs.window[]
local function winMatcher(winTitle, negative)
  return function(appName)
    local app = hs.application.get(appName)
    if app then
      for _, w in pairs(app:visibleWindows()) do
        if w:title():find(winTitle) and not negative then
          return { w }
        end
        if not w:title():find(winTitle) and negative then
          return { w }
        end
      end
    end
    return {}
  end
end

---Return true if Stage Manager is enabled.
---@return boolean
M.isStageManagerEnabled = function()
  local output =
    hs.execute("/usr/bin/defaults read com.apple.WindowManager GloballyEnabled")
  return util.trim(output) == "1"
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

---@param win hs.window
---@param area 'left'|'right'|'top'|'bottom'
---@param pctOrOffset number 0..1 is a percent, > 1 is a left/top offset
local function fill(win, area, pctOrOffset)
  local screenFrame = win:screen():frame()
  local pad = screenFrame.h * 0.03

  local left = screenFrame.x + pad
  local top = screenFrame.y + pad
  local width = screenFrame.w - 2 * pad
  local height = screenFrame.h - 2 * pad

  if area == 'left' or area == 'right' then
    if pctOrOffset <= 1 then
      width = pctOrOffset * screenFrame.w - 1.5 * pad
    else
      width = screenFrame.w - 1.5 * pad - pctOrOffset
    end
  else
    if pctOrOffset <= 1 then
      height = pctOrOffset * screenFrame.h - 1.5 * pad
    else
      height = screenFrame.h - 1.5 * pad - pctOrOffset
    end
  end

  if area == 'right' then
    if pctOrOffset <= 1 then
      left = screenFrame.x + screenFrame.w * (1 - pctOrOffset) + 0.5 * pad
    else
      left = screenFrame.x + pctOrOffset + 0.5 * pad
    end
  elseif area == 'bottom' then
    if pctOrOffset <= 1 then
      top = screenFrame.y + screenFrame.h * (1 - pctOrOffset) + 0.5 * pad
    else
      top = screenFrame.y + pctOrOffset + 0.5 * pad
    end
  end

  return hs.geometry.rect(left, top, width, height)
end

---@param area 'left'|'right'|'top'|'bottom'
---@param pctOrOffset number 0..1 is a percent, > 1 is a left/top offset
M.frame = function(area, pctOrOffset)
  return function(win)
    return fill(win, area, pctOrOffset)
  end
end

---@alias LayoutFrame {[1]: string, [2]: number} | fun(hs.window): hs.geometry

---Shim over hs.layout.apply with a simpler API
---@param layout {app: string, win: string|{[1]: string, negative?: boolean}|(fun(app:string):hs.window[]), display: string, frame: LayoutFrame}[]
---@return nil
M.layout = function(layout)
  local entries = {}

  for _, e in pairs(layout) do
    local frm = e.frame
    if type(e.frame) == 'table' then
      frm = M.frame(e.frame[1], e.frame[2])
    end

    local win = e.win
    if type(e.win) == 'table' then
      win = winMatcher(e.win[1], e.win.negative)
    end

    entries[#entries + 1] = {
      e.app,
      win,
      e.display,
      nil,
      frm,
      nil,
      options = { absolute_x = true, absolute_y = true },
    }
  end

  logger.i(hs.inspect(entries))

  hs.layout.apply(entries)
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
    windowFrame.w = newWidth
    windowFrame.x = windowFrame.x - (newWidth - oldWidth) / 2
  end

  if increment.height then
    local maxHeight = screenFrame.h - (windowFrame.y - screenFrame.y)
    local oldHeight = windowFrame.h
    local newHeight = math.min(windowFrame.h + increment.height, maxHeight)
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

return M
