# Agent model

**Status:** Multi-agent identity is **Defined**. MVP cognition is **Model A**. v2 **must** implement **Model C**. See [ADR-007](decisions/ADR-007-mvp-model-a-v2-model-c.md) and [v2-backlog.md](../planning/v2-backlog.md).

## Identity

An **AI Player** is the in-game registered character.

An **agent** is the cognitive process that calls MCP tools for that character.

They meet at `agent_id`.

Persona (`name`, `context`) is configuration bound by the Tool Gun. It is not a tool name.

**Forbidden:** `walter_move()`, `sarah_attack()`.

**Required:** `move_to(agent_id, target)`.

## Multiplicity

**Defined:**

- Many AI Players per server
- Independent personas
- Shared MCP tool surface
- **MVP:** one external MCP client multiplexes them via `agent_id`
- **v2:** the same surface plus optional Companion-hosted loops

## Model A — External multiplexed client (**Defined** for MVP)

```text
Claude Code (one session)
        |
        | list_agents, observe(walter), follow(walter), say(sarah)
        v
    Companion MCP
        |
        v
    GMod registry (Walter, Sarah, ...)
```

Fits the stated UX: the user connects *their* agent. The project never chooses an LLM vendor. NPC independence is the client's problem (prompting / multiple tool calls).

If the MCP client closes, characters have no cognition (DISCONNECTED). That is accepted for MVP.

## Model B — Companion-hosted loops only

**Rejected** as the product destination. It would make MCP a debug sidecar and force provider keys into the Companion as the primary path.

Pieces of B (provider adapters, per-NPC loops) return only as part of Model C.

## Model C — Hybrid (**Defined** for v2 backlog)

Keep Model A as the default.

v2 **must** add optional per-NPC autonomy loops that call the **same** semantic verbs. An unattended dedicated server can then keep AI Players thinking without an IDE. An external MCP client must still work.

Do not implement C during the vertical slice. Details: [v2-backlog.md](../planning/v2-backlog.md).

## Persona vs memory vs goals

| Concept | Phase | Owner (**Proposed**) |
| --- | --- | --- |
| Name + context string | MVP | GLua registry, copied to Companion |
| Recent events | MVP | GLua → Companion ring buffer |
| Persistent memories | **Future** | Companion / SQLite |
| Relationships | **Future** | Companion |
| Current goal | Later | GLua controller + Companion |

The agent should receive persona on `get_agent` / `observe`, not by baking it into tool names.

## Capability intersection

Even if a tool exists on the MCP server, a given AI Player may lack the capability. The server rejects the call. See [capabilities.md](../design/capabilities.md).

## Session lifecycle vs NPC lifecycle

MCP client connect/disconnect is not the same as entity spawn.

| Event | **MVP (Model A)** effect |
| --- | --- |
| NPC spawned | INACTIVE, not listed as controllable |
| Tool Gun bind | Listed; WAITING_FOR_AGENT |
| MCP client connected | WAITING_FOR_AGENT → ACTIVE (**Proposed**) |
| MCP client gone | DISCONNECTED |
| Entity removed / kicked | Unregister `agent_id` |

v2 loops will need extra rules (loop-enabled ACTIVE without an IDE session). That policy is owned by the v2 backlog, not by MVP.
