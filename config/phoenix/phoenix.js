/// <reference no-default-lib="true" />
/// <reference lib="es2015" />
/// <reference types="./phoenix.d.ts" />
// @ts-check

////////////////////////////////////////////////////////////////////////////////
//
// General setup
//

Phoenix.set({
  daemon: false,
  openAtLogin: true,
});

Event.on("willTerminate", () => {
  Storage.remove("lastPositions");
  Storage.remove("maxHeight");
});

// Event.on('mouseDidMove', focusWindowUnderMouse);

////////////////////////////////////////////////////////////////////////////////
//
// Constants
//

// Globals
const INCREMENT = 0.05;
const CONTROL_SHIFT = ["ctrl", "shift"];
const CONTROL_ALT_SHIFT = ["ctrl", "alt", "shift"];
const PADDING = 10;

// Relative Directions
const LEFT = "left";
const RIGHT = "right";
const CENTER = "center";

// Cardinal Directions
const NW = "nw";
const NE = "ne";
const SE = "se";
const SW = "sw";
const EAST = "east";
const WEST = "west";
const NORTH = "north";
const SOUTH = "south";

const MODAL_TIMEOUT = 750;
const THIN_WIDTH = (1020 / 3840) * 1.6;

/** @type {number | null} */
let helpTimer = null;
/** @type {(() => void) | null} */
let helpCloser = null;

////////////////////////////////////////////////////////////////////////////////
//
// bindings
//

/** @type {[string, string, string[], () => unknown][]} */
const keys = [
  ["Show help", "\\", CONTROL_SHIFT, () => showHelp()],

  ["Move to NW corner", "q", CONTROL_SHIFT, () => moveTo(NW)],
  ["Move to NE corner", "w", CONTROL_SHIFT, () => moveTo(NE)],
  ["Move to SE corner", "s", CONTROL_SHIFT, () => moveTo(SE)],
  ["Move to SW corner", "a", CONTROL_SHIFT, () => moveTo(SW)],
  ["Move to center", "z", CONTROL_SHIFT, () => moveTo(CENTER)],
  ["Development layout", "space", CONTROL_SHIFT, () => autoLayout()],

  [
    "Fill NW quadrant",
    "q",
    CONTROL_ALT_SHIFT,
    () => fill(NW, { portion: 1 - THIN_WIDTH }),
  ],
  [
    "Fill SW quadrant",
    "a",
    CONTROL_ALT_SHIFT,
    () => fill(SW, { portion: 1 - THIN_WIDTH }),
  ],
  [
    "Fill SE quadrant",
    "s",
    CONTROL_ALT_SHIFT,
    () => fill(SE, { portion: THIN_WIDTH }),
  ],
  [
    "Fill NE quadrant",
    "w",
    CONTROL_ALT_SHIFT,
    () => fill(NE, { portion: THIN_WIDTH }),
  ],
  [
    "Fill left half",
    "h",
    CONTROL_ALT_SHIFT,
    () => fill(LEFT, { portion: 1 - THIN_WIDTH }),
  ],
  [
    "Fill right half",
    "l",
    CONTROL_ALT_SHIFT,
    () => fill(RIGHT, { portion: THIN_WIDTH }),
  ],
  ["Fill screen", "f", CONTROL_ALT_SHIFT, () => toggleFillScreen()],
  ["Fill center", "z", CONTROL_ALT_SHIFT, () => center()],

  [
    "Increase height",
    "'",
    CONTROL_SHIFT,
    () => resize({ height: heightPercent(INCREMENT) }),
  ],
  [
    "Decrease height",
    ";",
    CONTROL_SHIFT,
    () => resize({ height: -heightPercent(INCREMENT) }),
  ],
  [
    "Increase width",
    "]",
    CONTROL_SHIFT,
    () => resize({ width: widthPercent(INCREMENT) }),
  ],
  [
    "Decrease width",
    "[",
    CONTROL_SHIFT,
    () => resize({ width: -widthPercent(INCREMENT) }),
  ],

  ["Focus western neighbor", "h", CONTROL_SHIFT, () => focusNeighbor(WEST)],
  ["Focus southern neighbor", "j", CONTROL_SHIFT, () => focusNeighbor(SOUTH)],
  ["Focus northern neighbor", "k", CONTROL_SHIFT, () => focusNeighbor(NORTH)],
  ["Focus eastern neighbor", "l", CONTROL_SHIFT, () => focusNeighbor(EAST)],

  ["Move to right display", "right", CONTROL_SHIFT, () => moveToScreen(RIGHT)],
  ["Move to left display", "left", CONTROL_SHIFT, () => moveToScreen(LEFT)],

  ["Move to right space", "right", CONTROL_ALT_SHIFT, () => moveToSpace(RIGHT)],
  ["Move to left space", "left", CONTROL_ALT_SHIFT, () => moveToSpace(LEFT)],
];

