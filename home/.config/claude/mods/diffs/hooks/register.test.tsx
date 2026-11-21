import { expect, test } from "claude-code/testing";

const EDIT = {
  plugin: "diffs",
  component: "ToolResult",
  requestId: "tu1",
  props: {
    tool_use_id: "tu1",
    tool: "Edit",
    isErrored: false,
    isExpanded: false,
    output: {
      filePath: "/a/b/foo.ts",
      oldString: "a",
      newString: "b",
      originalFile: "a",
      userModified: false,
      replaceAll: false,
      structuredPatch: [
        {
          oldStart: 1,
          oldLines: 2,
          newStart: 1,
          newLines: 3,
          lines: [" x", "-a", "+b", "+c"],
        },
      ],
    },
  },
} as const;

const statuses: (string | undefined)[] = [];

function engine(on: any) {
  on("env.get", () => ({ value: "/home/me" }));
  on("fs.write", (_: any, e: any) => {
    expect(e.path).toBe("/home/me/.local/state/claude/diffs-mode/s1");
    statuses.push(e.text);
    return { value: undefined };
  });
  on("ui.render", ($: any, e: any) => {
    const { Text } = $.ui.resolve(e);
    if (e.props?.tool === "Bash") {
      return (
        <Text>{e.props.output?.bashEditDiff ? "OUT BASHDIFF" : "OUT"}</Text>
      );
    }
    return <Text>DIFF</Text>;
  });
  on("command.register", () => ({ value: { command: "diffs" } }));
  on("session.start", (_: any, e: any) => ({ cwd: e.cwd }));
  on("session.id", () => ({ value: "s1" }));
  on("fs.read", () => {
    throw new Error("ENOENT");
  });
}

for (const surface of ["terminal", "desktop"] as const) {
  test(`collapses, expands and hides on ${surface}`, async ($, on) => {
    engine(on);
    await $.session.start({ cwd: "/", surface, isInteractive: true });

    const ui = await $.ui.mount({ ...EDIT, surface });
    expect((await ui.find({ type: "Text", text: /foo\.ts/ }))?.text).toBe(
      "foo.ts +2 −1 · ",
    );
    expect(await ui.find({ type: "Text", text: /DIFF/ })).toBeUndefined();

    await ui.press({ key: "toggle" });
    expect((await ui.find({ type: "Text", text: /DIFF/ }))?.text).toBe("DIFF");
    await ui.press({ key: "toggle" });
    expect(await ui.find({ type: "Text", text: /DIFF/ })).toBeUndefined();

    const ran = await $.command.run({
      command: "diffs",
      args: "hidden",
    } as any);
    expect(ran.text).toBeUndefined();
    expect(statuses.at(-1)).toBe("hidden");
    expect(await ui.find({ type: "Text", text: /foo/ })).toBeUndefined();

    await $.command.run({ command: "diffs", args: "full" } as any);
    expect((await ui.find({ type: "Text", text: /DIFF/ }))?.text).toBe("DIFF");
    await ui.unmount();
  });
}

test("other tools and ctrl+o are left alone", async ($, on) => {
  engine(on);
  const bash = await $.ui.mount({
    ...EDIT,
    props: { ...EDIT.props, tool: "Read" },
    surface: "terminal",
  });
  expect((await bash.find({ type: "Text", text: /DIFF/ }))?.text).toBe("DIFF");
  await bash.unmount();
  const expanded = await $.ui.mount({
    ...EDIT,
    props: { ...EDIT.props, isExpanded: true },
    surface: "terminal",
  });
  expect((await expanded.find({ type: "Text", text: /DIFF/ }))?.text).toBe(
    "DIFF",
  );
  await expanded.unmount();
});

const BASH = {
  plugin: "diffs",
  component: "ToolResult",
  requestId: "tu2",
  props: {
    tool_use_id: "tu2",
    tool: "Bash",
    isErrored: false,
    isExpanded: false,
    output: {
      stdout: "ok",
      stderr: "",
      interrupted: false,
      bashEditDiff: {
        files: [
          {
            filePath: "/r/a.md",
            hunks: [
              {
                oldStart: 1,
                oldLines: 1,
                newStart: 1,
                newLines: 2,
                lines: ["-a", "+b", "+c"],
              },
            ],
          },
          {
            filePath: "/r/b.md",
            hunks: [
              {
                oldStart: 1,
                oldLines: 1,
                newStart: 1,
                newLines: 1,
                lines: ["-x", "+y"],
              },
            ],
          },
        ],
        moreFiles: 0,
      },
    },
  },
} as const;

test("a Bash result keeps its output and folds its file diff", async ($, on) => {
  engine(on);
  await $.session.start({ cwd: "/", surface: "terminal", isInteractive: true });
  await $.command.run({ command: "diffs", args: "collapsed" } as any);

  const ui = await $.ui.mount({ ...BASH, surface: "terminal" });
  expect((await ui.find({ type: "Text", text: /^OUT/ }))?.text).toBe("OUT");
  expect((await ui.find({ type: "Text", text: /files/ }))?.text).toBe(
    "2 files +3 −2 · ",
  );

  await ui.press({ key: "toggle" });
  expect((await ui.find({ type: "Text", text: /^OUT/ }))?.text).toBe(
    "OUT BASHDIFF",
  );
  await ui.press({ key: "toggle" });

  await $.command.run({ command: "diffs", args: "hidden" } as any);
  expect((await ui.find({ type: "Text", text: /^OUT/ }))?.text).toBe("OUT");
  expect(await ui.find({ type: "Text", text: /files/ })).toBeUndefined();
  await ui.unmount();

  const plain = await $.ui.mount({
    ...BASH,
    props: {
      ...BASH.props,
      output: { stdout: "ok", stderr: "", interrupted: false },
    },
    surface: "terminal",
  });
  expect((await plain.find({ type: "Text", text: /^OUT/ }))?.text).toBe("OUT");
  await plain.unmount();
});

test("a resumed session reads its mode back", async ($, on) => {
  on("ui.render", ($: any, e: any) => {
    const { Text } = $.ui.resolve(e);
    return <Text>DIFF</Text>;
  });
  on("command.register", () => ({ value: { command: "diffs" } }));
  on("session.start", (_: any, e: any) => ({ cwd: e.cwd }));
  on("session.id", () => ({ value: "s2" }));
  on("env.get", () => ({ value: "/home/me" }));
  on("fs.read", (_: any, e: any) => {
    expect(e.path).toBe("/home/me/.local/state/claude/diffs-mode/s2");
    return { value: "full\n" };
  });
  on("fs.write", () => ({ value: undefined }));
  await $.session.start({ cwd: "/", surface: "terminal", isInteractive: true });

  const ui = await $.ui.mount({ ...EDIT, surface: "terminal" });
  expect((await ui.find({ type: "Text", text: /DIFF/ }))?.text).toBe("DIFF");
  await ui.unmount();
});
