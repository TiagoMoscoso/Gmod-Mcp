# ADR-005 — MCP hosted by the Companion, not GLua

**Status:** Accepted  
**Date:** 2026-09-06

## Context

The UX popup shows `http://127.0.0.1:8765/mcp` as if "the addon" exposed MCP.

Vanilla GLua cannot listen on TCP. `HTTP()` / `http.Fetch` also block private IPs on common listen/singleplayer setups. Existing GMod MCP bridges often use file IPC for this reason.

## Decision (proposed)

The **Companion process** hosts MCP.

GMod talks to the Companion over a still-**Open** bridge ([OQ-TRN-001](../../requirements/open-questions.md#oq-trn-001-gmod-companion-transport)).

The in-game popup displays the Companion's MCP URL (or "Companion not running").

## Consequences

- Workshop Lua-only packages cannot "just work" without a Companion install
- Local vs dedicated bind/auth become Companion config, not Lua HTTP servers
- A fake "MCP online" popup without a Companion is a product bug ([FR-UX-003](../../requirements/functional-requirements.md#fr-ux-003))

## Alternatives not chosen (yet)

- Native module that *is* the MCP HTTP server inside GMod (possible later; heavy, and still a binary)
- Pure file-IPC MCP (MCP clients expect stdio or HTTP; files would still need a Companion translator)

## Follow-up

Accepted after SPK-MCP-001 confirmed Streamable HTTP on the official Python MCP SDK's FastMCP (`companion-mcp-host` change). See [OQ-MCP-003](../../requirements/open-questions.md#oq-mcp-003-mcp-transport-flavor).
