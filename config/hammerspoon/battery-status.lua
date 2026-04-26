---@module "user.types.hammerspoon"

---@class BatteryStatusSensor
---@field entity_id string
---@field state string
---@field attributes table<string, any>

---@class MenuItem
---@field title string | hs.styledtext
---@field disabled boolean | nil
---@field fn function | nil

local util = require("util")

local FALLBACK_REFRESH_INTERVAL_SECONDS = 1800
local WEBSOCKET_RECONNECT_DELAY_SECONDS = 10
local LOW_BATTERY_THRESHOLD_PERCENT = 25
local ICON_WIDTH = 18
local ICON_HEIGHT = 18
local ENTITY_REGISTRY_REQUEST_ID = 1
local STATE_CHANGED_SUBSCRIPTION_ID = 2

local defaultIcon =
	util.loadImage("battery.svg"):setSize({ h = ICON_HEIGHT, w = ICON_WIDTH })
local lowBatteryIcon =
	util.loadImage("battery-low.svg"):setSize({ h = ICON_HEIGHT, w = ICON_WIDTH })

local M = {
	sensors = {},
	---@type table<string, string | nil>
	entityDeviceIds = {},
	---@type integer | nil
	lastUpdated = nil,
	---@type string | nil
	lastError = nil,
	---@type boolean
	isRefreshing = false,
	---@type hs.websocket | nil
	websocket = nil,
	---@type hs.timer | nil
	websocketReconnectTimer = nil,
}

---@return hs.menubar
local function createMenu()
	local menu = hs.menubar.new()
	if not menu then
		error("Failed to create menubar item")
	end
	return menu
end

---@return string
local function hassUrl()
	return "https://homeassistant.local"
end

---@return string
local function hassWebsocketUrl()
	return hassUrl():gsub("^http", "ws") .. "/api/websocket"
end

---@return string | nil, string | nil
local function hassToken()
	local token = hs.settings.get("hassToken")
	if not token then
		return nil, "Missing Home Assistant token setting (hassToken or hass_token)"
	end

	return token, nil
end

---@return table<string, string> | nil, string | nil
local function buildHeaders()
	local token, tokenError = hassToken()
	if not token then
		return nil, tokenError
	end

	return {
		Authorization = "Bearer " .. token,
		["Content-Type"] = "application/json",
	},
		nil
end

---@param entity table
---@return boolean
---@return_cast entity BatteryStatusSensor
local function isBatterySensor(entity)
	local attrs = entity.attributes or {}
	if attrs.device_class == "battery" then
		return true
	end

	return entity.entity_id:find("battery", 1, true) ~= nil
end

---@param entity BatteryStatusSensor
---@return string
local function sensorName(entity)
	local attrs = entity.attributes or {}
	return attrs.friendly_name or entity.entity_id
end

---@param entity BatteryStatusSensor
---@return boolean
local function shouldHideSensor(entity)
	local state = tostring(entity.state)
	local name = sensorName(entity):lower()
	local entityId = entity.entity_id:lower()

	return state == "unavailable"
		or state == "unknown"
		or name:find("battery state", 1, true) ~= nil
		or entityId:find("battery_state", 1, true) ~= nil
end

---@param entity BatteryStatusSensor
---@return boolean
local function hasPercentageUnit(entity)
	local attrs = entity.attributes or {}
	return attrs.unit_of_measurement == "%"
end

---@param entity BatteryStatusSensor
---@return number | nil
local function batteryPercent(entity)
	if not hasPercentageUnit(entity) then
		return nil
	end

	return tonumber(entity.state)
end

---@param entity table
---@return boolean
local function shouldDisplaySensor(entity)
	return type(entity) == "table"
		and type(entity.entity_id) == "string"
		and isBatterySensor(entity)
		and hasPercentageUnit(entity)
		and not shouldHideSensor(entity)
end

---@param entity BatteryStatusSensor
---@return string
local function sensorStatus(entity)
	local attrs = entity.attributes or {}
	local state = tostring(entity.state)
	local unit = attrs.unit_of_measurement
	local numericState = tonumber(state)

	if
		numericState ~= nil
		and type(unit) == "string"
		and unit ~= ""
		and not state:find(unit, 1, true)
	then
		return string.format("%s%s", state, unit)
	end

	return state
end

