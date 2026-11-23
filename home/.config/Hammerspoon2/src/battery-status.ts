// Menubar item listing Home Assistant battery sensors. Sensors are loaded over
// the REST API and kept current with a websocket subscription to state
// changes.

import { hassToken, hassUrl } from "./settings";
import { createLogger } from "./log";
import { formatTime, isRecord, loadIcon } from "./util";

const logger = createLogger("battery-status");

const FALLBACK_REFRESH_INTERVAL_SECONDS = 1800;
const WEBSOCKET_RECONNECT_DELAY_SECONDS = 10;
const LOW_BATTERY_THRESHOLD_PERCENT = 25;
const ICON_SIZE = 18;
const ENTITY_REGISTRY_REQUEST_ID = 1;
const STATE_CHANGED_SUBSCRIPTION_ID = 2;
const LOW_BATTERY_COLOR = "#FF3B30";

// HSWebSocket.readyState values
const WS_CONNECTING = 0;
const WS_OPEN = 1;

interface BatteryStatusSensor {
	entity_id: string;
	state: string;
	attributes: Record<string, unknown>;
}

const highBatteryIcon = loadIcon("battery-high.svg", ICON_SIZE);
const lowBatteryIcon = loadIcon("battery-low.svg", ICON_SIZE);

export const state = {
	sensors: [] as BatteryStatusSensor[],
	entityDeviceIds: {} as Record<string, string>,
	lastUpdated: null as Date | null,
	lastError: null as string | null,
	isRefreshing: false,
	websocket: null as HSWebSocket | null,
	websocketReconnectTimer: null as HSTimer | null,
};

function hassWebsocketUrl(): string {
	return `${hassUrl().replace(/^http/, "ws")}/api/websocket`;
}

function attrs(entity: BatteryStatusSensor): Record<string, unknown> {
	return entity.attributes ?? {};
}

function isBatterySensor(entity: BatteryStatusSensor): boolean {
	return attrs(entity).device_class === "battery" || entity.entity_id.includes("battery");
}

function sensorName(entity: BatteryStatusSensor): string {
	const name = attrs(entity).friendly_name;
	return typeof name === "string" ? name : entity.entity_id;
}

function shouldHideSensor(entity: BatteryStatusSensor): boolean {
	const entityState = String(entity.state);
	const name = sensorName(entity).toLowerCase();
	const entityId = entity.entity_id.toLowerCase();

	return (
		entityState === "unavailable" ||
		entityState === "unknown" ||
		name.includes("battery state") ||
		entityId.includes("battery_state")
	);
}

function hasPercentageUnit(entity: BatteryStatusSensor): boolean {
	return attrs(entity).unit_of_measurement === "%";
}

function batteryPercent(entity: BatteryStatusSensor): number | null {
	if (!hasPercentageUnit(entity)) {
		return null;
	}
	const percent = Number(entity.state);
	return Number.isFinite(percent) ? percent : null;
}

function shouldDisplaySensor(entity: unknown): entity is BatteryStatusSensor {
	if (!isRecord(entity) || typeof entity.entity_id !== "string") {
		return false;
	}
	const sensor = entity as unknown as BatteryStatusSensor;
	return isBatterySensor(sensor) && hasPercentageUnit(sensor) && !shouldHideSensor(sensor);
}

function sensorStatus(entity: BatteryStatusSensor): string {
	const entityState = String(entity.state);
	const unit = attrs(entity).unit_of_measurement;

	if (
		entityState.trim() !== "" &&
		Number.isFinite(Number(entityState)) &&
		typeof unit === "string" &&
		unit !== "" &&
		!entityState.includes(unit)
	) {
		return `${entityState}${unit}`;
	}

	return entityState;
}

function isLow(entity: BatteryStatusSensor): boolean {
	const percent = batteryPercent(entity);
	return percent !== null && percent <= LOW_BATTERY_THRESHOLD_PERCENT;
}

function sortSensors(): void {
	state.sensors.sort((a, b) => {
		const left = sensorName(a).toLowerCase();
		const right = sensorName(b).toLowerCase();
		return left < right ? -1 : left > right ? 1 : 0;
	});
}

