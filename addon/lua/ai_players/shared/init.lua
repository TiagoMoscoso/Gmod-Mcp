-- Shared module root. Sent to clients so the client autorun stub can include it.
if SERVER then
    AddCSLuaFile()
end

AI_PLAYERS = AI_PLAYERS or {}

include("ai_players/shared/protocol.lua")
