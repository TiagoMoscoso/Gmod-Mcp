## Purpose

Lets a combat-capable AI Player equip a weapon and attack a designated NPC through a GMod controller, without exposing aim or attack as MCP frame tools, and without continuing to fight after disconnect.

## ADDED Requirements

### Requirement: Semantic combat tools

The MCP server MUST expose `equip_weapon`, `attack`, and `stop_attack`. Aiming and firing cadence MUST NOT be MCP tools. Tools MUST take `agent_id`.

#### Scenario: Catalog

- **WHEN** a client lists tools after this change
- **THEN** `equip_weapon`, `attack`, and `stop_attack` MUST be present and `press_attack` / `move_mouse` MUST NOT

### Requirement: CombatController owns motor combat

`attack` MUST start a GMod CombatController that navigates toward the target, aims, and fires. The LLM MUST NOT send per-frame attack inputs. Damage on the designated NPC MUST be possible on the chosen embodiment.

#### Scenario: Kill that NPC

- **WHEN** the player designates an NPC, the agent observes it, calls `equip_weapon` if needed, then `attack`
- **THEN** the designated NPC MUST take damage from the AI Player without any MCP aim tool

#### Scenario: Async accept

- **WHEN** `attack` is accepted
- **THEN** the tool MUST return `accepted: true` and an `action_id` without waiting for the target to die

### Requirement: Capability and state gates

Combat tools MUST fail with `capability_denied` without `combat`, `invalid_state` when not ACTIVE, and `unknown_agent` for unknown ids.

#### Scenario: No combat cap

- **WHEN** `attack` is called on an agent lacking `combat`
- **THEN** the result MUST be `accepted: false` with `capability_denied`

### Requirement: Preemption

`attack` MUST cancel `follow` / `move_to`. `stop_attack` MUST cancel combat. `stop` MUST cancel locomotion and combat.

#### Scenario: Attack replaces follow

- **WHEN** Walter is following and the agent calls `attack`
- **THEN** follow MUST end and the CombatController MUST start

#### Scenario: stop_attack

- **WHEN** the agent calls `stop_attack` during `attack`
- **THEN** the AI Player MUST stop firing and leave combat

### Requirement: Disconnect safety

When the AI Player is DISCONNECTED, PAUSED, ERROR, or the Companion is gone, the CombatController MUST halt and MUST NOT keep IN_ATTACK held.

#### Scenario: Kill Companion mid-fight

- **WHEN** Walter is attacking and the Companion process is killed
- **THEN** Walter MUST stop attacking and MUST NOT continue as a silently intelligent attacker

### Requirement: Target known from perception

`attack` and weapon-against-entity targeting MUST require the target to be known from recent `observe` or events unless a later rule says otherwise. Agents MUST NOT attack arbitrary hidden entindexes as the default.

#### Scenario: Unseen target rejected

- **WHEN** `attack` is called with an entity id that is not in recent perception or events
- **THEN** the tool MUST return `accepted: false` (for example `invalid_target`) and MUST NOT start combat
