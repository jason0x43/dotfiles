#!/usr/bin/env bun

import { createHash, randomBytes } from "node:crypto";
import mime from "mime-types";

const CAMERA_HOST = Bun.env.CAMERA_HOST || "";
const CAMERA_USER = Bun.env.CAMERA_USER || "";
const CAMERA_PASS = Bun.env.CAMERA_PASS || "";
const REQUEST_TIMEOUT_MS = 30_000;
const DEFAULT_CHANNEL = 1;

type JsonObject = Record<string, unknown>;

function usage(): void {
  const app = Bun.argv[1];
  console.log(
    [
      "Usage:",
      `  ${app} <command> [args]`,
      "",
      "Commands:",
      "  info - get camera info",
      "  status - get orientation and position info",
      "  orient <angle> <pitch> - change the camera's orientation",
      "  snapshot <out> - save a snapshot to <out>; show the saved file name",
      "  point-and-shoot <angle> <pitch> - orient the camera and take a snapshot; show the saved file name",
      "",
      "Notes:",
      "  - <angle> must be between -180 and 180; negative values are to the left; 180 and -180 both point directly backwards",
      "  - <pitch> must be between -6 and 90; negative values are down; 90 is straight up",
      "  - <out> is an output file name",
    ].join("\n"),
  );
}

function checkEnv(): boolean {
  if (!CAMERA_HOST || !CAMERA_USER || !CAMERA_PASS) {
    console.error(
      "Error: set CAMERA_HOST, CAMERA_USER, and CAMERA_PASS in the environment.",
    );
    return false;
  }

  return true;
}

function md5(input: string): string {
  return createHash("md5").update(input).digest("hex");
}

function parseAuthHeader(header: string): Record<string, string> {
  const trimmed = header.replace(/^Digest\s+/i, "");
  const matches =
    trimmed.match(/([a-z0-9_-]+)=("(?:[^"\\]|\\.)*"|[^,]+)/gi) || [];
  const result: Record<string, string> = {};

  for (const match of matches) {
    const separatorIndex = match.indexOf("=");
    const key = match.slice(0, separatorIndex).trim();
    const rawValue = match.slice(separatorIndex + 1).trim();
    result[key] =
      rawValue.startsWith('"') && rawValue.endsWith('"')
        ? rawValue.slice(1, -1)
        : rawValue;
  }

  return result;
}

function buildDigestAuthorization(
  method: string,
  uri: string,
  challengeHeader: string,
  username: string,
  password: string,
): string {
  const challenge = parseAuthHeader(challengeHeader);
  const realm = challenge.realm;
  const nonce = challenge.nonce;

  if (!realm || !nonce) {
    throw new Error("Invalid digest challenge: missing realm or nonce");
  }

  const algorithm = (challenge.algorithm || "MD5").toUpperCase();
  const qopValue = challenge.qop
    ?.split(",")
    .map((value) => value.trim())
    .find((value) => value === "auth");
  const opaque = challenge.opaque;
  const nc = "00000001";
  const cnonce = randomBytes(16).toString("hex");

  const ha1Base = md5(`${username}:${realm}:${password}`);
  const ha1 =
    algorithm === "MD5-SESS" ? md5(`${ha1Base}:${nonce}:${cnonce}`) : ha1Base;
  const ha2 = md5(`${method}:${uri}`);
  const response = qopValue
    ? md5(`${ha1}:${nonce}:${nc}:${cnonce}:${qopValue}:${ha2}`)
    : md5(`${ha1}:${nonce}:${ha2}`);

  const fields: string[] = [
    `username="${username}"`,
    `realm="${realm}"`,
    `nonce="${nonce}"`,
    `uri="${uri}"`,
    `response="${response}"`,
    `algorithm=${algorithm}`,
  ];

  if (opaque) {
    fields.push(`opaque="${opaque}"`);
  }

  if (qopValue) {
    fields.push(`qop=${qopValue}`, `nc=${nc}`, `cnonce="${cnonce}"`);
  }

  return `Digest ${fields.join(", ")}`;
}

async function digestFetch(path: string): Promise<Response> {
  const url = new URL(`http://${CAMERA_HOST}${path}`);
  const method = "GET";
  const unauthenticated = await fetch(url, {
    method,
    redirect: "manual",
    signal: AbortSignal.timeout(REQUEST_TIMEOUT_MS),
  });

  if (unauthenticated.status !== 401) {
    return unauthenticated;
  }

  const challenge = unauthenticated.headers.get("www-authenticate");

  if (!challenge) {
    throw new Error("Missing WWW-Authenticate header on digest challenge");
  }

  const authorization = buildDigestAuthorization(
    method,
    `${url.pathname}${url.search}`,
    challenge,
    CAMERA_USER,
    CAMERA_PASS,
  );

  return fetch(url, {
    method,
    redirect: "manual",
    headers: {
      Authorization: authorization,
    },
    signal: AbortSignal.timeout(REQUEST_TIMEOUT_MS),
  });
}

async function request(path: string): Promise<Response> {
  const response = await digestFetch(path);

  if (!response.ok) {
    const raw = await response.text();
    const details = raw.trim();
    throw new Error(
      details.length > 0
        ? `HTTP ${response.status} ${response.statusText}: ${details}`
        : `HTTP ${response.status} ${response.statusText}`,
    );
  }

  return response;
}

async function requestText(path: string): Promise<string> {
  const response = await request(path);
  return await response.text();
}

async function getDeviceType(): Promise<JsonObject> {
  const text = await requestText("/cgi-bin/magicBox.cgi?action=getDeviceType");
  const parts = text.split("=") as [string, string];
  return { type: parts[1] };
}

