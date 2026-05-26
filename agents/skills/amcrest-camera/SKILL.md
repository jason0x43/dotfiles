---
name: amcrest-camera
description: Access and control the Amcrest IP camera. Use when the user asks to control, aim, orient, or look around with an Amcrest camera, or to get snapshots from an Amcrest camera. Read the SKILL.md file to use the skill.
---

# Amcrest camera

Use the script at `<skill>/scripts/amcrest.ts` to interact with the camera.

## Key commands

```bash
bun <skill>/scripts/amcrest.ts -h
```

Show help for the script. This is the source of truth for the available command line arguments.

### Check connectivity / identify the camera

```bash
bun <skill>/scripts/amcrest.ts info
```

This returns a single JSON document with general information about the camera.

### Orient the camera

```bash
bun <skill>/scripts/amcrest.ts orient 0 0
bun <skill>/scripts/amcrest.ts orient -45 10 
```

Orient sets the absolute position of the camera, not relative. If you say `orient -45 10`, followed by `orient -45 10`, the camera will not change position, because the second position is the same as the first.

### Take a snapshot

```bash
bun <skill>/scripts/amcrest.ts snapshot <name>
```

Name should be the name for the snapshot without an extension. For example, if name is "snap" and the downloaded image is a jpg, it will be saved to `./snap.jpg`. The script prints out the name of the saved file.

If the user asks to see the image, display the saved file with `show_image`. If you've just read the image with `read`, you don't need to call `show_image`, because `read` also displays the image.

### Orient and take a snapshot

```bash
bun <skill>/scripts/amcrest.ts point-and-shoot -45 10
```

Orient the camera and take a snapshot. The name of the snapshot will be printed.

## Orienting the camera

- When the camera is looking straight ahead, it's orientation is angle=0, pitch=0.
- To look left, reduce the angle. An angle of -90 is directly left. Valid angles are -180 to 180.
- To look up, increase the pitch. A pitch of 90 is straight up. Valid pitches are -6 to 90.
- If an object you're looking for is in the upper right part of the camera view and you want to center it, you would increase both the angle and pitch, moving the camera view to the right and upwards.
- If an object you're looking for is in the upper left part of the camera view and you want to center it, you would decrease the angle and increase the pitch, moving the camera view to the left and upwards.
