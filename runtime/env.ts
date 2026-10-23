// Loads runtime/.env and checks that the model has its key, before anything else starts.
// Plain Node, so `npm start` behaves the same on macOS, Linux and Windows.
import { existsSync, readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";

// Variables already set in the shell win over the file.
const envFile = fileURLToPath(new URL(".env", import.meta.url));
if (existsSync(envFile)) {
  for (const line of readFileSync(envFile, "utf8").split(/\r?\n/)) {
    const match = line.match(/^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*?)\s*$/);
    if (!match || line.trimStart().startsWith("#")) continue;
    const value = match[2].replace(/^(["'])(.*)\1$/, "$2");
    process.env[match[1]] ??= value;
  }
}

/** The environment variable that holds the key of each model provider. `null` needs no key. */
const keyVariables: Record<string, string | null> = {
  openai: "OPENAI_API_KEY",
  anthropic: "ANTHROPIC_API_KEY",
  google: "GOOGLE_API_KEY",
  gemini: "GOOGLE_API_KEY",
  "google-gemini": "GOOGLE_API_KEY",
  minimax: "MINIMAX_API_KEY",
  vertex: null,
};

const model = process.env.COPILOTKIT_MODEL || "anthropic:claude-sonnet-5-5";
const provider = model.split(/[:/]/)[0].toLowerCase();

if (!(provider in keyVariables)) {
  console.error(`error: unsupported provider "${provider}" in COPILOTKIT_MODEL=${model}.`);
  console.error(`Use one of: ${Object.keys(keyVariables).join(", ")}.`);
  process.exit(1);
}
const keyVariable = keyVariables[provider];
if (keyVariable && !process.env[keyVariable]) {
  console.error(`error: ${keyVariable} is not set (needed by COPILOTKIT_MODEL=${model}).`);
  console.error(`Open runtime/.env and set ${keyVariable}=<your key>.`);
  console.error("If runtime/.env does not exist yet, copy runtime/.env.example to runtime/.env first.");
  process.exit(1);
}
