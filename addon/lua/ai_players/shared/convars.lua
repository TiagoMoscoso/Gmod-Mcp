-- Companion connection convars. These describe where the Companion MCP
-- host will listen once the bridge change wires a real client; setting
-- them does not open a socket or claim a live endpoint on its own
-- (spec: Configuration surface without live bind).
if SERVER then
    AddCSLuaFile()
end

CreateConVar(
    "ai_players_companion_host",
    "127.0.0.1",
    FCVAR_ARCHIVE,
    "Companion MCP host. Keep this loopback for local Sandbox use; do not set 0.0.0.0 (ADR-005)."
)

CreateConVar(
    "ai_players_companion_port",
    "8765",
    FCVAR_ARCHIVE,
    "Companion MCP port."
)

CreateConVar(
    "ai_players_companion_path",
    "/mcp",
    FCVAR_ARCHIVE,
    "Companion MCP path."
)
