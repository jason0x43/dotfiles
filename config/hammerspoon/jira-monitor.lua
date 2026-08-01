---@module "user.types.hammerspoon"

local util = require("util")

-- jira-monitor writes status next to its cache under the state dir.
local STATUS_DIR = os.getenv("HOME") .. "/.local/state/jira-monitor"
local STATUS_PATH = STATUS_DIR .. "/status.json"
local STATE_DIR = os.getenv("HOME") .. "/.local/state/hammerspoon"
local STATE_PATH = STATE_DIR .. "/jira-monitor.json"
local REFRESH_INTERVAL_SECONDS = 60
local ICON_WIDTH = 18
local ICON_HEIGHT = 18
local REASON_ICON_SIZE = 14
local SUMMARY_MAX = 56

---@alias JiraRelevantReason "assignment" | "unassignment" | "mention" | "comment" | "update"

---@class JiraStatusIssue
---@field key string
---@field summary string
---@field status string
---@field url string
---@field assigneeAccountId string | nil
---@field categories string[]
---@field lastRelevantEventId string
---@field lastRelevantAt string
---@field lastRelevantReason JiraRelevantReason

---@class JiraStatusFile
---@field polledAt string
---@field account { accountId: string }
---@field counts table
---@field issues JiraStatusIssue[]

local notifyIcon =
	util.loadImage("jira-notify.svg"):setSize({ h = ICON_HEIGHT, w = ICON_WIDTH })
---@cast notifyIcon hs.image

---@param path string
---@return hs.image | nil
local function loadReasonIcon(path)
	local ok, icon = pcall(function()
		local image = util.loadImage(path):setSize({
			h = REASON_ICON_SIZE,
			w = REASON_ICON_SIZE,
		})
		---@cast image hs.image
		image:template(true)
		return image
	end)
	if ok then
		return icon
	end
	return nil
end

---Icons keyed by lastRelevantReason (what caused the issue to surface).
local reasonIcons = {
	comment = loadReasonIcon("jira-reason-comment.svg"),
	mention = loadReasonIcon("jira-reason-mention.svg"),
	assignment = loadReasonIcon("jira-reason-assignment.svg"),
	unassignment = loadReasonIcon("jira-reason-unassignment.svg"),
	update = loadReasonIcon("jira-reason-update.svg"),
}

local reasonTooltips = {
	comment = "New comment",
	mention = "Mentioned",
	assignment = "Assigned",
	unassignment = "Unassigned",
	update = "Updated",
}

local M = {
	---@type hs.menubar | nil
	menubar = nil,
	---@type hs.pathwatcher | nil
	watcher = nil,
	---@type hs.timer | nil
	timer = nil,
	---@type JiraStatusIssue[]  Issues from status.json (all tracked).
	allIssues = {},
	---@type JiraStatusIssue[]  Unseen subset shown in the menu.
	issues = {},
	---Map of issue key -> lastRelevantEventId value that was marked seen.
	---@type table<string, string>
	seen = {},
	---@type string | nil
	renderedSignature = nil,
}

---@param path string
---@return table | nil
local function readJsonFile(path)
	local file = io.open(path, "r")
	if not file then
		return nil
	end

	local content = file:read("*a")
	file:close()

	if type(content) ~= "string" or content == "" then
		return nil
	end

	return hs.json.decode(content)
end

---@param path string
local function ensureDir(path)
	if hs.fs.attributes(path) then
		return
	end

	local parent = path:match("(.+)/[^/]+$")
	if parent and parent ~= "" and parent ~= "/" then
		ensureDir(parent)
	end

	hs.fs.mkdir(path)
end

---True for event ids published by the daemon (`comment:123`, `history:456`).
---@param value string
---@return boolean
local function isEventId(value)
	return value:find("^[%w]+:") ~= nil
end

local function loadState()
	local state = readJsonFile(STATE_PATH)
	if type(state) ~= "table" or type(state.seen) ~= "table" then
		M.seen = {}
		return
	end

	local seen = {}
	for key, eventId in pairs(state.seen) do
		-- Drop pre-migration entries keyed on ISO timestamps.
		if type(key) == "string" and type(eventId) == "string" and isEventId(eventId) then
			seen[key] = eventId
		end
	end
	M.seen = seen
