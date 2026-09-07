## Context

See proposal.md for motivation. Embodiment and movement dispatcher exist or will exist. Spike: [SPK-CBT-001](docs/planning/technical-spikes.md). Pickup/use is out unless guns cannot be given via Spawn Menu.

## Goals / Non-Goals

**Goals:**

- CombatController (path + aim + IN_ATTACK).
- `equip_weapon` / `attack` / `stop_attack`.
- Preempt movement.
- Disconnect drops attack.
- Scenario B on `gm_construct`.

**Non-Goals:**

- MCP `reload`, `pickup`, aim tools.
- Friendly fire policy UI.
- DarkRP job combat rules (SandboxAdapter: combat allowed).

## Decisions

### Weapon source

Prefer Spawn Menu / given weapon on the AI Player. If embodiment cannot hold HL2 guns, document M1b go/no-go from the spike rather than adding pickup.

### Aim inside StartCommand / loco

Set view angles toward target hull; hold IN_ATTACK. Spread/reload timing are engine/controller, not tools.

### Attack preempts locomotion

ActionDispatcher: `attack` stops MovementController then starts CombatController (which may path internally).

### Target validation

Must appear in last observe or recent events for that agent. Reduces griefing-by-entindex.

### Disconnect

Reuse lifecycle halt from spawn-and-bind: clear buttons every tick while not ACTIVE.

## Risks / Trade-offs

- [NextBot SENT gunplay is weak] → Spike decides; may require player-bot embodiment for M1b.
- [LLM latency] → Controller runs autonomously after `attack` (R-ENG-004).
- [Stuck on nav while shooting] → Same stuck failure as movement; `action_failed`.

## Migration Plan

`reload` / `use` later plug into the same dispatcher. No MCP schema break if we keep `agent_id` + target object.

## Open Questions

- `equip_weapon` class name vs slot — pick a small schema in implementation (`weapon_smg1` or slot index).
