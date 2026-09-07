-- Shared Companion connection states. The bridge change drives real
-- transitions; this skeleton only defines the enum plus the honest
-- default so nothing can claim a working MCP endpoint before the
-- Companion bridge proves one (spec: No false MCP-ready UX).
if SERVER then
    AddCSLuaFile()
end

AI_PLAYERS.CompanionState = {
    DISCONNECTED = "disconnected",
    CONNECTED = "connected",
    ERROR = "error",
}
