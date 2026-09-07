## Why

The MVP hypothesis is that an external MCP agent can drive a GMod character with semantic actions while GMod owns motor control. Perception and chat are not enough: Walter must navigate `gm_construct` via navmesh when told to follow, without teleporting and without `press_w` tools. This change closes Scenario A.

## What Changes

- Run SPK-NAV-001: PathFollower + embodiment motor path on `gm_construct`; missing-nav fails loudly.
- MCP tools `move_to`, `follow`, `look_at`, `stop` keyed by `agent_id`.
- MovementController and LookController in GLua; async `accepted` + `action_id`.
- Events `target_reached`, `target_lost`, `action_failed` (no navmesh, stuck, invalid target).
- `say` MUST NOT cancel `follow`; a new `move_to` replaces the current locomotion.
- No teleport fallback. No frame-level input MCP tools.
- Do **not** implement combat tools (next change).

## Capabilities

### New Capabilities

- `addon/movement`: Capable ACTIVE AI Players MUST walk and follow via GMod controllers started by semantic MCP tools, with asynchronous completion events and no teleport or per-frame input tools.

### Modified Capabilities

- None.

## Impact

- Depends on `perception-and-chat` (follow target from `player_said` / observe).
- GLua `movement/` controllers; Companion movement tools.
- Scenario A definition of done.
- Combat can start in parallel after perception; sequentially, apply this first.
