# ADR-007 — MVP Model A, v2 Model C

**Status:** Accepted  
**Date:** 2026-09-06

## Context

Three orchestration models were on the table:

- **A.** External MCP client multiplexes all AI Players via `agent_id`
- **B.** Companion runs the LLM per NPC; MCP is debug/override
- **C.** Hybrid: A remains, then optional Companion loops on the same verbs

The product pitch is “connect the agent of your choice.” Unattended dedicated servers still need cognition without an IDE process.

## Decision

- **MVP implements Model A only.** Cognition lives in Claude Code, Codex, or any MCP client. The Companion does not call an LLM.
- **v2 must implement Model C.** Optional per-AI-Player autonomy loops attach to the same tool/controller layer. Documented in [v2-backlog.md](../../planning/v2-backlog.md).
- **Model B is rejected** as a destination. The project will not drop the external MCP path.

## Consequences

- MVP has no `providers/` implementation and no API keys in-tree
- ACTIVE for MVP **Proposed:** bound + Companion up + MCP client session (see lifecycle)
- Closing the MCP client → DISCONNECTED; characters stop deciding
- v2 work must not start by forking `follow` / `attack` into a parallel API
- NPC↔NPC unattended talk waits for v2 loops (and ConversationManager)

## Alternatives not chosen

- Model B from day one (vendor coupling, keys, cost before Walter walks)
- Leaving C as an informal “maybe later”
