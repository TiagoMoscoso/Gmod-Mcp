## Purpose

Hosts a localhost MCP server in the Companion so any MCP-compatible client can list and inspect AI Players through character-agnostic tools, without Garry's Mod and without code-execution surfaces.

## ADDED Requirements

### Requirement: Localhost MCP endpoint

The Companion MUST host an MCP server bound to `127.0.0.1` and MUST NOT bind `0.0.0.0` as the MVP default. After a successful start, the process MUST expose a stable URL that an MCP client can be configured with.

#### Scenario: Successful local bind

- **WHEN** the Companion starts with default settings and the port is free
- **THEN** an MCP-compatible client MUST be able to connect using a localhost URL (proposed shape `http://127.0.0.1:8765/mcp`)

#### Scenario: Public bind is not the default

- **WHEN** the Companion starts with default settings
- **THEN** the MCP listener MUST be bound to `127.0.0.1` only

### Requirement: Character-agnostic management tools

The MCP server MUST expose `list_agents`, `get_agent`, and `get_agent_status`. Tools that act on a character MUST take `agent_id`. The server MUST NOT generate per-character-name tools.

#### Scenario: List returns registered agents

- **WHEN** the mock registry contains one agent named Walter with a stable `agent_id`
- **THEN** `list_agents` MUST return that agent including `agent_id` and name

#### Scenario: Get agent by id

- **WHEN** a client calls `get_agent` with a known `agent_id`
- **THEN** the result MUST include persona/context, capabilities, and identity fields

#### Scenario: Unknown agent

- **WHEN** a client calls `get_agent` or `get_agent_status` with an unknown `agent_id`
- **THEN** the tool MUST fail with an `unknown_agent` error and MUST NOT invent an agent

#### Scenario: Tools are not named after characters

- **WHEN** a client inspects the MCP tool catalog
- **THEN** the catalog MUST NOT contain tools whose names include a character display name (for example `walter_move`)

### Requirement: Session awareness

The Companion MUST record whether at least one MCP client session is currently connected.

#### Scenario: Client connects

- **WHEN** an MCP client successfully connects
- **THEN** session state MUST be `connected`

#### Scenario: Client disconnects

- **WHEN** the last MCP client disconnects
- **THEN** session state MUST be `disconnected`

### Requirement: Forbidden tools are absent

The MCP server MUST NOT expose `execute_lua`, `shell`, `eval`, `run_console_command`, or frame-level input tools (`press_w`, `move_mouse`, `press_attack`, and equivalents).

#### Scenario: Catalog has no escape hatches

- **WHEN** a client lists available tools
- **THEN** none of the forbidden names MUST appear

### Requirement: Provider-agnostic interface

The MCP interface MUST be usable by any MCP-compatible client. The Companion MUST NOT require a specific LLM vendor SDK to expose tools.

#### Scenario: Generic MCP client can call list_agents

- **WHEN** a non-vendor-specific MCP client (for example MCP Inspector) connects to the localhost endpoint
- **THEN** it MUST be able to call `list_agents` successfully against the mock registry

### Requirement: Testable without Garry's Mod

Management tools MUST operate against an in-memory registry that can be seeded in tests without a running GMod server.

#### Scenario: Unit test seeds a mock agent

- **WHEN** a unit test inserts an agent into the in-memory registry and calls `list_agents`
- **THEN** the call MUST return that agent without contacting Garry's Mod
