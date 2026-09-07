## Context

See proposal.md for motivation. Embodiment is chosen. Observe can name the player to follow. Motor details stay in GLua ([ADR-002](docs/architecture/decisions/ADR-002-semantic-actions.md)). Spike: [SPK-NAV-001](docs/planning/technical-spikes.md).

## Goals / Non-Goals

**Goals:**

- MovementController + LookController.
- Async MCP contract.
- Scenario A pass on `gm_construct`.
- Fail loud on no mesh / stuck.

**Non-Goals:**

- Combat, `use`, ladders/jumps as MCP verbs.
- Off-nav fallback locomotion (Open; do not invent).
- Aim/attack.

## Decisions

### Controllers write embodiment motors

If player bot: `StartCommand` + `CUserCmd` forward/side move + PathFollower. If SENT: NextBot loco. MCP schema unchanged.

### Target object

`{ type: "entity"|"player"|"ai_player"|"position", id?, pos? }`. `follow` / `move_to` entity should appear in recent perception (anti-wallhack hypothesis). Positions from last observe.

### Stuck timeout

Pick a constant in code (e.g. no progress for N seconds → `action_failed` `stuck`). Not a user setting.

### LookController

`look_at` sets view/aim angles over time; may run with follow. `stop` clears look if it was the look action; if following, look-at-target can remain a controller detail.

### ActionDispatcher

Single server dispatcher maps tool → controller start/preempt. Combat change will plug in here (`attack` cancels follow).

## Risks / Trade-offs

- [No nav on other maps] → Vertical slice is `gm_construct`; fail closed.
- [Follow jitter] → Re-path throttled, not per tick from the LLM.
- [Wallhack follow by entindex] → Require target in recent observe/events for `follow`.

## Migration Plan

CombatController will preempt MovementController. Same `action_id` / event bus.

## Open Questions

- Exact arrival tolerance and stuck seconds — implementation constants.
- Attack-unseen-targets is a combat question, not this change.
