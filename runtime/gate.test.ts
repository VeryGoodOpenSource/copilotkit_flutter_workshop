import assert from "node:assert/strict";
import { createServer, type Server } from "node:http";
import type { AddressInfo } from "node:net";
import { after, before, describe, it } from "node:test";
import { createGate } from "./gate.js";

const lines: string[] = [];
let server: Server;
let base: string;

const call = (path: string, method: string, headers: Record<string, string> = {}) =>
  fetch(`${base}${path}`, { method, headers }).then((r) => r.status);

describe("createGate", () => {
  before(async () => {
    const gate = createGate((_req, res) => res.writeHead(200).end("ok"), {
      code: "secret",
      maxRunsPerSession: 2,
      maxRunsTotal: 3,
      log: (line) => lines.push(line),
    });
    server = createServer(gate);
    await new Promise<void>((resolve) => server.listen(0, resolve));
    base = `http://localhost:${(server.address() as AddressInfo).port}/api/copilotkit`;
  });
  after(() => server.close());

  it("keeps /info and the preflight open", async () => {
    assert.equal(await call("/info", "GET"), 200);
    assert.equal(await call("/agent/default/run", "OPTIONS"), 200);
  });

  it("refuses a missing or wrong code", async () => {
    assert.equal(await call("/agent/default/run", "POST"), 401);
    assert.equal(await call("/agent/default/run", "POST", { "x-workshop-code": "nope" }), 401);
    assert.equal(await call("/agent/default/run", "POST", { "x-workshop-code": "secre" }), 401);
  });

  it("refuses a stop request without the code", async () => {
    assert.equal(await call("/agent/default/stop/thread", "POST"), 401);
    assert.equal(await call("/agent/default/stop/thread", "POST", { "x-workshop-code": "secret" }), 200);
  });

  it("lets the right code through and logs the session", async () => {
    const headers = { "x-workshop-code": "secret", "x-workshop-session": "aaa" };
    assert.equal(await call("/agent/default/run", "POST", headers), 200);
    assert.match(lines.at(-1)!, /run session=aaa runs=1 total=1/);
  });

  it("caps the runs of one session, then of all of them", async () => {
    const run = (session: string) => call("/agent/default/run", "POST", { "x-workshop-code": "secret", "x-workshop-session": session });
    assert.equal(await run("aaa"), 200); // aaa: 2 of 2
    assert.equal(await run("aaa"), 429);
    assert.equal(await run("bbb"), 200); // total: 3 of 3
    assert.equal(await run("ccc"), 429);
  });

  it("asks for nothing when there is no code", async () => {
    const open = createServer(createGate((_req, res) => res.writeHead(200).end(), { maxRunsPerSession: 1, maxRunsTotal: 1 }));
    await new Promise<void>((resolve) => open.listen(0, resolve));
    const url = `http://localhost:${(open.address() as AddressInfo).port}/agent/default/run`;
    assert.equal((await fetch(url, { method: "POST" })).status, 200);
    assert.equal((await fetch(url, { method: "POST" })).status, 200);
    open.close();
  });
});
