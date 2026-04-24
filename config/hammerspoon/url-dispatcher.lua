-- Control which applications URLs load in

hs.loadSpoon("URLDispatcher")

local function openInChromeProfile(profile)
	return function(url)
		local task = hs.task.new(
			"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
			nil,
			function() end,
			{
				"--profile-directory=" .. profile,
				url,
			}
		)

		task:start()
	end
end

local chromeWork = 'Profile 1'

spoon.URLDispatcher.url_patterns = {
  { ".*", nil, openInChromeProfile(chromeWork), "Slack" },
  { ".*", "com.apple.safari" }
}

spoon.URLDispatcher:start()
