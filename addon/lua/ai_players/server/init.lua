-- Server-only module root.
AI_PLAYERS = AI_PLAYERS or {}

-- MVP only ships the Sandbox adapter (ADR-004); a DarkRP/Helix change
-- picks a different adapter here without touching combat/chat/use logic.
AI_PLAYERS.Adapter = include("ai_players/integrations/sandbox_adapter.lua")
AI_PLAYERS.Registry = include("ai_players/server/registry.lua")
AI_PLAYERS.Bridge = include("ai_players/server/bridge.lua")
include("ai_players/server/spawn.lua")
AI_PLAYERS.Bridge.Start()