for (const binding of keys) {
  Key.on(binding[1], binding[2], binding[3]);
}

////////////////////////////////////////////////////////////////////////////////
//
// Helper functions
//

/**
 * Get the windows for an app in a space
 *
 * This is much, much more efficient than using Space.windows and finding the
 * ones belonging to particular apps.
 *
 * @param {string} appName
 * @param {Space} space
 */
function getWindowsInSpace(appName, space) {
  const app = App.get(appName);
  if (!app) {
    Phoenix.log(`Could not find app ${appName}`);
    return [];
  }

  return app
    .windows({ visible: true })
    .filter((win) => win.spaces().find((s) => s.isEqual(space)));
}

/**
 * Layout a browser and terminal in a screen for development
 */
function autoLayout() {
  const space = Space.active();
  if (space.isFullScreen()) {
    return;
  }

  // space with one browser window and one terminal window

  const browserWins = [
    ...getWindowsInSpace("Safari", space),
    ...getWindowsInSpace("Wavebox", space),
    ...getWindowsInSpace("Google Chrome", space),
    ...getWindowsInSpace("Firefox", space),
  ];
  const terminalWins = getWindowsInSpace("kitty", space);
  if (browserWins.length === 1 && terminalWins.length === 1) {
    fill(LEFT, { window: browserWins[0], portion: 1 - THIN_WIDTH });
    fill(RIGHT, { window: terminalWins[0], portion: THIN_WIDTH });
    return;
  }

  // space with a reeder window

  const reederWins = getWindowsInSpace("Reeder", space);
  if (reederWins.length === 1) {
    moveTo(CENTER, reederWins[0]);
    return;
  }

  // space with a wavebox window

  const waveboxWins = getWindowsInSpace("Wavebox", space);
  if (waveboxWins.length === 1) {
    const messagesWins = getWindowsInSpace("Messages", space);

    if (messagesWins.length > 0) {
      fill(LEFT, { window: messagesWins[0], portion: 0.32 });
      fill(RIGHT, { window: waveboxWins[0], widthMinus: 90 });
    } else {
      fill(CENTER, { window: waveboxWins[0] });
    }

    return;
  }

  // space with Slack window
  const slackWins = getWindowsInSpace("Slack", space);
  if (slackWins.length === 1) {
    const messagesWins = getWindowsInSpace("Messages", space);

    if (messagesWins.length > 0) {
      fill(LEFT, { window: messagesWins[0], portion: 0.32 });
      fill(RIGHT, { window: slackWins[0], portion: 0.68 });
    } else {
      fill(CENTER, { window: slackWins[0] });
    }

    return;
  }
}

/**
 * Add icon space to a screen frame
 *
 * @param {Rectangle} frame
 */
function addIconSpace(frame) {
  return {
    ...frame,
    width: frame.width - 90,
  };
}

/**
 * Center a window on the screen and make it take up a large portion of the screen
 *
 * @param {Window} [window]
 */
function center(window = Window.focused()) {
  const screenFrame = getScreenFrame(window);
  const isLargeScreen = screenFrame.width > 2000;
  const widthScale = isLargeScreen ? 0.6 : 0.8;
  const heightScale = isLargeScreen ? 0.8 : 0.9;

  window.setSize({
    width: Math.round(screenFrame.width * widthScale),
    height: Math.round(screenFrame.height * heightScale),
  });

  moveTo(CENTER);
}

/**
 * Return the bottom left coordinate in frame2 that will center frame1 within
 * it
 *
 * @param {Rectangle} frame1
 * @param {Rectangle} [frame2]
 */
function centerFrame(frame1, frame2) {
  frame2 = frame2 || getScreenFrame();
  const x = frame2.x + Math.round(frame2.width / 2 - frame1.width / 2);
  const y = frame2.y + Math.round(frame2.height / 2 - frame1.height / 2);
  return { x, y };
}

