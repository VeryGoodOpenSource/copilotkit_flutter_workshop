// The agent: one AG-UI agent served by the CopilotKit runtime. A run is one go at the conversation:
//
//   1. read the form the app sent (RunAgentInput.state) and the thread (RunAgentInput.messages)
//   2. call Claude with two kinds of tools:
//        server tools   (update_form, reset_form) run here, check what Claude asks for and change the shared
//                       state, which goes back to the app as a STATE_SNAPSHOT: that is what fills the form
//        app tools      (showCalaverita) come with the input; the run ends with the call open, the app runs it
//                       (it adds the skull, and its card renders) and starts the next run
//   3. loop while Claude keeps calling server tools
//
// Nothing is kept between runs: the thread and the state arrive with each one.
import { randomUUID } from "node:crypto";
import Anthropic from "@anthropic-ai/sdk";
import { AbstractAgent, EventType, type BaseEvent, type Message, type RunAgentInput } from "@ag-ui/client";
import { Observable } from "rxjs";
import { systemPrompt } from "./prompt.js";
import { readState, type Draft } from "./state.js";
import { SERVER_TOOLS, serverTool } from "./tools.js";

export const MODEL = process.env.CLAUDE_MODEL || "claude-sonnet-5-5";
/** Model calls in one run. A request takes one or two; this only stops a loop. */
const MAX_STEPS = 6;

type Emit = (e: BaseEvent) => void;
const evt = (emit: Emit, type: EventType, rest: object = {}) => emit({ type, ...rest } as BaseEvent);

/** AG-UI thread → Anthropic messages. Tool results are grouped into the user turn that follows their call, and a call nobody answered is closed. */
export function toAnthropic(messages: Message[]): Anthropic.MessageParam[] {
  const out: Anthropic.MessageParam[] = [];
  const push = (role: "user" | "assistant", block: Anthropic.ContentBlockParam) => {
    const last = out.at(-1);
    if (last && last.role === role && Array.isArray(last.content)) last.content.push(block);
    else out.push({ role, content: [block] });
  };
  for (const m of messages) {
    if (m.role === "user") {
      const text = typeof m.content === "string" ? m.content : "";
      if (text.trim()) push("user", { type: "text", text });
    } else if (m.role === "assistant") {
      if (m.content?.trim()) push("assistant", { type: "text", text: m.content });
      for (const c of m.toolCalls ?? []) {
        let input: unknown = {};
        try { input = JSON.parse(c.function.arguments || "{}"); } catch { /* a call that never finished streaming */ }
        push("assistant", { type: "tool_use", id: c.id, name: c.function.name, input });
      }
    } else if (m.role === "tool") {
      push("user", { type: "tool_result", tool_use_id: m.toolCallId, content: String(m.content ?? "") });
    }
  }
  // Every tool_use needs a tool_result in the next turn.
  for (let i = 0; i < out.length; i++) {
    const turn = out[i];
    if (turn.role !== "assistant" || !Array.isArray(turn.content)) continue;
    const used = turn.content.filter((b): b is Anthropic.ToolUseBlockParam => b.type === "tool_use").map((b) => b.id);
    if (!used.length) continue;
    const next = out[i + 1];
    const answered = new Set(next && Array.isArray(next.content) ? next.content.flatMap((b) => (b.type === "tool_result" ? [b.tool_use_id] : [])) : []);
    const missing = used.filter((id) => !answered.has(id)).map((id): Anthropic.ToolResultBlockParam => ({ type: "tool_result", tool_use_id: id, content: "Cancelled.", is_error: true }));
    if (!missing.length) continue;
    if (next && next.role === "user" && Array.isArray(next.content)) next.content.unshift(...missing);
    else out.splice(i + 1, 0, { role: "user", content: missing });
  }
  return out;
}

export class CalaveritaAgent extends AbstractAgent {
  private ctl?: AbortController;
  private client?: Anthropic;

  constructor() {
    super({ description: "Fills the calaverita form and dresses the skull with the user, and writes the calaverita when asked" });
  }

  /** The runtime's stop route lands here. */
  abortRun() {
    this.ctl?.abort();
  }