---@param entity BatteryStatusSensor
---@return string | hs.styledtext
local function sensorMenuTitle(entity)
	local title =
		string.format("%s: %s", sensorName(entity), sensorStatus(entity))
	local percent = batteryPercent(entity)
	if percent == nil or percent > LOW_BATTERY_THRESHOLD_PERCENT then
		return title
	end

	local text = hs.styledtext.new(title, {
		color = { red = 1, green = 0.23, blue = 0.19, alpha = 1 },
	})
	---@cast text hs.styledtext
	return text
end

local function sortSensors()
	table.sort(M.sensors, function(left, right)
		return sensorName(left):lower() < sensorName(right):lower()
	end)
end

---@param entityId string
---@return integer | nil
local function sensorIndex(entityId)
	for index, sensor in ipairs(M.sensors) do
		if sensor.entity_id == entityId then
			return index
		end
	end

	return nil
end

---@return boolean
local function hasLowBattery()
	for _, sensor in ipairs(M.sensors) do
		local percent = batteryPercent(sensor)
		if percent ~= nil and percent <= LOW_BATTERY_THRESHOLD_PERCENT then
			return true
		end
	end

	return false
end

local function refreshMenuIcon()
	if not M.menu then
		return
	end

	local isLowBattery = hasLowBattery()
	M.menu:setIcon(
		isLowBattery and lowBatteryIcon or defaultIcon,
		not isLowBattery
	)
end

---@param entity BatteryStatusSensor
local function upsertSensor(entity)
	local index = sensorIndex(entity.entity_id)
	if index then
		M.sensors[index] = entity
	else
		table.insert(M.sensors, entity)
	end

	sortSensors()
	M.lastUpdated = os.time()
	refreshMenuIcon()
end

---@param entityId string
local function removeSensor(entityId)
	local index = sensorIndex(entityId)
	if not index then
		return
	end

	table.remove(M.sensors, index)
	M.lastUpdated = os.time()
	refreshMenuIcon()
end

---@param sensors BatteryStatusSensor[]
local function replaceSensors(sensors)
	M.sensors = sensors
	sortSensors()
	M.lastUpdated = os.time()
	refreshMenuIcon()
end

---@param entity BatteryStatusSensor
local function openSensorInHomeAssistant(entity)
	local deviceId = M.entityDeviceIds[entity.entity_id]
	if deviceId then
		hs.urlevent.openURL(
			string.format(
				"%s/config/devices/device/%s",
				hassUrl(),
				hs.http.encodeForQuery(deviceId)
			)
		)
		return
	end

	hs.urlevent.openURL(
		string.format(
			"%s/config/entities/entity/%s",
			hassUrl(),
			hs.http.encodeForQuery(entity.entity_id)
		)
	)
end

local function clearReconnectTimer()
	if M.websocketReconnectTimer then
		M.websocketReconnectTimer:stop()
		M.websocketReconnectTimer = nil
	end
end

local function scheduleWebsocketReconnect()
	if M.websocketReconnectTimer then
		return
	end

	M.websocketReconnectTimer = hs.timer.doAfter(
		WEBSOCKET_RECONNECT_DELAY_SECONDS,
		function()
			M.websocketReconnectTimer = nil
			M.connectWebsocket()
		end
	)
end

---@param payload table
local function handleEntityRegistryResult(payload)
	if payload.success ~= true then
		return
	end

	M.lastError = nil

	local result = payload.result
	local entities = type(result) == "table" and result.entities or nil
	if type(entities) ~= "table" then
		return
	end

	local entityDeviceIds = {}
	for _, registryEntity in ipairs(entities) do
		if
			type(registryEntity) == "table"
			and type(registryEntity.ei) == "string"
			and type(registryEntity.di) == "string"
		then
			entityDeviceIds[registryEntity.ei] = registryEntity.di
		end
	end

	M.entityDeviceIds = entityDeviceIds
end

---@param payload table
local function handleStateChangedEvent(payload)
	M.lastError = nil

	local event = payload.event
	if type(event) ~= "table" or event.event_type ~= "state_changed" then
		return
	end

	local data = event.data
	if type(data) ~= "table" or type(data.entity_id) ~= "string" then
		return
	end

	local newState = data.new_state
	if type(newState) == "table" then
		newState.entity_id = newState.entity_id or data.entity_id
		if shouldDisplaySensor(newState) then
			upsertSensor(newState)
			return
		end
	end

	removeSensor(data.entity_id)
end

