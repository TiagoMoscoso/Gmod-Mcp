## Why

MCP tools in the Companion cannot move the world until GMod and the Companion share a bridge. GLua has no listen sockets and may block private-IP HTTP, so transport is the project's highest engineering risk (R-ENG-001). This change must pick a transport via spike, define the message contract, handshake versions, and make the in-game popup tell the truth about MCP readiness.

## What Changes

- Run SPK-TRN-001 (file IPC under `garrysmod/data/` vs `HTTP()` to `127.0.0.1` vs another documented fallback) and write the winner into Companion/addon code plus `docs/architecture/companion.md`.
- Define a versioned message protocol: handshake, registry sync, action request/result, event push, observe request/response.
- Detect Companion down / protocol mismatch; never show a live MCP URL when the Companion is missing.
- Implement FR-UX-001/003 popup (or equivalent): copyable URL only when the Companion is actually hosting MCP; Setup Guide when not.
- Add contract tests with a fake GMod (or fake Companion) so the protocol can be tested without a full game.
- Do **not** spawn AI NPCs, bind personas, or implement controllers. Registry messages may use fixtures.

## Capabilities

### New Capabilities

- `bridge/protocol`: GMod and the Companion MUST exchange versioned handshake, registry, action, event, and observe messages over the spike-chosen transport; the client MUST present the MCP endpoint only when the Companion is healthy.

### Modified Capabilities

- None. `companion/mcp-server` tool names stay; this change supplies a real (or fixture) backend without changing MCP requirements.

## Impact

- Depends on `companion-mcp-host` and `gmod-addon-skeleton`.
- Touches Companion `transport/` and GLua `integrations/` bridge client.
- Client UI popup.
- Unblocks `ai-player-spawn-and-bind` (live registry sync).
