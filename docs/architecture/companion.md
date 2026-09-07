# Companion

**Status:** Existence of an out-of-process Companion that hosts MCP is **Accepted** (`ADR-005`). MCP transport is **Accepted**: Streamable HTTP via the official Python MCP SDK's FastMCP, confirmed by `SPK-MCP-001` in the `companion-mcp-host` change (see [OQ-MCP-003](../requirements/open-questions.md#oq-mcp-003-mcp-transport-flavor), now closed). GMod-to-Companion bridge transport is **Accepted for MVP**: file IPC under `garrysmod/data/`, confirmed by `SPK-TRN-001` in the `gmod-companion-bridge` change. Remaining stack rows below are still **candidates**.

## Why a Companion exists

Vanilla GLua cannot be a robust MCP HTTP server. Speech, SQLite, and third-party MCP SDKs are also poor fits inside the game thread.

The Companion is the process the MCP client speaks to, and the process GMod bridges to.

## GMod bridge transport

**Accepted for MVP:** GMod and the Companion exchange JSON envelopes through files under:

```text
garrysmod/data/ai_players/bridge/
```

`SPK-TRN-001` was run on 2026-09-07 with Garry's Mod launched from the local Steam Flatpak/Proton install, a 16-player Sandbox listen server on `gm_construct`, and a small Companion-side responder. GLua wrote a `hello` file and received a `hello_ok` file through `garrysmod/data/`; the generated report recorded `file_ipc = "ok"` on `gm_construct`.

The MVP bridge uses file IPC because it works inside vanilla GLua without a listen socket or native module, keeps the Workshop addon Lua-only, and avoids relying on private-IP HTTP behavior. Payloads are small, versioned JSON envelopes; the bridge is for semantic actions, registry updates, events, and observe snapshots, not per-frame input.

### Rejected for MVP: GLua `HTTP()` to `127.0.0.1`

`SPK-TRN-001` tried `HTTP()` to `http://127.0.0.1:8765/spike/hello`. The first listen-server run failed with `Couldn't connect to server` when no responder was listening. With a responder listening, the rerun completed through file IPC and did not produce an observed HTTP success before the file result. Because GMod private-IP HTTP is already documented as unreliable in listen/singleplayer contexts ([constraints.md](../requirements/constraints.md)), HTTP polling is not the MVP production bridge.

### Failure modes

- If the Companion process is missing, GMod does not receive fresh bridge files and the addon reports not-ready.
- If protocol versions differ, the handshake writes a reject/error state and both sides fail closed.
- If the Companion dies after a healthy handshake, stale heartbeat/status files time out and the addon returns to not-ready.
- If file payloads are malformed, unsupported, or stale, the receiver ignores them and records an error event/status rather than executing an action.
- File IPC latency is acceptable for MVP because observe is pull-based and actions are semantic. It must not be used for frame-level motor control.

## Candidate stack (not locked)

| Piece | Candidate | Notes |
| --- | --- | --- |
| Language | Python 3.12 | Familiar, MCP SDK exists |
| HTTP | FastAPI | Only if MCP is HTTP |
| MCP | Official Python SDK / FastMCP (`mcp>=1.29,<2`) | **Accepted.** Streamable HTTP at `/mcp`, bound to `127.0.0.1:8765` by default; confirmed by `SPK-MCP-001` |
| GMod bridge | File IPC under `garrysmod/data/ai_players/bridge/` | **Accepted for MVP.** Confirmed by `SPK-TRN-001` on a Sandbox listen server on `gm_construct` |
| Async | asyncio | Fits streaming HTTP |
| Memory DB | SQLite | **Future** |
| STT | whisper.cpp | **Future**, local bias |
| TTS | **Open** | [OQ-VOI-002](../requirements/open-questions.md#oq-voi-002-tts-engine) |

Alternatives (Go, TypeScript, .NET) are valid if a spike shows a better MCP host. Do not rewrite this document as if Python were mandatory.

## Responsibilities (phased)

### MVP

- Host MCP (**Accepted:** Streamable HTTP at `/mcp`)
- Session awareness (a client is connected or not)
- Translate tool calls → bridge actions
- Translate GMod events → `get_recent_events` / tool results
- Protocol version handshake (**Proposed**)

### Later

- Memory, relationships
- Conversation policy if not done in GLua
- STT/TTS workers

### v2 (required, not MVP)

- Optional autonomy loops (Model C)
- Pluggable LLM provider adapters

Keep `providers/` empty until v2. See [v2-backlog.md](../planning/v2-backlog.md).

### Never (as architecture)

- Navmesh
- CUserCmd
- DarkRP job logic
- `lua_run`

## Suggested internal layout (**Proposed**, not created)

```text
companion/
├── agents/
├── mcp/
├── memory/
├── speech/
├── transport/
└── providers/
```

`providers/` is **v2**. If you add stub vendor SDKs in MVP, you are leaking Model C into the vertical slice. Don't.

## Lifecycle relative to GMod

**Open:** who starts whom?

| Option | Notes |
| --- | --- |
| User starts Companion, then GMod | Honest, bad Workshop UX |
| GMod tries to spawn Companion | Needs process module or OS-specific paths |
| Companion started by an external helper | Extra install surface |

Do not invent a watchdog in this spec. Document the gap in the popup: Companion required / not running.

## Security posture (**Proposed** for local MVP)

- Bind `127.0.0.1`
- No tool that escapes into OS or Lua
- Token auth **Open** for non-local

## Data it may hold

| Data | Phase |
| --- | --- |
| In-memory registry mirror | MVP |
| Event ring buffer | MVP |
| SQLite memories | **Future** |
| Audio buffers | **Future** |

Persona text may be duplicated: GLua is authoritative for bind; Companion caches for MCP `get_agent`.
