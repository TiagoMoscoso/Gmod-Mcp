# Data flow

**Status:** Logical flows **Defined**. On-the-wire encoding **Open**.

## Vertical slice: "Walter come with me."

```text
Player chat
    → GLua chat hook
    → event player_said { agent-visible }
    → bridge → Companion event buffer
MCP client
    → get_recent_events / observe
    → say(walter, "...")
    → follow(walter, player)
Companion
    → bridge actions
GLua
    → chat as Walter
    → MovementController follow
    → ticks: PathFollower + StartCommand (if player bot)
    → events: target_reached / follow_updated
```

## Combat test: "Kill that NPC."

```text
player_said
    → observe (visible NPCs)
    → equip_weapon
    → attack(target)
CombatController
    → navigate, look, IN_ATTACK
    → events: took_damage | action_failed | goal_completed
```

Aim never appears as an MCP tool.

## Observation pull (**Proposed** for MVP)

The client pulls. GMod does not stream tokens into the LLM.

```text
observe(agent_id)
    → Companion asks GLua (or uses a short cache)
    → snapshot JSON
```

Cache TTL is **Open**. Stale combat snapshots are dangerous; **Hypothesis:** combat observe is always fresh, idle observe may be cached briefly.

## Bind flow

```text
Spawn AI NPC     → INACTIVE (not in list_agents as controllable)
Tool Gun apply   → registry row {id, name, context, caps}
                 → WAITING_FOR_AGENT
                 → list_agents includes Walter
MCP client sees Walter
Policy **Open**  → ACTIVE when client present and/or Companion healthy
```

## Companion missing (Workshop-only)

```text
Addon loads
    → bridge connect fails
    → popup: not ready + Setup Guide (GitHub)
    → spawn still possible
    → bind may register locally but MCP list is empty to the world
```

Exact bind-without-Companion behavior is **Open**; UI must not show a fake live URL.

## Voice (**Future**)

```text
Voice packet → C++ → PCM → Companion STT → player_spoke event → agent
Agent speak  → TTS → audio → GLua EmitSound (positional)
```

## Adapter boundary

```text
Core action "use"
    → GameAdapter:Use(entity)
SandboxAdapter → +use on entity
DarkRPAdapter  → may refuse or map to a job verb
```

Core never imports DarkRP.

## Authority

| Fact | Authority |
| --- | --- |
| Entity exists, HP, position | GMod |
| Lifecycle state | GMod registry |
| Persona strings after bind | GMod, cached by Companion |
| MCP session connected | Companion |
| Memories | Companion **Future** |
| Nav path | GMod |
