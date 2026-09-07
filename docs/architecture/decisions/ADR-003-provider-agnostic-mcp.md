# ADR-003 — Provider-agnostic MCP interface

**Status:** Accepted  
**Date:** 2026-09-06

## Context

The product examples mention Claude Code and Codex. Binding the addon to Anthropic or OpenAI APIs would force keys into GMod, exclude other clients, and contradict "bring your own agent."

## Decision

MCP is the only supported agent-facing interface.

The core shall not depend on a vendor SDK.

Tools are generic (`move_to`, `say`), never `claude_*` or `openai_*`.

Claude Code, Codex, Cursor, MCP Inspector, and custom clients are all valid.

## Consequences

- Orchestration **MVP = Model A** (external MCP client). **v2 must implement Model C** on the same verbs ([ADR-007](ADR-007-mvp-model-a-v2-model-c.md), [v2-backlog.md](../../planning/v2-backlog.md)).
- Provider adapters belong in v2, not in GLua and not in the MVP Companion dispatcher.
- We cannot ship "it just talks" without *some* MCP client in MVP; Workshop UX must explain MCP setup. Unattended talk without a client is v2.

## Alternatives not chosen

- First-party Anthropic/OpenAI integration in Lua
- Multiple parallel proprietary plugin APIs instead of MCP
