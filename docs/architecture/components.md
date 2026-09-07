# Components

**Status:** Component names are **Proposed**. Responsibilities are **Defined** where they follow locked principles.

## GLua addon (`addon/`)

GMod-facing gameplay. Intended Workshop payload.

| Module | Responsibility |
| --- | --- |
| Spawn / lifecycle | AI NPC entity, INACTIVE spawn, Kick/Remove according to embodiment |
| Tool Gun + UI | Name, context (MVP); playermodel + male/female voice (**v2**); inspect, pause (**Proposed**) |
| Spawn Menu | `NPCs > AI Players > AI NPC` |
| Bot registry | `agent_id` ↔ entity, state, capabilities, persona; **v2:** playermodel + voice preset |
| Perception | Filtered snapshots, LOS/distance ranking |
| Movement | Navmesh / PathFollower / StartCommand execution |
| Combat | Equip, aim, attack loop inside a controller |
| Interaction | Use / pickup / drop (**Soon**) |
| Conversation | Chat relay now; ConversationManager **Future** |
| Voice (Lua side) | **v2:** play selected TTS / 3D sound; no capture in Lua |
| GameAdapter | Sandbox first; other modes plugin in |
| Bridge client | Talk to Companion using the still-**Open** transport |

### GMod-conventional layout (**Proposed**)

Workshop addons need engine paths, not only an internal package:

```text
addon/
├── addon.json
├── lua/
│   ├── autorun/
│   ├── entities/
│   ├── weapons/          # Tool Gun
│   └── ai_players/       # internal modules
│       ├── shared/
│       ├── server/
│       ├── client/
│       ├── bot/
│       ├── perception/
│       ├── movement/
│       ├── combat/
│       ├── interaction/
│       ├── conversation/
│       ├── integrations/
│       └── voice/
```

Do not ship `companion/`, `native/`, or `docs/` inside the GMA.

## Companion

External process. **Proposed** language: Python 3.12. Candidates, not locks: FastAPI, official MCP SDK, asyncio, SQLite.

| Area | Responsibility |
| --- | --- |
| MCP server | Tools, later resources/notifications |
| Agent sessions | Connected clients |
| Agent routing | `agent_id` → game entity via bridge |
| Event dispatch | Game → MCP-visible recent events |
| Memory | **Future** |
| Conversation mgmt | **Future** (may live in GLua instead — **Open**) |
| STT/TTS | **Future** |
| Provider adapters | v2 Model C only — keep empty in MVP |

Companion is **not** the GMod gamemode. It must not reimplement navmesh.

## Native voice module (**Future**)

Conceptual names: `gmsv_aivoice_win64.dll`, `gmsv_aivoice_linux64.dll`.

| Area | Responsibility |
| --- | --- |
| Capture | Voice packets / intercept |
| Codec | Opus decode |
| PCM / VAD | Segmentation |
| Transport | Efficient handoff to Companion |
| Lua bindings | Thin: "here is a voice buffer / utterance" |

Gameplay stays in GLua. See [native-voice.md](native-voice.md).

## MCP clients (out of repo)

Claude Code, Codex, Cursor, Inspector, custom clients. First-class examples, zero vendor lock-in.

## Tests (`tests/`)

**Proposed** later:

- Companion unit tests
- Protocol contract tests (fake GMod)
- GLua tests are hard in-engine; prefer a small mock or dedicated spike

No test harness in this documentation pass.

## What each component must not do

| Component | Must not |
| --- | --- |
| Agent | Path-follow per tick, aim with mouse tools, `lua_run` |
| Companion | Become a second Source engine |
| GLua | Call OpenAI/Anthropic APIs directly as the architecture |
| C++ | Own Tool Gun, Spawn Menu, DarkRP, or MCP |
