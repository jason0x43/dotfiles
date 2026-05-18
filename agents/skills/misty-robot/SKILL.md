---
name: misty-robot
description: Instructions for interacting with a Mist robot; use when the user asks to interact with a Mistry robot.
---
- Use environment variables for credentials when running commands:
  ```bash
  export MISTY_HOST=10.0.0.221
  ```
- Use the cached local REST API reference first: `<this skill directory>/references/misty-rest-api.md`
- Use `<this skill directory>/scripts/take_picture.py` when asked to take a picture with Misty. It defaults to `1280x960` unless a different width/height is specified. Always show the picture you took.
- Use `<this skill directory>/scripts/move_head.py` when you need Misty to move its head and wait until the move completes before continuing. It sends `POST /api/head` and waits on `ActuatorPosition` WebSocket events before returning.
- `move_head.py` always sends explicit `Pitch`, `Roll`, and `Yaw` values. Any omitted axis defaults to `0`, so if you only want to change one axis, pass the current values for the others or Misty may re-center them.
- For Misty head rotation, right turns use negative yaw values and left turns use positive yaw values. For example, 90 degrees right is `--yaw -90`.
- For Misty head pitch, positive values tilt the camera downward and negative values tilt it upward.
- Head moves can stop a couple degrees off target; the helper script treats positions within a small tolerance as complete.
- If `move_head.py` times out waiting for WebSocket actuator events, retry with a lower velocity and/or a longer timeout.
- Original vendor source for the REST API reference: https://docs.mistyrobotics.com/misty-ii/reference/rest/
