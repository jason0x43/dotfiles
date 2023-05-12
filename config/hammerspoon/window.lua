local const = require("const")
local util = require("util")

local logger = hs.logger.new("window", "info")

local M = {}

---Return the screen frame with edge padding
---@param screen hs.screen
---@return hs.geometry frame
---@return integer padding
local function getScreenFrame(screen)
  local frame = screen:frame()
  local pad = frame.h * 0.03
  return hs.geometry.rect(
    frame.x + pad,
    frame.y + pad,
    frame.w - 2 * pad,
    frame.h - 2 * pad
  ), pad
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

---Resize the focused window to fill an area
---@param area 'left'|'right'|'top'|'bottom'
---@param pctOrOffset number 0..1 is a percent, > 1 is a left/top offset
---@param win? hs.window
local function fill(area, pctOrOffset, win)
  win = win or hs.window.focusedWindow()
  local screenFrame, pad = getScreenFrame(win:screen())

  local left = screenFrame.x
  local top = screenFrame.y
  local width = screenFrame.w
  local height = screenFrame.h

  if area == "left" or area == "right" then
    if pctOrOffset <= 1 then
      width = pctOrOffset * screenFrame.w - 0.5 * pad
    else
      width = screenFrame.w - pctOrOffset
    end
  else
    if pctOrOffset <= 1 then
      height = pctOrOffset * screenFrame.h - 1.5 * pad
    else
      height = screenFrame.h - pctOrOffset
    end
  end

  if area == "right" then
    if pctOrOffset <= 1 then
      left = screenFrame.x + screenFrame.w * (1 - pctOrOffset) + 0.5 * pad
    else
      left = screenFrame.x + pctOrOffset
    end
  elseif area == "bottom" then
    if pctOrOffset <= 1 then
      top = screenFrame.y + screenFrame.h * (1 - pctOrOffset)
    else
      top = screenFrame.y + pctOrOffset + 0.5 * pad
    end
  end

  return hs.geometry.rect(left, top, width, height)
end

---@param area 'left'|'right'|'top'|'bottom'
---@param pctOrOffset number 0..1 is a percent, > 1 is a left/top offset
local function frame(area, pctOrOffset)
  return function(win)
    return fill(area, pctOrOffset, win)
  end
end

---Return the padded frame for a screen
---@param screen hs.screen
---@return hs.geometry
M.screenFrame = function(screen)
  local f = getScreenFrame(screen)
  return f
end

---Return true if Stage Manager is enabled.
---@return boolean
M.isStageManagerEnabled = function()
  local output =
    hs.execute("/usr/bin/defaults read com.apple.WindowManager GloballyEnabled")
  return util.trim(output) == "1"
end

---@param area 'left'|'right'|'center'
---@param options? { window?: hs.window, portion?: number, width?: number, widthMinus?: number }
M.fill = function(area, options)
  options = options or {}
  local window = options.window or hs.window.focusedWindow()
  local width = options.width
  local portion = options.portion
  local widthMinus = options.widthMinus

  local screenFrame = window:screen():frame()
  local isLargeScreen = screenFrame.w > 2000
  local winFrame = window:frame()
  local pad = screenFrame.h * 0.03

  if portion then
    width = screenFrame.w * portion
  elseif widthMinus then
    width = screenFrame.w - widthMinus
  end

  if width == nil then
    width = screenFrame.w / 2
  end

  ---@type {h: number, w: number, x: number, y: number}
  local bounds = {}

  -- size
  if area == const.LEFT or area == const.RIGHT then
    bounds.h = screenFrame.h
    bounds.w = width
  else
    bounds.h = screenFrame.h / 2
    bounds.w = screenFrame.w / 2
  end

  winFrame.h = bounds.h
  winFrame.w = bounds.w

  if isLargeScreen then
    if area == const.LEFT or area == const.RIGHT then
      winFrame.h = screenFrame.h - 2 * pad
      winFrame.w = winFrame.w - 2 * pad
    end
  end

  -- x-coordinate
  if area == const.LEFT then
    winFrame.x = screenFrame.x + pad
  elseif area == const.RIGHT then
    winFrame.x = screenFrame.x
      + (screenFrame.w - bounds.w)
      + (bounds.w - winFrame.w - const.PADDING) / 2
  else
    winFrame.x = screenFrame.x + (screenFrame.w / 2 - bounds.w / 2)
  end

  -- y-coordinate
  if area == const.LEFT or area == const.RIGHT then
    winFrame.y = screenFrame.y + pad
  else
    winFrame.y = screenFrame.y + (screenFrame.h / 2 - bounds.h / 2)
  end

  window:setFrame(winFrame)
end

---Move the focused window to an area
---@param area 'left'|'right'|'center'
---@return hs.window
M.moveTo = function(area)
  local win = hs.window.focusedWindow()
  local winFrame = win:frame()
  local screenFrame = getScreenFrame(win:screen())

  if area == 'left' then
    winFrame.x = screenFrame.x
  elseif area == 'center' then
    winFrame.x = screenFrame.x + (screenFrame.w - winFrame.w) / 2
    winFrame.y = screenFrame.y + (screenFrame.h - winFrame.h) / 2
  elseif area == 'right' then
    winFrame.x = screenFrame.x + (screenFrame.w - winFrame.w)
  end

  win:setFrame(winFrame)
  return win
end

---Move the focused window to a space
---@param hint integer|'next'|'prev'
M.moveToSpace = function(hint)
  local win = hs.window.focusedWindow()
  local winId = win:id()
  if winId == nil then
    logger.w("Couldn't get ID of focused window")
    return
  end

  ---@type integer
  local spaceId

  if type(hint) == "number" then
    spaceId = hint
  else
    local spaceIds = hs.spaces.spacesForScreen()
    if not spaceIds then
      logger.w("Couldn't get list of space IDs")
      return
    end
    local currentSpaceId = hs.spaces.focusedSpace()
    local idx = util.indexOf(spaceIds, currentSpaceId)
    if not idx then
      logger.w("Couldn't find " .. currentSpaceId .. " in " .. spaceIds)
      return
    end

    if hint == "next" then
      idx = idx + 1
      if idx == #spaceIds then
        idx = 1
      end
    elseif hint == "prev" then
      idx = idx - 1
      if idx == 0 then
        idx = #spaceIds
      end
    end

    spaceId = spaceIds[idx]
  end

  hs.spaces.moveWindowToSpace(winId, spaceId)
  win:focus()
end

---@alias LayoutFrame {[1]: string, [2]: number} | (fun(hs.window): hs.geometry)

---Shim over hs.layout.apply with a simpler API
---@param layout {app: string, win: string | {[1]: string, negative?: boolean} | (fun(app:string):hs.window[]), display: string, frame: LayoutFrame}[]
---@return nil
M.layout = function(layout)
  ---@type LayoutEntry[]
  local entries = {}

  for _, e in pairs(layout) do
    local frm = e.frame
    if type(e.frame) == "table" then
      frm = frame(e.frame[1], e.frame[2])
    end

    local win = e.win
    if type(e.win) == "table" then
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

  hs.layout.apply(entries)
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
