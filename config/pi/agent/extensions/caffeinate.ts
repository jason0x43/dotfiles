/**
 * pi-caffeinate — Keep the machine awake while the agent is working.
 *
 * Works on macOS, Linux, and Windows:
 *
 * macOS:   Spawns `caffeinate -i` which creates a keep-awake
 *          assertion via IOKit.
 *
 * Linux:   Spawns `systemd-inhibit --what=idle ... sleep infinity`
 *          which takes an idle inhibitor lock via logind.
 *          Falls back silently if systemd-inhibit is not available
 *          (e.g. non-systemd distros).
 *
 * Windows: Spawns a PowerShell process that calls
 *          SetThreadExecutionState(ES_CONTINUOUS | ES_SYSTEM_REQUIRED)
 *          via kernel32.dll P/Invoke, then waits forever. Killing the
 *          process releases the execution state automatically.
 *
 * On all platforms only idle sleep is affected — display sleep,
 * lid-close sleep, and explicit user-initiated sleep work normally.
 * The machine is kept awake only while the agent is running (not
 * while waiting for user input).
 *
 * A process.on('exit') handler acts as a safety net so that the
 * child is always cleaned up, even if pi exits without firing
 * session_shutdown (e.g. uncaught exception).
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { spawn, type ChildProcess } from "node:child_process";
import { platform } from "node:os";

/**
 * Build the command + args to keep the machine awake on the current platform.
 * Returns null if the platform is unsupported.
 */
function getCommand(): { cmd: string; args: string[] } | null {
  switch (platform()) {
    case "darwin":
      return { cmd: "caffeinate", args: ["-i"] };

    case "linux":
      return {
        cmd: "systemd-inhibit",
        args: [
          "--what=idle",
          "--who=pi-caffeinate",
          "--why=Keeping machine awake for Pi agent",
          "--mode=block",
          "sleep",
          "infinity",
        ],
      };

    case "win32":
      // PowerShell one-liner that:
      // 1. Adds a P/Invoke signature for SetThreadExecutionState
      // 2. Calls it with ES_CONTINUOUS | ES_SYSTEM_REQUIRED (0x80000001)
      // 3. Sleeps forever (the execution state is thread-scoped and
      //    released automatically when the process exits)
      return {
        cmd: "powershell.exe",
        args: [
          "-NoProfile",
          "-NoLogo",
          "-WindowStyle",
          "Hidden",
          "-Command",
          [
            "Add-Type -MemberDefinition",
            "'[DllImport(\"kernel32.dll\")] public static extern uint SetThreadExecutionState(uint esFlags);'",
            "-Name NativeMethods -Namespace Win32;",
            "[Win32.NativeMethods]::SetThreadExecutionState(0x80000001);",
            "[Threading.Thread]::Sleep([Threading.Timeout]::Infinite)",
          ].join(" "),
        ],
      };

    default:
      return null;
  }
}

export default function (pi: ExtensionAPI) {
  const maybeCommand = getCommand();
  if (!maybeCommand) {
    return;
  }

  const command = maybeCommand;
  let proc: ChildProcess | null = null;

  function caffeinate() {
    if (proc) {
      return;
    }

    proc = spawn(command.cmd, command.args, {
      stdio: "ignore",
      detached: false,
    });

    proc.on("error", () => {
      proc = null;
    });

    proc.on("exit", () => {
      proc = null;
    });
  }

  function decaffeinate() {
    if (!proc) {
      return;
    }

    proc.kill();
    proc = null;
  }

  // Decaffeinate when the pi process exits.
  process.on("exit", () => {
    decaffeinate();
  });

  pi.on("agent_start", async () => {
    caffeinate();
  });

  pi.on("agent_end", async () => {
    decaffeinate();
  });

  pi.on("session_shutdown", async () => {
    decaffeinate();
  });
}
