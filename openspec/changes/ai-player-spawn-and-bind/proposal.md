## Why

The vertical slice starts when a player places an inactive AI NPC, binds a persona with the Tool Gun, and sees that character on `list_agents`. Without spawn, lifecycle, and a stable `agent_id`, MCP tools have nothing real to address. Embodiment is still open, so this change begins with SPK-BOT-001 rather than pretending player bots and NextBots are the same entity.

## What Changes

- Run SPK-BOT-001 (`player.CreateNextBot` on listen server vs NextBot SENT from Spawn Menu) and lock M1 embodiment in docs + code.
- Register Spawn Menu category `NPCs > AI Players > AI NPC`.
- Spawned entity starts INACTIVE: no agent-driven autonomy.
- Tool Gun left-click bind applies name + context/persona and registers a stable `agent_id`.
- Lifecycle states: INACTIVE, WAITING_FOR_AGENT, ACTIVE, PAUSED, ERROR, DISCONNECTED (PAUSED may be unused by UX; the state still exists).
- Multi-agent data model (more than one AI Player can be registered); the first slice may still test a single Walter.
- Hardcoded MVP capabilities: `observe`, `move`, `chat`, `combat`.
- Sync registry over the bridge so Companion `list_agents` / `get_agent` / `get_agent_status` reflect GMod.
- On Companion loss, bound NPCs MUST NOT continue attacking or roaming as if intelligent (idle / DISCONNECTED).
- Do **not** implement inspect, pause/resume UI, unbind, playermodel picker, or voice.

## Capabilities

### New Capabilities

- `addon/spawn-lifecycle`: Players can spawn an inactive AI NPC that becomes a registered AI Player with explicit lifecycle states, a stable `agent_id`, and safe idle behavior when no agent is driving it.
- `addon/toolgun-bind`: A Tool Gun left-click binds name and persona/context onto an inactive AI NPC and publishes that AI Player to the Companion registry.

### Modified Capabilities

- None.

## Impact

- Depends on `gmod-companion-bridge`.
- New `lua/entities` (and possibly player-bot spawn path) and `lua/weapons` Tool Gun.
- Server registry is the authority for identity and state.
- Unblocks `perception-and-chat`.
