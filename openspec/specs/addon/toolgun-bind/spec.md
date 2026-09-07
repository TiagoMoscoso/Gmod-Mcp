## Purpose

Lets a player bind a name and persona onto an inactive AI NPC with the Tool Gun so the character becomes a registered AI Player visible to MCP management tools.

## Requirements

### Requirement: Tool Gun left-click bind

The system MUST provide a Tool Gun that binds configuration to an AI NPC by left-click. The bind MUST apply at least a name and a context/persona.

#### Scenario: Bind Walter

- **WHEN** the user sets name `Walter` and context `You are Walter, my mechanic friend.` and left-clicks an INACTIVE AI NPC
- **THEN** the NPC MUST become a registered AI Player with that name and context

#### Scenario: Bind requires name and context

- **WHEN** the user left-clicks an AI NPC with empty name or empty context
- **THEN** the bind MUST NOT register an AI Player

### Requirement: Bound agent appears on MCP

After a successful bind, the Companion `list_agents` tool MUST include the new AI Player. `get_agent` MUST return the bound name and context for that `agent_id`.

#### Scenario: list_agents includes Walter

- **WHEN** bind succeeds and the bridge is healthy
- **THEN** `list_agents` MUST include Walter's `agent_id` and name

#### Scenario: get_agent returns persona

- **WHEN** a client calls `get_agent` for the bound `agent_id`
- **THEN** the result MUST include the bound name and context text

### Requirement: MVP capabilities are granted at bind

A successful MVP bind MUST grant the hardcoded capability set `observe`, `move`, `chat`, and `combat`. The Tool Gun MUST NOT require capability checkboxes for the vertical slice.

#### Scenario: Default caps on bind

- **WHEN** bind succeeds
- **THEN** `get_agent` MUST report capabilities including `observe`, `move`, `chat`, and `combat`

### Requirement: GLua is authority for persona

After bind, GMod is the authority for name and context. The Companion MUST cache those strings for MCP reads and MUST NOT invent a different persona.

#### Scenario: Companion cache matches GMod

- **WHEN** bind completes and `get_agent` is called
- **THEN** the returned name and context MUST match the Tool Gun values stored in the GLua registry
