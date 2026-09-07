-- Companion connection settings (ADR-005 proposes http://127.0.0.1:8765/mcp).
-- These convars only describe where the bridge will later look for the
-- Companion; setting them does not start a connection and must never be
-- read as proof one exists (see shared/companion_status.lua).
if SERVER then
    AddCSLuaFile()
end

CreateConVar(
    "ai_players_companion_host",
    "127.0.0.1",
    FCVAR_ARCHIVE,
    "Companion MCP host. Keep this a loopback address; do not bind a public interface here."
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
    "Companion MCP HTTP path."
)
