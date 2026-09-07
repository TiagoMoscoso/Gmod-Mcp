## Context

See proposal.md for motivation. MCP already serves tools against a mock registry (`companion-mcp-host`). GLua loads without a bridge (`gmod-addon-skeleton`). Constraints: no GLua listen sockets; `HTTP()` to private IPs may be blocked on listen/SP ([constraints.md](docs/requirements/constraints.md)). Spike: [SPK-TRN-001](docs/planning/technical-spikes.md). Popup: [user-experience.md](docs/product/user-experience.md), SPK-HTTP-001.

## Goals / Non-Goals

**Goals:**

- Choose transport with a time-boxed spike and document it.
- Versioned envelope for handshake, registry, actions, events, observe.
- Popup truthfulness (FR-UX-001, FR-UX-003).
- Contract tests with a fake peer.

**Non-Goals:**

- Real AI NPC spawn/bind (fixtures for registry messages).
- Perception quality, movement, combat.
- Public-internet MCP / token auth.
- Companion auto-spawn from GLua (OQ: who starts whom — user starts Companion first).

## Decisions

### Spike order: file IPC first, then HTTP

Try writes under `garrysmod/data/` (known GMod MCP pattern) because HTTP to `127.0.0.1` is the documented failure mode. If file IPC is good enough for MVP latency (local, pull-based observe), keep it. If HTTP works on the target listen-server setup, it may be simpler. Record the winner; do not support two production transports in MVP.

**Alternative:** native websocket module. Rejected for MVP (no native in vertical slice).

### JSON envelopes, `type` + `protocol_version`

Example types: `hello`, `hello_ok`, `hello_reject`, `registry_upsert`, `registry_remove`, `action_request`, `action_result`, `event`, `observe_request`, `observe_result`. GMod remains authority for world facts; Companion caches.

**Alternative:** protobuf. Rejected — GLua JSON is enough.

### Fail closed on version mismatch

Matches OQ-DIST-004 hypothesis (explicit protocol version). Strict refuse for MVP.

### Popup states

`companion_missing` | `handshake_failed` | `online_no_client` | `online_client_connected`. Only `online_*` show a copyable URL. Setup Guide = GitHub README.

Companion MCP session flag (from previous change) can be polled over the bridge or inferred; if transport cannot push, GLua polls a status file/endpoint.

### Contract tests

Python tests simulate GMod by writing/reading the same transport. Optional Lua-side tests later; do not block on in-engine GLua tests.

## Risks / Trade-offs

- [File IPC latency / locking] → MVP is pull observe, not per-tick stream; keep payloads small.
- [HTTP works on dedicated but not listen] → Spike must run on listen server (`gm_construct`), not only dedicated.
- [Popup lies if GLua can reach files but MCP HTTP is down] → Health MUST include "MCP listener bound", not only "saw a file".

## Migration Plan

Spawn-and-bind replaces fixture registry upserts with real `agent_id` rows. Perception fills observe payloads.

## Open Questions

- Exact poll interval / file names if file IPC wins — pick during spike; does not change requirements.
- Who starts the Companion (user vs GMod spawn) remains Open; MVP assumption: user starts Companion first.
