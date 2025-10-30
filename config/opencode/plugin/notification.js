// @ts-check

/** @typedef {import('@opencode-ai/plugin').Plugin} Plugin */

/** @type {Plugin} */
export const NotificationPlugin = async ({ $ }) => {
  return {
    event: async ({ event }) => {
      // Send notification on session completion
      if (event.type === "session.idle") {
        await $`osascript -e 'display notification "Session completed!" with title "opencode"'`;
      }
    },
  };
};