  run(input: RunAgentInput): Observable<BaseEvent> {
    const ctl = (this.ctl = new AbortController());
    return new Observable<BaseEvent>((sub) => {
      const emit: Emit = (e) => { if (!sub.closed) sub.next(e); };
      const go = async () => {
        evt(emit, EventType.RUN_STARTED, { threadId: input.threadId, runId: input.runId });
        try {
          await this.converse(input, emit, ctl.signal);
          if (!ctl.signal.aborted) evt(emit, EventType.RUN_FINISHED, { threadId: input.threadId, runId: input.runId });
        } catch (err) {
          if (ctl.signal.aborted) return;
          const message = err instanceof Error ? err.message : String(err);
          console.error("[agent] run failed:", message);
          evt(emit, EventType.RUN_ERROR, { message });
        }
      };
      void go().finally(() => sub.complete());
      return () => ctl.abort();
    });
  }

  private async converse(input: RunAgentInput, emit: Emit, signal: AbortSignal) {
    const client = (this.client ??= new Anthropic());
    let state: Draft = readState(input.state);
    const appTools = input.tools ?? [];
    const names = new Set([...SERVER_TOOLS.map((t) => t.name), ...appTools.map((t) => t.name)]);
    const tools: Anthropic.Tool[] = [
      ...SERVER_TOOLS.map((t) => ({ name: t.name, description: t.description, input_schema: t.schema as Anthropic.Tool.InputSchema })),
      ...appTools.map((t) => ({ name: t.name, description: t.description, input_schema: { type: "object" as const, ...(t.parameters as object) } })),
    ];
    const messages = toAnthropic(input.messages);

    for (let step = 0; step < MAX_STEPS && !signal.aborted; step++) {
      const stream = client.messages.stream(
        { model: MODEL, max_tokens: 2048, system: systemPrompt(state, input.context ?? [], (n) => names.has(n)), tools, messages },
        { signal },
      );
      let messageId: string = randomUUID();
      const open = new Map<number, { kind: "text" | "tool"; id: string; sentArgs: boolean }>();
      for await (const e of stream) {
        if (e.type === "message_start") messageId = e.message.id;
        else if (e.type === "content_block_start") {
          const b = e.content_block;
          if (b.type === "text") {
            open.set(e.index, { kind: "text", id: messageId, sentArgs: false });
            evt(emit, EventType.TEXT_MESSAGE_START, { messageId, role: "assistant" });
          } else if (b.type === "tool_use") {
            open.set(e.index, { kind: "tool", id: b.id, sentArgs: false });
            evt(emit, EventType.TOOL_CALL_START, { toolCallId: b.id, toolCallName: b.name, parentMessageId: messageId });
          }
        } else if (e.type === "content_block_delta") {
          const o = open.get(e.index);
          if (!o) continue;
          if (e.delta.type === "text_delta") evt(emit, EventType.TEXT_MESSAGE_CONTENT, { messageId: o.id, delta: e.delta.text });
          else if (e.delta.type === "input_json_delta" && e.delta.partial_json) {
            o.sentArgs = true;
            evt(emit, EventType.TOOL_CALL_ARGS, { toolCallId: o.id, delta: e.delta.partial_json });
          }
        } else if (e.type === "content_block_stop") {
          const o = open.get(e.index);
          if (!o) continue;
          open.delete(e.index);
          if (o.kind === "text") evt(emit, EventType.TEXT_MESSAGE_END, { messageId: o.id });
          else {
            if (!o.sentArgs) evt(emit, EventType.TOOL_CALL_ARGS, { toolCallId: o.id, delta: "{}" });
            evt(emit, EventType.TOOL_CALL_END, { toolCallId: o.id });
          }
        }
      }
      const reply = await stream.finalMessage();
      if (signal.aborted) return;

      const calls = reply.content.filter((b): b is Anthropic.ToolUseBlock => b.type === "tool_use");
      if (reply.stop_reason !== "tool_use" || !calls.length) return;

      const results: Anthropic.ToolResultBlockParam[] = [];
      let handedToApp = false;
      for (const call of calls) {
        const tool = serverTool(call.name);
        if (!tool) { handedToApp = true; continue; } // the app's: its answer starts the next run
        const out = tool.run(state, call.input);
        if (out.state !== state) {
          state = out.state;
          evt(emit, EventType.STATE_SNAPSHOT, { snapshot: state });
        }
        evt(emit, EventType.TOOL_CALL_RESULT, { messageId: randomUUID(), toolCallId: call.id, content: out.result, role: "tool" });
        results.push({ type: "tool_result", tool_use_id: call.id, content: out.result });
      }
      if (handedToApp) return;
      messages.push(
        { role: "assistant", content: reply.content.map((b) => (b.type === "tool_use" ? { type: "tool_use", id: b.id, name: b.name, input: b.input } : b.type === "text" ? { type: "text", text: b.text } : b)) as Anthropic.ContentBlockParam[] },
        { role: "user", content: results },
      );
    }
  }
}
