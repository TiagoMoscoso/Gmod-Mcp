## Context

See proposal.md for motivation. The repo today is `docs/` plus OpenSpec. [docs/architecture/components.md](docs/architecture/components.md) and [docs/planning/distribution.md](docs/planning/distribution.md) already propose `addon/`, `companion/`, `native/`, `tests/`. This design only instantiates that split as empty-but-runnable trees. No MCP, bridge, or entities yet.

Constraints: Workshop GMA cannot ship Python; vanilla GLua cannot host MCP HTTP; OQ-DIST-001 (license) and OQ-NAME-001 (public name) stay open.

## Goals / Non-Goals

**Goals:**

- Land the directory contract later changes implement inside.
- Make `addon/` look like a GMod addon (`addon.json`, `lua/autorun`).
- Make `companion/` a Python package that installs and prints a "not ready" status.
- Share one protocol version string (`1` or `0.1.0-dev`) on both sides.

**Non-Goals:**

- MCP server, tools, or Streamable HTTP.
- GMod ↔ Companion transport.
- Spawn Menu entity, Tool Gun, controllers.
- `native/` voice module.
- SPDX LICENSE / CI / Workshop upload.

## Decisions

### Directory layout follows the documented monorepo

Use the README proposal:

```text
addon/          → GMA candidate
companion/      → GitHub-only process
tests/          → Companion (and later contract) tests
docs/           → already exists
native/         → omit until voice
```

**Alternative:** nested `src/gmod` + `src/companion`. Rejected: GMod Workshop tooling expects `addon.json` + `lua/` at the addon root.

### GLua namespace `ai_players`

Autorun files include `lua/ai_players/` modules. Folder name is an implementation identifier, not the locked public product name (OQ-NAME-001).

**Alternative:** `gmod_ai_players`. Longer; can rename before public listing.

### Companion language: Python 3.12 candidate

Match [docs/architecture/companion.md](docs/architecture/companion.md). `pyproject.toml` with a console script that exits 0 after printing that MCP is not hosted yet.

**Alternative:** TypeScript/Go. Valid if SPK-MCP-001 later replaces the host; the folder name `companion/` stays.

### Protocol version as duplicated constants

`addon/lua/ai_players/shared/protocol.lua` (`AI_PLAYERS_PROTOCOL_VERSION = "1"`) and `companion/src/ai_players_companion/protocol.py` (`PROTOCOL_VERSION = "1"`). No shared generated file: GLua cannot import Python.

**Alternative:** JSON in repo root read by both. Extra moving parts for a skeleton; defer until the bridge change if needed.

### No LICENSE file

Leaving license unset is explicit. Do not invent MIT.

## Risks / Trade-offs

- [Provisional addon title in `addon.json` becomes sticky] → Use "GMod AI Players" as provisional; document OQ-NAME-001 in README.
- [Empty `tests/` invites dumping later] → `tests/` holds a placeholder README pointing at Companion unit tests in `companion-mcp-host`.
- [Python choice reversed by MCP spike] → Keep `companion/` language-agnostic in specs; only this design names Python.

## Migration Plan

Greenfield. No deploy. Rollback is delete the new trees. Later Workshop packaging reads only `addon/`.

## Open Questions

None that affect this change. Transport, embodiment, and MCP flavor belong to later changes.