/**
 * Fill an area of the screen
 *
 * @param {string} area
 * @param {{
 *   window?: Window,
 *   portion?: number,
 *   width?: number,
 *   widthMinus?: number
 * }} options
 */
function fill(area, options = {}) {
  let { window, portion, width, widthMinus } = options;

  window = window || Window.focused();
  if (!window) {
    return;
  }

  let screenFrame = getScreenFrame(window);
  const isLargeScreen = screenFrame.width > 2000;
  const frame = window.frame();

  if (isLargeScreen) {
    screenFrame = addIconSpace(screenFrame);
  }

  if (portion) {
    width = screenFrame.width * portion;
  } else if (widthMinus) {
    width = screenFrame.width - widthMinus;
  }

  if (!width) {
    width = screenFrame.width / 2;
  }

  Phoenix.log(`windowFrame: ${JSON.stringify(frame)}`);
  Phoenix.log(`screenFrame: ${JSON.stringify(screenFrame)}`);

  const bounds = {};

  // size
  switch (area) {
    case NW:
    case NE:
    case SW:
    case SE:
      bounds.height = screenFrame.height / 2 - 0.5 * PADDING;
      bounds.width = width - PADDING;
      break;
    case LEFT:
    case RIGHT:
      bounds.height = screenFrame.height;
      bounds.width = width - PADDING;
      break;
    case CENTER:
      bounds.height = screenFrame.height;
      bounds.width = screenFrame.width;
      break;
  }

  frame.height = bounds.height;
  frame.width = bounds.width;

  if (isLargeScreen) {
    switch (area) {
      case LEFT:
      case RIGHT:
      case CENTER:
        frame.height *= 0.95;
        frame.width *= 0.95;
        break;
    }
  }

  // x-coordinate
  switch (area) {
    case NW:
    case SW:
      frame.x = screenFrame.x;
      break;
    case LEFT:
      frame.x = screenFrame.x + (bounds.width - frame.width) / 2;
      break;
    case CENTER:
      frame.x = screenFrame.x + (screenFrame.width - frame.width) / 2;
      break;
    case NE:
    case SE:
    case RIGHT:
      frame.x = screenFrame.x +
        (screenFrame.width - bounds.width) +
        (bounds.width - frame.width - PADDING) / 2;
      break;
  }

  // y-coordinate
  switch (area) {
    case NW:
    case NE:
      frame.y = screenFrame.y;
      break;
    case RIGHT:
    case LEFT:
    case CENTER:
      frame.y = screenFrame.y + (screenFrame.height - frame.height) / 2;
      break;
    case SE:
    case SW:
      frame.y = screenFrame.y + frame.height + PADDING;
      break;
  }

  Phoenix.log(`Setting frame to ${JSON.stringify(frame)}`);
  window.setFrame(frame);
}

/**
 * Move focus to the closest neighbor in a given direction
 *
 * @param {string} direction
 * @param {Window} [window]
 */
function focusNeighbor(direction, window = Window.focused()) {
  const neighbors = window.neighbors(direction);
  for (const n of neighbors) {
    if (n.isVisible()) {
      n.focus();
      break;
    }
  }
}

/** @type {number} */
let focusTimer;

/**
 * Focus the window currently under the mouse cursor
 *
 * @param {Point} position
 */
function _focusWindowUnderMouse(position) {
  clearTimeout(focusTimer);
  const args = Array.prototype.slice.call(arguments);
  focusTimer = setTimeout(() => {
    Phoenix.log("Focus event: " + JSON.stringify(args));
    const window = getWindowAt(position);
    if (window) {
      Phoenix.log("Focusing window", JSON.stringify(window.app().name()));
      // window.focus();
    }
  }, 100);
}

/**
 * Indicate whether two frames are equal
 *
 * @param {Rectangle} frame1
 * @param {Rectangle} frame2
 */
function framesEqual(frame1, frame2) {
  if (!frame1 && !frame2) {
    return true;
  }
  if (!frame1 || !frame2) {
    return false;
  }
  return (
    frame1.x == frame2.x &&
    frame1.y == frame2.y &&
    frame1.width == frame2.width &&
    frame1.height == frame2.height
  );
}

/**
 * Get a delta frame between a window and its screen
 *
 * @param {Window} [window]
 */
function getDeltaFrame(window = Window.focused()) {
  const frame = window.frame();
  const screen = getScreenFrame(window);

  return {
    x: screen.x - frame.x,
    y: screen.y - frame.y,
    width: screen.width - frame.width,
    height: screen.height - frame.height,
  };
}

