// Offline checks, no key needed: `npm run smoke`. Covers the state rules, the thread conversion and one whole run
// of the agent against a scripted Claude stream.
import assert from "node:assert/strict";
import type { BaseEvent, RunAgentInput } from "@ag-ui/client";
import { CalaveritaAgent, toAnthropic } from "./agent.js";
import { apply, defaultState, readState } from "./state.js";
import { SERVER_TOOLS } from "./tools.js";

// state
const s0 = defaultState();
assert.equal(s0.skull.hat, "none");
const a = apply(s0, { name: "  Ana ", job: "Pilot", tone: "sarcastic", skull: { hat: "crown", color: "#F00", glasses: "monocle" } });
assert.equal(a.state.name, "Ana", "text is trimmed");
assert.equal(a.state.tone, "sarcastic");
assert.equal(a.state.skull.hat, "crown");
assert.equal(a.state.skull.color, "#ff0000", "colors are normalized");
assert.equal(a.state.skull.glasses, "none", "a bad variant changes nothing");
assert.equal(a.rejected.length, 1);
assert.match(a.rejected[0], /glasses: "monocle" does not exist/);
assert.equal(s0.name, "", "apply does not mutate");
assert.equal(apply(s0, { tone: "angry" }).rejected.length, 1);
assert.equal(apply(s0, { skull: { beard: "long" } as never }).rejected.length, 1);
assert.deepEqual(readState(null), s0);
assert.equal(readState({ tone: "angry", skull: { hat: "helmet", color: "red", flowers: "trio" } }).tone, "playful", "bad input falls back");
assert.deepEqual(readState({ tone: "angry", skull: { hat: "helmet", color: "red", flowers: "trio" } }).skull, { ...s0.skull, flowers: "trio" });

// the tools the model sees
const update = SERVER_TOOLS[0];
assert.match(update.run(s0, { name: "Ana" }).result, /Applied: name/);
assert.match(update.run(s0, { skull: { hat: "helmet" } }).result, /Rejected, fix and call again/);
assert.match(update.run(s0, { name: 7 }).result, /invalid/);
assert.deepEqual(SERVER_TOOLS[1].run(a.state, {}).state, s0);

// thread → Claude
const thread = toAnthropic([
  { id: "1", role: "user", content: "hat please" },
  { id: "2", role: "assistant", toolCalls: [{ id: "c1", type: "function", function: { name: "showCalaverita", arguments: "{" } }] },
  { id: "3", role: "user", content: "never mind" },
]);
assert.deepEqual(thread[2].content, [{ type: "tool_result", tool_use_id: "c1", content: "Cancelled.", is_error: true }, { type: "text", text: "never mind" }]);

// one run: update_form (server) then showCalaverita (the app's)
const ev = (e: unknown) => e;
const text = (i: number, t: string) => [ev({ type: "content_block_start", index: i, content_block: { type: "text", text: "" } }), ev({ type: "content_block_delta", index: i, delta: { type: "text_delta", text: t } }), ev({ type: "content_block_stop", index: i })];
const tool = (i: number, id: string, name: string, args: string) => [ev({ type: "content_block_start", index: i, content_block: { type: "tool_use", id, name, input: {} } }), ...(args ? [ev({ type: "content_block_delta", index: i, delta: { type: "input_json_delta", partial_json: args } })] : []), ev({ type: "content_block_stop", index: i })];
const turns = [
  { id: "msg_1", events: [...text(0, "On it."), ...tool(1, "tu_1", "update_form", '{"name":"Ana","job":"pilot","skull":{"hat":"crown"}}')], content: [{ type: "tool_use", id: "tu_1", name: "update_form", input: { name: "Ana", job: "pilot", skull: { hat: "crown" } } }], stop: "tool_use" },
  { id: "msg_2", events: [...tool(0, "tu_2", "showCalaverita", '{"lines":["a","b","c","d"]}')], content: [{ type: "tool_use", id: "tu_2", name: "showCalaverita", input: { lines: ["a", "b", "c", "d"] } }], stop: "tool_use" },
];
const sent: unknown[] = [];
const agent = new CalaveritaAgent();
(agent as any).client = {
  messages: {
    stream(params: { messages: unknown[] }) {
      sent.push(structuredClone(params.messages));
      const t = turns[sent.length - 1];
      return {
        async *[Symbol.asyncIterator]() { yield ev({ type: "message_start", message: { id: t.id } }); yield* t.events; },
        finalMessage: async () => ({ content: t.content, stop_reason: t.stop }),
      };
    },
  },
};
const input = {
  threadId: "t", runId: "r", state: null, context: [], forwardedProps: {},
  messages: [{ id: "u1", role: "user", content: "Ana is a pilot, write her calaverita" }],
  tools: [{ name: "showCalaverita", description: "show", parameters: { type: "object", properties: { lines: { type: "array", items: { type: "string" } } } } }],
} as unknown as RunAgentInput;
const events: BaseEvent[] = [];
await new Promise<void>((done, fail) => agent.run(input).subscribe({ next: (e) => events.push(e), error: fail, complete: done }));
const types = events.map((e) => e.type);
assert.deepEqual(types, [
  "RUN_STARTED",
  "TEXT_MESSAGE_START", "TEXT_MESSAGE_CONTENT", "TEXT_MESSAGE_END",
  "TOOL_CALL_START", "TOOL_CALL_ARGS", "TOOL_CALL_END",
  "STATE_SNAPSHOT", "TOOL_CALL_RESULT",
  "TOOL_CALL_START", "TOOL_CALL_ARGS", "TOOL_CALL_END",
  "RUN_FINISHED",
]);
assert.deepEqual((events[7] as any).snapshot, { name: "Ana", job: "pilot", tone: "playful", skull: { ...defaultState().skull, hat: "crown" } });
assert.equal(sent.length, 2, "the model was called again after the server tool, and not after the app's");
console.log("smoke ok:", types.length, "events");
