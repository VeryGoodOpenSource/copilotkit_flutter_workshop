import "./env.js";
import { serve } from "@hono/node-server";
import { Hono } from "hono";
import { cors } from "hono/cors";
import { CopilotRuntime, createCopilotHonoHandler, InMemoryAgentRunner } from "@copilotkit/runtime/v2";
import { CalaveritaAgent, MODEL } from "./agent.js";

process.env.COPILOTKIT_TELEMETRY_DISABLED ??= "true";
if (!process.env.ANTHROPIC_API_KEY) {
  console.error("ANTHROPIC_API_KEY is not set. Copy .env.example to .env and put your key in it.");
  process.exit(1);
}

const runtime = new CopilotRuntime({
  agents: { calaverita: new CalaveritaAgent() },
  runner: new InMemoryAgentRunner(),
});

const app = new Hono();
app.use("*", cors({ origin: "*", allowHeaders: ["authorization", "content-type", "x-workshop-code", "x-workshop-session"] }));
app.get("/health", (c) => c.text("ok"));
app.route("/", createCopilotHonoHandler({ runtime, basePath: "/api/copilotkit" }));

const port = Number(process.env.PORT ?? 4100);
serve({ fetch: app.fetch, port });
console.log(`Calaverita agent on http://localhost:${port}/api/copilotkit  (agent id: calaverita, model: ${MODEL})`);
