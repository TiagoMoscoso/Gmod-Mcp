## Context

See proposal.md for motivation. `scaffold-monorepo` provides `companion/` as a Python package that does not host MCP. [ADR-005](docs/architecture/decisions/ADR-005-mcp-hosted-by-companion.md) proposes Companion-hosted MCP. [ADR-003](docs/architecture/decisions/ADR-003-provider-agnostic-mcp.md) forbids vendor-shaped APIs. Registry data from GMod arrives in `gmod-companion-bridge`; this change uses a mock.

## Goals / Non-Goals

**Goals:**

- Decide MCP transport flavor via SPK-MCP-001 (default attempt: Streamable HTTP).
- Serve management tools on localhost with a mock registry.
- Keep the tool catalog safe (no lua/shell/eval/frame input).
- Unit-test the server without GMod.

**Non-Goals:**

- Bridge protocol or file IPC.
- Perception, `say`, movement, combat tools (stubs allowed only if needed to keep the catalog honest; prefer omitting until later changes).
- Model C / `providers/` LLM loops.
- Token auth for non-local binds ([OQ-MCP-001](docs/requirements/open-questions.md)).

## Decisions

### Python official MCP SDK / FastMCP first

Candidate stack from [companion.md](docs/architecture/companion.md). SPK-MCP-001 is time-boxed: if Streamable HTTP on FastMCP works with Inspector, keep it. If not, stdio is an acceptable spike outcome **for developers**, but the in-game popup still needs an HTTP URL later — record that gap in `companion.md`.

**Alternative:** TypeScript MCP SDK. Only if the Python spike fails.

### Bind `127.0.0.1:8765` path `/mcp`

Matches the vision example. Port/path remain Proposed, not a user-facing promise beyond docs.

**Alternative:** Random port. Harder to copy into MCP client configs; skip for MVP.

### In-memory registry module

`companion/src/ai_players_companion/agents/registry.py` with `AgentRecord(agent_id, name, context, capabilities, state)`. Tests seed records. Bridge change will swap the backend.

**Alternative:** SQLite now. Rejected — memory is Future.

### Tool handlers share one catalog module

A single allow-list of tool names. Forbidden names are tests, not comments.

### Session flag, not multi-tenant auth

MVP is local Model A: one client. Track connected/disconnected. No API keys.

## Risks / Trade-offs

- [GMod HTTP to 127.0.0.1 may still be blocked] → Out of scope; bridge spike owns transport. MCP HTTP is for the **external client**, not necessarily for GLua.
- [Python SDK churn] → Pin versions in `pyproject.toml`; spike notes go into `docs/architecture/companion.md`.
- [Empty action tools confuse agents] → Do not advertise `move_to` until movement-actions. Catalog grows per change.

## Migration Plan

Replace mock registry reads with bridge-backed reads in `gmod-companion-bridge` without renaming tools.

## Open Questions

- Exact JSON field names for `get_agent` beyond identity/persona/capabilities/state — freeze a small schema in implementation; Cosmetics can change later without spec churn.
