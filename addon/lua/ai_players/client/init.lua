-- Client-only module root.
AI_PLAYERS = AI_PLAYERS or {}

-- No Companion bridge exists yet: default to disconnected so no popup
-- or panel can draw an "MCP Server Online" state with a copyable live
-- URL. The bridge change flips this once it proves a real connection.
AI_PLAYERS.CompanionStatus = AI_PLAYERS.CompanionState.DISCONNECTED
