# GMod AI Players — addon

This is the Garry's Mod side of the project: a Workshop-shaped GLua addon
(`lua/autorun`, `lua/ai_players/`). It does **not** host MCP itself.

## What this skeleton does

- Loads `lua/ai_players/{shared,server,client,integrations}` via
  `lua/autorun` on both realms.
- Selects a Sandbox `GameAdapter` (`SandboxAdapter`) so core code never
  depends on DarkRP/Helix types.
- Exposes `ai_players_companion_host` / `_port` / `_path` convars (default
  `127.0.0.1` / `8765` / `/mcp`) describing where a Companion will
  eventually be reached.
- Defaults the client's Companion connection status to `disconnected`.

## What this skeleton does not do

- Spawn an AI NPC, register a Tool Gun, or run any controller
  (movement/combat/look). Those land in later changes.
- Open any socket, file, or other IPC to a Companion.
- Claim an MCP endpoint is live. There is no popup, and no convar default
  here should be read as "the server is up" — that only becomes true once
  the Companion bridge (see `gmod-companion-bridge` in the full repo)
  completes a real handshake.

## Where MCP actually lives

MCP is hosted by the **Companion**, an out-of-process host that this GMA
does not ship. See the full monorepo on GitHub
(<https://github.com/TiagoMoscoso/Gmod-Mcp>) — the `docs/` and `companion/`
directories there are not included in the Steam Workshop package — for the
full architecture, including
[ADR-005](../docs/architecture/decisions/ADR-005-mcp-hosted-by-companion.md)
on why MCP is not hosted inside Garry's Mod.
