-- Contract every GameAdapter must satisfy (ADR-004). Core modules call
-- these methods instead of touching DarkRP/Helix types directly; swapping
-- AI_PLAYERS.Adapter is how a future DarkRPAdapter or HelixAdapter plugs
-- in without editing combat/chat/use call sites.
if SERVER then
    AddCSLuaFile()
end

local GameAdapter = {}
GameAdapter.__index = GameAdapter

-- Adapter id, e.g. "sandbox". Used by logging/tests, not gameplay logic.
GameAdapter.Name = "base"

-- Whether the AI Player may equip and use weapons against entities.
function GameAdapter:CanCombat()
    return false
end

-- Formats a chat line for the gamemode's chat path.
function GameAdapter:FormatChat(speakerName, message)
    return speakerName .. ": " .. message
end

-- Whether the AI Player may +use the given entity.
function GameAdapter:Use(_entity)
    return false
end

function GameAdapter.New(overrides)
    return setmetatable(overrides or {}, GameAdapter)
end

AI_PLAYERS.GameAdapter = GameAdapter
