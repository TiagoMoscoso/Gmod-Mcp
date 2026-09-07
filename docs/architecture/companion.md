# Companion

**Status:** Existence of an out-of-process Companion that hosts MCP is **Accepted** (`ADR-005`). MCP transport is **Accepted**: Streamable HTTP via the official Python MCP SDK's FastMCP, confirmed by `SPK-MCP-001` in the `companion-mcp-host` change (see [OQ-MCP-003](../requirements/open-questions.md#oq-mcp-003-mcp-transport-flavor), now closed). Remaining stack rows below are still **candidates**.

## Why a Companion exists

Vanilla GLua cannot be a robust MCP HTTP server. Speech, SQLite, and third-party MCP SDKs are also poor fits inside the game thread.

The Companion is the process the MCP client speaks to, and the process GMod bridges to.

## Candidate stack (not locked)

| Piece | Candidate | Notes |
| --- | --- | --- |
| Language | Python 3.12 | Familiar, MCP SDK exists |
| HTTP | FastAPI | Only if MCP is HTTP |
| MCP | Official Python SDK / FastMCP (`mcp>=1.29,<2`) | **Accepted.** Streamable HTTP at `/mcp`, bound to `127.0.0.1:8765` by default; confirmed by `SPK-MCP-001` |
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
