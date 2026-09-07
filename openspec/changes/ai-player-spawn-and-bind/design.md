## Context

See proposal.md for motivation. Bridge is healthy; MCP `list_agents` still has no real world entity. Embodiment is Open ([OQ-BOT-001](docs/requirements/open-questions.md)). Lifecycle: [npc-lifecycle.md](docs/design/npc-lifecycle.md). MVP UX: Spawn Menu + left-click bind only.

## Goals / Non-Goals

**Goals:**

- Decide embodiment via SPK-BOT-001.
- Spawn Menu NPC, INACTIVE spawn, Tool Gun bind, registry, bridge upsert.
- Safe idle on DISCONNECTED.
- Multi-agent data model.

**Non-Goals:**

- Right-click inspect, reload pause, unbind.
- Playermodel / voice C-panel (v2).
- Capability checkboxes.
- Perception snapshots, `say`, movement, combat execution (registry only).

## Decisions

### Spike: listen server + player bot first, SENT fallback

Combat (M1b) needs guns. Try `player.CreateNextBot` on a listen server with extra slots. If Spawn Menu UX cannot place a player bot directly, spawn a SENT placeholder that the bind path promotes, or document "spawn via tool / command" as spike output. If player bots are unusable, NextBot SENT is M1 embodiment and M1b may be weaker — record go/no-go.

**Alternative:** ship both embodiments. Rejected for MVP complexity.

### Removal rules follow embodiment

Player bot: `Kick`, never `Entity:Remove`. SENT: normal entity remove. Registry delete on either.

### agent_id format

Opaque string `agt_` + uuid or increment. Never the display name. Never SteamID.

### ACTIVE policy (MVP)

WAITING_FOR_AGENT → ACTIVE when bridge is healthy **and** an MCP client session is connected (Model A). If the client is absent, remain WAITING_FOR_AGENT. Hypothesis from lifecycle doc.

### Capabilities hardcoded

No UI. Walter slice gets combat on. Server cvars for caps are later.

### Inactive appearance

Idle animation / stand. Do not wander. Exact model Open; use a default citizen/nextbot model from the spike.

## Risks / Trade-offs

- [Singleplayer cannot spawn player bots] → Document listen server requirement in addon README and popup/setup notes.
- [Slot exhaustion] → `list_agents` still works; spawn fails loudly with ERROR / user message.
- [SENT vs bot fork leaks into MCP] → Keep MCP schema embodiment-agnostic; controllers adapt later.

## Migration Plan

Perception will query the registry for origin/eyes. Movement/combat controllers attach to the chosen entity type. Disconnect safety here is the same halt CombatController will reuse.

## Open Questions

- Exact Spawn Menu entity class name (`npc_ai_player` vs similar) — pick during implementation; not a requirement change.
- Whether WAITING_FOR_AGENT allows read-only `observe` — defer to perception-and-chat (default: no until ACTIVE).
