-- Sandbox GameAdapter (ADR-004): the MVP default and the only adapter this
-- change ships. Server-only because combat/use rules are server-authoritative
-- (see docs/architecture/gmod-runtime.md "Gamemode adapters"). Sandbox-safe
-- defaults only; DarkRP/Helix rules do not belong here.
AI_PLAYERS.SandboxAdapter = AI_PLAYERS.GameAdapter.New({
    -- Sandbox has no faction/turf restrictions; combat is allowed by default.
    -- Controllers (Future) still gate this per AI Player capability.
    CanCombat = function(agentEntity, target) return true end,

    -- Sandbox chat has no gamemode-specific prefix to apply.
    FormatChat = function(agentEntity, message) return message end,

    -- Interaction/use verbs are Future (docs/architecture/components.md); no
    -- entity may be +used through this adapter yet.
    Use = function(agentEntity, targetEntity) return false end,
})
