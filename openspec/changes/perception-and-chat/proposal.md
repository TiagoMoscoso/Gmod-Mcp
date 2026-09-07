## Why

An external agent cannot follow or fight until it can see a filtered slice of the world and exchange chat. Dumping `ents.GetAll()` is both a token bomb and a wallhack. This change adds `observe`, `get_self`, `get_recent_events`, `player_said`, and `say` so Scenario A has a closed perception/communication loop before movement controllers exist.

## What Changes

- GLua computes a bounded perception snapshot from the AI Player's senses (distance/LOS/relevance), not a map dump.
- MCP tools: `observe`, `get_self`, `get_recent_events`.
- Ring buffer of events: at least `player_said` and placeholders for later action completion (`target_reached`, `action_failed`).
- Player chat that the AI Player could reasonably notice becomes `player_said`.
- MCP `say` relays through the gamemode chat path as the AI Player.
- Caps + `truncated` flag. No SteamIDs/IPs in MVP snapshots.
- Do **not** implement `get_entity` / `get_player` (Soon), NPC↔NPC ConversationManager, or voice.

## Capabilities

### New Capabilities

- `addon/perception`: The system MUST provide filtered observe/self/event tools for an AI Player computed in GLua from that character's senses, never a full entity dump.
- `addon/chat`: The system MUST deliver hearable player chat as events and MUST allow an AI Player to `say` in game chat.

### Modified Capabilities

- None.

## Impact

- Depends on `ai-player-spawn-and-bind` (real `agent_id` + entity).
- Companion tools grow; GLua perception + conversation modules.
- Unblocks `movement-actions` and `combat-actions` in parallel.
