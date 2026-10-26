// The password gate and the spend limits of the shared deployment.
import { timingSafeEqual } from "node:crypto";
import type { IncomingMessage, ServerResponse } from "node:http";

export type Handler = (req: IncomingMessage, res: ServerResponse) => unknown;

export interface GateOptions {
  /** The workshop password. Without one the gate lets everything through. */
  code?: string;
  /** Runs one session (`X-Workshop-Session`) may start. */
  maxRunsPerSession: number;
  /** Runs all sessions together may start, until the instance restarts. */
  maxRunsTotal: number;
  /** One line per run, for the Cloud Run logs. */
  log?: (line: string) => void;
}

function reject(res: ServerResponse, status: number, error: string) {
  res.writeHead(status, { "content-type": "application/json", "access-control-allow-origin": "*" });
  res.end(JSON.stringify({ error }));
}

function matches(given: string, wanted: string) {
  const a = Buffer.from(given);
  const b = Buffer.from(wanted);
  return a.length === b.length && timingSafeEqual(a, b);
}

/** Wraps `next` so every request needs the password, and every run counts against the caps. */
export function createGate(next: Handler, options: GateOptions): Handler {
  const { code, maxRunsPerSession, maxRunsTotal, log = () => {} } = options;
  if (!code) return next;

  const runsBySession = new Map<string, number>();
  let runsTotal = 0;

  return (req, res) => {
    const path = (req.url ?? "").split("?")[0];
    // `/info` and the CORS preflight stay open, so `tool/doctor.mjs` and the browser work without the code.
    if (req.method === "OPTIONS" || path.endsWith("/info")) return next(req, res);

    if (!matches(String(req.headers["x-workshop-code"] ?? ""), code)) {
      return reject(res, 401, "Missing or wrong workshop code.");
    }
    if (req.method === "POST" && path.endsWith("/run")) {
      const session = String(req.headers["x-workshop-session"] ?? "").replace(/[^A-Za-z0-9-]/g, "").slice(0, 64) || "unknown";
      const runs = (runsBySession.get(session) ?? 0) + 1;
      if (runs > maxRunsPerSession || runsTotal >= maxRunsTotal) {
        log(`run refused session=${session} runs=${runs - 1} total=${runsTotal}`);
        return reject(res, 429, "The workshop run limit is reached.");
      }
      runsBySession.set(session, runs);
      runsTotal += 1;
      log(`run session=${session} runs=${runs} total=${runsTotal}`);
    }
    return next(req, res);
  };
}
