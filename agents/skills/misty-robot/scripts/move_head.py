#!/usr/bin/env python3
"""Move Misty's head and wait for the move to complete.

Examples:
  python3 move_head.py --yaw -20
  python3 move_head.py --pitch 0 --roll 0 --yaw 45 --velocity 30

This script sends POST /api/head, subscribes to Misty's ActuatorPosition
WebSocket stream, and returns only after the commanded head axes are within
`tolerance` degrees of their targets for `settle-ms` milliseconds.

Note: omitted axes default to 0 degrees because /api/head expects explicit
Pitch/Roll/Yaw values.
"""

from __future__ import annotations

import argparse
import base64
import hashlib
import json
import os
import select
import socket
import sys
import time
from dataclasses import dataclass
from typing import Any
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

DEFAULT_IP = os.environ.get("MISTY_IP")
DEFAULT_TIMEOUT = 30.0
DEFAULT_VELOCITY = 20.0
DEFAULT_TOLERANCE = 3.0
DEFAULT_SETTLE_MS = 300
DEFAULT_DEBOUNCE_MS = 100
WS_GUID = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"

AXIS_TO_SENSOR = {
    "pitch": "Actuator_HeadPitch",
    "roll": "Actuator_HeadRoll",
    "yaw": "Actuator_HeadYaw",
}
AXIS_TO_EVENT = {
    "pitch": "HeadPitch",
    "roll": "HeadRoll",
    "yaw": "HeadYaw",
}
EVENT_TO_AXIS = {value.lower(): key for key, value in AXIS_TO_EVENT.items()}


@dataclass
class CommandTargets:
    pitch: float
    roll: float
    yaw: float

    def as_payload(self, velocity: float) -> dict[str, Any]:
        return {
            "Pitch": self.pitch,
            "Roll": self.roll,
            "Yaw": self.yaw,
            "Velocity": velocity,
            "Units": "degrees",
        }

    def as_dict(self) -> dict[str, float]:
        return {"pitch": self.pitch, "roll": self.roll, "yaw": self.yaw}


class WebSocketError(RuntimeError):
    pass


