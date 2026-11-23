export const HOME = hs.fs.homeDirectory();

export interface RunResult {
	exitCode: number;
	stdout: string;
	stderr: string;
}

/**
 * Run a program asynchronously. Unlike hs.task.runAsync(), the returned
 * Promise always resolves, even when the program exits non-zero or can't be
 * started (exitCode is then -1).
 */
export async function run(path: string, args: string[] = []): Promise<RunResult> {
	try {
		return await hs.task.runAsync(path, args, {}, () => {});
	} catch (err) {
		// runAsync rejects with the result object on a non-zero exit
		if (err && typeof err === "object" && "exitCode" in err) {
			const result = err as RunResult;
			return {
				exitCode: result.exitCode,
				stdout: result.stdout ?? "",
				stderr: result.stderr ?? "",
			};
		}
		return { exitCode: -1, stdout: "", stderr: String(err) };
	}
}

/** Run a command with /bin/sh -c. Always resolves; see run(). */
export function shell(command: string): Promise<RunResult> {
	return run("/bin/sh", ["-c", command]);
}

function xmlEscape(value: string): string {
	return value
		.replace(/&/g, "&amp;")
		.replace(/</g, "&lt;")
		.replace(/>/g, "&gt;")
		.replace(/"/g, "&quot;");
}

let detachedCount = 0;

/**
 * Run a command with `zsh -l -c` as a one-off launchd job rather than as a
 * child of Hammerspoon, so that Hammerspoon isn't its "responsible" app for
 * macOS privacy checks. This is what lets `op` reach the 1Password app: it may
 * use 1Password's group container itself, but Hammerspoon may not. Always
 * resolves; see run().
 */
export async function runDetached(command: string, timeoutSeconds = 300): Promise<RunResult> {
	const id = `${Date.now()}-${hs.appinfo.pid}-${detachedCount++}`;
	const label = `local.hammerspoon2.task.${id}`;
	const dir = `${hs.fs.tempDirectory()}/hammerspoon2-${id}`;
	const plist = `${dir}/job.plist`;
	const outFile = `${dir}/output`;
	const exitFile = `${dir}/exit`;

	hs.fs.mkdir(dir);
	const script = `${command}\necho $? > ${shellQuote(exitFile)}`;
	hs.fs.write(
		plist,
		`<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
	<key>Label</key><string>${xmlEscape(label)}</string>
	<key>RunAtLoad</key><true/>
	<key>ProgramArguments</key><array>
		<string>/bin/zsh</string><string>-l</string><string>-c</string>
		<string>${xmlEscape(script)}</string>
	</array>
	<key>StandardOutPath</key><string>${xmlEscape(outFile)}</string>
	<key>StandardErrorPath</key><string>${xmlEscape(outFile)}</string>
</dict></plist>
`,
	);

	const domain = `gui/$(/usr/bin/id -u)`;
	const cleanup = () => {
		shell(`/bin/launchctl bootout ${domain}/${label}`).then(() => hs.fs.deletePath(dir));
	};

	const started = await shell(`/bin/launchctl bootstrap ${domain} ${shellQuote(plist)}`);
	if (started.exitCode !== 0) {
		cleanup();
		return { exitCode: -1, stdout: "", stderr: `launchctl bootstrap failed: ${started.stderr}` };
	}

	const startedAt = hs.timer.secondsSinceEpoch();
	return new Promise((resolve) => {
		const timer = hs.timer.doEvery(0.5, () => {
			const finished = hs.fs.exists(exitFile);
			const timedOut = hs.timer.secondsSinceEpoch() - startedAt > timeoutSeconds;
			if (!finished && !timedOut) {
				return;
			}
			timer.stop();

			const output = hs.fs.read(outFile, 0, 0) ?? "";
			const exitCode = finished ? Number((hs.fs.read(exitFile, 0, 0) ?? "").trim()) : -1;
			cleanup();
			resolve({
				exitCode: Number.isFinite(exitCode) ? exitCode : -1,
				stdout: output,
				stderr: timedOut && !finished ? `Timed out after ${timeoutSeconds}s` : "",
			});
		});
	});
}

/** Quote a string for use as a single shell word. */
export function shellQuote(value: string): string {
	return `'${value.replace(/'/g, `'\\''`)}'`;
}

/**
 * Load an icon from the config's icons directory and give it a point size.
 * Icons are template images by default, so macOS tints them to match the
 * menubar or menu (Hammerspoon 1 did this for menubar icons automatically).
 */
export function loadIcon(name: string, size: number, template = true): HSImage {
	const path = `${hs.appinfo.configDir}/icons/${name}`;
	const image = HSImage.fromPath(path);
	if (!image) {
		throw new Error(`Failed to load image from path: ${path}`);
	}
	image.size = new HSSize(size, size);
	image.template = template;
	return image;
}

/** Truncate a string to at most max characters, ending it with an ellipsis. */
export function truncate(value: string | null | undefined, max: number): string {
	if (typeof value !== "string" || value === "") {
		return "";
	}
	const chars = Array.from(value);
	if (chars.length <= max) {
		return value;
	}
	return chars.slice(0, max - 1).join("") + "…";
}

/** Read and parse a JSON file, returning null if it's missing or invalid. */
export function readJsonFile(path: string): unknown {
	if (!hs.fs.isFile(path)) {
		return null;
	}

	const content = hs.fs.read(path, 0, 0);
	if (!content) {
		return null;
	}

	try {
		return JSON.parse(content);
	} catch {
		return null;
	}
}

export function isRecord(value: unknown): value is Record<string, unknown> {
	return typeof value === "object" && value !== null && !Array.isArray(value);
}

/** Format a date as HH:MM:SS in local time. */
export function formatTime(date: Date): string {
	const pad = (n: number) => String(n).padStart(2, "0");
	return `${pad(date.getHours())}:${pad(date.getMinutes())}:${pad(date.getSeconds())}`;
}

/** Show a transient on-screen alert. */
export function alert(message: string, seconds = 2): void {
	hs.ui.alert(message).duration(seconds).show();
}

/** Show a macOS notification. */
export function notify(title: string, body: string): void {
	hs.notify.create({ title, body })?.send();
}
