# Tests

Companion unit tests land with the [companion-mcp-host](../openspec/changes/companion-mcp-host)
change, and must run without Garry's Mod. Protocol contract tests follow the
same rule once a bridge transport is implemented.

## `addon/` (GLua)

`addon/` has no in-engine test suite; a real Garry's Mod install is out of
scope for CI. [`tests/addon/`](addon/) instead boots the `ai_players`
module graph against a small mock of the GMod globals it touches
(`include`, `AddCSLuaFile`, convars, …) and fails on any Lua error:

```bash
lua tests/addon/run_boot.lua
```

See `docs/architecture/components.md` ("GLua tests are hard in-engine;
prefer a small mock or dedicated spike").