class SimpleWebSocket:
    def __init__(self, host: str, port: int = 80, path: str = "/pubsub", timeout: float = DEFAULT_TIMEOUT) -> None:
        self.host = host
        self.port = port
        self.path = path
        self.timeout = timeout
        self.sock: socket.socket | None = None
        self._recv_buffer = bytearray()

    def connect(self) -> None:
        sock = socket.create_connection((self.host, self.port), timeout=self.timeout)
        sock.settimeout(self.timeout)

        key = base64.b64encode(os.urandom(16)).decode("ascii")
        request = (
            f"GET {self.path} HTTP/1.1\r\n"
            f"Host: {self.host}:{self.port}\r\n"
            "Upgrade: websocket\r\n"
            "Connection: Upgrade\r\n"
            f"Sec-WebSocket-Key: {key}\r\n"
            "Sec-WebSocket-Version: 13\r\n"
            "\r\n"
        )
        sock.sendall(request.encode("ascii"))

        response = self._read_http_headers(sock)
        status_line = response.split("\r\n", 1)[0]
        if " 101 " not in status_line:
            raise WebSocketError(f"WebSocket upgrade failed: {status_line}")

        accept = self._header_value(response, "sec-websocket-accept")
        expected = base64.b64encode(hashlib.sha1(f"{key}{WS_GUID}".encode("ascii")).digest()).decode("ascii")
        if accept != expected:
            raise WebSocketError("WebSocket handshake validation failed")

        self.sock = sock

    def close(self) -> None:
        if self.sock is None:
            return
        try:
            self.send_text("", opcode=0x8)
        except Exception:
            pass
        try:
            self.sock.close()
        finally:
            self.sock = None

    def send_json(self, payload: dict[str, Any]) -> None:
        self.send_text(json.dumps(payload))

    def send_text(self, text: str, opcode: int = 0x1) -> None:
        if self.sock is None:
            raise WebSocketError("WebSocket is not connected")

        payload = text.encode("utf-8")
        frame = bytearray()
        frame.append(0x80 | (opcode & 0x0F))

        length = len(payload)
        if length < 126:
            frame.append(0x80 | length)
        elif length < 65536:
            frame.append(0x80 | 126)
            frame.extend(length.to_bytes(2, "big"))
        else:
            frame.append(0x80 | 127)
            frame.extend(length.to_bytes(8, "big"))

        mask = os.urandom(4)
        frame.extend(mask)
        frame.extend(b ^ mask[i % 4] for i, b in enumerate(payload))
        self.sock.sendall(frame)

    def recv_json(self, timeout: float | None = None) -> Any:
        text = self.recv_text(timeout=timeout)
        return json.loads(text)

    def recv_text(self, timeout: float | None = None) -> str:
        opcode, payload = self._recv_frame(timeout=timeout)
        if opcode == 0x1:
            return payload.decode("utf-8")
        raise WebSocketError(f"Unexpected WebSocket opcode: {opcode}")

    def _recv_frame(self, timeout: float | None = None) -> tuple[int, bytes]:
        if self.sock is None:
            raise WebSocketError("WebSocket is not connected")

        while True:
            self._fill_buffer(2, timeout)
            first = self._recv_buffer[0]
            second = self._recv_buffer[1]
            fin = (first & 0x80) != 0
            opcode = first & 0x0F
            masked = (second & 0x80) != 0
            length = second & 0x7F
            offset = 2

            if length == 126:
                self._fill_buffer(offset + 2, timeout)
                length = int.from_bytes(self._recv_buffer[offset : offset + 2], "big")
                offset += 2
            elif length == 127:
                self._fill_buffer(offset + 8, timeout)
                length = int.from_bytes(self._recv_buffer[offset : offset + 8], "big")
                offset += 8

            mask = b""
            if masked:
                self._fill_buffer(offset + 4, timeout)
                mask = bytes(self._recv_buffer[offset : offset + 4])
                offset += 4

            self._fill_buffer(offset + length, timeout)
            payload = bytes(self._recv_buffer[offset : offset + length])
            del self._recv_buffer[: offset + length]

            if masked:
                payload = bytes(b ^ mask[i % 4] for i, b in enumerate(payload))

            if not fin:
                raise WebSocketError("Fragmented WebSocket frames are not supported")

            if opcode == 0x9:  # ping
                self.send_text(payload.decode("utf-8", errors="ignore"), opcode=0xA)
                continue
            if opcode == 0xA:  # pong
                continue
            if opcode == 0x8:  # close
                raise WebSocketError("WebSocket closed by peer")
            return opcode, payload

    def _fill_buffer(self, size: int, timeout: float | None) -> None:
        if self.sock is None:
            raise WebSocketError("WebSocket is not connected")

        deadline = None if timeout is None else time.monotonic() + timeout
        while len(self._recv_buffer) < size:
            remaining = None if deadline is None else max(0.0, deadline - time.monotonic())
            if deadline is not None and remaining == 0.0:
                raise TimeoutError("Timed out waiting for WebSocket data")
            readable, _, _ = select.select([self.sock], [], [], remaining)
            if not readable:
                raise TimeoutError("Timed out waiting for WebSocket data")
            chunk = self.sock.recv(4096)
            if not chunk:
                raise WebSocketError("WebSocket connection closed")
            self._recv_buffer.extend(chunk)

    @staticmethod
    def _read_http_headers(sock: socket.socket) -> str:
        data = bytearray()
        while b"\r\n\r\n" not in data:
            chunk = sock.recv(4096)
            if not chunk:
                raise WebSocketError("Unexpected EOF during WebSocket handshake")
            data.extend(chunk)
        header_bytes, _, remainder = data.partition(b"\r\n\r\n")
        # Preserve any bytes read beyond the HTTP headers as WebSocket data.
        if remainder:
            # Not expected during handshake, but harmless to drop here because Misty
            # should not send pubsub data before we subscribe.
            pass
        return header_bytes.decode("iso-8859-1")

    @staticmethod
    def _header_value(headers: str, header_name: str) -> str | None:
        wanted = header_name.lower()
        for line in headers.split("\r\n")[1:]:
            if ":" not in line:
                continue
            name, value = line.split(":", 1)
            if name.strip().lower() == wanted:
                return value.strip()
        return None


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Move Misty's head and wait for completion.")
    parser.add_argument("--ip", default=DEFAULT_IP, help=f"Misty IP address (default: {DEFAULT_IP})")
    parser.add_argument("--pitch", type=float, default=0.0, help="Target pitch in degrees (defaults to 0 if omitted)")
    parser.add_argument("--roll", type=float, default=0.0, help="Target roll in degrees (defaults to 0 if omitted)")
    parser.add_argument("--yaw", type=float, default=0.0, help="Target yaw in degrees (defaults to 0 if omitted)")
    parser.add_argument("--velocity", type=float, default=DEFAULT_VELOCITY, help=f"Movement velocity (default: {DEFAULT_VELOCITY})")
    parser.add_argument("--timeout", type=float, default=DEFAULT_TIMEOUT, help=f"Overall timeout in seconds (default: {DEFAULT_TIMEOUT})")
    parser.add_argument("--tolerance", type=float, default=DEFAULT_TOLERANCE, help=f"Allowed error in degrees (default: {DEFAULT_TOLERANCE})")
    parser.add_argument("--settle-ms", type=int, default=DEFAULT_SETTLE_MS, help=f"How long all axes must remain in tolerance before returning (default: {DEFAULT_SETTLE_MS})")
    parser.add_argument("--debounce-ms", type=int, default=DEFAULT_DEBOUNCE_MS, help=f"ActuatorPosition debounce interval (default: {DEFAULT_DEBOUNCE_MS})")
    parser.add_argument("--verbose", action="store_true", help="Print actuator updates while waiting")
    return parser.parse_args()