/**
 * Parent frame
 *
 * @param {Window} [window]
 */
function getScreenFrame(window = Window.focused()) {
  const screenFrame = window.screen().flippedVisibleFrame();
  Phoenix.log(`screenFrame: ${JSON.stringify(screenFrame)}`);
  return padScreenFrame(screenFrame);
}

/**
 * Return the window at a given position
 *
 * @param {Point} position
 */
function getWindowAt(position) {
  // If Window.at works, take it
  let win = Window.at(position);
  if (win) {
    Phoenix.log("Returning Window.at");
    return win;
  }

  // If the mouse is still within the bounds of the currently focused window,
  // keep focus there
  const focused = Window.focused();
  if (focused && isWithin(position, focused.frame())) {
    Phoenix.log("Returning focused window");
    return focused;
  }

  // Return the first window that the mouse is within
  for (const w of Window.all({ visible: true })) {
    if (isWithin(position, w.frame())) {
      Phoenix.log("May be " + w.app().name());
      if (!win) {
        win = w;
      }
      // return w;
    }
  }
  return win;
}

/**
 * Get a percent of the screen height
 *
 * @param {number} percent
 * @param {Window} [window]
 */
function heightPercent(percent, window = Window.focused()) {
  const screen = getScreenFrame(window);
  return Math.round(screen.height * percent);
}

/**
 * Return true if a point is within a frame
 *
 * @param {Point} point
 * @param {Rectangle} frame
 */
function isWithin(point, frame) {
  return (
    point.x >= frame.x &&
    point.y >= frame.y &&
    point.x < frame.x + frame.width &&
    point.y < frame.y + frame.height
  );
}

/**
 * Move to cardinal directions NW, NE, SE, SW or relative direction CENTER
 *
 * @param {string} direction
 * @param {Window} [window]
 */
function moveTo(direction, window = Window.focused()) {
  const delta = getDeltaFrame(window);
  const frame = window.frame();
  const screenFrame = getScreenFrame(window);

  // x-coordinate
  switch (direction) {
    case NW:
    case SW:
      frame.x = screenFrame.x;
      break;
    case NE:
    case SE:
      frame.x = screenFrame.x + delta.width;
      break;
    case CENTER:
      frame.x = screenFrame.x + delta.width / 2;
      break;
  }

  // y-coordinate
  switch (direction) {
    case NW:
    case NE:
      frame.y = screenFrame.y;
      break;
    case SE:
    case SW:
      frame.y = screenFrame.y + delta.height;
      break;
    case CENTER:
      frame.y = screenFrame.y + delta.height / 2;
      break;
  }

  Phoenix.log(`Setting frame to ${JSON.stringify(frame)}`);
  window.setFrame(frame);
}

/**
 * Move a window to the screen to the left or right
 *
 * @param {string} direction
 * @param {Window} [window]
 */
function moveToScreen(direction, window = Window.focused()) {
  const screen = window.screen();
  const newScreen = direction === RIGHT ? screen.next() : screen.previous();
  if (screen === newScreen) {
    return;
  }

  const screenFrame = padScreenFrame(screen.flippedVisibleFrame());
  const newScreenFrame = padScreenFrame(newScreen.flippedVisibleFrame());
  const windowFrame = window.frame();

  Phoenix.log(`-------------------------------------------`);
  Phoenix.log(`screenFrame: ${JSON.stringify(screenFrame)}`);
  Phoenix.log(`newScreenFrame: ${JSON.stringify(newScreenFrame)}`);
  Phoenix.log(`windowFrame: ${JSON.stringify(windowFrame)}`);

  const widthRatio = newScreenFrame.width / screenFrame.width;
  const heightRatio = newScreenFrame.height / screenFrame.height;

  const width = Math.round(windowFrame.width * widthRatio);
  const height = Math.round(windowFrame.height * heightRatio);
  const x = Math.round(
    newScreenFrame.x + (windowFrame.x - screenFrame.x) * widthRatio,
  );
  const y = Math.round(
    newScreenFrame.y + (windowFrame.y - screenFrame.y) * heightRatio,
  );
  const newWindowFrame = { x, y, width, height };

  // Moving between screens in a single operation doesn't work reliably, so do
  // the operations one at a time
  if (
    newWindowFrame.height > windowFrame.height ||
    newWindowFrame.width > windowFrame.width
  ) {
    // New window is bigger -- move first
    window.setTopLeft(newWindowFrame);
    window.setSize(newWindowFrame);
  } else {
    // New window is smaller -- shrink it first
    window.setSize(newWindowFrame);
    window.setTopLeft(newWindowFrame);
  }
}

