/**
 * Minimal Mode Extension
 *
 * Overrides built-in tools to provide a "minimal" display mode:
 * - read, find, grep, ls → collapsed by default (summary count when collapsed, full output when expanded)
 * - bash (read-only commands) → collapsed by default; write/edit/unsafe commands → always full output
 * - On session_start, calls ctx.ui.setToolsExpanded(false) so the session starts in collapsed state
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import {
  createBashTool,
  createEditTool,
  createFindTool,
  createGrepTool,
  createLsTool,
  createReadTool,
  createWriteTool,
} from "@mariozechner/pi-coding-agent";
import { Text } from "@mariozechner/pi-tui";
import { homedir } from "os";

/**
 * Shorten a path by replacing home directory with ~
 */
function shortenPath(path: string): string {
  const home = homedir();
  if (path.startsWith(home)) {
    return `~${path.slice(home.length)}`;
  }
  return path;
}

// Cache for built-in tools by cwd
const toolCache = new Map<string, ReturnType<typeof createBuiltInTools>>();

function createBuiltInTools(cwd: string) {
  return {
    read: createReadTool(cwd),
    bash: createBashTool(cwd),
    edit: createEditTool(cwd),
    write: createWriteTool(cwd),
    find: createFindTool(cwd),
    grep: createGrepTool(cwd),
    ls: createLsTool(cwd),
  };
}

function getBuiltInTools(cwd: string) {
  let tools = toolCache.get(cwd);
  if (!tools) {
    tools = createBuiltInTools(cwd);
    toolCache.set(cwd, tools);
  }
  return tools;
}

/** Read-only bash commands that are collapsed by default. */
const READONLY_BASH_COMMANDS = new Set([
  "cat",
  "head",
  "tail",
  "wc",
  "sort",
  "uniq",
  "cut",
  "tr",
  "jq",
  "yq",
  "awk",
  "sed",
  "grep",
  "rg",
  "fd",
  "fzf",
  "diff",
  "patch",
  "xz",
  "zstd",
  "gzip",
  "gunzip",
  "base64",
  "md5sum",
  "sha256sum",
  "sha1sum",
  "stat",
  "file",
  "dirname",
  "basename",
  "realpath",
  "readlink",
  "hexdump",
  "od",
  "strings",
  "tree",
  "ls",
  "find",
  "echo",
  "printf",
  "date",
  "id",
  "whoami",
  "pwd",
  "env",
  "export",
  "unset",
]);

/**
 * Detect if a bash command is read-only and safe to collapse.
 * Every command in the chain must be in READONLY_BASH_COMMANDS.
 * Any write/edit/destructive operator (->, | tee, ;, ||, &&) disqualifies the whole command.
 */
function isReadonlyBash(command: string): boolean {
  const trimmed = command.trim();
  if (!trimmed) {
    return false;
  }

  // Split on command chain separators: ;  ||  &&
  // Each segment may contain pipes internally — those are fine for read-only tools.
  const chain = trimmed.split(/\s*(?:;|\|\||&&)\s*/);

  for (const segment of chain) {
    // Extract the primary command (first word, before any | pipe)
    const primary = segment
      .trim()
      .split(/\s*\|\s*/)[0]
      .trim()
      .split(/\s+/)[0];
    if (!primary) continue;

    // Unknown command → not read-only
    if (!READONLY_BASH_COMMANDS.has(primary)) {
      return false;
    }
  }

  // Additional safety: reject if any destructive operators are present anywhere.
  // This catches commands that look safe individually but have write redirects.
  const destructive =
    /\b(>|>>|\|\s*(tee|xargs)|\\\x00|\brm\b|\bmv\b|\bcp\b|\bdd\b|\btruncate\b|\bchmod\b|\bchown\b|\btouch\b|\bmkdir\b|\brmdir\b|\bunlink\b|\bkill\b|\bpkill\b|\bkillall\b|\bwget\b|\bcurl\b|\bnc\b|\bexec\b|\bsource\b)/i;
  if (destructive.test(trimmed)) {
    return false;
  }

  return true;
}

