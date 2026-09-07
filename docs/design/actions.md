# Actions

**Status:** Semantic catalog and async execution are **Defined**. Queue rules are **Open**.

## Contract

1. MCP accepts an action.
2. GMod starts or rejects a controller.
3. The tool returns quickly with `accepted` + `action_id` (**Proposed**).
4. The world updates for many ticks without further LLM input.
5. Events report terminal or important intermediate states.

The agent does not call `press_attack` twenty times a second.

## MVP verbs

| Action | Controller | Notes |
| --- | --- | --- |
| `move_to` | Movement | Position or entity id |
| `follow` | Movement | Until `stop`, death, or `target_lost` |
| `look_at` | Look | May combine with movement |
| `stop` | Movement | Clears locomotion |
| `say` | Chat relay | Parallel with movement **Hypothesis** |
| `equip_weapon` | Combat | Class name or slot **Open** schema |
| `attack` | Combat | Includes path + aim + fire |
| `stop_attack` | Combat | |

## Later verbs

`use`, `pickup`, `drop`, `reload`, `speak`, `remember`, `recall`, `set_relationship`, adapter verbs.

`flee` may be sugar over `move_to` away from a threat; do not add it until needed.

## Targets

**Proposed** target object:

```json
{ "type": "entity" | "player" | "ai_player" | "position", "id": "...", "pos": [x, y, z] }
```

**Hypothesis:** `follow` / `attack` require the target to appear in recent perception or events (anti-wallhack). `move_to` position may be a point the agent already observed.

## Failures

Controllers must fail loudly:

- no navmesh
- stuck timeout
- invalid entity
- capability denied
- wrong lifecycle state
- no player slot / embodiment error

Emit `action_failed` with a short machine `code` and human `message`.

Do not invent timeout seconds here.

## Preemption (**Open**, [OQ-ACT-001](../requirements/open-questions.md#oq-act-001-action-queue--concurrency))

**Hypothesis** for MVP:

- `say` does not cancel `follow`
- `attack` cancels `follow` / `move_to`
- `stop` cancels locomotion and combat
- A second `move_to` replaces the first

## Motor details the LLM must not see as tools

Navmesh generation, ladder handling, jump buttons, mouse delta, spread, reload timing (except later `reload` as a semantic request), animation events.

## Mapping to GMod (**Hypothesis** until embodiment spike)

If player bot: controllers write `CUserCmd` in `StartCommand`.

If NextBot SENT: loco + custom attack; gunplay may be weaker.

The MCP schema should stay embodiment-agnostic.
