## Context

See proposal.md for motivation. Scaffold already has `addon.json`, autorun stubs, and `protocol.lua`. This change turns stubs into a loadable module graph. Spawn, Tool Gun, and bridge are later changes. Client vs server duties: [gmod-runtime.md](docs/architecture/gmod-runtime.md).

## Goals / Non-Goals

**Goals:**

- Shared/server/client include graph under `lua/ai_players/`.
- `GameAdapter` + `SandboxAdapter` stub (chat/combat/use methods can no-op).
- Convars for companion host/port/path/protocol.
- Honest "not connected" client state with no fake URL.

**Non-Goals:**

- ENT spawnable, SWEP Tool Gun, registry, controllers.
- Actual socket/file IPC.
- DarkRP adapter.

## Decisions

### Module layout from components.md

```text
addon/lua/ai_players/
  shared/   protocol, convars, adapter interface
  server/   init, adapter select
  client/   init, status state (disconnected)
  integrations/  sandbox_adapter.lua
```

Entity and weapon folders wait for spawn-and-bind.

**Alternative:** everything in autorun. Rejected — Workshop and later modules need includes.

### Adapter is an interface table, not a class framework

GLua tables with `CanCombat`, `FormatChat`, `Use` stubs returning Sandbox defaults / false.

**Alternative:** full OOP. Unnecessary for MVP.

### Client status net-ready but empty

A shared enum `disconnected` / `connected` / `error`. Client HUD/popup is drawn in the bridge change; this change only ensures nothing paints "Online".

**Alternative:** implement the full popup now. Rejected — FR-UX-001 needs a real endpoint from the Companion.

### Convar prefix `ai_players_`

`ai_players_companion_host`, `_port`, `_path`. Replicated where the client must show the URL later.

## Risks / Trade-offs

- [Autorun include order bugs] → Single shared init that servers/clients include explicitly; verify with `lua_openscript` / listen server load.
- [Convars leak 0.0.0.0] → Default host `127.0.0.1`; document in convar help text.

## Migration Plan

Bridge change will net the real Companion URL into the client status panel. Spawn change will add `lua/entities` and `lua/weapons`.

## Open Questions

None for this change.