def http_post_json(url: str, payload: dict[str, Any], timeout: float) -> Any:
    data = json.dumps(payload).encode("utf-8")
    request = Request(url, data=data, headers={"Content-Type": "application/json"}, method="POST")
    try:
        with urlopen(request, timeout=timeout) as response:
            raw = response.read()
    except HTTPError as exc:
        detail = exc.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"HTTP {exc.code} from Misty: {detail}") from exc
    except URLError as exc:
        raise RuntimeError(f"Could not reach Misty: {exc}") from exc

    try:
        return json.loads(raw)
    except json.JSONDecodeError as exc:
        preview = raw[:500].decode("utf-8", errors="replace")
        raise RuntimeError(f"Misty returned non-JSON data: {preview}") from exc


def accepted_response(payload: Any) -> bool:
    if isinstance(payload, list) and payload:
        first = payload[0]
        if isinstance(first, dict):
            return bool(first.get("result"))
    if isinstance(payload, dict):
        return bool(payload.get("result"))
    return False


def subscribe_to_actuator_position(ws: SimpleWebSocket, debounce_ms: int) -> None:
    for axis, sensor_name in AXIS_TO_SENSOR.items():
        ws.send_json(
            {
                "Operation": "subscribe",
                "Type": "ActuatorPosition",
                "DebounceMs": debounce_ms,
                "EventName": AXIS_TO_EVENT[axis],
                "Message": "",
                "ReturnProperty": None,
                "EventConditions": [
                    {
                        "Property": "sensorName",
                        "Inequality": "=",
                        "Value": sensor_name,
                    }
                ],
            }
        )


def extract_axis_and_value(message: Any) -> tuple[str, float] | None:
    if not isinstance(message, dict):
        return None

    event_name = message.get("eventName") or message.get("EventName")
    axis = EVENT_TO_AXIS.get(str(event_name).lower()) if event_name is not None else None
    if axis is None:
        return None

    payload = message.get("message") or message.get("Message")
    if not isinstance(payload, dict):
        return None

    value = payload.get("value")
    if value is None:
        value = payload.get("Value")
    if value is None:
        value = payload.get("position")
    if value is None:
        value = payload.get("Position")
    if value is None:
        return None

    try:
        numeric_value = float(value)
    except (TypeError, ValueError):
        return None

    return axis, numeric_value


def wait_for_targets(
    ws: SimpleWebSocket,
    targets: CommandTargets,
    timeout: float,
    tolerance: float,
    settle_ms: int,
    verbose: bool,
) -> dict[str, float]:
    target_map = targets.as_dict()
    latest: dict[str, float] = {}
    in_tolerance_since: float | None = None
    deadline = time.monotonic() + timeout

    while True:
        remaining = deadline - time.monotonic()
        if remaining <= 0:
            if latest:
                raise TimeoutError(f"Timed out waiting for head movement to complete. Last actuator values: {latest}")
            raise TimeoutError("Timed out waiting for head movement to complete. No actuator events were received.")

        payload = ws.recv_json(timeout=min(remaining, 2.0))
        extracted = extract_axis_and_value(payload)
        if extracted is None:
            continue

        axis, actual = extracted
        latest[axis] = actual

        if verbose:
            print(f"{axis}={actual:.2f}", file=sys.stderr)

        all_axes_seen = all(axis_name in latest for axis_name in target_map)
        all_in_tolerance = all_axes_seen and all(abs(latest[axis_name] - target) <= tolerance for axis_name, target in target_map.items())

        if all_in_tolerance:
            if in_tolerance_since is None:
                in_tolerance_since = time.monotonic()
            elapsed_ms = (time.monotonic() - in_tolerance_since) * 1000.0
            if elapsed_ms >= settle_ms:
                return latest
        else:
            in_tolerance_since = None


def main() -> int:
    args = parse_args()
    targets = CommandTargets(pitch=args.pitch, roll=args.roll, yaw=args.yaw)

    ws = SimpleWebSocket(host=args.ip, path="/pubsub", timeout=args.timeout)
    try:
        ws.connect()
        subscribe_to_actuator_position(ws, debounce_ms=args.debounce_ms)

        response = http_post_json(f"http://{args.ip}/api/head", targets.as_payload(args.velocity), timeout=args.timeout)
        if not accepted_response(response):
            raise RuntimeError(f"Misty did not accept head command: {json.dumps(response)}")

        final_positions = wait_for_targets(
            ws=ws,
            targets=targets,
            timeout=args.timeout,
            tolerance=args.tolerance,
            settle_ms=args.settle_ms,
            verbose=args.verbose,
        )
    finally:
        ws.close()

    print("Head movement complete")
    print(json.dumps({"target": targets.as_dict(), "final": final_positions}, indent=2, sort_keys=True))
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (RuntimeError, TimeoutError, WebSocketError) as exc:
        print(f"Error: {exc}", file=sys.stderr)
        raise SystemExit(1)
