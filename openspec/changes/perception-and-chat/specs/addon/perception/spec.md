## Purpose

Gives each AI Player a filtered, pull-based view of itself, nearby relevant entities, and recent events without dumping the map or leaking god-camera data.

## ADDED Requirements

### Requirement: Filtered observe snapshot

The system MUST provide `observe` for a given `agent_id`. The snapshot MUST include self, nearby/relevant players, AI Players, a bounded entity list, and recent events. The snapshot MUST NOT include every entity on the map.

#### Scenario: Observe returns grouped snapshot

- **WHEN** an ACTIVE AI Player with `observe` capability is observed
- **THEN** the result MUST contain `self`, `visible_players`, `visible_ai_players`, `visible_entities`, and `recent_events` groupings (field names may match this shape)

#### Scenario: Map dump is forbidden

- **WHEN** `observe` runs on `gm_construct` with many props
- **THEN** the entity arrays MUST be capped and MUST NOT equal `ents.GetAll()` in size

#### Scenario: Truncated flag

- **WHEN** relevant entities exceed the cap
- **THEN** the snapshot MUST set a `truncated` flag (per list or overall) so the agent knows overflow was dropped

### Requirement: Self description

The system MUST provide `get_self` for a given `agent_id` including at least position, health, weapon, alive, lifecycle state, and current action if any.

#### Scenario: get_self for Walter

- **WHEN** a client calls `get_self` for Walter's `agent_id`
- **THEN** the result MUST include position, health, alive, and lifecycle state

### Requirement: Recent events ring buffer

The system MUST expose `get_recent_events` for an AI Player. MVP events MUST include player chat the AI Player can notice, and MUST be able to carry action completion/failure events once controllers exist.

#### Scenario: Read events since cursor

- **WHEN** events exist and the client calls `get_recent_events`
- **THEN** the result MUST return a bounded list of recent events for that `agent_id`

#### Scenario: Unknown agent

- **WHEN** `observe` / `get_self` / `get_recent_events` is called with an unknown `agent_id`
- **THEN** the tool MUST fail with `unknown_agent`

### Requirement: GLua computes senses

Perception traces and filters MUST run in GMod. The Companion MUST NOT invent entities that GLua did not send. The Companion MAY drop fields to fit size limits but MUST NOT add entities.

#### Scenario: Companion does not invent ents

- **WHEN** GLua returns a snapshot with three visible players
- **THEN** the MCP `observe` result MUST NOT include additional players the game did not report

### Requirement: Privacy in snapshots

MVP snapshots MUST NOT include player IP addresses or SteamIDs.

#### Scenario: No SteamID in observe

- **WHEN** `observe` includes a human player
- **THEN** that record MUST NOT contain a SteamID or IP field
