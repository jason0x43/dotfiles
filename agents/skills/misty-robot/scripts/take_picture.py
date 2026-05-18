#!/usr/bin/env python3
"""Take a picture with Misty and save it locally.

Examples:
  python3 take_picture.py
  python3 take_picture.py --ip 10.0.0.172
  python3 take_picture.py --width 1280 --height 960 --output ./photo.jpg
"""

from __future__ import annotations

import argparse
import base64
import json
import mimetypes
import os
import sys
from datetime import datetime
from pathlib import Path
from typing import Any
from urllib.error import HTTPError, URLError
from urllib.parse import urlencode
from urllib.request import urlopen

DEFAULT_IP = os.environ.get("MISTY_IP")
DEFAULT_WIDTH = 1280
DEFAULT_HEIGHT = 960
DEFAULT_TIMEOUT = 30


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Take a picture with Misty and save it locally.")
    parser.add_argument("--ip", default=DEFAULT_IP, help=f"Misty IP address (default: {DEFAULT_IP})")
    parser.add_argument("--width", type=int, default=DEFAULT_WIDTH, help=f"Image width (default: {DEFAULT_WIDTH})")
    parser.add_argument("--height", type=int, default=DEFAULT_HEIGHT, help=f"Image height (default: {DEFAULT_HEIGHT})")
    parser.add_argument("--timeout", type=int, default=DEFAULT_TIMEOUT, help=f"HTTP timeout in seconds (default: {DEFAULT_TIMEOUT})")
    parser.add_argument(
        "--output",
        help="Output path. If omitted, saves to <current working directory>/photos/misty-<timestamp>.<ext>",
    )
    parser.add_argument(
        "--display-on-screen",
        action="store_true",
        help="Ask Misty to display the captured image on screen if supported.",
    )
    parser.add_argument(
        "--overwrite-existing",
        action="store_true",
        help="Allow Misty to overwrite an on-robot file if FileName is used by the API.",
    )
    parser.add_argument(
        "--robot-filename",
        help="Optional filename hint to send to Misty for the captured image.",
    )
    return parser.parse_args()


def fetch_json(url: str, timeout: int) -> Any:
    try:
        with urlopen(url, timeout=timeout) as response:
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


def unwrap_result(payload: Any) -> Any:
    if isinstance(payload, list) and payload:
        first = payload[0]
        if isinstance(first, dict) and "result" in first:
            return first["result"]
    if isinstance(payload, dict) and "result" in payload:
        return payload["result"]
    return payload


def infer_extension(content_type: str | None, name: str | None) -> str:
    if name:
        suffix = Path(name).suffix
        if suffix:
            return suffix
    if content_type:
        guessed = mimetypes.guess_extension(content_type.split(";", 1)[0].strip())
        if guessed:
            if guessed == ".jpe":
                return ".jpg"
            return guessed
    return ".jpg"


def default_output_dir() -> Path:
    pwd = os.environ.get("PWD")
    if pwd:
        candidate = Path(pwd).expanduser()
        if candidate.is_dir():
            return candidate.resolve()
    return Path.cwd().resolve()


def resolve_output_path(output: str | None, content_type: str | None, name: str | None) -> Path:
    if output:
        return Path(output).expanduser().resolve()

    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    ext = infer_extension(content_type, name)
    return (default_output_dir() / "photos" / f"misty-{timestamp}{ext}").resolve()


def save_image(data_b64: str, destination: Path) -> None:
    try:
        binary = base64.b64decode(data_b64)
    except Exception as exc:  # noqa: BLE001
        raise RuntimeError("Could not decode base64 image data from Misty") from exc

    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_bytes(binary)


def main() -> int:
    args = parse_args()

    params = {
        "Base64": "true",
        "Width": str(args.width),
        "Height": str(args.height),
        "DisplayOnScreen": "true" if args.display_on_screen else "false",
        "OverwriteExisting": "true" if args.overwrite_existing else "false",
    }
    if args.robot_filename:
        params["FileName"] = args.robot_filename

    url = f"http://{args.ip}/api/cameras/rgb?{urlencode(params)}"
    payload = fetch_json(url, args.timeout)
    result = unwrap_result(payload)

    if not isinstance(result, dict):
        raise RuntimeError(f"Unexpected response shape from Misty: {result!r}")

    data_b64 = result.get("base64") or result.get("Base64")
    content_type = result.get("contentType") or result.get("ContentType")
    name = result.get("name") or result.get("Name")

    if not data_b64:
        raise RuntimeError(f"Misty response did not include image data: {json.dumps(payload, indent=2)}")

    output_path = resolve_output_path(args.output, content_type, name)
    save_image(data_b64, output_path)

    print(f"Saved photo to: {output_path}")
    if name:
        print(f"Robot image name: {name}")
    if content_type:
        print(f"Content-Type: {content_type}")
    print(f"Source URL: {url}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except RuntimeError as exc:
        print(f"Error: {exc}", file=sys.stderr)
        raise SystemExit(1)
