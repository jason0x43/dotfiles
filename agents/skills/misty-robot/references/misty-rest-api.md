# Misty REST API (compact cached reference)

Source: https://docs.mistyrobotics.com/misty-ii/reference/rest/  
Fetched: 2026-05-17

Use this file as the local, compact reference for controlling Misty without re-downloading the full vendor docs.

## Basics

- Base URL: `http://<robot-ip>/api/<endpoint>`
- Request body: JSON unless noted otherwise
- Success response is typically:
  ```json
  [{ "result": true, "status": "Success" }]
  ```
- If an endpoint is not listed here, check the vendor source.
- No documented docking endpoint was found in the REST docs.

## High-value endpoints

### Audio

- List audio files: `GET /api/audio/list`
  - Returns file names and whether each asset is user-added.
- Play audio: `POST /api/audio/play`
  ```json
  { "FileName": "002-Weerp.wav" }
  ```
  - Use the exact filename, including `.wav`.
  - Optional: `Volume` (0-100)
- Get audio file: `GET /api/audio?FileName=<name>&Base64=true|false`
- Upload audio: `POST /api/audio`
  - JSON upload: `FileName`, `Data`, optional `ImmediatelyApply`, `OverwriteExisting`
  - Multipart upload also supported
- Delete uploaded audio: `DELETE /api/audio`
  ```json
  { "FileName": "ExampleSong.wav" }
  ```
  - Only user-uploaded audio can be deleted.

### Images / Screen

- List images: `GET /api/images/list`
- Display image: `POST /api/images/display`
  ```json
  { "FileName": "e_Joy2.jpg", "Alpha": 1 }
  ```
  - Set `FileName` to `""` to clear the screen.
- Get image: `GET /api/images?FileName=<name>&Base64=true|false`
- Upload image: `POST /api/images`
  - JSON upload: `FileName`, `Data`, optional `Width`, `Height`, `ImmediatelyApply`, `OverwriteExisting`
  - Multipart upload also supported
- Delete uploaded image: `DELETE /api/images`
  ```json
  { "FileName": "ExampleImage.png" }
  ```
  - Only user-uploaded images can be deleted.

### Lights

- Chest LED: `POST /api/led`
  ```json
  { "Red": 255, "Green": 0, "Blue": 0 }
  ```
- Flashlight: `POST /api/flashlight`
  ```json
  { "On": true }
  ```

### Driving / Motion

- Drive until stopped: `POST /api/drive`
  ```json
  { "LinearVelocity": 20, "AngularVelocity": 0 }
  ```
- Drive for time: `POST /api/drive/time`
  ```json
  { "LinearVelocity": 10, "AngularVelocity": 0, "TimeMs": 1000 }
  ```
  - `TimeMs < 100` does not drive.
  - Positive `LinearVelocity` moves forward.
  - Negative `LinearVelocity` moves backward.
- Stop driving: `POST /api/drive/stop`
- Halt all motors: `POST /api/halt`
- Track drive: `POST /api/drive/track`
  ```json
  { "LeftTrackSpeed": 30, "RightTrackSpeed": 70 }
  ```
- Drive heading + distance: `POST /api/drive/hdt`
  ```json
  { "Heading": 90, "Distance": 1, "TimeMs": 4000 }
  ```
  - Optional: `Reverse: true`
- Drive arc: `POST /api/drive/arc`
  ```json
  { "Heading": 90, "Radius": 1, "TimeMs": 4000 }
  ```

### Head / Arms

- Move head: `POST /api/head`
  ```json
  { "Pitch": 0, "Roll": 0, "Yaw": 0, "Velocity": 10, "Units": "degrees" }
  ```
  - Units: `degrees`, `radians`, or `position`
- Move one arm: `POST /api/arms`
  ```json
  { "Arm": "left", "Position": -90, "Velocity": 100, "Units": "degrees" }
  ```
- Move both arms: `POST /api/arms/set`
  ```json
  { "LeftArmPosition": -90, "RightArmPosition": -90, "LeftArmVelocity": 50, "RightArmVelocity": 50, "Units": "degrees" }
  ```

### Camera / Sensor snapshots

- Depth picture: `GET /api/cameras/depth`
- Fisheye picture: `GET /api/cameras/fisheye?Base64=true|false`
  - `Base64=true` returns image data for saving/reuse.
- SLAM streaming start: `POST /api/slam/streaming/start`
- SLAM streaming stop: `POST /api/slam/streaming/stop`

### Navigation / Mapping

- Get map: `GET /api/slam/map`
- Drive to location: `POST /api/drive/coordinates`
  ```json
  { "Destination": "10:25" }
  ```
- Follow path: `POST /api/drive/path`
  ```json
  { "Waypoints": [{ "X": 0, "Y": 0 }, { "X": 5, "Y": 5 }] }
  ```
  - These navigation endpoints depend on a valid map and active tracking.

### Other useful endpoints

- Trigger running skill event: `POST /api/skills/event`
  ```json
  {
    "UniqueId": "<skill-guid>",
    "EventName": "UserEvent",
    "Payload": "{\"test\":\"two\"}"
  }
  ```
- Serial write: `POST /api/serial`
  ```json
  { "Message": "your-data" }
  ```
- External HTTP request from Misty: `POST /api/request`

## Practical usage notes

- For short forward motion, use `POST /api/drive/time` with:
  ```json
  { "LinearVelocity": 10, "AngularVelocity": 0, "TimeMs": <duration_ms> }
  ```
- For short backward motion, use:
  ```json
  { "LinearVelocity": -10, "AngularVelocity": 0, "TimeMs": <duration_ms> }
  ```
- For moving a specified distance, prefer `POST /api/drive/hdt` with `Heading`, `Distance`, and `TimeMs`.
- For playing sound, prefer `POST /api/audio/play` with the exact filename.
- Audio/image deletes only work for user-uploaded assets, not system assets.
- Some endpoints are marked Alpha/Beta in vendor docs; behavior may be less stable.

## Minimal examples

### Play sound
```json
POST /api/audio/play
{ "FileName": "002-Weerp.wav" }
```

### Forward 1 second
```json
POST /api/drive/time
{ "LinearVelocity": 10, "AngularVelocity": 0, "TimeMs": 1000 }
```

### Backward 1 second
```json
POST /api/drive/time
{ "LinearVelocity": -10, "AngularVelocity": 0, "TimeMs": 1000 }
```

### Stop
```json
POST /api/drive/stop
```

### Change LED to green
```json
POST /api/led
{ "Red": 0, "Green": 255, "Blue": 0 }
```
