# Functional requirements

**Status:** **Defined** unless marked otherwise. Keep this list small and testable.

Related: [non-functional-requirements.md](non-functional-requirements.md), [open-questions.md](open-questions.md).

## Bots and lifecycle

### FR-BOT-001

The system shall allow spawning an inactive AI NPC from the Spawn Menu category `NPCs > AI Players > AI NPC`.

An inactive AI NPC shall not run agent-driven autonomy.

### FR-BOT-002

The system shall allow binding an AI configuration to an AI NPC using the Tool Gun.

The bind shall at least apply a **name** and a **context/persona**.

### FR-BOT-003

The system shall register a bound AI NPC as an AI Player with a stable `agent_id`.

### FR-BOT-004

The system shall allow more than one AI Player to exist at the same time, each with its own name, context, and `agent_id`.

**Note:** the first vertical slice may test a single Walter. The data model must still be multi-agent.

### FR-BOT-005

The system shall represent AI Player lifecycle in explicit states, including at least INACTIVE, WAITING_FOR_AGENT, ACTIVE, PAUSED, ERROR, and DISCONNECTED.

Meanings and transitions: [npc-lifecycle.md](../design/npc-lifecycle.md). Exact behavior in INACTIVE/DISCONNECTED without a client is **Open** ([OQ-BOT-002](open-questions.md#oq-bot-002-behavior-without-agent)).

## UX

### FR-UX-001

After integration startup, the system shall present the MCP endpoint to the host (popup or equivalent), including a copyable URL.

Example shape: `http://127.0.0.1:8765/mcp`. Host, port, and path are **Proposed**, not locked.

### FR-UX-002

The system shall expose a Tool Gun that can bind configuration to an AI NPC by left-click.

Right-click inspect, reload pause/resume, and unbind are **Proposed**. See [user-experience.md](../product/user-experience.md).

### FR-UX-003

If the Companion is not available, the system shall not report a working MCP endpoint as ready.

**Proposed** copy and Setup Guide target: GitHub. Exact screens are **Open**.

## MCP

### FR-MCP-001

The MCP server shall expose all currently registered AI Players (list operation).

### FR-MCP-002

MCP tools that act on a character shall identify the target by `agent_id` (or a later-accepted session scope). Tools shall not be generated per character name.

### FR-MCP-003

The MCP server shall provide `get_agent` and `get_agent_status` for a given `agent_id`.

### FR-MCP-004

The MCP interface shall be usable by any MCP-compatible client. The addon shall not require a specific LLM vendor.

## Perception

### FR-PER-001

The system shall provide a filtered observation of the world for an AI Player (`observe`).

The snapshot shall not include every entity on the map.

### FR-PER-002

The system shall provide a self-description for an AI Player (`get_self`).

### FR-PER-003

The system shall expose recent, relevance-filtered events for an AI Player (`get_recent_events`).

MVP events include at least: player chat directed at or hearable by the AI Player, action completion/failure, and (for the combat test) enough target information to attack a designated NPC.

## Actions

### FR-ACT-001

The system shall accept semantic actions from the agent and execute them in Garry's Mod via controllers. Frame-level input tools shall not be provided.

### FR-ACT-002

The system shall support `move_to`, `follow`, `look_at`, and `stop` for capable AI Players.

### FR-ACT-003

The system shall support `equip_weapon`, `attack`, and `stop_attack` for AI Players whose capabilities allow combat.

Aiming and firing cadence are controller concerns, not MCP tools.

### FR-ACT-004

Semantic actions that take game time shall be accepted asynchronously. Completion and failure shall be reported as events (for example `target_reached`, `action_failed`).

Exact JSON envelope is **Proposed**. See [actions.md](../design/actions.md).

## Communication

### FR-COM-001

The system shall allow an AI Player to send a chat message (`say`).

### FR-COM-002

The system shall deliver player chat that an AI Player could reasonably notice as an event the agent can read.

Hearing distance, team chat rules, and voice are **Open** / **Future** as noted in [conversations.md](../design/conversations.md).

## Distribution

### FR-DIST-001

The GLua addon shall be structured so it can be published to the Steam Workshop as a GMA without including Companion source or documentation.

### FR-DIST-002

The full project (docs, addon, Companion, native source when it exists) shall be publishable to a public GitHub repository.

## Future placeholders (not MVP requirements)

These are **Future**. They are listed so they are not invented later as if they were already required:

- FR-VOI (STT/TTS)
- FR-MEM (persistent memory)
- FR-CNV (NPC-to-NPC ConversationManager)
- FR-GM-DRP (DarkRP verbs)
