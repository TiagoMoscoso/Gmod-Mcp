# NPC lifecycle

**Status:** States are **Proposed**. Spawn → inactive → bind is **Defined**. MVP (Model A): no MCP client means no cognition (DISCONNECTED/WAITING). Idle pose vs wander is still **Open** ([OQ-BOT-002](../requirements/open-questions.md#oq-bot-002-behavior-without-agent)). v2 loops: [v2-backlog.md](../planning/v2-backlog.md).

## States

| State | Meaning |
| --- | --- |
| `INACTIVE` | Spawned. No persona bind. Not a controllable AI Player. No agent autonomy. |
| `WAITING_FOR_AGENT` | Bound (name, context, `agent_id`). Listed on MCP. Not yet considered driven. |
| `ACTIVE` | Eligible to accept semantic actions from an agent. |
| `PAUSED` | Bound and known, but new actions are rejected or queued unused. Controllers should halt. |
| `ERROR` | Fault (bridge, controller, protocol). Inspect should show a reason. |
| `DISCONNECTED` | Companion or MCP client lost after the NPC was already bound. |

Whether WAITING_FOR_AGENT and DISCONNECTED look identical in the world is **Open**.

## Proposed transitions

```text
spawn
  ↓
INACTIVE
  ↓ Tool Gun bind
WAITING_FOR_AGENT
  ↓ agent available (policy Open)
ACTIVE
  ↓ pause
PAUSED
  ↓ resume
ACTIVE
  ↓ agent / Companion lost
DISCONNECTED
  ↓ agent available
ACTIVE
  ↓ unrecoverable fault
ERROR
  ↓ successful recovery / rebind
WAITING_FOR_AGENT or ACTIVE
```

Unbind / entity removed / `Kick` (player bots) → registry delete (terminal).

Spawn of a new body is a new `agent_id` unless persistence is later defined ([OQ-BOT-004](../requirements/open-questions.md#oq-bot-004-persistence-across-maps--sessions)).

## Transition rules (**Proposed**)

| From | To | Trigger |
| --- | --- | --- |
| (none) | INACTIVE | Spawn Menu place |
| INACTIVE | WAITING_FOR_AGENT | Tool Gun bind with valid name+context |
| WAITING_FOR_AGENT | ACTIVE | MVP (Model A): Companion healthy and MCP client connected |
| ACTIVE | PAUSED | Reload / pause command |
| PAUSED | ACTIVE | Resume |
| ACTIVE / PAUSED | DISCONNECTED | Bridge or session drop |
| DISCONNECTED | ACTIVE | Session restored |
| * | ERROR | Explicit failure |
| ERROR | WAITING_FOR_AGENT | Operator rebind / clear error |
| * | (removed) | Unbind, kill entity, map change without persistence |

INACTIVE must not jump to ACTIVE without bind.

## Actions allowed per state (**Proposed**)

| State | `observe` | Movement/combat | `say` |
| --- | --- | --- | --- |
| INACTIVE | no (unknown id) | no | no |
| WAITING_FOR_AGENT | maybe read-only **Open** | no | no |
| ACTIVE | yes | if capable | if capable |
| PAUSED | yes | no | no |
| DISCONNECTED | local only, not MCP | no new | no |
| ERROR | inspect in UI | no | no |

## World behavior without cognition

**Open** ([OQ-BOT-002](../requirements/open-questions.md#oq-bot-002-behavior-without-agent)).

**Hypothesis** for safety: INACTIVE, WAITING_FOR_AGENT, PAUSED, DISCONNECTED, ERROR all stand idle and hold no attack buttons.

Do not wander with a gun while DISCONNECTED.

## Why not fewer states

Merging WAITING_FOR_AGENT into INACTIVE hides "this NPC is configured but nobody is driving it."

Merging DISCONNECTED into ERROR hides a normal laptop-sleep event as a fault.

Merging PAUSED into DISCONNECTED hides an intentional freeze.

## Inspect (**Proposed**)

Right-click shows: state, `agent_id`, name, last action_id, last error string, Companion protocol version.
