#!/usr/bin/env node
// Checks that this machine is ready for the workshop: `node tool/doctor.mjs`.
//
// Plain Node with no dependencies, so it runs the same on macOS, Linux and Windows.
// It never prints an API key, it only says whether one is set.
//
//   node tool/doctor.mjs                        check the machine, the shared backend and your own runtime
//   node tool/doctor.mjs --backend <url>        check another hosted runtime instead of the shared one
//   node tool/doctor.mjs --only machine         check just the machine (what setup runs first)
//   node tool/doctor.mjs --only backend --backend <url>   check just that runtime
//   --code <password>   (or WORKSHOP_CODE) the password, when the hosted backend asks for one
//
// Your own runtime is optional (the shared backend needs none), so what it lacks is
// shown as information, not as a warning.
import { spawnSync } from "node:child_process";
import { existsSync, readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";

const root = fileURLToPath(new URL("..", import.meta.url));
const isWindows = process.platform === "win32";
const useColor = process.stdout.isTTY && !process.env.NO_COLOR;
const paint = (code, text) => (useColor ? `\x1b[${code}m${text}\x1b[0m` : text);

const SDK_REPO = "https://github.com/VGVentures/copilotkit_flutter_sdk.git";
const FLUTTER_VERSION = "3.47.0";
const RUNTIME_URL = "http://localhost:8200/api/copilotkit";

const only = process.argv.includes("--only") ? process.argv[process.argv.indexOf("--only") + 1] : undefined;
const onlyBackend = only === "backend";
const onlyMachine = only === "machine";

const results = { ok: 0, info: 0, warn: 0, fail: 0 };
function report(level, title, hint) {
  results[level]++;
  const mark = { ok: paint("32", "✓"), info: paint("2", "·"), warn: paint("33", "!"), fail: paint("31", "✗") }[level];
  console.log(`${mark} ${title}`);
  if (hint) for (const line of [].concat(hint)) console.log(`    ${paint("2", line)}`);
}

/** Runs a command and returns its output, or `null` when it can't run. */
function run(command, args, options = {}) {
  const result = spawnSync(command, args, {
    cwd: root,
    encoding: "utf8",
    shell: isWindows, // finds fvm.bat and npm.cmd
    stdio: ["ignore", "pipe", "pipe"],
    timeout: options.timeout ?? 120_000,
    env: { ...process.env, GIT_TERMINAL_PROMPT: "0" },
  });
  if (result.error || result.status !== 0) return { ok: false, output: `${result.stdout ?? ""}${result.stderr ?? ""}` };
  return { ok: true, output: `${result.stdout ?? ""}${result.stderr ?? ""}` };
}

/** Reads runtime/.env into an object, without touching process.env. */
function readEnvFile(path) {
  const values = {};
  if (!existsSync(path)) return values;
  for (const line of readFileSync(path, "utf8").split(/\r?\n/)) {
    const match = line.match(/^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*?)\s*$/);
    if (match && !line.trimStart().startsWith("#")) values[match[1]] = match[2].replace(/^(["'])(.*)\1$/, "$2");
  }
  return values;
}

async function fetchWithTimeout(url, options = {}, timeout = 8_000) {
  return fetch(url, { ...options, signal: AbortSignal.timeout(timeout) });
}

/** A hosted backend may be asleep (Cloud Run cold start): wait longer, and try twice. */
async function fetchHosted(url, options = {}) {
  try {
    return await fetchWithTimeout(url, options, 30_000);
  } catch {
    return fetchWithTimeout(url, options, 30_000);
  }
}

console.log(paint("1", `Calaverita Generator workshop: ${onlyBackend ? "backend" : "setup"} check\n`));

/** The checks of this machine. */
async function checkMachine() {
  if (!onlyMachine) console.log(paint("1", "Your machine"));
  // Node.js
  const [major, minor] = process.versions.node.split(".").map(Number);
  if (major < 20) {
    report("fail", `Node.js ${process.versions.node} is too old, the runtime needs 20 or later`, "Install the current LTS from https://nodejs.org");
  } else if (major === 20 && minor < 19) {
    report("warn", `Node.js ${process.versions.node} works for the runtime`, "`npx copilotkit` needs 20.19 or later, so update if you plan to use it.");
  } else {
    report("ok", `Node.js ${process.versions.node}`);
  }

  // Git
  const git = run("git", ["--version"]);
  if (git.ok) report("ok", git.output.trim());
  else report("fail", "Git is not installed", "Install it from https://git-scm.com. Flutter needs it to fetch the SDK.");

  // FVM and Flutter
  const fvm = run("fvm", ["--version"]);
  if (!fvm.ok) {
    report("fail", "FVM is not installed", [
      "macOS: brew tap leoafarias/fvm && brew install fvm",
      "Windows: choco install fvm   (then turn on Developer Mode in Settings, FVM needs symlinks)",
      "Any system: dart pub global activate fvm",
      "More: https://fvm.app",
    ]);
  } else {
    report("ok", `FVM ${fvm.output.trim().split("\n").pop()}`);
    const flutter = run("fvm", ["flutter", "--version"], { timeout: 180_000 });
    if (flutter.ok && flutter.output.includes(`Flutter ${FLUTTER_VERSION}`)) {
      report("ok", `Flutter ${FLUTTER_VERSION} through FVM`);
    } else if (flutter.ok) {
      const found = flutter.output.match(/Flutter (\d+\.\d+\.\d+)/)?.[1] ?? "another version";
      report("fail", `Flutter ${found} is active, the workshop needs ${FLUTTER_VERSION}`, "Run `fvm install` in the repository folder.");
    } else {
      report("fail", `Flutter ${FLUTTER_VERSION} is not installed yet`, "Run `fvm install` in the repository folder. The first time takes a few minutes.");
    }
  }

  // Chrome
  const chromePaths = isWindows
    ? [process.env.PROGRAMFILES, process.env["PROGRAMFILES(X86)"], process.env.LOCALAPPDATA]
        .filter(Boolean)
        .map((base) => `${base}\\Google\\Chrome\\Application\\chrome.exe`)
    : process.platform === "darwin"
      ? ["/Applications/Google Chrome.app"]
      : ["/usr/bin/google-chrome", "/usr/bin/google-chrome-stable", "/usr/bin/chromium", "/usr/bin/chromium-browser"];
  if (process.env.CHROME_EXECUTABLE) chromePaths.unshift(process.env.CHROME_EXECUTABLE);
  if (chromePaths.some((path) => existsSync(path))) {
    report("ok", "Chrome");
  } else {
    report("warn", "Chrome was not found", "The app runs in Chrome (`flutter run -d chrome`). Install it from https://www.google.com/chrome");
  }

  // The SDK
  const sdk = run("git", ["ls-remote", SDK_REPO, "HEAD"], { timeout: 25_000 });
  if (sdk.ok && sdk.output.trim()) {
    report("ok", "Can reach the CopilotKit Flutter SDK on GitHub");
  } else {
    report("fail", "Can't reach the CopilotKit Flutter SDK on GitHub", [
      "Check your network. If the repository is still private, you need access to it.",
      SDK_REPO,
    ]);
  }
}

/** Your own runtime (the runtime/ folder): optional, `node tool/setup.mjs` sets it up when you pick it. */
async function checkLocalRuntime() {
  console.log(`\n${paint("1", "Your own runtime")} ${paint("2", "(only for the local backend, setup prepares it when you pick it)")}`);
  const runtimeDir = `${root}runtime`;
  if (existsSync(`${runtimeDir}/node_modules`) || existsSync(`${runtimeDir}\\node_modules`)) {
    report("ok", "Runtime dependencies are installed");
  } else {
    report("info", "Runtime dependencies are not installed yet");
  }
  const env = readEnvFile(`${runtimeDir}/.env`);
  const model = process.env.COPILOTKIT_MODEL || env.COPILOTKIT_MODEL || "anthropic:claude-sonnet-5-5";
  const keyName = { openai: "OPENAI_API_KEY", anthropic: "ANTHROPIC_API_KEY", google: "GOOGLE_API_KEY", gemini: "GOOGLE_API_KEY" }[model.split(/[:/]/)[0].toLowerCase()];
  if (!keyName || process.env[keyName] || env[keyName]) {
    report("ok", keyName ? `${keyName} is set (the value is not shown)` : `Model ${model} needs no key`);
  } else {
    report("info", `${keyName} is not set`);
  }

  // Is a runtime running?
  try {
    const response = await fetchWithTimeout(`${RUNTIME_URL}/info`);
    if (response.ok) report("ok", `A runtime is running at ${RUNTIME_URL}`);
    else report("warn", `Something answers at ${RUNTIME_URL} but not like a runtime (HTTP ${response.status})`);
  } catch {
    report("info", "No runtime is running");
  }
}

if (!onlyBackend) await checkMachine();

// A hosted backend: the one given, else the shared one of the workshop
const backendIndex = process.argv.indexOf("--backend");
const sharedBackendUrl = (() => {
  try {
    return JSON.parse(readFileSync(`${root}tool/workshop.config.json`, "utf8")).sharedBackendUrl;
  } catch {
    return undefined;
  }
})();
const backendArg = backendIndex !== -1 ? process.argv[backendIndex + 1] ?? "" : only ? undefined : sharedBackendUrl;
if (backendArg !== undefined) {
  const backend = backendArg.replace(/\/$/, "");
  if (!onlyBackend) console.log(`\n${paint("1", backend === sharedBackendUrl?.replace(/\/$/, "") ? "The shared backend" : "The backend")}`);
  if (!backend) {
    report("fail", "--backend needs a URL", "Example: node tool/doctor.mjs --backend https://example.com/api/copilotkit");
  } else {
    try {
      const info = await fetchHosted(`${backend}/info`);
      if (!info.ok) throw new Error(`HTTP ${info.status}`);
      report("ok", `The backend answers at ${backend}`);
      const preflight = await fetchHosted(`${backend}/agent/default/run`, {
        method: "OPTIONS",
        headers: {
          Origin: "http://localhost:5000",
          "Access-Control-Request-Method": "POST",
          "Access-Control-Request-Headers": "content-type",
        },
      });
      const allowed = preflight.headers.get("access-control-allow-origin");
      if (allowed) report("ok", `The backend allows browser requests (CORS: ${allowed})`);
      else report("fail", "The backend does not allow browser requests", "The Flutter web app calls it from the browser, so it must answer the CORS preflight.");
      // An empty run is refused with 401 before it reaches the model, and with the right password it is a 400.
      const codeIndex = process.argv.indexOf("--code");
      const code = (codeIndex !== -1 ? process.argv[codeIndex + 1] : process.env.WORKSHOP_CODE) ?? "";
      const open = await fetchHosted(`${backend}/agent/default/run`, { method: "POST" });
      if (open.status !== 401) {
        report("ok", "The backend asks for no password");
      } else if (!code) {
        report("ok", "The backend asks for a workshop password", "Pass it with --code <password> to check it.");
      } else {
        const withCode = await fetchHosted(`${backend}/agent/default/run`, { method: "POST", headers: { "X-Workshop-Code": code } });
        if (withCode.status === 401) report("fail", "The backend refused the workshop password", "Check it with the organizer.");
        else report("ok", "The workshop password is accepted");
      }
      if (backend.startsWith("http://") && !backend.includes("localhost")) {
        report("warn", "The backend is plain http", "A page served over https can't call it. Use https for a hosted app.");
      }
    } catch (error) {
      report("fail", `Can't reach the backend at ${backend}`, String(error.message ?? error));
    }
  }
}

if (!only) await checkLocalRuntime();

console.log(
  `\n${results.fail === 0 ? paint("32", "Ready to go.") : paint("31", `${results.fail} thing${results.fail === 1 ? "" : "s"} to fix.`)} ` +
    `${results.ok} ok, ${results.warn} warning${results.warn === 1 ? "" : "s"}, ${results.fail} failed.`,
);
process.exit(results.fail === 0 ? 0 : 1);
