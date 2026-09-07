## Purpose

Lets players talk to an AI Player through game chat and lets that AI Player reply with a semantic say action, without NPC-to-NPC conversation management.

## ADDED Requirements

### Requirement: Hearable player chat becomes an event

The system MUST deliver player typed chat that an AI Player could reasonably notice as a `player_said` event the agent can read via `get_recent_events` or `observe`.

#### Scenario: Directed chat reaches Walter

- **WHEN** a nearby player says `Walter come with me.` in chat
- **THEN** Walter's event buffer MUST contain a `player_said` event including the text and a speaker identity the agent can use as a follow target later

#### Scenario: Unbound NPC is not an MCP listener

- **WHEN** a player chats near an INACTIVE unbound NPC
- **THEN** no MCP agent MUST receive that as a controllable AI Player event (no `agent_id` exists)

### Requirement: Agent say appears in game chat

The system MUST allow an ACTIVE AI Player with `chat` capability to send a chat message via MCP tool `say`. The message MUST appear to other players as coming from that AI Player through the gamemode chat path.

#### Scenario: Walter says hello

- **WHEN** the agent calls `say` with Walter's `agent_id` and text
- **THEN** players MUST see that text in chat attributed to Walter

#### Scenario: say rejected when not ACTIVE

- **WHEN** `say` is called for a DISCONNECTED or INACTIVE id
- **THEN** the tool MUST return `accepted: false` with `invalid_state` or `unknown_agent`

#### Scenario: say rejected without chat capability

- **WHEN** `say` is called for an agent whose capabilities omit `chat`
- **THEN** the tool MUST return `accepted: false` with `capability_denied`

### Requirement: say is not a motor tool

`say` MUST NOT require frame-level input tools and MUST NOT be implemented as `press_y` / console `say` hacks that bypass the AI Player identity.

#### Scenario: Chat uses the AI Player identity

- **WHEN** `say` succeeds
- **THEN** the chat MUST use the bound AI Player name, not the host player's name
