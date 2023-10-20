local window = require("window")
local const = require("const")
local raycast = require("raycast")
local settings = require("settings")
local ui = require("ui")

local logger = hs.logger.new("init", "info")

settings.init("settings.json")
raycast.init()

-- Layout the active display
hs.hotkey.bind({ "ctrl", "shift" }, "space", function()
  logger.i("running layout")
  window.layout({
    { app = "Safari", display = "DELL P2715Q", frame = { "left", 0.6 } },
    {
      app = "Wavebox",
      win = { "Wavebox:Main", negative = true },
      display = "DELL P2715Q",
      frame = { "left", 0.6 },
    },
    {
      app = "WezTerm",
      display = "DELL P2715Q",
      frame = { "right", 0.4 },
    },
    {
      app = "Messages",
      display = "Built-in Retina Display",
      frame = { "left", 0.3 },
    },
    {
      app = "Wavebox",
      win = { "Wavebox:Main" },
      display = "Built-in Retina Display",
      frame = { "right", 95 },
    },
    {
      app = "Slack",
      display = "Built-in Retina Display",
      frame = { "right", 95 },
    },
  })
end)

-- Move the active window to the center of the display
hs.hotkey.bind({ "ctrl", "shift" }, "z", function()
  window.moveTo("center")
end)

-- Move the active window to the center of the display
hs.hotkey.bind({ "ctrl", "shift", "alt" }, "z", function()
  local win = hs.window.focusedWindow()
  local frame = win:screen():frame()
  win:setSize({ w = frame.w * 0.7, h = frame.h * 0.8 })
  window.moveTo("center")
end)

-- Make the active window fill the display
hs.hotkey.bind({ "ctrl", "alt", "shift" }, "f", function()
  local win = hs.window.focusedWindow()
  local frame = window.screenFrame(win:screen())
  win:setFrame(frame)
end)

-- Move the active window to the left side of the display
hs.hotkey.bind({ "ctrl", "shift" }, "h", function()
  window.moveTo("left")
end)

-- Fill the left side of the display with the active window
hs.hotkey.bind({ "ctrl", "alt", "shift" }, "h", function()
  window.fill("left")
end)

-- Move the active window to the right side of the display
hs.hotkey.bind({ "ctrl", "shift" }, "l", function()
  window.moveTo("right")
end)

-- Fill the right side of the display with the active window
hs.hotkey.bind({ "ctrl", "alt", "shift" }, "l", function()
  window.fill("right")
end)

-- Move the focus window one space to the right
hs.hotkey.bind({ "ctrl", "shift" }, "right", function()
  window.moveToSpace("next")
end)

-- Move the focus window one space to the left
hs.hotkey.bind({ "ctrl", "shift" }, "left", function()
  window.moveToSpace("prev")
end)

-- Move the focus window one screen to the right
hs.hotkey.bind({ "ctrl", "alt", "shift" }, "right", function()
  hs.window.focusedWindow():moveOneScreenEast()
end)

-- Move the focused window one screen to the left
hs.hotkey.bind({ "ctrl", "alt", "shift" }, "left", function()
  hs.window.focusedWindow():moveOneScreenWest()
end)

-- Make the current window thinner
hs.hotkey.bind({ "ctrl", "shift" }, "[", function()
  window.resize({ width = -const.INCREMENT })
end)

-- Make the current window wider
hs.hotkey.bind({ "ctrl", "shift" }, "]", function()
  window.resize({ width = const.INCREMENT })
end)

-- Make the current window shorter
hs.hotkey.bind({ "ctrl", "shift" }, ";", function()
  window.resize({ height = -const.INCREMENT })
end)

-- Make the current window taller
hs.hotkey.bind({ "ctrl", "shift" }, "'", function()
  window.resize({ height = const.INCREMENT })
end)

-- Reload the Hammerspoon config
hs.hotkey.bind({ "ctrl", "shift" }, "r", function()
  hs.reload()
end)

hs.hotkey.bind({ "ctrl", "alt", "shift", "cmd" }, "up", function()
  hs.http.asyncPost(
    hs.settings.get('hass_url') .. "/api/events/mac_script",
    '{"service":"media_player.volume_up","entity":"media_player.'
      .. hs.settings.get("media_player")
      .. '"}',
    {
      ["Content-Type"] = "application/json",
      Authorization = "Bearer " .. hs.settings.get("hass_token"),
    },
    function() end
  )
end)

hs.hotkey.bind({ "ctrl", "alt", "shift", "cmd" }, "down", function()
  hs.http.asyncPost(
    hs.settings.get('hass_url') .. "/api/events/mac_script",
    '{"service":"media_player.volume_down","entity":"media_player.'
      .. hs.settings.get("media_player")
      .. '"}',
    {
      ["Content-Type"] = "application/json",
      Authorization = "Bearer " .. hs.settings.get("hass_token"),
    },
    function() end
  )
end)

hs.hotkey.bind({ "ctrl", "alt", "shift", "cmd" }, "right", function()
  hs.http.asyncPost(
    hs.settings.get('hass_url') .. "/api/events/mac_script",
    '{"service":"media_player.media_play_pause","entity":"media_player.'
      .. hs.settings.get("media_player")
      .. '"}',
    {
      ["Content-Type"] = "application/json",
      Authorization = "Bearer " .. hs.settings.get("hass_token"),
    },
    function() end
  )
end)

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

hs.hotkey.bind({ "ctrl", "shift" }, "m", ui.mouseHighlight)

hs.alert.show("Hammerspoon config loaded")
