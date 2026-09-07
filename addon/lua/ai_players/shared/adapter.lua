-- GameAdapter is the seam between core AI Player logic and gamemode-specific
-- rules (ADR-004). Core modules under ai_players/ must call through this
-- interface and must never import DarkRP, Helix, or other gamemode types
-- directly. Sandbox is the only concrete adapter for now (see
-- integrations/sandbox_adapter.lua); DarkRP/Helix adapters are Future.
if SERVER then
    AddCSLuaFile()
end

AI_PLAYERS.GameAdapter = AI_PLAYERS.GameAdapter or {}

-- Builds a GameAdapter table from safe no-op defaults, so a concrete adapter
-- only has to override the methods it actually implements.
function AI_PLAYERS.GameAdapter.New(overrides)
    local adapter = {
        -- CanCombat(agentEntity, target) -> bool: may this AI Player fight here?
        CanCombat = function(agentEntity, target) return false end,
        -- FormatChat(agentEntity, message) -> string: gamemode chat formatting.
        FormatChat = function(agentEntity, message) return message end,
        -- Use(agentEntity, targetEntity) -> bool: may this AI Player +use this entity?
        Use = function(agentEntity, targetEntity) return false end,
    }

    for key, value in pairs(overrides or {}) do
        adapter[key] = value
    end

    return adapter
end
