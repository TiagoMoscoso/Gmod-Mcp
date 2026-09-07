-- Protocol version this addon speaks. Must match
-- companion/src/ai_players_companion/protocol.py until the bridge handshake
-- change replaces the duplicated constant with a real negotiation.
if SERVER then
    AddCSLuaFile()
end

AI_PLAYERS_PROTOCOL_VERSION = "1"
