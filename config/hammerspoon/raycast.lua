local M = {}

M.init = function()
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

  if raycastEscape == nil or raycastCmdW == nil then
    hs.alert.show("Error creating Raycast hotkeys")
  else
    -- Watch for the Raycast popup to en/disable the Raycast hotkey overrides
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
end

return M
