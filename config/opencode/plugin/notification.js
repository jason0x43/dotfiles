// @ts-check

import { existsSync } from "node:fs";

/** @typedef {import('@opencode-ai/plugin').Plugin} Plugin */

const NOTIFIER_APP =
  "~/Applications/opencode-notifier.app/Contents/MacOS/terminal-notifier";
const SOUND = "Tink";

/**
 * Resolve ~ to home directory
 * @param {string} path
 * @returns {string}
 */
function expandPath(path) {
  if (path.startsWith("~/")) {
    return path.replace("~", process.env.HOME || "");
  }
  return path;
}

/** @typedef {import('@opencode-ai/plugin').PluginInput} PluginInput */

/**
 * Check if a command exists in PATH
 * @param {PluginInput['$']} $
 * @param {string} cmd
 * @returns {Promise<boolean>}
 */
async function commandExists($, cmd) {
  try {
    await $`which ${cmd}`.quiet();
    return true;
  } catch {
    return false;
  }
}

/**
 * Send a notification using the best available method
 * @param {PluginInput['$']} $
 * @param {string} title
 * @param {string} message
 */
async function notify($, title, message) {
  const notifierPath = expandPath(NOTIFIER_APP);

  if (existsSync(notifierPath)) {
    await $`${notifierPath} -title ${title} -message ${message} -sound ${SOUND}`.quiet();
  } else if (await commandExists($, "terminal-notifier")) {
    await $`terminal-notifier -title ${title} -message ${message} -sound ${SOUND}`.quiet();
  } else {
    await $`osascript -e ${'display notification "' + message + '" with title "' + title + '" sound name "' + SOUND + '"'}`.quiet();
  }
}

/** @type {Plugin} */
export const NotificationPlugin = async ({ $ }) => {
  return {
    event: async ({ event }) => {
      // Send notification on session completion
      if (event.type === "session.idle") {
        await notify($, "opencode", "Session completed!");
      }
    },
  };
};
