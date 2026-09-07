-- MVP GameAdapter (ADR-004). Sandbox has no jobs/whitelist/zone system,
-- so combat is always allowed; interaction (+use) stays denied until the
-- interaction controller exists (design.md non-goal), not because
-- Sandbox forbids it.
local SandboxAdapter = AI_PLAYERS.GameAdapter.New({
    Name = "sandbox",
})

function SandboxAdapter:CanCombat()
    return true
end

return SandboxAdapter
