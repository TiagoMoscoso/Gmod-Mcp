## Purpose

Lets a player spawn an inactive AI NPC that becomes a registered AI Player with a stable agent_id, explicit lifecycle states, and no autonomy until an agent is actually driving it.

## Requirements

### Requirement: Inactive spawn from Spawn Menu

The system MUST allow spawning an AI NPC from Spawn Menu category `NPCs > AI Players > AI NPC`. The spawned entity MUST start INACTIVE and MUST NOT run agent-driven autonomy.

#### Scenario: Place from Spawn Menu

- **WHEN** a player selects `NPCs > AI Players > AI NPC` and places it on `gm_construct`
- **THEN** an AI NPC MUST appear in the world in state INACTIVE

#### Scenario: Inactive does not roam on its own

- **WHEN** an INACTIVE AI NPC exists with no bind
- **THEN** it MUST NOT issue agent-driven movement or attack

### Requirement: Stable agent_id after bind

The system MUST register a bound AI NPC as an AI Player with a stable `agent_id`. MCP tools MUST identify the character by that `agent_id`. A new body after removal MUST receive a new `agent_id` (no persistence across maps in MVP).

#### Scenario: Bind creates agent_id

- **WHEN** a valid Tool Gun bind completes
- **THEN** the registry MUST assign an `agent_id` that remains unchanged until the entity is removed

#### Scenario: Removal drops the agent

- **WHEN** a registered AI Player entity is removed or kicked according to embodiment rules
- **THEN** `list_agents` MUST no longer include that `agent_id`

### Requirement: Explicit lifecycle states

The system MUST represent AI Player lifecycle with at least INACTIVE, WAITING_FOR_AGENT, ACTIVE, PAUSED, ERROR, and DISCONNECTED. INACTIVE MUST NOT jump to ACTIVE without bind.

#### Scenario: Bind moves to waiting

- **WHEN** an INACTIVE NPC is bound with valid name and context
- **THEN** its state MUST become WAITING_FOR_AGENT (or ACTIVE if the MVP policy treats a connected MCP client as immediately available)

#### Scenario: Companion loss disconnects

- **WHEN** a bound ACTIVE AI Player's Companion or bridge drops
- **THEN** its state MUST become DISCONNECTED

#### Scenario: Disconnected NPC is not a silent attacker

- **WHEN** an AI Player is DISCONNECTED, INACTIVE, WAITING_FOR_AGENT, PAUSED, or ERROR
- **THEN** it MUST stand idle and MUST NOT hold attack buttons or continue a combat controller

### Requirement: Multi-agent registry

The system MUST allow more than one AI Player at the same time, each with its own name, context, and `agent_id`.

#### Scenario: Two bound NPCs have distinct ids

- **WHEN** two AI NPCs are bound with different names
- **THEN** `list_agents` MUST return two records with distinct `agent_id` values and distinct names

### Requirement: Lifecycle gates actions

Movement and combat actions MUST be rejected unless the AI Player is ACTIVE (and capable). INACTIVE entities MUST NOT be addressable as MCP agents.

#### Scenario: Inactive unknown to MCP

- **WHEN** an AI NPC is spawned but not bound
- **THEN** `list_agents` MUST NOT present it as a controllable AI Player
