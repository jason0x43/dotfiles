local window = require("window")

local updateDebounceTimer
local function updateStageManager()
	local delay = 1
	if updateDebounceTimer then
		updateDebounceTimer:stop()
	end

	updateDebounceTimer = hs.timer.doAfter(delay, function()
    local screens = hs.screen.allScreens()

    if #screens > 1 and window.isStageManagerEnabled() then
      hs.alert.show("Disabling Stage Manager")
      window.setStageManagerEnabled(false)
    elseif #screens == 1 and not window.isStageManagerEnabled() then
      hs.alert.show("Enabling Stage Manager")
      window.setStageManagerEnabled(true)
    end

		updateDebounceTimer = nil
	end)
end

-- Update Stage Manager state on display layout changes
if not MonitorWatcher then
	MonitorWatcher = hs.screen.watcher
		.new(function()
			updateStageManager()
		end)
		:start()
end

-- Update Stage Manager state when macBook wakes
if not PowerWatcher then
	PowerWatcher = hs.caffeinate.watcher
		.new(function(event)
			if
				event == hs.caffeinate.watcher.systemDidWake
				or event == hs.caffeinate.watcher.screensDidWake
			then
				updateStageManager()
			end
		end)
		:start()
end
