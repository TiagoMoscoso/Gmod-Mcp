-- Server-side entry point for the AI Players skeleton.
-- No NPC spawn, no MCP claim: those land in later changes.
AddCSLuaFile("ai_players/client/init.lua")

include("ai_players/shared/init.lua")
include("ai_players/server/init.lua")
