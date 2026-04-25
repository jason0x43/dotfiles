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

local chromeWork = "Profile 1"
local workUrls = hs.settings.get("workUrls")

spoon.URLDispatcher.url_patterns = {}

if workUrls then
	for _, entry in ipairs(workUrls) do
		local urlPattern = { entry.pattern, nil, openInChromeProfile(chromeWork) }
		if entry.app then
			table.insert(urlPattern, entry.app)
		end
		table.insert(spoon.URLDispatcher.url_patterns, urlPattern)
	end
end

table.insert(spoon.URLDispatcher.url_patterns, { ".*", "com.apple.safari" })

spoon.URLDispatcher:start()
