## Context

See proposal.md for motivation. Registry and embodiment exist. Observe is pull-based ([perception.md](docs/design/perception.md)). Chat hearing distance is Open; pick a pragmatic radius. ConversationManager and NPC↔NPC are Future.

## Goals / Non-Goals

**Goals:**

- GLua snapshot builder with caps, LOS/distance, `truncated`.
- MCP `observe`, `get_self`, `get_recent_events`, `say`.
- `player_said` events with enough speaker info to follow later.
- ChatRelay via SandboxAdapter.

**Non-Goals:**

- `get_entity` / `get_player` / `use`.
- Voice.
- Exact meter values as product options (pick constants).
- Per-tick perception stream.

## Decisions

### Caps (MVP constants, not user settings)

Hypothesis until OQ-PER-001: radius ~1500 units; max 8 players, 8 NPCs/AI, 16 other ents; events 32. Always include current follow/attack target if set (later controllers).

**Alternative:** unlimited lists. Rejected (tokens, wallhacks).

### LOS: eye trace for players/NPCs; skip tiny props

Sandbox fairness: default LOS on. No `omniscient` capability.

### Event buffer in GLua, mirrored to Companion

GMod is authority. Companion ring buffer is a copy for MCP reads so observe can be served without a second GMod round-trip **or** always-fresh observe for combat (hypothesis: observe is always a live bridge request; events may be pushed). Prefer live observe for MVP simplicity.

### player_said payload

`{ type: "player_said", text, speaker: { type: "player", id, name } }`. Hearing: same team or all Sandbox + distance. Ignore team in Sandbox MVP.

### say parallelism

`say` does not cancel movement (hypothesis in actions.md). No MovementController in this change; just don't design `say` as exclusive.

### Attribution

Use the entity's gamemode chat hook (`PlayerSay` equivalent for bots / `chat.AddText` from NPC name). Exact API depends on embodiment spike.

## Risks / Trade-offs

- [Hearing too wide] → Distance cap; document the number in code comments.
- [Stale observe in combat] → Always-fresh observe requests over the bridge; no TTL cache in MVP.
- [Token cost] → Caps + truncated; no model paths.

## Migration Plan

Movement/combat will append `target_reached` / `action_failed` / damage events into the same buffer. No schema fork.

## Open Questions

- Exact radius/caps — freeze constants in code; OQ-PER-001 can revise later without renaming tools.