export default function (pi: ExtensionAPI) {
  // Start session in collapsed (minimal) state
  pi.on("session_start", (_event, ctx) => {
    ctx.ui.setToolsExpanded(false);
    ctx.ui.setStatus("minimal-mode", "[ctrl+o: expand]");
  });

  // =========================================================================
  // Read Tool (collapsible: collapsed = empty, expanded = full output)
  // =========================================================================
  pi.registerTool({
    name: "read",
    label: "read",
    description:
      "Read the contents of a file. Supports text files and images (jpg, png, gif, webp). Images are sent as attachments. For text files, output is truncated to 2000 lines or 50KB (whichever is hit first). Use offset/limit for large files.",
    parameters: getBuiltInTools(process.cwd()).read.parameters,

    async execute(toolCallId, params, signal, onUpdate, ctx) {
      const tools = getBuiltInTools(ctx.cwd);
      return tools.read.execute(toolCallId, params, signal, onUpdate);
    },

    renderCall(args, theme) {
      const path = shortenPath(args.path || "");
      let pathDisplay = path
        ? theme.fg("accent", path)
        : theme.fg("toolOutput", "...");

      if (args.offset !== undefined || args.limit !== undefined) {
        const startLine = args.offset ?? 1;
        const endLine =
          args.limit !== undefined ? startLine + args.limit - 1 : "";
        pathDisplay += theme.fg(
          "warning",
          `:${startLine}${endLine ? `-${endLine}` : ""}`,
        );
      }

      return new Text(
        `${theme.fg("toolTitle", theme.bold("read"))} ${pathDisplay}`,
        0,
        0,
      );
    },

    renderResult(result, { expanded }, theme) {
      if (!expanded) {
        return new Text("", 0, 0);
      }

      const textContent = result.content.find((c) => c.type === "text");
      if (!textContent || textContent.type !== "text") {
        return new Text("", 0, 0);
      }

      const lines = textContent.text.split("\n");
      const output = lines
        .map((line) => theme.fg("toolOutput", line))
        .join("\n");
      return new Text(`\n${output}`, 0, 0);
    },
  });

  // =========================================================================
  // Bash Tool (read-only commands collapsed, others always full)
  // =========================================================================
  pi.registerTool({
    name: "bash",
    label: "bash",
    description:
      "Execute a bash command in the current working directory. Returns stdout and stderr. Output is truncated to last 2000 lines or 50KB (whichever is hit first).",
    parameters: getBuiltInTools(process.cwd()).bash.parameters,

    async execute(toolCallId, params, signal, onUpdate, ctx) {
      const tools = getBuiltInTools(ctx.cwd);
      return tools.bash.execute(toolCallId, params, signal, onUpdate);
    },

    renderCall(args, theme) {
      const command = args.command || "...";
      const timeout = args.timeout as number | undefined;
      const timeoutSuffix = timeout
        ? theme.fg("muted", ` (timeout ${timeout}s)`)
        : "";
      return new Text(
        theme.fg("toolTitle", theme.bold(`$ ${command}`)) + timeoutSuffix,
        0,
        0,
      );
    },

    renderResult(result, options, theme, context) {
      const command = context.args.command as string | undefined;
      const collapsed = command && isReadonlyBash(command);

      // Collapsed: show only line count
      if (collapsed && !options.expanded) {
        const textContent = result.content.find((c) => c.type === "text");
        if (textContent?.type === "text" && textContent.text.trim()) {
          const count = textContent.text
            .trim()
            .split("\n")
            .filter(Boolean).length;
          return new Text(theme.fg("muted", ` → ${count} lines`), 0, 0);
        }
        return new Text("", 0, 0);
      }

      // Full output: always for write/edit/destructive, or when expanded
      const textContent = result.content.find((c) => c.type === "text");
      if (!textContent || textContent.type !== "text") {
        return new Text("", 0, 0);
      }

      const color = context.isError
        ? (line: string) => theme.fg("error", line)
        : (line: string) => theme.fg("toolOutput", line);
      const output = textContent.text.trim().split("\n").map(color).join("\n");

      if (!output) {
        return new Text("", 0, 0);
      }

      return new Text(`\n${output}`, 0, 0);
    },
  });

  // =========================================================================
  // Write Tool (always full — ignores expanded toggle)
  // =========================================================================
  pi.registerTool({
    name: "write",
    label: "write",
    description:
      "Write content to a file. Creates the file if it doesn't exist, overwrites if it does. Automatically creates parent directories.",
    parameters: getBuiltInTools(process.cwd()).write.parameters,

    async execute(toolCallId, params, signal, onUpdate, ctx) {
      const tools = getBuiltInTools(ctx.cwd);
      return tools.write.execute(toolCallId, params, signal, onUpdate);
    },

    renderCall(args, theme) {
      const path = shortenPath(args.path || "");
      const pathDisplay = path
        ? theme.fg("accent", path)
        : theme.fg("toolOutput", "...");
      const lineCount = args.content ? args.content.split("\n").length : 0;
      const lineInfo =
        lineCount > 0 ? theme.fg("muted", ` (${lineCount} lines)`) : "";
      return new Text(
        `${theme.fg("toolTitle", theme.bold("write"))} ${pathDisplay}${lineInfo}`,
        0,
        0,
      );
    },

    renderResult(result, _options, theme) {
      // Always show full output — ignore the expanded toggle
      if (result.content.some((c) => c.type === "text" && c.text)) {
        const textContent = result.content.find((c) => c.type === "text");
        if (textContent?.type === "text" && textContent.text) {
          return new Text(`\n${theme.fg("error", textContent.text)}`, 0, 0);
        }
      }
      return new Text("", 0, 0);
    },
  });

  // =========================================================================
  // Edit Tool (always full — ignores expanded toggle)
  // =========================================================================
  pi.registerTool({
    name: "edit",
    label: "edit",
    description:
      "Edit a file by replacing exact text. The oldText must match exactly (including whitespace). Use this for precise, surgical edits.",
    parameters: getBuiltInTools(process.cwd()).edit.parameters,

    async execute(toolCallId, params, signal, onUpdate, ctx) {
      const tools = getBuiltInTools(ctx.cwd);
      return tools.edit.execute(toolCallId, params, signal, onUpdate);
    },

    renderCall(args, theme) {
      const path = shortenPath(args.path || "");
      const pathDisplay = path
        ? theme.fg("accent", path)
        : theme.fg("toolOutput", "...");
      return new Text(
        `${theme.fg("toolTitle", theme.bold("edit"))} ${pathDisplay}`,
        0,
        0,
      );
    },

    renderResult(result, _options, theme, context) {
      // Always show full output — ignore the expanded toggle
      const textContent = result.content.find((c) => c.type === "text");
      if (!textContent || textContent.type !== "text") {
        return new Text("", 0, 0);
      }

      const text = textContent.text;
      if (context.isError || text.includes("Error") || text.includes("error")) {
        return new Text(`\n${theme.fg("error", text)}`, 0, 0);
      }

      return new Text(`\n${theme.fg("toolOutput", text)}`, 0, 0);
    },
  });

  // =========================================================================
  // Find Tool (collapsible: collapsed = "→ N files", expanded = full list)
  // =========================================================================
  pi.registerTool({
    name: "find",
    label: "find",
    description:
      "Find files by name pattern (glob). Searches recursively from the specified path. Output limited to 200 results.",
    parameters: getBuiltInTools(process.cwd()).find.parameters,

    async execute(toolCallId, params, signal, onUpdate, ctx) {
      const tools = getBuiltInTools(ctx.cwd);
      return tools.find.execute(toolCallId, params, signal, onUpdate);
    },

    renderCall(args, theme) {
      const pattern = args.pattern || "";
      const path = shortenPath(args.path || ".");
      const limit = args.limit;

      let text = `${theme.fg("toolTitle", theme.bold("find"))} ${theme.fg("accent", pattern)}`;
      text += theme.fg("toolOutput", ` in ${path}`);
      if (limit !== undefined) {
        text += theme.fg("toolOutput", ` (limit ${limit})`);
      }

      return new Text(text, 0, 0);
    },

    renderResult(result, { expanded }, theme) {
      if (!expanded) {
        const textContent = result.content.find((c) => c.type === "text");
        if (textContent?.type === "text") {
          const count = textContent.text
            .trim()
            .split("\n")
            .filter(Boolean).length;
          if (count > 0) {
            return new Text(theme.fg("muted", ` → ${count} files`), 0, 0);
          }
        }
        return new Text("", 0, 0);
      }

      const textContent = result.content.find((c) => c.type === "text");
      if (!textContent || textContent.type !== "text") {
        return new Text("", 0, 0);
      }

      const output = textContent.text
        .trim()
        .split("\n")
        .map((line) => theme.fg("toolOutput", line))
        .join("\n");

      return new Text(`\n${output}`, 0, 0);
    },
  });

  // =========================================================================
  // Grep Tool (collapsible: collapsed = "→ N matches", expanded = full results)
  // =========================================================================
  pi.registerTool({
    name: "grep",
    label: "grep",
    description:
      "Search file contents by regex pattern. Uses ripgrep for fast searching. Output limited to 200 matches.",
    parameters: getBuiltInTools(process.cwd()).grep.parameters,

    async execute(toolCallId, params, signal, onUpdate, ctx) {
      const tools = getBuiltInTools(ctx.cwd);
      return tools.grep.execute(toolCallId, params, signal, onUpdate);
    },

    renderCall(args, theme) {
      const pattern = args.pattern || "";
      const path = shortenPath(args.path || ".");
      const glob = args.glob;
      const limit = args.limit;

      let text = `${theme.fg("toolTitle", theme.bold("grep"))} ${theme.fg("accent", `/${pattern}/`)}`;
      text += theme.fg("toolOutput", ` in ${path}`);
      if (glob) {
        text += theme.fg("toolOutput", ` (${glob})`);
      }
      if (limit !== undefined) {
        text += theme.fg("toolOutput", ` limit ${limit}`);
      }

      return new Text(text, 0, 0);
    },

    renderResult(result, { expanded }, theme) {
      if (!expanded) {
        const textContent = result.content.find((c) => c.type === "text");
        if (textContent?.type === "text") {
          const count = textContent.text
            .trim()
            .split("\n")
            .filter(Boolean).length;
          if (count > 0) {
            return new Text(theme.fg("muted", ` → ${count} matches`), 0, 0);
          }
        }
        return new Text("", 0, 0);
      }

      const textContent = result.content.find((c) => c.type === "text");
      if (!textContent || textContent.type !== "text") {
        return new Text("", 0, 0);
      }

      const output = textContent.text
        .trim()
        .split("\n")
        .map((line) => theme.fg("toolOutput", line))
        .join("\n");

      return new Text(`\n${output}`, 0, 0);
    },
  });

  // =========================================================================
  // Ls Tool (collapsible: collapsed = "→ N entries", expanded = full listing)
  // =========================================================================
  pi.registerTool({
    name: "ls",
    label: "ls",
    description:
      "List directory contents with file sizes. Shows files and directories with their sizes. Output limited to 500 entries.",
    parameters: getBuiltInTools(process.cwd()).ls.parameters,

    async execute(toolCallId, params, signal, onUpdate, ctx) {
      const tools = getBuiltInTools(ctx.cwd);
      return tools.ls.execute(toolCallId, params, signal, onUpdate);
    },

    renderCall(args, theme) {
      const path = shortenPath(args.path || ".");
      const limit = args.limit;

      let text = `${theme.fg("toolTitle", theme.bold("ls"))} ${theme.fg("accent", path)}`;
      if (limit !== undefined) {
        text += theme.fg("toolOutput", ` (limit ${limit})`);
      }

      return new Text(text, 0, 0);
    },

    renderResult(result, { expanded }, theme) {
      if (!expanded) {
        const textContent = result.content.find((c) => c.type === "text");
        if (textContent?.type === "text") {
          const count = textContent.text
            .trim()
            .split("\n")
            .filter(Boolean).length;
          if (count > 0) {
            return new Text(theme.fg("muted", ` → ${count} entries`), 0, 0);
          }
        }
        return new Text("", 0, 0);
      }

      const textContent = result.content.find((c) => c.type === "text");
      if (!textContent || textContent.type !== "text") {
        return new Text("", 0, 0);
      }

      const output = textContent.text
        .trim()
        .split("\n")
        .map((line) => theme.fg("toolOutput", line))
        .join("\n");

      return new Text(`\n${output}`, 0, 0);
    },
  });
}
