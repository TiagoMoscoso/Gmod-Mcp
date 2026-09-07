## Purpose

Lets an ACTIVE AI Player walk the map, follow a player, look at a target, and stop using semantic actions executed by GMod controllers rather than LLM frame inputs.

## ADDED Requirements

### Requirement: Semantic movement tools

The MCP server MUST expose `move_to`, `follow`, `look_at`, and `stop` for capable AI Players. Tools MUST take `agent_id` and MUST NOT be named after characters. Frame-level input tools MUST NOT exist.

#### Scenario: Catalog contains movement verbs only

- **WHEN** a client lists tools after this change
- **THEN** `move_to`, `follow`, `look_at`, and `stop` MUST be present and `press_w` / `move_mouse` MUST NOT

### Requirement: Asynchronous accept

Semantic movement that takes game time MUST return quickly with `accepted` true and an `action_id` when started, or `accepted` false with an error code. Completion MUST arrive later as events.

#### Scenario: move_to accepted

- **WHEN** an ACTIVE capable agent calls `move_to` with a valid position or entity
- **THEN** the tool MUST return `accepted: true` and an `action_id` without waiting for arrival

#### Scenario: Reject unknown agent

- **WHEN** `follow` is called with an unknown `agent_id`
- **THEN** the result MUST be `accepted: false` with `unknown_agent`

#### Scenario: Reject capability

- **WHEN** `move_to` is called and the AI Player lacks `move`
- **THEN** the result MUST be `accepted: false` with `capability_denied`

#### Scenario: Reject invalid state

- **WHEN** `follow` is called while DISCONNECTED or INACTIVE
- **THEN** the result MUST be `accepted: false` with `invalid_state`

### Requirement: Navmesh follow without teleport

`follow` and `move_to` MUST navigate using the map navmesh (PathFollower or equivalent). The AI Player MUST NOT teleport to the target. Missing navmesh MUST fail with `action_failed`, not a silent skip.

#### Scenario: Walter follows on gm_construct

- **WHEN** the player says to follow and the agent calls `follow` on a navmeshed `gm_construct`
- **THEN** Walter MUST walk toward the player and keep following without teleporting

#### Scenario: Missing navmesh fails

- **WHEN** `move_to` is issued on a map with no usable navmesh
- **THEN** GMod MUST emit `action_failed` with a machine-readable code and MUST NOT teleport

### Requirement: Completion events

Controllers MUST emit `target_reached` on success, `target_lost` when a follow target vanishes, and `action_failed` on stuck/invalid/no-mesh failures. Agents MUST be able to read those via `get_recent_events` or `observe`.

#### Scenario: Arrival event

- **WHEN** `move_to` arrives within the controller's tolerance
- **THEN** a `target_reached` event MUST appear for that `agent_id` and `action_id`

### Requirement: Preemption hypothesis for MVP

`say` MUST NOT cancel `follow`. A second `move_to` MUST replace the first. `stop` MUST cancel locomotion (and look-at locomotion coupling).

#### Scenario: say while following

- **WHEN** Walter is following and the agent calls `say`
- **THEN** follow MUST continue

#### Scenario: stop cancels follow

- **WHEN** the agent calls `stop` during `follow`
- **THEN** locomotion MUST halt and follow MUST end
