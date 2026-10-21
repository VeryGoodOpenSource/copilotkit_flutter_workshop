// The tools the agent runs on the server. They only touch the form. The one the app registers (`showCalaverita`)
// arrives with each run and is never run here: the run ends with the call open.
import { z } from "zod";
import { NONE, PARTS, TONES, partNames } from "./catalog.js";
import { apply, defaultState, type Draft } from "./state.js";

const variants = (part: keyof typeof PARTS) => `one of ${[NONE, ...PARTS[part]].join(", ")}`;

const update = z.object({
  name: z.string().optional().describe("The name of the person the calaverita is for"),
  job: z.string().optional().describe("What the person does for a living"),
  tone: z.string().optional().describe(`How the calaverita sounds, one of ${TONES.join(", ")}`),
  skull: z
    .object({
      color: z.string().optional().describe("Skull color, hex like #12a5a0"),
      hat: z.string().optional().describe(`Hat, ${variants("hat")}`),
      glasses: z.string().optional().describe(`Glasses, ${variants("glasses")}`),
      mustache: z.string().optional().describe(`Mustache, ${variants("mustache")}`),
      flowers: z.string().optional().describe(`Flowers, ${variants("flowers")}`),
    })
    .optional()
    .describe(`How the skull portrait looks: color, ${partNames.join(", ")}`),
});

export interface ServerTool {
  name: string;
  description: string;
  schema: Record<string, unknown>;
  /** Runs the tool on [state]. Returns the new state and the text the model sees. */
  run(state: Draft, input: unknown): { state: Draft; result: string };
}

const json = (s: z.ZodType) => z.toJSONSchema(s) as Record<string, unknown>;

export const SERVER_TOOLS: ServerTool[] = [
  {
    name: "update_form",
    description:
      "Change the form: the name, the job, the tone and how the skull looks. Give every change in one call. Only the fields you give change.",
    schema: json(update),
    run(state, input) {
      const parsed = update.safeParse(input);
      if (!parsed.success) return { state, result: `Nothing changed, the arguments are invalid: ${parsed.error.message}` };
      const { state: next, done, rejected } = apply(state, parsed.data);
      const lines = [done.length ? `Applied: ${done.join("; ")}.` : "Nothing was applied."];
      if (rejected.length) lines.push(`Rejected, fix and call again:\n- ${rejected.join("\n- ")}`);
      return { state: next, result: lines.join("\n") };
    },
  },
  {
    name: "reset_form",
    description: "Start over: clear the form and take everything off the skull. Only when the user asks to start over.",
    schema: json(z.object({})),
    run: () => ({ state: defaultState(), result: "The form is empty again." }),
  },
];

export const serverTool = (name: string) => SERVER_TOOLS.find((t) => t.name === name);
