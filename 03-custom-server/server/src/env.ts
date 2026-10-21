import { existsSync } from "node:fs";

// Loads server/.env when it is there. Variables already set in the shell win.
if (existsSync(".env")) process.loadEnvFile(".env");