end

local function saveState()
	ensureDir(STATE_DIR)
	hs.json.write({ seen = M.seen }, STATE_PATH, true, true)
end

---@param value string | nil
---@param max integer
---@return string
local function truncate(value, max)
	if type(value) ~= "string" or value == "" then
		return ""
	end
	if #value <= max then
		return value
	end
	return value:sub(1, max - 1) .. "…"
end

---Parse a daemon ISO-8601 UTC timestamp to epoch seconds.
---@param iso string
---@return number | nil
local function parseIsoUtc(iso)
	local y, mo, d, h, mi, s = iso:match("^(%d+)%-(%d+)%-(%d+)T(%d+):(%d+):(%d+)")
	if not y then
		return nil
	end

	-- os.time interprets fields as local time; subtract the local-UTC offset.
	local asLocal = os.time({
		year = tonumber(y),
		month = tonumber(mo),
		day = tonumber(d),
		hour = tonumber(h),
		min = tonumber(mi),
		sec = tonumber(s),
		isdst = false,
	})
	if type(asLocal) ~= "number" then
		return nil
	end

	local now = os.time()
	local utcNow = os.date("!*t", now)
	local offset = os.difftime(
		now,
		os.time({
			year = utcNow.year,
			month = utcNow.month,
			day = utcNow.day,
			hour = utcNow.hour,
			min = utcNow.min,
			sec = utcNow.sec,
			isdst = false,
		})
	)
	return asLocal - offset
end

---Compact relative age for menu titles (e.g. "3w", "2d", "5h").
---@param iso string | nil
---@return string
local function formatAge(iso)
	if type(iso) ~= "string" or iso == "" then
		return ""
	end

	local eventTime = parseIsoUtc(iso)
	if type(eventTime) ~= "number" then
		return ""
	end

	local ageSec = math.max(0, os.time() - eventTime)

	if ageSec < 60 then
		return "now"
	end
	if ageSec < 3600 then
		return string.format("%dm", math.floor(ageSec / 60))
	end
	if ageSec < 86400 then
		return string.format("%dh", math.floor(ageSec / 3600))
	end
	if ageSec < 86400 * 14 then
		return string.format("%dd", math.floor(ageSec / 86400))
	end
	if ageSec < 86400 * 60 then
		return string.format("%dw", math.floor(ageSec / (86400 * 7)))
	end
	return string.format("%dmo", math.floor(ageSec / (86400 * 30)))
end

---@param issue JiraStatusIssue
---@return boolean
local function isUnseen(issue)
	local seenId = M.seen[issue.key]
	if type(seenId) ~= "string" then
		return true
	end
	return seenId ~= issue.lastRelevantEventId
end

---Prune seen entries for keys no longer present in status, then persist.
---Only call after a successful status parse — never with an empty/failed read,
---or a mid-write of status.json will wipe seen state and resurface everything.
---@param issues JiraStatusIssue[]
local function pruneSeen(issues)
	if #issues == 0 then
		return
	end

	local present = {}
	for _, issue in ipairs(issues) do
		present[issue.key] = true
	end

	local changed = false
	for key in pairs(M.seen) do
		if not present[key] then
			M.seen[key] = nil
			changed = true
		end
	end

	if changed then
		saveState()
	end
end

---@param issue JiraStatusIssue
local function markSeen(issue)
	if
		type(issue.key) ~= "string"
		or type(issue.lastRelevantEventId) ~= "string"
		or issue.lastRelevantEventId == ""
	then
		return
	end
	M.seen[issue.key] = issue.lastRelevantEventId
	saveState()
end

local function markAllSeen()
	local changed = false
	for _, issue in ipairs(M.allIssues) do
		if
			type(issue.key) == "string"
			and type(issue.lastRelevantEventId) == "string"
			and issue.lastRelevantEventId ~= ""
			and M.seen[issue.key] ~= issue.lastRelevantEventId
		then
			M.seen[issue.key] = issue.lastRelevantEventId
			changed = true
		end
	end
	if changed then
		saveState()
	end
end

