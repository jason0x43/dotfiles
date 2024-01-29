local window = require("window")
local const = require("const")
local raycast = require("raycast")
local settings = require("settings")
local ui = require("ui")

local logger = hs.logger.new("init", "info")
local monitor = "PHL 272P7VU"

settings.init("settings.json")
raycast.init()

hs.application.enableSpotlightForNameSearches(true)

---@param apps hs.application[]
---@param name string
local function contains_app(apps, name)
  for _, app in pairs(apps) do
    if app:name() == name then
      return true
    end
  end
  return false
end

-- Layout the active display
hs.hotkey.bind({ "ctrl", "shift" }, "space", function()
  local layout = {}
  local layouts = {
    Safari = { app = "Safari", display = monitor, frame = { "left", 0.6 } },
    Chrome = { app = "Chrome", display = monitor, frame = { "left", 0.6 } },
    WezTerm = { app = "WezTerm", display = monitor, frame = { "right", 0.4 } },
    Messages = {
      app = "Messages",
      display = "Built-in Retina Display",
      frame = { "left", 0.3 },
    },
    Slack = {
      app = "Slack",
      display = "Built-in Retina Display",
      frame = { "right", 95 },
    },
  }

  if window.isStageManagerEnabled() then
    layouts = {
      Safari = { app = "Safari", display = monitor, frame = { "right", 0.9 } },
      Chrome = { app = "Chrome", display = monitor, frame = { "right", 0.9 } },
      Fastmail = {
        app = "Fastmail",
        display = monitor,
        frame = { "right", 0.9 },
      },
      WezTerm = {
        app = "WezTerm",
        display = monitor,
        frame = { "center", 0.6 },
      },
      Messages = {
        app = "Messages",
        display = "Built-in Retina Display",
        frame = { "right", 0.6 },
      },
      Slack = {
        app = "Slack",
        display = "Built-in Retina Display",
        frame = { "right", 95 },
      },
    }
  end

  local apps = hs.application.runningApplications()

  if contains_app(apps, "Safari") then
    table.insert(layout, layouts.Safari)
  end

  if contains_app(apps, "Chrome") then
    table.insert(layout, layouts.Chrome)
  end

  if contains_app(apps, "Fastmail") then
    table.insert(layout, layouts.Fastmail)
  end

  if contains_app(apps, "WezTerm") then
    table.insert(layout, layouts.WezTerm)
  end

  if contains_app(apps, "Messages") then
    table.insert(layout, layouts.Messages)
  end

  if contains_app(apps, "Slack") then
    table.insert(layout, layouts.Slack)
  end

  window.layout(layout)
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
    hs.settings.get("hass_url") .. "/api/events/mac_script",
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
    hs.settings.get("hass_url") .. "/api/events/mac_script",
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
    hs.settings.get("hass_url") .. "/api/events/mac_script",
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
