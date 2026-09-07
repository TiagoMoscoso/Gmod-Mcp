## Why

Companion MCP work can proceed in Python, but GLua needs a Workshop-shaped runtime that loads on a listen server without claiming MCP is online or spawning AI NPCs. A real module layout (autorun, shared/server/client, Sandbox adapter stub, convars) lets the bridge and spawn changes land in conventional GMod paths instead of a lump of one-off scripts.

## What Changes

- Flesh out `addon/lua/ai_players/{shared,server,client}` beyond scaffold stubs.
- Add a `SandboxAdapter` stub so core modules do not import DarkRP types.
- Add convars for later bridge/MCP configuration (host/port/path) without using them to fake a live endpoint.
- Client bootstrap MUST NOT show an MCP URL as ready.
- Do **not** register a spawnable AI NPC, Tool Gun, or controllers.

## Capabilities

### New Capabilities

- `addon/runtime-bootstrap`: The GLua addon MUST load on Sandbox as a conventional addon, isolate gamemode-specific hooks behind a Sandbox adapter stub, and MUST NOT report a working MCP endpoint until the Companion bridge later proves it.

### Modified Capabilities

- None.

## Impact

- Depends on `scaffold-monorepo` (`addon/` tree, protocol constant).
- Parallel with `companion-mcp-host`.
- Touches GLua only; no Python.
- Unblocks `gmod-companion-bridge` client popup and server bridge client.