---@param issues JiraStatusIssue[]
---@return table[]
local function buildMenu(issues)
	local menu = {}

	for _, issue in ipairs(issues) do
		local summary = truncate(issue.summary, SUMMARY_MAX)
		local age = formatAge(issue.lastRelevantAt)
		local title = issue.key
		if summary ~= "" and age ~= "" then
			title = string.format("%s  %s  · %s", issue.key, summary, age)
		elseif summary ~= "" then
			title = string.format("%s  %s", issue.key, summary)
		elseif age ~= "" then
			title = string.format("%s  · %s", issue.key, age)
		end

		local reason = issue.lastRelevantReason
		table.insert(menu, {
			title = title,
			image = reasonIcons[reason],
			tooltip = reasonTooltips[reason],
			fn = function()
				if type(issue.url) == "string" and issue.url ~= "" then
					hs.urlevent.openURL(issue.url)
				end
				markSeen(issue)
				M.refresh()
			end,
		})
	end

	table.insert(menu, { title = "-" })
	table.insert(menu, {
		title = "Clear All",
		fn = function()
			markAllSeen()
			M.refresh()
		end,
	})

	return menu
end

---@param issues JiraStatusIssue[]
---@return string
local function issuesSignature(issues)
	local parts = {}
	for i, issue in ipairs(issues) do
		parts[i] = table.concat({
			issue.key or "",
			issue.lastRelevantEventId or "",
			issue.lastRelevantAt or "",
			issue.lastRelevantReason or "",
			issue.summary or "",
			issue.url or "",
		}, "\0")
	end
	return table.concat(parts, "\n")
end

local function removeMenubar()
	if not M.menubar then
		return
	end

	M.menubar:delete()
	M.menubar = nil
	M.renderedSignature = nil
end

---@return hs.menubar
local function ensureMenubar()
	if M.menubar then
		return M.menubar
	end

	local item = hs.menubar.new(true, "jira-monitor")
	if not item then
		error("Failed to create jira-monitor menubar item")
	end

	item:setTooltip("Jira monitor")
	item:setMenu(function()
		return buildMenu(M.issues)
	end)

	M.menubar = item
	-- Force icon apply on the next refresh after recreating the menubar.
	M.renderedSignature = nil
	return item
end

function M.refresh()
	local status = readJsonFile(STATUS_PATH)
	-- status.json is written in place; a pathwatcher tick mid-write can yield
	-- nil/invalid JSON. Keep the previous menu and seen map in that case.
	if type(status) ~= "table" or type(status.issues) ~= "table" then
		return
	end

	local allIssues = {}
	for _, issue in ipairs(status.issues) do
		if
			type(issue) == "table"
			and type(issue.key) == "string"
			and type(issue.lastRelevantEventId) == "string"
			and issue.lastRelevantEventId ~= ""
		then
			table.insert(allIssues, issue)
		end
	end

	pruneSeen(allIssues)
	M.allIssues = allIssues

	local visible = {}
	for _, issue in ipairs(allIssues) do
		if isUnseen(issue) then
			table.insert(visible, issue)
		end
	end

	local signature = issuesSignature(visible)
	M.issues = visible

	if #visible == 0 then
		removeMenubar()
		return
	end

	local item = ensureMenubar()
	item:returnToMenuBar()
	if signature == M.renderedSignature then
		return
	end

	M.renderedSignature = signature
	item:setIcon(notifyIcon)
end

---Debounce pathwatcher callbacks so we read after the daemon finishes writing.
---@type hs.timer | nil
local refreshDebounce = nil

local function scheduleRefresh()
	if refreshDebounce then
		refreshDebounce:stop()
	end
	refreshDebounce = hs.timer.doAfter(0.4, function()
		refreshDebounce = nil
		M.refresh()
	end)
end

ensureDir(STATUS_DIR)
ensureDir(STATE_DIR)
loadState()
M.refresh()

M.watcher = hs.pathwatcher.new(STATUS_DIR, scheduleRefresh):start()
-- Pathwatcher alone can miss writes (sleep/wake, coalesced FSEvents, mid-write
-- reads that bail). Poll periodically so unseen issues still surface.
M.timer = hs.timer.doEvery(REFRESH_INTERVAL_SECONDS, function()
	M.refresh()
end)

return M
