## Why

The repository is documentation-only. Every later MVP change needs a Workshop-extractable `addon/` tree and a GitHub-only `companion/` tree before gameplay or MCP can land. Without that layout, GLua and Python work collide and Workshop packaging becomes an afterthought.

## What Changes

- Create the empty monorepo layout proposed in the project README: `addon/`, `companion/`, `tests/` (no `native/` yet; voice is Future).
- Add a Workshop-shaped `addon.json` and GLua autorun stubs that load without spawning AI NPCs or claiming MCP is online.
- Add a Python Companion project skeleton (`pyproject.toml`, package package, README run notes) that does not yet host MCP.
- Add a shared protocol version constant placeholder so later handshake work has one source of truth.
- Add `.gitignore` entries for Python, venv, GMod, and OS junk.
- Do **not** add an SPDX LICENSE (OQ-DIST-001 remains open).
- Do **not** implement MCP tools, bridge transport, spawn, or controllers.

## Capabilities

### New Capabilities

- `repo/monorepo-layout`: The repository MUST be a dual-distribution monorepo: GLua lives under `addon/` as a GMA candidate; Companion and tests live outside that tree; Workshop packaging MUST be able to ship `addon/` without Companion, docs, or native source.

### Modified Capabilities

- None. `openspec/specs/` is empty.

## Impact

- New directories: `addon/`, `companion/`, `tests/`.
- Touches [README.md](README.md) install/run notes for the skeleton (docs stay the source of truth for product spec).
- No runtime APIs, no MCP surface, no GMod entities.
- Unblocks parallel work on `companion-mcp-host` and `gmod-addon-skeleton`.
