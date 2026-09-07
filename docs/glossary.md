# Glossary

Terms used across the specification. Status: **Defined** as vocabulary; some referents remain **Proposed**.

## AI Player

A registered in-game character that can be observed and controlled by an external agent through MCP. An AI Player has an identity (`agent_id`), a persona/context, a lifecycle state, and a set of capabilities.

"AI NPC" in the Spawn Menu is the **spawnable entity**. It becomes an AI Player after Tool Gun bind.

## Agent

The cognitive side of an AI Player. **MVP:** an external MCP client. **v2:** that client and/or an optional Companion autonomy loop. The agent is **not** the GMod entity.

## Agent ID

Stable identifier for a registered AI Player. MCP tools take `agent_id` rather than character names. **Defined.**

## Companion

External process that hosts MCP (proposed) and bridges agents to the Garry's Mod server. Candidate stack: Python. Not shipped inside a Steam Workshop GMA by default. See [companion.md](architecture/companion.md).

## Controller

A deterministic GMod subsystem that executes a semantic action over time (movement, combat, look-at). The LLM does not implement path following or aiming. **Defined** principle.

## Capability

An explicitly granted permission for an AI Player (for example `move`, `combat`, `say`). Agents may only invoke tools allowed by that AI Player's capabilities. **Proposed** model: [capabilities.md](design/capabilities.md).

## Embodiment

How the AI Player exists in the engine: player bot (`player.CreateNextBot`), NextBot SENT, classic NPC, or a hybrid. **Open.** See [OQ-BOT-001](requirements/open-questions.md#oq-bot-001-embodiment).

## GameAdapter

Interface that maps core verbs onto a gamemode. Sandbox is the first adapter. DarkRP/Helix are **Future**. Core must not import DarkRP types. **Defined** principle.

## GMA

Garry's Mod addon archive published to the Steam Workshop via `gmad` / `gmpublish`.

## MCP

[Model Context Protocol](https://modelcontextprotocol.io/). The only supported agent-facing API for this project. Tools, and later resources/notifications, are provider-agnostic.

## Motor control

Low-level execution: navmesh, `PathFollower`, `GM:StartCommand`, `CUserCmd`, buttons, view angles. Owned by GMod, not by the LLM. **Defined.**

## Perception snapshot

Filtered world view returned by `observe`: self, nearby/relevant players, AI Players, entities, and recent events. Not a dump of the map. **Defined** principle.

## Persona / context

Natural-language character brief bound with the Tool Gun (name, personality, relationships). Distinct from persistent memory. **Defined** for MVP; memory is **Future**.

## Semantic action

High-level intent such as `move_to`, `follow`, `attack`, `say`. Accepted asynchronously; completed via events. **Defined.** Contrast: frame-level input (`press_w`) is forbidden.

## Vertical slice

The smallest end-to-end path that proves the architecture: spawn, bind, chat, `say`, `follow`, then a combat test. See [mvp.md](planning/mvp.md).
