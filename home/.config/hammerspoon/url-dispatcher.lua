-- Control which applications URLs load in

hs.loadSpoon("URLDispatcher")

-- Work URLs open in a separate Chrome instance that sends everything through
-- the bcvpn proxy (the containerized BCRV VPN; see bcvpn-status.lua and
-- /Applications/Chrome Work.app). It has its own user data directory because
-- Chrome only reads --proxy-server when an instance starts.
local VPN_CHROME_DIR = os.getenv("HOME")
	.. "/Library/Application Support/Google/Chrome-Work"
local VPN_PROXY = "http://127.0.0.1:8888"

---Warn when bcvpn isn't connected, since pages won't load until it is.
local function warnIfVpnDown()
	local bcvpn = package.loaded["bcvpn-status"]
	local status = bcvpn and bcvpn.state and bcvpn.state.status
	if status and status ~= "connected" then
		hs.notify
			.new({
				title = "bcvpn isn't connected",
				informativeText = "Work links open in VPN Chrome, which can't load pages until bcvpn connects.",
			})
			:send()
	end
end

---Open a URL in the VPN Chrome. If it's running, Chrome hands the URL to it;
---otherwise this starts it with the proxy flags. `open` makes launchd, not
---Hammerspoon, the parent of a newly started Chrome.
---@param url string
local function openInVpnChrome(url)
	warnIfVpnDown()
	hs.task
		.new("/usr/bin/open", nil, {
			"-na",
			"Google Chrome",
			"--args",
			"--user-data-dir=" .. VPN_CHROME_DIR,
			"--proxy-server=" .. VPN_PROXY,
			"--no-first-run",
			"--no-default-browser-check",
			url,
		})
		:start()
end

local workUrls = hs.settings.get("workUrls")
---@cast workUrls { pattern: string, app?: string }[] | nil

spoon.URLDispatcher.url_patterns = {}

if workUrls then
	for _, entry in ipairs(workUrls) do
		local urlPattern = { entry.pattern, nil, openInVpnChrome }
		if entry.app then
			table.insert(urlPattern, entry.app)
		end
		table.insert(spoon.URLDispatcher.url_patterns, urlPattern)
	end
end

table.insert(spoon.URLDispatcher.url_patterns, { ".*", "com.apple.safari" })

spoon.URLDispatcher:start()
