# Use cases

**Status:** **Defined** for the primary Sandbox cases that drive the MVP. Later cases are **Future**.

IDs are for traceability, not a complete backlog.

## UC-001 — Discover the MCP endpoint

**Actor:** Sandbox host  
**Phase:** MVP  
**Status:** **Defined**

After the addon loads, the host sees where to point an MCP client and can copy that URL.

Related: [FR-UX-001](../requirements/functional-requirements.md#fr-ux-001).

## UC-002 — Connect a generic MCP client

**Actor:** Host using Claude Code, Codex, or another client  
**Phase:** MVP  
**Status:** **Defined**

The host adds the project's MCP server to any compatible client. No vendor-specific GLua adapter is required.

Related: [ADR-003](../architecture/decisions/ADR-003-provider-agnostic-mcp.md).

## UC-003 — Spawn an inactive AI NPC

**Actor:** Player with spawn permission  
**Phase:** MVP  
**Status:** **Defined**

From `NPCs > AI Players > AI NPC`, the player places an entity that does not act autonomously.

Related: [FR-BOT-001](../requirements/functional-requirements.md#fr-bot-001).

## UC-004 — Bind Walter

**Actor:** Player with the Tool Gun  
**Phase:** MVP  
**Status:** **Defined**

The player sets name `Walter` and a mechanic persona, then left-clicks the NPC. The NPC becomes a registered AI Player listed by MCP.

Related: [FR-BOT-002](../requirements/functional-requirements.md#fr-bot-002), [FR-MCP-001](../requirements/functional-requirements.md#fr-mcp-001).

## UC-005 — "Come with me"

**Actor:** Player + agent  
**Phase:** MVP (vertical slice)  
**Status:** **Defined**

The player types a chat message asking Walter to follow. The agent receives a recent-event / perception update, calls `say` and `follow`, Walter answers in chat, navigates, and keeps following.

Related: [mvp.md](../planning/mvp.md).

## UC-006 — "Kill that NPC"

**Actor:** Player + agent  
**Phase:** MVP (second test)  
**Status:** **Defined** as a validation scenario, not as a requirement that every AI Player must be hostile by default.

The player designates a target in chat. The agent observes, equips a weapon if allowed, and issues `attack`. GMod's combat controller handles pathing and aiming.

Related: [FR-ACT-003](../requirements/functional-requirements.md#fr-act-003).

## UC-007 — Inspect status

**Actor:** Player  
**Phase:** Soon after MVP  
**Status:** **Proposed**

Right-click shows name, state, capabilities, last action, last error.

## UC-008 — Pause an AI Player

**Actor:** Player  
**Phase:** Soon after MVP  
**Status:** **Proposed**

Reload (or equivalent) moves ACTIVE ↔ PAUSED. Paused characters do not take new semantic actions.

## UC-009 — Two independent personas

**Actor:** Host  
**Phase:** After vertical slice, still pre-voice  
**Status:** **Defined** as a product requirement; not required inside the first Walter-only slice.

Walter and Sarah exist together with distinct contexts. Tools always take `agent_id`.

## UC-010 — Player ↔ NPC conversation

**Actor:** Player and AI Player  
**Phase:** MVP text; voice **Future**  
**Status:** **Defined** for chat; **Future** for STT/TTS.

## UC-011 — NPC ↔ NPC conversation

**Actor:** Two AI Players  
**Phase:** **Future**  
**Status:** **Future**

Hearing is distance/LOS-limited. A ConversationManager prevents infinite reply loops. See [conversations.md](../design/conversations.md).

## UC-012 — Workshop-only install

**Actor:** Player who subscribed on Steam  
**Phase:** Distribution  
**Status:** **Defined** goal with **Open** Companion install

The GLua addon installs from Workshop. If the Companion is missing, the UI must not pretend MCP is ready. Setup Guide points to GitHub.

Related: [distribution.md](../planning/distribution.md).

## UC-013 — Dedicated Linux server

**Actor:** Server operator  
**Phase:** After local Sandbox path works  
**Status:** **Open** UX and packaging

`srcds` install, bind address, auth, and native binaries differ from a listen server. See [OQ-UX-001](../requirements/open-questions.md#oq-ux-001-local-vs-dedicated-server-ux).

## UC-014 — DarkRP job verbs

**Actor:** RP player / officer AI Player  
**Phase:** **Future**  
**Status:** **Future**

A DarkRP adapter may add `buy`, `arrest`, `fine`, etc. Core Sandbox does not implement these.

## UC-015 — Voice in / voice out

**Actor:** Players near an AI Player  
**Phase:** Output presets **v2**; STT **Future**  
**Status:** Output UX **Defined** for v2; pipeline details **Open**

v2 Tool Gun: pick male or female voice for NPC → player speech in multiplayer. Agent `speak` → TTS → 3D sound. Player → NPC STT remains later. True Source voice injection is investigation only.

## UC-016 — Choose playermodel and voice on bind

**Actor:** Host with the Tool Gun  
**Phase:** **v2**  
**Status:** **Defined**

On the Tool Gun C-panel the host selects a player model and a multiplayer voice (at least male / female), then binds. Other players see that body and, when the AI Player speaks, hear that voice family.

Related: [v2-backlog.md](../planning/v2-backlog.md) C6, C7.
