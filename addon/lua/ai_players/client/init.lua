-- Client-only module root: popup, Tool Gun C-panel, inspect UI live here
-- (see docs/architecture/gmod-runtime.md). This change only establishes the
-- include graph; the Companion status popup lands in gmod-companion-bridge.
AI_PLAYERS = AI_PLAYERS or {}

-- Honest until the bridge change proves a real handshake: never derive an
-- "MCP Server Online" popup or a copyable live URL from this default.
AI_PLAYERS.Client = AI_PLAYERS.Client or {}
AI_PLAYERS.Client.CompanionStatus = AI_PLAYERS.CompanionStatus.DISCONNECTED
