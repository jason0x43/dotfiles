import type { Plugin, PluginInput } from "@opencode-ai/plugin";
import { existsSync } from "node:fs";

const NOTIFIER_APP =
  "~/Applications/opencode-notifier.app/Contents/MacOS/terminal-notifier";
const SOUND = "Funk";

/**
 * Resolve ~ to home directory
 */
function expandPath(path: string): string {
  if (path.startsWith("~/")) {
    return path.replace("~", process.env.HOME || "");
  }
  return path;
}

/**
 * Check if a command exists in PATH
 */
async function commandExists($: PluginInput["$"], cmd: string) {
  try {
    await $`which ${cmd}`.quiet();
    return true;
  } catch {
    return false;
  }
}

/**
 * Send a notification using the best available method
 */
async function notify($: PluginInput["$"], title: string, message: string) {
  const notifierPath = expandPath(NOTIFIER_APP);

  if (existsSync(notifierPath)) {
    await $`${notifierPath} -title ${title} -message ${message} -sound ${SOUND}`.quiet();
  } else if (await commandExists($, "terminal-notifier")) {
    await $`terminal-notifier -title ${title} -message ${message} -sound ${SOUND}`.quiet();
  } else {
    await $`osascript -e ${'display notification "' + message + '" with title "' + title + '" sound name "' + SOUND + '"'}`.quiet();
  }
}

export const NotifyPlugin: Plugin = async ({ client, $ }) => {
  return {
    async event(input) {
      if (input.event.type === "session.idle") {
        const sessionID = input.event.properties.sessionID;

        const sessionResult = await client.session.get({
          path: { id: sessionID },
        });

        // If the session has a parentID it's a sub-agent, so don't notify.
        if (sessionResult.data && sessionResult.data.parentID) {
          return;
        }

        await notify($, "opencode", "Session completed!");
      }
    },
  };
};