function M.connectWebsocket()
	if M.websocket then
		local status = M.websocket:status()
		if status == "connecting" or status == "open" then
			return
		end
	end

	local token, tokenError = hassToken()
	if not token then
		M.lastError = tokenError
		refreshMenuIcon()
		return
	end

	clearReconnectTimer()

	---@type hs.websocket | nil
	local socket
	socket = hs.websocket.new(hassWebsocketUrl(), function(event, message)
		if M.websocket ~= socket or not socket then
			return
		end

		if event == "received" then
			local payload = hs.json.decode(message)
			if type(payload) ~= "table" then
				return
			end

			if payload.type == "auth_required" then
				socket:send(
					hs.json.encode({ type = "auth", access_token = token }),
					false
				)
				return
			end

			if payload.type == "auth_ok" then
				M.lastError = nil
				socket:send(
					hs.json.encode({
						id = ENTITY_REGISTRY_REQUEST_ID,
						type = "config/entity_registry/list_for_display",
					}),
					false
				)
				socket:send(
					hs.json.encode({
						id = STATE_CHANGED_SUBSCRIPTION_ID,
						type = "subscribe_events",
						event_type = "state_changed",
					}),
					false
				)
				M.refresh()
				return
			end

			if payload.type == "auth_invalid" then
				M.lastError = "Home Assistant websocket authentication failed"
				M.websocket = nil
				socket:close()
				return
			end

			if payload.type == "result" then
				if payload.id == ENTITY_REGISTRY_REQUEST_ID then
					handleEntityRegistryResult(payload)
					return
				end

				if
					payload.id == STATE_CHANGED_SUBSCRIPTION_ID
					and payload.success ~= true
				then
					M.lastError = "Failed to subscribe to Home Assistant state changes"
					socket:close()
					return
				end
			end

			if
				payload.type == "event"
				and payload.id == STATE_CHANGED_SUBSCRIPTION_ID
			then
				handleStateChangedEvent(payload)
			end
			return
		end

		if event == "fail" then
			M.lastError = "Home Assistant websocket connection failed"
		end

		if event == "closed" or event == "fail" then
			if M.websocket == socket then
				M.websocket = nil
				scheduleWebsocketReconnect()
			end
		end
	end)

	M.websocket = socket
end

function M.refresh()
	if M.isRefreshing then
		return
	end

	local headers, headerError = buildHeaders()
	if not headers then
		M.lastError = headerError
		M.sensors = {}
		refreshMenuIcon()
		return
	end

	M.isRefreshing = true

	hs.http.asyncGet(hassUrl() .. "/api/states", headers, function(status, body)
		M.isRefreshing = false

		if status ~= 200 then
			M.lastError =
				string.format("Home Assistant returned HTTP %s", tostring(status))
			return
		end

		local decoded = hs.json.decode(body)
		if type(decoded) ~= "table" then
			M.lastError = "Failed to decode Home Assistant response"
			return
		end

		local sensors = {}
		for _, entity in ipairs(decoded) do
			if shouldDisplaySensor(entity) then
				table.insert(sensors, entity)
			end
		end

		M.lastError = nil
		replaceSensors(sensors)
	end)
end

---@return MenuItem[]
function M.buildMenu()
	local menu = {
		{ title = "Home Assistant Battery Status", disabled = true },
		{ title = "Refresh now", fn = M.refresh },
		{ title = "-" },
	}

	if M.isRefreshing then
		table.insert(menu, { title = "Refreshing…", disabled = true })
	end

	if M.lastError then
		table.insert(menu, { title = M.lastError, disabled = true })
		if #M.sensors > 0 then
			table.insert(menu, { title = "-" })
		else
			return menu
		end
	end

	if #M.sensors == 0 then
		table.insert(
			menu,
			{ title = "No battery percentage sensors found", disabled = true }
		)
		return menu
	end

	for _, sensor in ipairs(M.sensors) do
		local currentSensor = sensor
		table.insert(menu, {
			title = sensorMenuTitle(currentSensor),
			fn = function()
				openSensorInHomeAssistant(currentSensor)
			end,
		})
	end

	if M.lastUpdated then
		table.insert(menu, { title = "-" })
		table.insert(menu, {
			title = string.format("Updated %s", os.date("%H:%M:%S", M.lastUpdated)),
			disabled = true,
		})
	end

	return menu
end

M.menu = createMenu()
refreshMenuIcon()
M.menu:setTooltip("Home Assistant battery sensors")
M.menu:setMenu(M.buildMenu)

M.refresh()
M.connectWebsocket()
M.watcher = hs.timer.doEvery(FALLBACK_REFRESH_INTERVAL_SECONDS, M.refresh)

return M
