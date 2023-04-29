local win = require("window")
local const = require("const")
local raycast = require("raycast")

local logger = hs.logger.new("init", "info")

raycast.init()

-- Layout the active display
hs.hotkey.bind({ "ctrl", "shift" }, "space", function()
  win.layout({
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
      win = "Wavebox:Main",
      display = "Built-in Retina Display",
      frame = { "right", 110 },
    },
  })
end)

-- Move the active window to the center of the display
hs.hotkey.bind({ "ctrl", "shift" }, "z", function()
  win.moveTo("center")
end)

-- Move the active window to the center of the display
hs.hotkey.bind({ "ctrl", "shift" }, "h", function()
  win.moveTo("left")
end)

-- Move the active window to the center of the display
hs.hotkey.bind({ "ctrl", "shift" }, "l", function()
  win.moveTo("right")
end)

-- Move the focuse window one screen to the right
hs.hotkey.bind({ "ctrl", "shift" }, "right", function()
  win.moveToSpace("next")
end)

-- Move the focuse window one screen to the left
hs.hotkey.bind({ "ctrl", "shift" }, "left", function()
  win.moveToSpace("prev")
end)

-- Make the current window thinner
hs.hotkey.bind({ "ctrl", "shift" }, "[", function()
  win.resize({ width = -const.INCREMENT })
end)

-- Make the current window wider
hs.hotkey.bind({ "ctrl", "shift" }, "]", function()
  win.resize({ width = const.INCREMENT })
end)

-- Make the current window shorter
hs.hotkey.bind({ "ctrl", "shift" }, ";", function()
  win.resize({ height = -const.INCREMENT })
end)

-- Make the current window taller
hs.hotkey.bind({ "ctrl", "shift" }, "'", function()
  win.resize({ height = const.INCREMENT })
end)

-- Reload the Hammerspoon config
hs.hotkey.bind({ "ctrl", "shift" }, "r", function()
  hs.reload()
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

hs.alert.show("Hammerspoon config loaded")
