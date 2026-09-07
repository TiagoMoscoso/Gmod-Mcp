# GMod AI Players — addon

**Status:** skeleton only. This addon does not spawn an AI NPC, register a
Tool Gun, or open any connection yet.

The Companion — an out-of-process service — hosts MCP and bridges to this
addon (**Proposed:** `http://127.0.0.1:8765/mcp`, see
[ADR-005](../docs/architecture/decisions/ADR-005-mcp-hosted-by-companion.md)).
Garry's Mod never hosts MCP itself and never calls an LLM API directly; see
[docs/architecture/gmod-runtime.md](../docs/architecture/gmod-runtime.md).

## What exists in this skeleton

- A conventional `lua/autorun` + `lua/ai_players/{shared,server,client,integrations}`
  module graph that loads on the Sandbox gamemode with no other addons.
- A `GameAdapter` interface (`ai_players/shared/game_adapter.lua`) and a
  `SandboxAdapter` (`ai_players/integrations/sandbox_adapter.lua`) so
  DarkRP/Helix support can plug in later without editing core modules
  (ADR-004).
- `ai_players_companion_host/port/path` convars describing where a future
  bridge will look for the Companion. Setting them does **not** open a
  socket; nothing here binds a port.
- A client-side Companion status that always starts `disconnected`. This
  addon draws no popup and no copyable URL, live or otherwise.

## What does not exist yet

- Spawning an AI NPC, the Tool Gun bind, or the Spawn Menu entry
  ([gmod-companion-bridge](../openspec/changes/gmod-companion-bridge),
  [ai-player-spawn-and-bind](../openspec/changes/ai-player-spawn-and-bind)).
- A real connection to the Companion.
- Movement, combat, or perception controllers.

See [docs/planning/mvp.md](../docs/planning/mvp.md) for the full vertical
slice this skeleton is a foundation for.
