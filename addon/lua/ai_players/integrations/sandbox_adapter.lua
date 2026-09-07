-- MVP GameAdapter (ADR-004). Sandbox-specific overrides land in a later
-- task; this file exists so server init has a concrete adapter to select
-- instead of the bare interface.
local SandboxAdapter = AI_PLAYERS.GameAdapter.New({
    Name = "sandbox",
})

return SandboxAdapter
