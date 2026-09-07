## Why

Scenario B is part of the MVP: Walter must attack a designated NPC after the player says to kill it. Aiming and firing cadence are controller concerns, not MCP mouse tools. Combat also proves that killing the Companion cannot leave a silently intelligent attacker. This change closes M1b.

## What Changes

- Run SPK-CBT-001 against the chosen embodiment (aim + IN_ATTACK inside GLua).
- MCP tools `equip_weapon`, `attack`, `stop_attack` keyed by `agent_id`.
- CombatController: navigate, aim, fire; no `press_attack` / `move_mouse` tools.
- `attack` cancels `follow` / `move_to`. `stop` / `stop_attack` halt combat.
- Target should be known from perception or recent events (anti-wallhack hypothesis).
- DISCONNECTED / Companion death MUST drop attack buttons.
- Hypothesis: spawn-menu / given weapons are enough; no pickup required unless the spike says otherwise.
- Do **not** implement `reload` as an MCP tool (Soon), voice, or Model C.

## Capabilities

### New Capabilities

- `addon/combat`: Capable ACTIVE AI Players MUST equip a weapon and attack a designated target through a GMod CombatController, with semantic MCP start/stop only, and MUST stop attacking when the agent connection is lost.

### Modified Capabilities

- None. Movement preemption is additional combat behavior; movement requirements stay valid.

## Impact

- Depends on perception (visible NPC target) and embodiment. May apply in parallel with `movement-actions` if two people work; sequentially after Scenario A.
- GLua `combat/` module; Companion combat tools.
- Completes MVP definition of done for combat.
