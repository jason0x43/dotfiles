---
name: amcrest-camera
description: Access and control the Amcrest IP camera at 10.0.0.221 via the Amcrest/Dahua HTTP API. Use when the user wants snapshots, device info, config reads/writes, streams, or PTZ-style camera control for an Amcrest camera.
---

# Amcrest camera

- API reference PDF: `/Users/jason/Downloads/HTTP_API_V3.26.pdf`
- The API is primarily under `/cgi-bin/*.cgi`
- Authentication is HTTP Digest auth per RFC 7616
- Prefer HTTPS if the camera supports it; otherwise use HTTP on the local network

## Before doing anything

1. Use environment variables for credentials when running commands:

```bash
export CAMERA_HOST=10.0.0.221
export CAMERA_USER='...'
export CAMERA_PASS='...'
```

2. Prefer the helper scripts in `<skill>/scripts`; they already use digest auth and basic timeouts.
3. For one-off curl commands, use digest auth:

```bash
curl --digest -u "$CAMERA_USER:$CAMERA_PASS" "http://$CAMERA_HOST/cgi-bin/magicBox.cgi?action=getDeviceType"
```

## Important API conventions

- Request `channel` values usually start at `1`
- Many config table indexes in responses start at `0`
- `getConfig`/`setConfig` use `key=value` query params
- Some newer `/cgi-bin/api/...` endpoints use JSON request bodies
- Successful `set...` operations often return plain `OK`
- Snapshot responses are binary JPEG data

## Helper scripts

Use the helper scripts in `<skill>/scripts` before hand-writing curl commands when they fit the task.

### `<skill>/scripts/get_camera_info.sh`

Fetches common identification and status endpoints.

```bash
export CAMERA_HOST=10.0.0.221
export CAMERA_USER='...'
export CAMERA_PASS='...'
<skill>/scripts/get_camera_info.sh
```

### `<skill>/scripts/take_snapshot.sh`

Captures a JPEG snapshot and prints the output path.

```bash
export CAMERA_HOST=10.0.0.221
export CAMERA_USER='...'
export CAMERA_PASS='...'
<skill>/scripts/take_snapshot.sh
<skill>/scripts/take_snapshot.sh latest.jpg
```

Optional env:
- `CHANNEL` default `1`
- `TYPE` default `0`

If the user asks to see the image, display the saved file with `show_image`.

### `<skill>/scripts/ptz_move.sh`

Use for PTZ-capable cameras only.

Common PTZ codes for `start`/`stop` include:
- `Up`
- `Down`
- `Left`
- `Right`
- `LeftUp`
- `RightUp`
- `LeftDown`
- `RightDown`
- `ZoomTele`
- `ZoomWide`
- `FocusNear`
- `FocusFar`

```bash
export CAMERA_HOST=10.0.0.221
export CAMERA_USER='...'
export CAMERA_PASS='...'

<skill>/scripts/ptz_move.sh status
<skill>/scripts/ptz_move.sh start Up
<skill>/scripts/ptz_move.sh stop Up
<skill>/scripts/ptz_move.sh relative 0.1 0.1 0
<skill>/scripts/ptz_move.sh absolute -0.8 0.3 0.5
```

Optional env:
- `CHANNEL` default `1`

## Common tasks

### Check connectivity / identify the camera

Prefer:

```bash
<skill>/scripts/get_camera_info.sh
```

Or call individual endpoints:

```bash
curl --digest -u "$CAMERA_USER:$CAMERA_PASS" "http://$CAMERA_HOST/cgi-bin/magicBox.cgi?action=getDeviceType"
curl --digest -u "$CAMERA_USER:$CAMERA_PASS" "http://$CAMERA_HOST/cgi-bin/magicBox.cgi?action=getSystemInfoNew"
curl --digest -u "$CAMERA_USER:$CAMERA_PASS" "http://$CAMERA_HOST/cgi-bin/magicBox.cgi?action=getSerialNo"
```

### Get the current camera time

```bash
curl --digest -u "$CAMERA_USER:$CAMERA_PASS" "http://$CAMERA_HOST/cgi-bin/global.cgi?action=getCurrentTime"
```

### Set the current camera time

URL-encode the space as `%20`:

```bash
curl --digest -u "$CAMERA_USER:$CAMERA_PASS" "http://$CAMERA_HOST/cgi-bin/global.cgi?action=setCurrentTime&time=2026-05-17%2021:00:00"
```

### Fetch a snapshot

Prefer:

```bash
<skill>/scripts/take_snapshot.sh
<skill>/scripts/take_snapshot.sh snapshot.jpg
```

Or call the endpoint directly:

```bash
curl --digest -u "$CAMERA_USER:$CAMERA_PASS" -o snapshot.jpg "http://$CAMERA_HOST/cgi-bin/snapshot.cgi?channel=1&type=0"
```

If the user asks to see the image, display the saved file with `show_image`.