function refreshMenuIcon(): void {
	menu.setIcon(state.sensors.some(isLow) ? lowBatteryIcon : highBatteryIcon);
}

function sensorsChanged(): void {
	sortSensors();
	state.lastUpdated = new Date();
	refreshMenuIcon();
}

function upsertSensor(entity: BatteryStatusSensor): void {
	const index = state.sensors.findIndex((s) => s.entity_id === entity.entity_id);
	if (index === -1) {
		state.sensors.push(entity);
	} else {
		state.sensors[index] = entity;
	}
	sensorsChanged();
}

function removeSensor(entityId: string): void {
	const index = state.sensors.findIndex((s) => s.entity_id === entityId);
	if (index === -1) {
		return;
	}
	state.sensors.splice(index, 1);
	state.lastUpdated = new Date();
	refreshMenuIcon();
}

function openSensorInHomeAssistant(entity: BatteryStatusSensor): void {
	const deviceId = state.entityDeviceIds[entity.entity_id];
	const url = deviceId
		? `${hassUrl()}/config/devices/device/${hs.http.encodeForQuery(deviceId)}`
		: `${hassUrl()}/config/entities/entity/${hs.http.encodeForQuery(entity.entity_id)}`;
	hs.urlevent.openURL(url);
}

function clearReconnectTimer(): void {
	state.websocketReconnectTimer?.stop();
	state.websocketReconnectTimer = null;
}

function scheduleWebsocketReconnect(): void {
	if (state.websocketReconnectTimer) {
		return;
	}

	state.websocketReconnectTimer = hs.timer.doAfter(WEBSOCKET_RECONNECT_DELAY_SECONDS, () => {
		state.websocketReconnectTimer = null;
		connectWebsocket();
	});
}

function handleEntityRegistryResult(payload: Record<string, unknown>): void {
	if (payload.success !== true) {
		return;
	}

	state.lastError = null;

	const result = payload.result;
	const entities = isRecord(result) ? result.entities : null;
	if (!Array.isArray(entities)) {
		return;
	}

	const entityDeviceIds: Record<string, string> = {};
	for (const entity of entities) {
		if (isRecord(entity) && typeof entity.ei === "string" && typeof entity.di === "string") {
			entityDeviceIds[entity.ei] = entity.di;
		}
	}
	state.entityDeviceIds = entityDeviceIds;
}

function handleStateChangedEvent(payload: Record<string, unknown>): void {
	state.lastError = null;

	const event = payload.event;
	if (!isRecord(event) || event.event_type !== "state_changed") {
		return;
	}

	const data = event.data;
	if (!isRecord(data) || typeof data.entity_id !== "string") {
		return;
	}

	const newState = data.new_state;
	if (isRecord(newState)) {
		newState.entity_id ??= data.entity_id;
		if (shouldDisplaySensor(newState)) {
			upsertSensor(newState);
			return;
		}
	}

	removeSensor(data.entity_id);
}

