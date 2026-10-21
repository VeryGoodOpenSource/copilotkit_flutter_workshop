// The form: the state the agent and the app share. The app sends it with every run and
// takes back whatever this file produces, so the two must agree on the shape.
import { DEFAULT_COLOR, NONE, PARTS, PALETTE, TONES, partNames, type Part, type Tone } from "./catalog.js";

export interface Skull {
  color: string;
  hat: string;
  glasses: string;
  mustache: string;
  flowers: string;
}
export interface Draft {
  name: string;
  job: string;
  tone: Tone;
  skull: Skull;
}
/** What the agent may change. Every field is optional: only what is given changes. */
export interface Change {
  name?: string;
  job?: string;
  tone?: string;
  skull?: Partial<Skull>;
}

const HEX = /^#([0-9a-f]{3}|[0-9a-f]{6})$/i;
/** `#abc` and `#AABBCC` both become `#aabbcc`; anything else is not a color. */
export function hex(value: unknown): string | undefined {
  if (typeof value !== "string" || !HEX.test(value.trim())) return undefined;
  const h = value.trim().toLowerCase().slice(1);
  return `#${h.length === 3 ? [...h].map((c) => c + c).join("") : h}`;
}

const isTone = (value: unknown): value is Tone => (TONES as readonly unknown[]).includes(value);
const isVariant = (part: Part, value: unknown) => value === NONE || (PARTS[part] as readonly unknown[]).includes(value);

export function defaultState(): Draft {
  return {
    name: "",
    job: "",
    tone: "playful",
    skull: { color: DEFAULT_COLOR, hat: NONE, glasses: NONE, mustache: NONE, flowers: NONE },
  };
}

const text = (value: unknown) => (typeof value === "string" ? value.trim().slice(0, 60) : undefined);

/** Reads the state the app sent. Anything missing or malformed falls back to the default, so a half-filled state still works. */
export function readState(raw: unknown): Draft {
  const state = defaultState();
  if (!raw || typeof raw !== "object") return state;
  const s = raw as Record<string, any>;
  state.name = text(s.name) ?? state.name;
  state.job = text(s.job) ?? state.job;
  if (isTone(s.tone)) state.tone = s.tone;
  const skull = s.skull;
  if (skull && typeof skull === "object") {
    state.skull.color = hex(skull.color) ?? state.skull.color;
    for (const part of partNames) if (isVariant(part, skull[part])) state.skull[part] = skull[part];
  }
  return state;
}

export interface Applied {
  state: Draft;
  done: string[];
  rejected: string[];
}

/** Applies the agent's changes. A change that cannot apply is reported back to the model (it fixes it and tries again); the rest still apply. */
export function apply(state: Draft, change: Change): Applied {
  const next: Draft = structuredClone(state);
  const done: string[] = [];
  const rejected: string[] = [];

  for (const field of ["name", "job"] as const) {
    if (change[field] === undefined) continue;
    const value = text(change[field]);
    if (value) {
      next[field] = value;
      done.push(field);
    } else rejected.push(`${field}: needs some text`);
  }
  if (change.tone !== undefined) {
    if (isTone(change.tone)) {
      next.tone = change.tone;
      done.push("tone");
    } else rejected.push(`tone: "${change.tone}" does not exist (tones: ${TONES.join(", ")})`);
  }
  for (const [key, value] of Object.entries(change.skull ?? {})) {
    if (value === undefined) continue;
    if (key === "color") {
      const color = hex(value);
      if (color) {
        next.skull.color = color;
        done.push("skull color");
      } else rejected.push(`skull.color: "${value}" is not a hex color like #12a5a0 (festive: ${Object.entries(PALETTE).map(([h, n]) => `${n} ${h}`).join(", ")})`);
    } else if ((partNames as string[]).includes(key)) {
      const part = key as Part;
      if (isVariant(part, value)) {
        next.skull[part] = value;
        done.push(`skull ${part}`);
      } else rejected.push(`skull.${part}: "${value}" does not exist (${[NONE, ...PARTS[part]].join(", ")})`);
    } else rejected.push(`skull.${key}: there is no such part (parts: color, ${partNames.join(", ")})`);
  }
  return { state: next, done, rejected };
}
