#!/usr/bin/env node
// Gets a step running with one command: `node tool/setup.mjs`.
//
// It installs Flutter through FVM, checks the machine, connects the app to a backend and runs it in Chrome.
// Plain Node with no dependencies, so it runs the same on macOS, Linux and Windows.
//
// The backend is one of:
//   shared   the pre-configured one (see tool/workshop.config.json), nothing to set up
//   local    a runtime on this machine, with your own Anthropic key (the runtime/ folder of this repository)
//   custom   any other CopilotKit runtime you have a URL for, e.g. one made with `npx copilotkit with-claude`
//
// Options (everything is asked when left out):
//   --step <00|01|02|03>             which step to run
//   --backend <shared|local|custom>  which backend to use (step 03 always runs its own server)
//   --url <url>                      the runtime URL, for a custom backend
//   --agent <id>                     the agent id, when the backend has more than one
//   --code <code>                    the workshop password of the shared backend (or set WORKSHOP_CODE)
//   --no-run                         set everything up, then print the commands instead of running them
//   --no-app                         start the backend and keep it running, without the app
//   --yes                            never ask, use the defaults and the options given
import { spawn, spawnSync } from "node:child_process";
import { copyFileSync, existsSync, openSync, readFileSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { createInterface } from "node:readline/promises";
import { fileURLToPath } from "node:url";

const root = fileURLToPath(new URL("..", import.meta.url));
const isWindows = process.platform === "win32";
const useColor = process.stdout.isTTY && !process.env.NO_COLOR;
const paint = (code, text) => (useColor ? `\x1b[${code}m${text}\x1b[0m` : text);
const say = (text = "") => console.log(text);
const heading = (text) => say(`\n${paint("1", text)}`);
const hint = (text) => say(paint("2", `  ${text}`));

const STEPS = {
  "00": { dir: "00-foundations", title: "Foundations, no agent" },
  "01": { dir: "01-shared-state", title: "Shared state, the agent fills the form" },
  "02": { dir: "02-generative-ui", title: "Generative UI, the agent writes the calaverita" },
  "03": { dir: "03-custom-server", title: "Custom server, optional", server: { dir: "server", port: 4100, agent: "calaverita" } },
};
const LOCAL_RUNTIME = { dir: "runtime", port: 8200, agent: "default" };
const config = JSON.parse(readFileSync(`${root}tool/workshop.config.json`, "utf8"));

// ---------------------------------------------------------------- arguments

const args = process.argv.slice(2);
if (args.includes("--help") || args.includes("-h")) {
  const header = readFileSync(fileURLToPath(import.meta.url), "utf8").split("\n").filter((l) => l.startsWith("//")).map((l) => l.slice(3));
  say(header.join("\n"));
  process.exit(0);
}
const option = (name) => {
  const index = args.indexOf(`--${name}`);
  return index === -1 ? undefined : args[index + 1];
};
const flag = (name) => args.includes(`--${name}`);
const interactive = Boolean(process.stdin.isTTY) && !flag("yes");

function fail(message, ...more) {
  say(`\n${paint("31", "✗")} ${message}`);
  for (const line of more) hint(line);
  process.exit(1);
}

// ---------------------------------------------------------------- helpers

/** Runs a command, showing its output. Returns whether it succeeded. */
function runVisible(command, commandArgs, cwd = root) {
  return spawnSync(command, commandArgs, { cwd, stdio: "inherit", shell: isWindows }).status === 0;
}

function runQuiet(command, commandArgs, cwd = root) {
  const result = spawnSync(command, commandArgs, { cwd, encoding: "utf8", shell: isWindows, stdio: ["ignore", "pipe", "pipe"] });
  return { ok: result.status === 0, output: `${result.stdout ?? ""}${result.stderr ?? ""}` };
}

async function ask(question, fallback) {
  if (!interactive) return fallback;
  // A new interface for each question: one that stays open would also echo what is typed
  // while a secret is asked for.
  const rl = createInterface({ input: process.stdin, output: process.stdout });
  const answer = (await rl.question(`${question}${fallback ? paint("2", ` [${fallback}]`) : ""} `)).trim();
  rl.close();
  return answer || fallback;
}

/** Asks for a secret without echoing it. */
async function askSecret(question) {
  if (!interactive) return undefined;
  process.stdout.write(`${question} `);
  const { stdin } = process;
  stdin.setRawMode(true);
  stdin.resume();
  stdin.setEncoding("utf8");
  const value = await new Promise((resolve) => {
    let typed = "";
    const onData = (chunk) => {
      for (const char of chunk) {
        if (char === "\r" || char === "\n") {
          stdin.off("data", onData);
          return resolve(typed);
        }
        if (char === "\u0003") process.exit(130); // ctrl-c
        if (char === "\u007f" || char === "\b") typed = typed.slice(0, -1);
        else typed += char;
      }
    };
    stdin.on("data", onData);
  });
  stdin.setRawMode(false);
  stdin.pause();
  process.stdout.write("\n");
  return value.trim();
}

async function choose(question, choices, fallbackKey) {
  if (!interactive) return fallbackKey;
  say(`\n${question}`);
  choices.forEach(({ label }, index) => say(`  ${index + 1}. ${label}`));
  const fallbackIndex = choices.findIndex(({ key }) => key === fallbackKey) + 1;
  const answer = await ask("Your choice?", String(fallbackIndex));
  return choices[Number(answer) - 1]?.key ?? fallbackKey;
}

/** Reads a .env file into an object, without touching process.env. */
function readEnvFile(path) {
  const values = {};
  if (!existsSync(path)) return values;
  for (const line of readFileSync(path, "utf8").split(/\r?\n/)) {
    const match = line.match(/^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*?)\s*$/);
    if (match && !line.trimStart().startsWith("#")) values[match[1]] = match[2].replace(/^(["'])(.*)\1$/, "$2");
  }
  return values;
}

async function fetchJson(url) {
  const response = await fetch(url, { signal: AbortSignal.timeout(8_000) });
  if (!response.ok) throw new Error(`HTTP ${response.status}`);
  return response.json();
}

const isRunning = (url) => fetchJson(`${url}/info`).then(() => true, () => false);

// ---------------------------------------------------------------- the machine

heading("1. Checking your machine");
if (!runQuiet("fvm", ["--version"]).ok) {
  runVisible("node", ["tool/doctor.mjs"]);
  fail("FVM is missing, install it first (see above), then run this again.");
}
say("Installing Flutter 3.47.0 through FVM (a few minutes the first time)...");
if (!runVisible("fvm", ["install"])) fail("`fvm install` failed.", "On Windows, turn on Developer Mode (Settings → System → For developers) and try again.");
if (!runVisible("node", ["tool/doctor.mjs"])) fail("Fix the items marked ✗ above, then run this again.");

// ---------------------------------------------------------------- the step

const stepKey = await choose(
  "Which step do you want to run?",
  Object.entries(STEPS).map(([key, { title }]) => ({ key, label: `${key} · ${title}` })),
  option("step")?.padStart(2, "0") ?? "02",
);
const step = STEPS[stepKey];
if (!step) fail(`There is no step "${option("step")}". Use 00, 01, 02 or 03.`);
const stepDir = `${root}${step.dir}`;

// ---------------------------------------------------------------- the backend

/** The backend the app talks to: its URL and agent id, and the folder to start if it is ours. */
let backend = null;
/** The password of the shared backend. The app sends it as a header; a runtime on your machine asks for none. */
let workshopCode = "";

/** Makes sure `dir` has the model key in its .env, asking for it when it is missing. */
async function ensureKey(dir) {
  const envPath = `${dir}/.env`;
  const env = readEnvFile(envPath);
  const model = process.env.COPILOTKIT_MODEL || env.COPILOTKIT_MODEL || "anthropic:claude-sonnet-5-5";
  const variable = { openai: "OPENAI_API_KEY", anthropic: "CLAUDE_API_KEY", google: "GOOGLE_API_KEY", gemini: "GOOGLE_API_KEY" }[model.split(/[:/]/)[0].toLowerCase()];
  if (!variable) return;
  if (process.env[variable] || env[variable]) {
    say(`${paint("32", "✓")} ${variable} is set (the value is not shown).`);
    return;
  }
  const key = await askSecret(`Paste your ${variable} (nothing is shown as you type):`);
  if (!key) fail(`${variable} is not set.`, `Open ${dir.replace(root, "")}/.env and set ${variable}=<your key>, or choose another backend.`);
  if (!existsSync(envPath)) copyFileSync(`${dir}/.env.example`, envPath);
  const current = readFileSync(envPath, "utf8");
  const line = new RegExp(`^\\s*#?\\s*${variable}=.*$`, "m");
  writeFileSync(envPath, line.test(current) ? current.replace(line, `${variable}=${key}`) : `${current.replace(/\s*$/, "\n")}${variable}=${key}\n`);
  say(`${paint("32", "✓")} Saved it in ${dir.replace(root, "")}/.env (git-ignored).`);
}

async function useOwnServer({ dir, port, agent }) {
  const folder = `${root}${dir}`;
  await ensureKey(folder);
  if (!existsSync(`${folder}/node_modules`)) {
    say("Installing the server's dependencies...");
    if (!runVisible("npm", ["install", "--no-audit", "--no-fund"], folder)) fail("`npm install` failed.");
  }
  backend = { url: `http://localhost:${port}/api/copilotkit`, agent: option("agent") ?? agent, folder };
}

async function useExternal(url, defaultAgent) {
  const base = url.replace(/\/$/, "");
  if (!runVisible("node", ["tool/doctor.mjs", "--only", "backend", "--backend", base])) {
    fail(`The backend at ${base} is not ready.`, "Check the URL, and that the backend is running and allows browser requests.");
  }
  let agent = option("agent") ?? defaultAgent;
  try {
    const ids = Object.keys((await fetchJson(`${base}/info`)).agents ?? {});
    if (ids.length && !ids.includes(agent)) {
      agent = ids.length === 1 ? ids[0] : await choose("This backend has several agents. Which one?", ids.map((id) => ({ key: id, label: id })), ids[0]);
      say(`Using the agent "${agent}".`);
    }
  } catch {
    // The doctor already said whether the backend answers.
  }
  backend = { url: base, agent };
}

if (stepKey !== "00" && step.server) {
  heading("2. Backend");
  say(`Step 03 has a server of its own, in ${step.dir}/${step.server.dir}.`);
  await useOwnServer({ ...step.server, dir: `${step.dir}/${step.server.dir}` });
} else if (stepKey !== "00") {
  heading("2. Backend");
  const choices = [
    ...(config.sharedBackendUrl ? [{ key: "shared", label: "The shared backend, nothing to set up" }] : []),
    { key: "local", label: "My own runtime on this machine, with my Anthropic key" },
    { key: "custom", label: "A custom backend I have a URL for, e.g. made with `npx copilotkit with-claude`" },
  ];
  const wanted = option("backend") ?? (config.sharedBackendUrl ? "shared" : "local");
  const kind = await choose("Which backend should the app use?", choices, wanted);
  if (kind === "shared") {
    if (!config.sharedBackendUrl) fail("The shared backend is not configured yet.", "Use --backend local, or --backend custom --url <url>.");
    await useExternal(config.sharedBackendUrl, config.sharedAgentId ?? "default");
    workshopCode = option("code") ?? process.env.WORKSHOP_CODE ?? (await askSecret("Workshop password (nothing is shown as you type, empty if there is none):")) ?? "";
  } else if (kind === "custom") {
    say("\nTo make a backend with CopilotKit's tool, run this in another terminal and follow its steps:");
    hint("npx copilotkit with-claude my-backend");
    hint("(it needs Node 20.19 or later, and it makes a Next.js app that includes the runtime)");
    const url = option("url") ?? (await ask("Paste the runtime URL it gives you:", ""));
    if (!url) fail("A custom backend needs its runtime URL.", "Pass it with --url <url>.");
    await useExternal(url, "default");
  } else {
    await useOwnServer(LOCAL_RUNTIME);
  }
}

// ---------------------------------------------------------------- the app

heading(`${stepKey === "00" ? "2" : "3"}. Getting the app ready`);
if (!runVisible("fvm", ["flutter", "pub", "get"], stepDir)) fail("`flutter pub get` failed.", "If it can't fetch the CopilotKit SDK, check that you can reach github.com.");

const appDir = `${stepDir}/apps/calaverita_app`;
const appArgs = ["flutter", "run", "-d", "chrome", ...(backend ? [`--dart-define=RUNTIME_URL=${backend.url}`, `--dart-define=AGENT_ID=${backend.agent}`, ...(workshopCode ? [`--dart-define=WORKSHOP_CODE=${workshopCode}`] : [])] : [])];
const appCommand = `fvm ${appArgs.join(" ")}`;
/** The same command for the screen: the password is never printed. */
const shownCommand = workshopCode ? appCommand.replace(workshopCode, "<workshop password>") : appCommand;

/** Starts the backend of ours in the background and waits until it answers. Returns a function that stops it. */
async function startBackend() {
  if (await isRunning(backend.url)) {
    say(`${paint("32", "✓")} A runtime is already running at ${backend.url}, using it.`);
    return () => {};
  }
  const logFile = `${tmpdir()}${isWindows ? "\\" : "/"}calaverita-backend.log`;
  const log = openSync(logFile, "w");
  const child = spawn("npm", ["start", "--silent"], {
    cwd: backend.folder,
    shell: isWindows,
    detached: !isWindows,
    stdio: ["ignore", log, log],
    env: { ...process.env, PORT: new URL(backend.url).port },
  });
  const stop = () => {
    if (child.exitCode !== null) return;
    if (isWindows) spawnSync("taskkill", ["/pid", String(child.pid), "/T", "/F"], { stdio: "ignore" });
    else process.kill(-child.pid, "SIGTERM");
  };
  process.on("exit", stop);
  say(`Starting the backend (its log is ${logFile})...`);
  for (let waited = 0; waited < 45_000; waited += 500) {
    if (child.exitCode !== null) fail("The backend stopped right away.", `See ${logFile}`);
    if (await isRunning(backend.url)) {
      say(`${paint("32", "✓")} The backend answers at ${backend.url}`);
      return stop;
    }
    await new Promise((resolve) => setTimeout(resolve, 500));
  }
  stop();
  fail("The backend did not start in time.", `See ${logFile}`);
}

if (flag("no-run")) {
  heading("Ready. To run it yourself:");
  if (backend?.folder) say(`  1. In one terminal:   cd ${backend.folder.replace(root, "")} && npm start`);
  say(`  ${backend?.folder ? "2. In another:" : "Run:"}        cd ${appDir.replace(root, "")} && ${shownCommand}`);
  process.exit(0);
}

const stopBackend = backend?.folder ? await startBackend() : () => {};
for (const signal of ["SIGINT", "SIGTERM"]) process.on(signal, () => { stopBackend(); process.exit(130); });

if (flag("no-app")) {
  heading("The backend is running. Press Ctrl-C to stop it.");
  await new Promise(() => {});
}

heading(`Running step ${stepKey} in Chrome (the first build takes a minute)...`);
const status = spawnSync("fvm", appArgs, { cwd: appDir, stdio: "inherit", shell: isWindows }).status;
stopBackend();
process.exit(status ?? 0);
