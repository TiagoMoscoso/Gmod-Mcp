-- Shared module root: runs on both realms, so it must stay free of
-- server-only or client-only calls. Sent to clients via AddCSLuaFile so the
-- client autorun stub can include it. Holds the parts of the module graph
-- both realms need to agree on (protocol version, adapter interface,
-- convars, Companion status enum) before realm-specific code loads.
if SERVER then
    AddCSLuaFile()
end

AI_PLAYERS = AI_PLAYERS or {}

include("ai_players/shared/protocol.lua")
include("ai_players/shared/adapter.lua")
include("ai_players/shared/convars.lua")
include("ai_players/shared/companion_status.lua")
