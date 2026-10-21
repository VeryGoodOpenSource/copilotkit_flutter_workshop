// Copilot Runtime for the Calaverita Generator workshop, based on the
// CopilotKit Flutter SDK's example runtime. Start it with ./start.sh.
import { createServer } from "node:http";
import { networkInterfaces } from "node:os";
import { BuiltInAgent, CopilotRuntime } from "@copilotkit/runtime/v2";
import { createCopilotNodeListener } from "@copilotkit/runtime/v2/node";

const basePath = "/api/copilotkit";
const port = Number(process.env.PORT ?? 8200);
const model = process.env.COPILOTKIT_MODEL ?? "anthropic:claude-sonnet-5-5";

// One prompt serves every workshop step: it only mentions what the app
// offers, and the app only offers more in later steps.
const prompt = `You are the assistant of the Calaverita Generator, a Flutter app that writes funny rhyming "literary skulls" (calaveritas) for Día de Muertos about a friend or coworker.

The app shares its form with you as application state, a JSON object with three fields:
- "name": the person's name
- "job": what they do for a living
- "tone": exactly one of "playful", "sarcastic" or "dramatic"

When the user tells you about the person, fill the form: call AGUISendStateDelta with a "replace" operation for each field the user gave you ("/name", "/job", "/tone"). Only change the fields the user mentioned, and never invent a name or a job. If something is missing, ask for it in one short question.

Keep your replies to one or two short, warm sentences.

If you have a showCalaverita tool, call it once the form is complete and the user asks for the calaverita: write four rhyming lines (two couplets) that fit the name, the job and the tone, and pass them to the tool. If you don't have that tool, tell the user to press "Write my calaverita".`;

const runtime = new CopilotRuntime({
  agents: {
    default: new BuiltInAgent({
      model,
      prompt,
    }),
  },
});

function lanAddresses(): string[] {
  return Object.values(networkInterfaces())
    .flat()
    .filter((net) => net !== undefined && net.family === "IPv4" && !net.internal)
    .map((net) => net!.address);
}

createServer(createCopilotNodeListener({ runtime, basePath, cors: true })).listen(
  port,
  "0.0.0.0",
  () => {
    console.log(`Copilot Runtime (${model}) listening on:`);
    console.log(`  http://localhost:${port}${basePath}`);
    for (const address of lanAddresses()) {
      console.log(`  http://${address}:${port}${basePath}`);
    }
  },
);
