## 1. Module graph

- [ ] 1.1 Create `lua/ai_players/{shared,server,client,integrations}` and wire `lua/autorun` includes for each realm and verify a Sandbox listen server loads with no Lua error
- [ ] 1.2 Add shared convars `ai_players_companion_host/port/path` defaulting to `127.0.0.1`, `8765`, `/mcp` and verify `ai_players_companion_host` default is not a public bind address

## 2. Gamemode adapter stub

- [ ] 2.1 Define a `GameAdapter` table interface (`CanCombat`, `FormatChat`, `Use` or equivalent no-ops) in shared/server code and verify Sandbox init selects `SandboxAdapter`
- [ ] 2.2 Implement `SandboxAdapter` with Sandbox-safe defaults and verify a repo search of `addon/lua/ai_players` finds no DarkRP/Helix requires

## 3. Honest client state

- [ ] 3.1 Add a client-side Companion status value defaulting to disconnected and verify loading the addon never draws an MCP-online popup or copyable live URL
- [ ] 3.2 Document in a short `addon/README.md` that MCP is hosted by the Companion and this skeleton does not spawn NPCs and verify the README points at GitHub docs, not a fake local endpoint success path
