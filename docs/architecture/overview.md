# Architecture overview

**Status:** Hybrid split is **Proposed**. Semantic actions, MCP as agent API, Sandbox-first adapters, and dual public distribution are **Defined**.

## Layers

```text
                 AI AGENT
       Claude / Codex / MCP client
                     |
                     | MCP
                     v
              AI COMPANION
           (proposed: Python)
                     |
         actions / events / state
                     |
                     v
            GARRY'S MOD SERVER
                     |
        +------------+-------------+
        |                          |
       GLua                       C++
 gameplay / world logic        voice core
                                 (future)
```

| Layer | Question it answers |
| --- | --- |
| Agent | What should this character think and do? |
| Companion | How do we route that thought as MCP, sessions, and (later) speech/memory? |
| GLua | What is happening inside the game, and how do we execute verbs? |
| C++ | What did humans say? (voice) — **Future** |

## Architectural requirements (**Defined**)

1. The LLM does not emit per-frame inputs.
2. GMod controllers own navmesh, path following, `StartCommand` / `CUserCmd`, aiming, and arrival.
3. MCP tools are character-agnostic and take `agent_id`.
4. Perception is filtered.
5. No generic code-execution tools.
6. Core gameplay stays in GLua.
7. GitHub holds the monorepo; Workshop holds a derived GLua artifact.
8. MVP cognition is Model A (external MCP client). v2 **must** implement Model C. See [ADR-007](decisions/ADR-007-mvp-model-a-v2-model-c.md).

## Proposed runtime shape

```text
MCP client  --MCP-->  Companion  --bridge-->  GMod (GLua [+ future native])
```

**Proposed:** Companion hosts the HTTP MCP URL shown in the popup. GMod does not listen for MCP. See [ADR-005](decisions/ADR-005-mcp-hosted-by-companion.md).

**Open:** the bridge protocol ([OQ-TRN-001](../requirements/open-questions.md#oq-trn-001-gmod-companion-transport)).

## Cognition vs motor control

```text
observe / events          semantic action
     ^                         |
     |                         v
  Agent  <--- MCP --->  Companion  ---> ActionDispatcher
                                              |
                                              v
                                    MovementController
                                    CombatController
                                    LookController
                                    ChatRelay
                                              |
                                              v
                                    StartCommand / nav / ents
                                              |
                                              v
                                    events (target_reached, ...)
```

Example: `move_to(agent_id, target)` **starts** a MovementController. The controller handles pathfinding, obstacles, and failure. The agent later sees `target_reached` or `action_failed`.

## What is not decided here

- Python vs another Companion language
- File IPC vs HTTP vs native sockets
- Player bot vs NextBot

Orchestration is decided: MVP = A, v2 = C. Remaining opens live in [open-questions.md](../requirements/open-questions.md) and [technical-spikes.md](../planning/technical-spikes.md).

## ADRs

| ADR | Title | Status |
| --- | --- | --- |
| [001](decisions/ADR-001-hybrid-architecture.md) | Hybrid GLua / C++ / Python | Proposed |
| [002](decisions/ADR-002-semantic-actions.md) | Semantic actions, not frame inputs | Accepted |
| [003](decisions/ADR-003-provider-agnostic-mcp.md) | Provider-agnostic MCP | Accepted |
| [004](decisions/ADR-004-sandbox-first-adapters.md) | Sandbox-first + adapters | Accepted |
| [005](decisions/ADR-005-mcp-hosted-by-companion.md) | MCP hosted by Companion | Proposed |
| [006](decisions/ADR-006-dual-distribution.md) | GitHub + Steam Workshop | Proposed |
| [007](decisions/ADR-007-mvp-model-a-v2-model-c.md) | MVP Model A, v2 Model C | Accepted |