async function getMachineName(): Promise<JsonObject> {
  const text = await requestText("/cgi-bin/magicBox.cgi?action=getMachineName");
  const parts = text.split("=") as [string, string];
  return { name: parts[1] };
}

async function getSerialNumber(): Promise<JsonObject> {
  const text = await requestText("/cgi-bin/magicBox.cgi?action=getSerialNo");
  const parts = text.split("=") as [string, string];
  return { serialNumber: parts[1] };
}

async function getHardwareVersion(): Promise<JsonObject> {
  const text = await requestText(
    "/cgi-bin/magicBox.cgi?action=getHardwareVersion",
  );
  const parts = text.split("=") as [string, string];
  return { version: parts[1] };
}
//
async function getSystemInfo(): Promise<JsonObject> {
  const text = await requestText(
    "/cgi-bin/magicBox.cgi?action=getSystemInfoNew",
  );
  const properties = text.split("\n").map((p) => p.trim());
  const info: Record<string, string> = {};
  for (const prop of properties) {
    const [key, value] = prop.split("=") as [string, string];
    const sep = key.indexOf(".");
    const name = key.slice(sep + 1);
    info[name] = value;
  }
  return { info };
}

async function getCurrentTime(): Promise<JsonObject> {
  const text = await requestText("/cgi-bin/global.cgi?action=getCurrentTime");
  const parts = text.split("=") as [string, string];
  return { time: parts[1] };
}

function mergeResult(result: JsonObject, output: JsonObject) {
  for (const key of Object.keys(output)) {
    result[key] = output[key];
  }
}

/**
 * Get general camera info
 */
async function getInfo(): Promise<JsonObject> {
  const output: JsonObject = {
    requestedAt: new Date().toISOString(),
  };

  const requests = [
    getDeviceType,
    getMachineName,
    getSerialNumber,
    getHardwareVersion,
    getSystemInfo,
    getCurrentTime,
  ] as const;

  await Promise.all(
    requests.map(async (request) => {
      mergeResult(output, await request());
    }),
  );

  return output;
}

/**
 * Get the camera's orientation status
 */
async function getStatus(channel: number = 1) {
  const text = await requestText(
    `/cgi-bin/ptz.cgi?action=getStatus&channel=${channel}`,
  );
  const props = text.split("\r");
  const status: Record<string, unknown> = {};
  for (const prop of props) {
    const [key, value] = prop.split("=") as [string, string];
    const name = key.split(".")[1] as string;
    status[name] = value;
  }
  return status;
}

/**
 * Set the camera orientation
 */
async function orient(
  angle: number,
  pitch: number,
  channel: number = DEFAULT_CHANNEL,
): Promise<void> {
  const normalizedPitch = Math.min(Math.max(-6, 5 + pitch), 90);
  const params = new URLSearchParams({
    action: "moveAbsolutely",
    channel: `${channel}`,
    arg1: `${-angle / 180}`,
    arg2: `${-normalizedPitch / 180}`,
    arg3: "1",
  });

  await requestText(`/cgi-bin/ptz.cgi?${params.toString()}`);
}

/**
 * Take a snapshot
 */
async function snapshot(name: string, channel: number = 1) {
  const params = new URLSearchParams({
    channel: `${channel}`,
    type: "0",
  });
  const resp = await request(`/cgi-bin/snapshot.cgi?${params}`);
  const data = await resp.arrayBuffer();
  const ext = mime.extension(resp.headers.get("content-type") || "") || "jpg";
  const filename = `${name}.${ext}`;
  Bun.write(filename, new Uint8Array(data));
  return filename;
}

/**
 * Orient the camera and take a snapshot
 */
async function pointAndShoot(
  angle: number,
  pitch: number,
  name: string | undefined = undefined,
  channel: number = DEFAULT_CHANNEL,
) {
  await orient(angle, pitch, channel);
	// Wait a second for the camera to settle before taking a snapshot.
	await new Promise((resolve) => setTimeout(resolve, 1000));
  return await snapshot(
    name ?? `point-and-shoot_${angle}_${pitch}_${Date.now()}`,
    channel,
  );
}

function parseNumber(value: string | undefined, label: string): number {
  if (value !== undefined && !Number.isNaN(Number(value))) {
    return Number(value);
  }
  throw new Error(`${label} must be a valid number`);
}

function parseString(value: string | undefined, label: string): string {
  if (value !== undefined) {
    return value;
  }
  throw new Error(`${label} must be a string`);
}

async function main(): Promise<void> {
  const cmd = Bun.argv[2];

  if (!cmd || cmd === "-h" || cmd === "--help") {
    usage();
    process.exit(0);
  }

  if (!checkEnv()) {
    usage();
    process.exit(1);
  }

  switch (cmd) {
    case "info": {
      const result = await getInfo();
      console.log(JSON.stringify(result, null, 2));
      break;
    }
    case "status": {
      const result = await getStatus();
      console.log(JSON.stringify(result, null, 2));
      break;
    }
    case "orient": {
      const angle = parseNumber(Bun.argv[3], "angle");
      const pitch = parseNumber(Bun.argv[4], "pitch");
      await orient(angle, pitch);
      break;
    }
    case "snapshot": {
      const name = parseString(Bun.argv[3], "name");
      const filename = await snapshot(name);
      console.log(filename);
      break;
    }
    case "point-and-shoot": {
      const angle = parseNumber(Bun.argv[3], "angle");
      const pitch = parseNumber(Bun.argv[4], "pitch");
      const filename = await pointAndShoot(angle, pitch);
      console.log(filename);
      break;
    }
    default: {
      throw new Error(`Unknown command: ${cmd}`);
    }
  }
}

try {
  await main();
} catch (error) {
  console.error(`${error}`);
  process.exit(1);
}