### Read configuration

```bash
curl --digest -u "$CAMERA_USER:$CAMERA_PASS" "http://$CAMERA_HOST/cgi-bin/configManager.cgi?action=getConfig&name=General"
curl --digest -u "$CAMERA_USER:$CAMERA_PASS" "http://$CAMERA_HOST/cgi-bin/configManager.cgi?action=getConfig&name=Encode"
curl --digest -u "$CAMERA_USER:$CAMERA_PASS" "http://$CAMERA_HOST/cgi-bin/configManager.cgi?action=getConfig&name=VideoWidget"
```

### Write configuration

Be conservative. Read config first, then change only the needed keys.

Example:

```bash
curl --digest -u "$CAMERA_USER:$CAMERA_PASS" "http://$CAMERA_HOST/cgi-bin/configManager.cgi?action=setConfig&General.MachineName=FrontDoorCam"
```

### MJPEG stream

```bash
curl --digest -u "$CAMERA_USER:$CAMERA_PASS" "http://$CAMERA_HOST/cgi-bin/mjpg/video.cgi?channel=1&subtype=0"
```

### RTSP token creation

Some streaming workflows use a token endpoint with JSON:

```bash
curl --digest -u "$CAMERA_USER:$CAMERA_PASS" \
  -H 'Content-Type: application/json' \
  -d '{"Channel":0}' \
  "http://$CAMERA_HOST/cgi-bin/api/TokenManager/createToken"
```

### PTZ control

Only use PTZ endpoints if the device supports PTZ.

Prefer:

```bash
<skill>/scripts/ptz_move.sh status
<skill>/scripts/ptz_move.sh start Up
<skill>/scripts/ptz_move.sh stop Up
<skill>/scripts/ptz_move.sh relative 0.1 0.1 0.0
<skill>/scripts/ptz_move.sh absolute -0.8 0.3 0.5
```

Or call the endpoints directly.

Start moving up:

```bash
curl --digest -u "$CAMERA_USER:$CAMERA_PASS" "http://$CAMERA_HOST/cgi-bin/ptz.cgi?action=start&channel=1&code=Up&arg1=0&arg2=1&arg3=0"
```

Stop moving up:

```bash
curl --digest -u "$CAMERA_USER:$CAMERA_PASS" "http://$CAMERA_HOST/cgi-bin/ptz.cgi?action=stop&channel=1&code=Up&arg1=0&arg2=0&arg3=0"
```

Relative move:

```bash
curl --digest -u "$CAMERA_USER:$CAMERA_PASS" "http://$CAMERA_HOST/cgi-bin/ptz.cgi?action=moveRelatively&channel=1&arg1=0.1&arg2=0.1&arg3=0.0"
```

Absolute move:

```bash
curl --digest -u "$CAMERA_USER:$CAMERA_PASS" "http://$CAMERA_HOST/cgi-bin/ptz.cgi?action=moveAbsolutely&channel=1&arg1=-0.8&arg2=0.3&arg3=0.5"
```

## How to explore the API safely

1. Start with read-only endpoints like:
   - `magicBox.cgi?action=getDeviceType`
   - `magicBox.cgi?action=getSystemInfoNew`
   - `global.cgi?action=getCurrentTime`
   - `configManager.cgi?action=getConfig&name=...`
2. Confirm whether the device supports a feature before using it.
3. For any write action, show the user exactly what will change.
4. Prefer changing one setting at a time.

## If you need more API detail

Convert the PDF to text and search it:

```bash
pdftotext /Users/jason/Downloads/HTTP_API_V3.26.pdf /tmp/amcrest-api.txt
rg -n "snapshot|configManager|magicBox|ptz|global.cgi|TokenManager" /tmp/amcrest-api.txt
```

Useful documented endpoints from this PDF include:
- `/cgi-bin/snapshot.cgi`
- `/cgi-bin/magicBox.cgi?action=getDeviceType`
- `/cgi-bin/magicBox.cgi?action=getSystemInfoNew`
- `/cgi-bin/global.cgi?action=getCurrentTime`
- `/cgi-bin/global.cgi?action=setCurrentTime`
- `/cgi-bin/configManager.cgi?action=getConfig`
- `/cgi-bin/configManager.cgi?action=setConfig`
- `/cgi-bin/mjpg/video.cgi`
- `/cgi-bin/api/TokenManager/createToken`
- `/cgi-bin/ptz.cgi`

## Failure handling

- `401 Unauthorized`: digest challenge / bad auth setup
- `403 Forbidden`: authenticated but not allowed, or wrong credentials after challenge
- `404 Not Found`: endpoint unsupported on this model/firmware
- `500 Internal Server Error`: request shape accepted but device failed to execute it

When an endpoint fails, verify:
- host/IP is correct: `10.0.0.221`
- credentials are correct
- the feature exists on this model
- `channel=1` is appropriate
- parameters are URL-encoded correctly