export function connectWebsocket(): void {
	const current = state.websocket;
	if (current && (current.readyState === WS_CONNECTING || current.readyState === WS_OPEN)) {
		return;
	}

	const token = hassToken();
	if (!token) {
		state.lastError = "Missing Home Assistant token setting (hassToken or hass_token)";
		refreshMenuIcon();
		return;
	}

	clearReconnectTimer();

	const socket = hs.http.openWebSocket(hassWebsocketUrl());
	if (!socket) {
		state.lastError = "Invalid Home Assistant websocket URL";
		return;
	}
	state.websocket = socket;

	const send = (message: Record<string, unknown>) => socket.send(JSON.stringify(message));

	const onDisconnected = () => {
		if (state.websocket === socket) {
			state.websocket = null;
			scheduleWebsocketReconnect();
		}
	};

	socket
		.setMessageCallback((message) => {
			if (state.websocket !== socket) {
				return;
			}

			let payload: unknown;
			try {
				payload = JSON.parse(message);
			} catch {
				return;
			}
			if (!isRecord(payload)) {
				return;
			}

			switch (payload.type) {
				case "auth_required":
					send({ type: "auth", access_token: token });
					return;

				case "auth_ok":
					state.lastError = null;
					send({
						id: ENTITY_REGISTRY_REQUEST_ID,
						type: "config/entity_registry/list_for_display",
					});
					send({
						id: STATE_CHANGED_SUBSCRIPTION_ID,
						type: "subscribe_events",
						event_type: "state_changed",
					});
					refresh();
					return;

				case "auth_invalid":
					state.lastError = "Home Assistant websocket authentication failed";
					// Don't reconnect with a bad token
					state.websocket = null;
					socket.close();
					return;

				case "result":
					if (payload.id === ENTITY_REGISTRY_REQUEST_ID) {
						handleEntityRegistryResult(payload);
					} else if (payload.id === STATE_CHANGED_SUBSCRIPTION_ID && payload.success !== true) {
						state.lastError = "Failed to subscribe to Home Assistant state changes";
						socket.close();
						onDisconnected();
					}
					return;

				case "event":
					if (payload.id === STATE_CHANGED_SUBSCRIPTION_ID) {
						handleStateChangedEvent(payload);
					}
					return;
			}
		})
		.setCloseCallback(() => onDisconnected())
		.setErrorCallback((error) => {
			if (state.websocket !== socket) {
				return;
			}
			logger.w(`Websocket error: ${error}`);
			state.lastError = "Home Assistant websocket connection failed";
			onDisconnected();
		});
}

export async function refresh(): Promise<void> {
	if (state.isRefreshing) {
		return;
	}

	const token = hassToken();
	if (!token) {
		state.lastError = "Missing Home Assistant token setting (hassToken or hass_token)";
		state.sensors = [];
		refreshMenuIcon();
		return;
	}

	state.isRefreshing = true;
	try {
		const response = await hs.http.get(`${hassUrl()}/api/states`, {
			Authorization: `Bearer ${token}`,
			"Content-Type": "application/json",
		});

		if (response.status !== 200) {
			state.lastError = `Home Assistant returned HTTP ${response.status}`;
			return;
		}

		let decoded: unknown;
		try {
			decoded = JSON.parse(response.body);
		} catch {
			decoded = null;
		}
		if (!Array.isArray(decoded)) {
			state.lastError = "Failed to decode Home Assistant response";
			return;
		}

		state.lastError = null;
		state.sensors = decoded.filter(shouldDisplaySensor);
		sensorsChanged();
	} finally {
		state.isRefreshing = false;
	}
}

function buildMenu(): Record<string, unknown>[] {
	const items: Record<string, unknown>[] = [
		{ title: "Home Assistant Battery Status", disabled: true },
		{ title: "Refresh now", fn: () => refresh() },
		{ title: "-" },
	];

	if (state.isRefreshing) {
		items.push({ title: "Refreshing…", disabled: true });
	}

	if (state.lastError) {
		items.push({ title: state.lastError, disabled: true });
		if (state.sensors.length === 0) {
			return items;
		}
		items.push({ title: "-" });
	}

	if (state.sensors.length === 0) {
		items.push({ title: "No battery percentage sensors found", disabled: true });
		return items;
	}

	for (const sensor of state.sensors) {
		items.push({
			title: `${sensorName(sensor)}: ${sensorStatus(sensor)}`,
			...(isLow(sensor) ? { color: LOW_BATTERY_COLOR } : {}),
			fn: () => openSensorInHomeAssistant(sensor),
		});
	}

	if (state.lastUpdated) {
		items.push({ title: "-" });
		items.push({ title: `Updated ${formatTime(state.lastUpdated)}`, disabled: true });
	}

	return items;
}

const menu = hs.menubar.create();
refreshMenuIcon();
menu.setTooltip("Home Assistant battery sensors");
menu.setMenu(buildMenu);

refresh();
connectWebsocket();

export const timer = hs.timer.doEvery(FALLBACK_REFRESH_INTERVAL_SECONDS, () => {
	refresh();
});
