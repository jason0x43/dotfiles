import { atom, memberOf, read, update } from "claude-code";
import type { CoreEngineInterface, Register } from "claude-code";

import type { DiffMode } from "../types";

const MODES: DiffMode[] = ["full", "collapsed", "hidden"];
const TOOLS = ["Edit", "MultiEdit", "Write", "NotebookEdit"];

const mode = atom({ plugin: "diffs", key: "mode" } as const, "collapsed");
const isFlipped = atom({ plugin: "diffs", key: "isFlipped" } as const, false);

function isMode(value: unknown): value is DiffMode {
  return MODES.includes(value as DiffMode);
}

type Hunk = { lines?: unknown };

// Counts added and removed lines from a result's structuredPatch, or from the
// written content for a new file.
function stats(output: unknown): { added: number; removed: number } | null {
  if (!output || typeof output !== "object") return null;
  const out = output as {
    type?: string;
    content?: unknown;
    structuredPatch?: unknown;
  };

  let added = 0;
  let removed = 0;
  if (Array.isArray(out.structuredPatch) && out.structuredPatch.length > 0) {
    for (const hunk of out.structuredPatch as Hunk[]) {
      if (!Array.isArray(hunk.lines)) continue;
      for (const line of hunk.lines) {
        if (typeof line !== "string") continue;
        if (line.startsWith("+")) added++;
        else if (line.startsWith("-")) removed++;
      }
    }
    return { added, removed };
  }

  if (out.type === "create" && typeof out.content === "string") {
    const text = out.content.replace(/\n$/, "");
    return { added: text === "" ? 0 : text.split("\n").length, removed: 0 };
  }

  return null;
}

function pathOf(output: unknown): string | undefined {
  if (!output || typeof output !== "object") return undefined;
  const out = output as { filePath?: unknown; notebook_path?: unknown };
  const path = out.filePath ?? out.notebook_path;
  return typeof path === "string" ? path : undefined;
}

function basename(path: string): string {
  return path.slice(path.lastIndexOf("/") + 1);
}

type Engine = Pick<CoreEngineInterface, "env" | "fs" | "session">;

// Each session's mode lives in a file named by its id, which the statusLine
// command reads (its input's session_id) to show the mode on the main status
// line, and which a resumed session reads its mode back from.
async function modeFile($: Engine): Promise<string | undefined> {
  const home = await $.env.get("HOME");
  if (!home) return undefined;
  return `${home}/.local/state/claude/diffs-mode/${await $.session.id()}`;
}

async function publish($: Engine, current: DiffMode) {
  const path = await modeFile($);
  if (!path) return;
  try {
    await $.fs.write(path, current);
  } catch {
    // The status line just goes without it.
  }
}

// Writes this session's mode for the status line; answers the session id.
async function sync(
  $: Engine & Pick<CoreEngineInterface, "state">,
): Promise<string> {
  const id = await $.session.id();
  await publish($, await read($, mode));
  return id;
}

async function recall($: Engine): Promise<DiffMode | undefined> {
  const path = await modeFile($);
  if (!path) return undefined;
  try {
    const text = String(await $.fs.read(path)).trim();
    return isMode(text) ? text : undefined;
  } catch {
    return undefined;
  }
}

type BashEditDiff = {
  files?: { filePath?: string; hunks?: Hunk[] }[];
  moreFiles?: number;
};

// A Bash result's diff of the files the command changed, when it has one.
function bashDiff(output: unknown): BashEditDiff | null {
  if (!output || typeof output !== "object") return null;
  const diff = (output as { bashEditDiff?: BashEditDiff }).bashEditDiff;
  return diff && Array.isArray(diff.files) && diff.files.length > 0
    ? diff
    : null;
}

function bashSummary(diff: BashEditDiff): string {
  let added = 0;
  let removed = 0;
  for (const file of diff.files ?? []) {
    const counts = stats({ structuredPatch: file.hunks });
    added += counts?.added ?? 0;
    removed += counts?.removed ?? 0;
  }
  const count = (diff.files?.length ?? 0) + (diff.moreFiles ?? 0);
  const only = count === 1 ? diff.files?.[0]?.filePath : undefined;
  const what = only ? basename(only) : `${count} files`;
  return `${what} +${added} −${removed}`;
}

export const register: Register = (on) => {
  // The session id last written for; a /clear moves on to a new id without a
  // session.start, so the next prompt writes the file for it.
  let publishedFor: string | undefined;

  on("session.start", async ($, e, next) => {
    const stored = await recall($);
    if (stored) await update($, mode, () => stored);
    publishedFor = await sync($);

    await $.command.register({
      name: "diffs",
      description: "Show, collapse or hide inline diffs (no argument cycles)",
      argumentHint: "[full|collapsed|hidden]",
    });

    return next(e);
  });

  on("command.run", { command: "diffs" }, async ($, e) => {
    const arg = e.args.trim().toLowerCase();
    const current = await read($, mode);

    let wanted: DiffMode;
    if (arg === "") {
      wanted = MODES[(MODES.indexOf(current) + 1) % MODES.length] ?? "full";
    } else if (isMode(arg)) {
      wanted = arg;
    } else {
      return { text: `Unknown mode "${arg}". Use full, collapsed or hidden.` };
    }

    await update($, mode, () => wanted);
    publishedFor = await sync($);

    return {};
  });

  on("prompt.submit", async ($, e, next) => {
    if ((await $.session.id()) !== publishedFor) {
      publishedFor = await sync($);
    }
    return next(e);
  });

  on("ui.render", { component: "ToolResult" }, async ($, e, next) => {
    // ctrl+o and --verbose always show everything; errors show their text.
    if (e.props.isExpanded || e.props.isErrored) return next(e);

    // Bash keeps its own output; only the diff of changed files under it is
    // folded away.
    const fromBash = e.props.tool === "Bash" ? bashDiff(e.props.output) : null;
    if (!fromBash && !TOOLS.includes(e.props.tool)) return next(e);

    const current = await read($, mode);
    const flip = memberOf(isFlipped, e);
    const flipped = await read($, flip);
    const { Box, Button, Text } = $.ui.resolve(e);

    const withoutDiff = () => {
      const { bashEditDiff: _, ...output } = e.props.output as Record<
        string,
        unknown
      >;
      return next({ ...e, props: { ...e.props, output } });
    };

    if (current === "hidden") return fromBash ? withoutDiff() : <Box />;

    const toggle = (label: string) => (
      <Button
        key="toggle"
        label={label}
        plain
        dimColor
        onPress={() => update($, flip, (v) => !v)}
      />
    );

    const isOpen = current === "full" ? !flipped : flipped;
    if (isOpen) {
      if (current === "full") return next(e);
      return (
        <Box flexDirection="column">
          {await next(e)}
          <Box paddingLeft={5}>{toggle("▾ collapse diff")}</Box>
        </Box>
      );
    }

    const parts: string[] = [];
    if (fromBash) {
      parts.push(bashSummary(fromBash));
    } else {
      const counts = stats(e.props.output);
      const path = pathOf(e.props.output);
      if (path) parts.push(basename(path));
      if (counts) parts.push(`+${counts.added} −${counts.removed}`);
    }

    const summary = (
      <Box paddingLeft={5}>
        <Text dimColor>{parts.length ? `${parts.join(" ")} · ` : ""}</Text>
        {toggle("▸ show diff")}
      </Box>
    );
    if (!fromBash) return summary;

    return (
      <Box flexDirection="column">
        {await withoutDiff()}
        {summary}
      </Box>
    );
  });
};
