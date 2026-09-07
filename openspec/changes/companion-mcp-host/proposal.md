## Why

Vanilla GLua cannot host a robust MCP HTTP server, and the product principle is that agents speak MCP, not a vendor SDK. The Companion must expose a provider-agnostic MCP endpoint that can be tested with a mock registry before any GMod bridge exists, so Python work can proceed in parallel with the addon skeleton.

## What Changes

- Run SPK-MCP-001: confirm Streamable HTTP vs stdio and whether the official Python MCP SDK / FastMCP is enough.
- Host MCP on `127.0.0.1` at a documented path (proposed: `http://127.0.0.1:8765/mcp`).
- Implement management tools against an in-memory **mock** registry: `list_agents`, `get_agent`, `get_agent_status`.
- Track whether an MCP client session is connected or disconnected.
- Reject and never register forbidden tools (`execute_lua`, `shell`, `eval`, `run_console_command`, frame-level input).
- Expose protocol version on the Companion side for later handshake.
- Add unit tests that do not require Garry's Mod.
- Do **not** implement GMod transport, perception, movement, combat, or Model C provider loops.

## Capabilities

### New Capabilities

- `companion/mcp-server`: The Companion process MUST host a provider-agnostic MCP server bound to localhost, expose character-agnostic management tools keyed by `agent_id`, report client session presence, and MUST NOT expose code-execution or frame-input tools.

### Modified Capabilities

- None.

## Impact

- Depends on `scaffold-monorepo` (`companion/` Python package).
- New Companion modules under `companion/` (`mcp/`, in-memory registry).
- New tests under `companion/` or `tests/` (no GMod).
- Unblocks `gmod-companion-bridge`, which replaces the mock registry with live GMod data.
