-- Companion connection state enum. Exists so the client can hold an honest
-- "not connected yet" value instead of inventing one ad hoc; only the
-- gmod-companion-bridge change may ever set this to CONNECTED, once a real
-- handshake succeeds.
if SERVER then
    AddCSLuaFile()
end

AI_PLAYERS.CompanionStatus = {
    DISCONNECTED = "disconnected",
    CONNECTED = "connected",
    ERROR = "error",
}
