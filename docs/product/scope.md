# Scope

**Status:** Phasing is **Defined** as intent. Numeric limits and extra tools are **Open** unless listed.

This document classifies capabilities. It does not schedule calendar dates. See [milestones.md](../planning/milestones.md) and [mvp.md](../planning/mvp.md).

## In product (eventually)

The system should **eventually** allow an agent to:

| Capability | Phase | Notes |
| --- | --- | --- |
| Observe a filtered environment | MVP | [perception.md](../design/perception.md) |
| Perceive nearby players | MVP | Distance/relevance filtered |
| Perceive NPCs | MVP (combat test) | Enough to designate a target |
| Perceive other AI Players | Soon | Required before NPC↔NPC |
| Perceive relevant props/entities | Soon | Not a map dump |
| Walk the map | MVP | Via `move_to` |
| Navigate using navmesh | MVP | Failure if no mesh: **Open** fallback |
| Follow players | MVP | Vertical slice |
| Look at entities | MVP | Semantic `look_at` |
| Use entities | Soon | `use` |
| Pick up / interact with objects | Soon | When the gamemode allows |
| Select weapons | MVP (combat test) | `equip_weapon` |
| Aim | MVP | Inside combat controller, not MCP |
| Shoot | MVP (combat test) | Part of `attack` |
| Attack entities/players | MVP (combat test) | Capability-gated |
| Flee | Later | May be `move_to` away; dedicated verb optional |
| Chat | MVP | `say` |
| Produce voice | **v2** | Tool Gun male/female preset + TTS `speak`. Engine **Open** |
| Hear players (voice) | **Future** | Native + STT |
| Talk to other AI Players | **Future** | ConversationManager |
| Receive world events | MVP | Filtered recent events |
| React to damage | Soon | Event `took_damage`; policy **Open** |
| Keep objectives | Later | Goal stack **Open** |
| Persistent memory | **Future** | [memory.md](../design/memory.md) |
| Relationships | **Future** | `set_relationship` |

## Explicitly out of MVP

Do not implement in the first vertical slice:

- Advanced memory
- STT / TTS
- Playermodel picker and male/female voice picker (that is **v2**, required — [v2-backlog.md](../planning/v2-backlog.md))
- Complex NPC-to-NPC dialogue
- DarkRP / Helix / economy
- Native voice capture
- Source voice-packet injection
- Arbitrary Lua, shell, eval, or console execution
- Companion-hosted LLM loops / provider adapters (that is **v2**, required — [v2-backlog.md](../planning/v2-backlog.md))

## MCP tools by phase

Tools are **never** named after characters (`walter_move` is forbidden). All take `agent_id` unless a session-scoped alternative is later accepted. See [OQ-MCP-002](../requirements/open-questions.md#oq-mcp-002-session-scoped-vs-agent_id).

### MVP

| Tool | Group |
| --- | --- |
| `list_agents` | Management |
| `get_agent` | Management |
| `get_agent_status` | Management |
| `observe` | Perception |
| `get_self` | Perception |
| `get_recent_events` | Perception |
| `move_to` | Movement |
| `follow` | Movement |
| `look_at` | Movement |
| `stop` | Movement |
| `say` | Communication |
| `equip_weapon` | Combat |
| `attack` | Combat |
| `stop_attack` | Combat |

### Soon after MVP

| Tool | Group |
| --- | --- |
| `get_entity` | Perception |
| `get_player` | Perception |
| `use` | Interaction |
| `pickup` | Interaction |
| `drop` | Interaction |
| `reload` | Combat |

Pause/resume may be Tool Gun only at first; an MCP tool is **Open**.

### Future / v2

| Tool | Group | Notes |
| --- | --- | --- |
| `speak` | Communication | **v2.** Uses the Tool Gun voice preset (at least male / female). TTS engine **Open** |
| `remember` | Memory | **Future** |
| `recall` | Memory | **Future** |
| `set_relationship` | Memory | **Future** |
| Gamemode verbs (`buy`, `arrest`, …) | Adapters | **Future** |

## Forbidden tools

**Defined.** Do not expose:

- `execute_lua`
- `shell`
- `eval`
- `run_console_command`
- Frame-level input (`press_w`, `move_mouse`, `press_attack`, …)

## Gamemode scope

| Target | Phase |
| --- | --- |
| Sandbox | MVP |
| DarkRP adapter | **Future** |
| Helix adapter | **Future** |
| Other gamemodes | **Future**, via adapters |

Core capabilities that adapters may reuse: move, observe, talk, combat, use.

## Distribution scope

| Artifact | Channel | Phase |
| --- | --- | --- |
| GLua addon | GitHub + Steam Workshop | **Defined** goal |
| Companion | GitHub (install path **Open**) | Required for MCP |
| Native voice module | **Future**; channel **Open** | Not MVP |

## Not in scope as silent decisions

Anything listed in [open-questions.md](../requirements/open-questions.md) is out of "we already chose that" territory.