/**
 * Move a window to the space to the left or right
 *
 * @param {string} direction
 * @param {Window} [window]
 */
function moveToSpace(direction, window) {
  window = window || Window.focused();
  if (!window) {
    return;
  }

  const space = Space.active();
  if (!space) {
    return;
  }

  const targetSpace = direction == RIGHT ? space.next() : space.previous();
  if (!targetSpace) {
    return;
  }

  targetSpace.addWindows([window]);
  space.removeWindows([window]);
  window.focus();
}

/**
 * Apply padding to a screen frame
 *
 * @param {Rectangle} frame
 */
function padScreenFrame(frame) {
  return {
    x: frame.x + PADDING,
    y: frame.y + PADDING,
    width: frame.width - 2 * PADDING,
    height: frame.height - 2 * PADDING,
  };
}

/**
 * Resize SE-corner by value
 *
 * @param {{ width?: number, height?: number }} increment
 * @param {Window} [window]
 */
function resize(increment, window = Window.focused()) {
  const screenFrame = getScreenFrame(window);
  const windowFrame = window.frame();

  if (increment.width) {
    const maxWidth = screenFrame.width - (windowFrame.x - screenFrame.x);
    windowFrame.width = Math.min(windowFrame.width + increment.width, maxWidth);
  }

  if (increment.height) {
    const maxHeight = screenFrame.height - (windowFrame.y - screenFrame.y);
    windowFrame.height = Math.min(
      windowFrame.height + increment.height,
      maxHeight,
    );
  }

  window.setFrame(windowFrame);
}

/**
 * Show help
 */
function showHelp() {
  if (helpCloser != null) {
    clearTimeout(helpTimer);
    helpTimer = setTimeout(helpCloser, MODAL_TIMEOUT);
    return;
  }

  /** @param {[string, string, string[], () => unknown][]} modalKeys */
  function makeModal(modalKeys) {
    const lines = [];
    for (const key of modalKeys) {
      lines.push(`${key[2].join("+")}+${key[1]} - ${key[0]}`);
    }
    const text = lines.join("\n");
    return Modal.build({ weight: 20, text });
  }

  const leftKeys = keys.slice(0, Math.ceil(keys.length / 2));
  const rightKeys = keys.slice(leftKeys.length);

  const leftModal = makeModal(leftKeys);
  const rightModal = makeModal(rightKeys);

  const leftFrame = leftModal.frame();
  const leftOrigin = centerFrame(leftFrame);
  leftOrigin.x -= Math.round(leftFrame.width / 2 + PADDING / 2);
  leftModal.origin = leftOrigin;

  const rightFrame = rightModal.frame();
  const rightOrigin = centerFrame(rightFrame);
  rightOrigin.x += Math.round(rightFrame.width / 2 + PADDING / 2);
  rightModal.origin = rightOrigin;

  leftModal.show();
  rightModal.show();

  helpCloser = () => {
    leftModal.close();
    rightModal.close();
    helpCloser = null;
    helpTimer = null;
  };

  helpTimer = setTimeout(helpCloser, MODAL_TIMEOUT);
}

/**
 * Toggle a window between filling the screen and its original size
 *
 * @param {Window} [window]
 */
function toggleFillScreen(window = Window.focused()) {
  const windowId = window.hash();
  /** @type {{ [key: number]: Rectangle }} */
  const lastPositions = Storage.get("lastPositions") || {};
  const windowFrame = window.frame();
  const screenFrame = getScreenFrame();

  if (!framesEqual(windowFrame, screenFrame)) {
    Phoenix.log("Filling center");
    lastPositions[windowId] = { ...windowFrame };
    Storage.set("lastPositions", lastPositions);
    fill(CENTER, { window });
  } else if (lastPositions[windowId]) {
    window.setFrame(lastPositions[windowId]);
  }
}

/**
 * Get a percent of the screen width
 *
 * @param {number} percent
 * @param {Window} [window]
 */
function widthPercent(percent, window = Window.focused()) {
  const screenFrame = getScreenFrame(window);
  return Math.round(screenFrame.width * percent);
}
