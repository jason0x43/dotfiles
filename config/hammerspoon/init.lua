local win = require("window")
local const = require("const")
local raycast = require("raycast")

local logger = hs.logger.new("init", "info")

raycast.setup()

-- Layout the active display
hs.hotkey.bind({ "ctrl", "shift" }, "space", function()
  win.layout()
end)

-- Move the active window to the center of the display
hs.hotkey.bind({ "ctrl", "shift" }, "z", function()
  win.moveTo(const.CENTER)
end)

-- Make the current window thinner
hs.hotkey.bind({ "ctrl", "shift" }, "[", function()
  win.resize({ width = -win.widthPercent(const.INCREMENT) })
end)

-- Make the current window wider
hs.hotkey.bind({ "ctrl", "shift" }, "]", function()
  win.resize({ width = win.widthPercent(const.INCREMENT) })
end)

-- Make the current window shorter
hs.hotkey.bind({ "ctrl", "shift" }, ";", function()
  win.resize({ height = -win.heightPercent(const.INCREMENT) })
end)

-- Make the current window taller
hs.hotkey.bind({ "ctrl", "shift" }, "'", function()
  win.resize({ height = win.heightPercent(const.INCREMENT) })
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
