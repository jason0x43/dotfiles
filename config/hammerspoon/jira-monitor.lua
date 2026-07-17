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
local SUMMARY_MAX = 64

---@alias JiraRelevantReason "assignment" | "mention" | "comment"

---@class JiraStatusIssue
---@field key string
---@field summary string
---@field status string
---@field url string
---@field categories string[]
---@field lastRelevantAt string
---@field lastRelevantReason JiraRelevantReason

---@class JiraStatusFile
---@field polledAt string
---@field account table
---@field counts table
---@field issues JiraStatusIssue[]

local notifyIcon =
	util.loadImage("jira-notify.svg"):setSize({ h = ICON_HEIGHT, w = ICON_WIDTH })
---@cast notifyIcon hs.image

---@param path string
---@return hs.image
local function loadReasonIcon(path)
	local icon = util.loadImage(path):setSize({
		h = REASON_ICON_SIZE,
		w = REASON_ICON_SIZE,
	})
	---@cast icon hs.image
	icon:template(true)
	return icon
end

---Icons keyed by lastRelevantReason (what caused the issue to surface).
local reasonIcons = {
	comment = loadReasonIcon("jira-reason-comment.svg"),
	mention = loadReasonIcon("jira-reason-mention.svg"),
	assignment = loadReasonIcon("jira-reason-assignment.svg"),
}

local reasonTooltips = {
	comment = "New comment",
	mention = "Mentioned",
	assignment = "Assigned",
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
	---Map of issue key -> lastRelevantAt value that was marked seen.
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

local function loadState()
	local state = readJsonFile(STATE_PATH)
	if type(state) ~= "table" or type(state.seen) ~= "table" then
		M.seen = {}
		return
	end

	local seen = {}
	for key, lastRelevantAt in pairs(state.seen) do
		if type(key) == "string" and type(lastRelevantAt) == "string" then
			seen[key] = lastRelevantAt
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

---@param issue JiraStatusIssue
---@return boolean
local function isUnseen(issue)
	local seenAt = M.seen[issue.key]
	if type(seenAt) ~= "string" then
		return true
	end
	return seenAt ~= issue.lastRelevantAt
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
	if type(issue.key) ~= "string" or type(issue.lastRelevantAt) ~= "string" then
		return
	end
	M.seen[issue.key] = issue.lastRelevantAt
	saveState()
end

local function markAllSeen()
	local changed = false
	for _, issue in ipairs(M.allIssues) do
		if
			type(issue.key) == "string"
			and type(issue.lastRelevantAt) == "string"
			and M.seen[issue.key] ~= issue.lastRelevantAt
		then
			M.seen[issue.key] = issue.lastRelevantAt
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
		local title = issue.key
		if summary ~= "" then
			title = string.format("%s  %s", issue.key, summary)
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
		if type(issue) == "table" and type(issue.key) == "string" then
			table.insert(allIssues, issue)
		end
	end

	M.allIssues = allIssues
	pruneSeen(allIssues)

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
