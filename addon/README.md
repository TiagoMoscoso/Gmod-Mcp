# GMod AI Players — addon

**Status:** spawns an inactive AI NPC and binds it with a Tool Gun. No
movement, combat, perception, or chat yet.

## Server requirements: listen or dedicated server, not true singleplayer

Binding creates the AI Player as a real player bot (`player.CreateNextBot`),
confirmed by `SPK-BOT-001` (see [docs/architecture/gmod-runtime.md](../docs/architecture/gmod-runtime.md#embodiment-accepted-for-m1)).
Player bots consume a player slot and **cannot be created in true
singleplayer**. To spawn and bind an AI Player you need:

- A **listen server** (`Host Server` from the Sandbox menu, or `+maxplayers 2`
  or higher on launch) or a **dedicated server** — not "New Game".
- At least one free player slot per AI Player you want bound.

If `player.CreateNextBot` returns an invalid entity (no free slot, or true
singleplayer), the bind fails with a `no_player_slot` chat message and the
placeholder NPC stays INACTIVE; it does not silently do nothing.

## What exists now

- `NPCs > AI Players > AI NPC` in the Spawn Menu places an INACTIVE
  placeholder NPC. It stands idle and is not an MCP-controllable AI Player
  yet.
- A Tool Gun mode ("AI Players") with **Name** and **Context** fields.
  Left-clicking an INACTIVE AI NPC with both fields set promotes it to a
  registered AI Player with a stable `agent_id`, visible to the Companion's
  `list_agents` / `get_agent` / `get_agent_status` tools.
- Lifecycle states (INACTIVE, WAITING_FOR_AGENT, ACTIVE, PAUSED, ERROR,
  DISCONNECTED); a bound AI Player only becomes ACTIVE once the Companion
  bridge is healthy and an MCP client is connected, and returns to
  DISCONNECTED (standing idle, no autonomy) if either drops.

The Companion — an out-of-process service — hosts MCP and bridges to this
addon (**Proposed:** `http://127.0.0.1:8765/mcp`, see
[ADR-005](../docs/architecture/decisions/ADR-005-mcp-hosted-by-companion.md)).
Garry's Mod never hosts MCP itself and never calls an LLM API directly; see
[docs/architecture/gmod-runtime.md](../docs/architecture/gmod-runtime.md).

## Module layout

- A conventional `lua/autorun` + `lua/ai_players/{shared,server,client,integrations}`
  module graph, plus `lua/entities/ai_players_npc` (the Spawn Menu
  placeholder) and `lua/weapons/gmod_tool/stools/ai_players_bind.lua`
  (the Tool Gun mode).
- A `GameAdapter` interface (`ai_players/shared/game_adapter.lua`) and a
  `SandboxAdapter` (`ai_players/integrations/sandbox_adapter.lua`) so
  DarkRP/Helix support can plug in later without editing core modules
  (ADR-004).
- The server-side `Registry` (`ai_players/server/registry.lua`) is the
  single source of truth for `agent_id`, name, context, capabilities, and
  lifecycle state; `ai_players/server/spawn.lua` promotes a bound
  placeholder to a real player bot.
- A real file IPC bridge to the Companion (`ai_players/server/bridge.lua`,
  `ai_players_companion_host/port/path` convars). It binds loopback only.

## What does not exist yet

- Movement, combat, or perception controllers (`move_to`, `follow`,
  `look_at`, `attack`, `observe`): the lifecycle gate (`Registry:CanAct`)
  is ready for them, but nothing calls it yet.
- `say` / chat relay.
- Right-click inspect, pause/resume UI, unbind, or a capability picker
  (MVP capabilities are hardcoded at bind).

See [docs/planning/mvp.md](../docs/planning/mvp.md) for the full vertical
slice this addon is a foundation for.
