# MCP

**Status:** MCP as the only agent API is **Defined**. Tool list phasing is **Defined** in [scope.md](../product/scope.md). Host process is **Proposed** (Companion).

## Design rules

1. Provider-agnostic. No Claude- or OpenAI-specific tools.
2. Multi AI Player. No per-name tools.
3. Capability-checked. Reject disallowed verbs.
4. Semantic. No `press_w` / `move_mouse` / `press_attack`.
5. No `execute_lua`, `shell`, `eval`, `run_console_command`.
6. Long actions are async. Tools accept work; events report completion.

## Endpoint

**Proposed** example shown in the in-game popup:

```text
http://127.0.0.1:8765/mcp
```

Host, port, path, and Streamable HTTP vs stdio are **Open** ([OQ-MCP-003](../requirements/open-questions.md#oq-mcp-003-mcp-transport-flavor)).

## Tool catalog

Parameters below are illustrative, not a frozen JSON schema.

### Agent management — MVP

| Tool | Intent |
| --- | --- |
| `list_agents` | All registered AI Players |
| `get_agent` | Persona, capabilities, entity summary |
| `get_agent_status` | Lifecycle state, current action |

### Perception — MVP

| Tool | Intent |
| --- | --- |
| `observe` | Bounded snapshot |
| `get_self` | Health, weapon, position, velocity |
| `get_recent_events` | Ring buffer since cursor/timestamp |

`get_entity` / `get_player` — **Soon**.

### Movement — MVP

| Tool | Intent |
| --- | --- |
| `move_to` | Start MovementController toward position or entity |
| `follow` | Follow a player/entity until `stop` or loss |
| `look_at` | Face entity/position |
| `stop` | Cancel locomotion |

### Combat — MVP (second test)

| Tool | Intent |
| --- | --- |
| `equip_weapon` | Select weapon class/slot |
| `attack` | Start CombatController on a target |
| `stop_attack` | Cancel combat |

`reload` — **Soon**. Aim is **not** a tool.

### Communication

| Tool | Phase |
| --- | --- |
| `say` | MVP |
| `speak` | **Future** (TTS) |

### Interaction — Soon

`use`, `pickup`, `drop`.

### Memory — Future

`remember`, `recall`, `set_relationship`.

## Async contract (**Proposed**)

`move_to` return shape:

```json
{
  "accepted": true,
  "action_id": "act_...",
  "agent_id": "agt_...",
  "state": "running"
}
```

Rejection:

```json
{
  "accepted": false,
  "error": "capability_denied" | "invalid_state" | "unknown_agent" | "busy"
}
```

Completion arrives later via `get_recent_events` / observe:

- `target_reached`
- `target_lost`
- `action_failed`
- `took_damage`
- `player_said`
- `enemy_seen` (**Soon**)
- `goal_completed` (**Later**)

Whether MCP also pushes notifications/resources is **Future**; tools are enough for MVP.

## Resources and prompts (**Future**)

Possible later:

- Resource `agent://{id}/perception`
- Prompt templates for persona

Do not require them for the vertical slice.

## Safety

Tool handlers must:

- Resolve `agent_id` through the registry
- Enforce lifecycle (no `attack` from INACTIVE)
- Enforce capabilities
- Validate targets exist and are currently observable unless a later rule says otherwise (**Open:** attack unseen targets?)

Default **Hypothesis:** `attack` and `follow` require the target to be known from perception or a recent event, to reduce griefing-by-entindex.
