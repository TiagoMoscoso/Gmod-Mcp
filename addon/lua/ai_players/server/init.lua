-- Server-only module root: registry, perception, controllers, bridge, chat,
-- and combat live here (see docs/architecture/gmod-runtime.md). This change
-- only establishes the include graph and the Sandbox adapter selection;
-- controllers and the bridge land in later changes.
AI_PLAYERS = AI_PLAYERS or {}

include("ai_players/integrations/sandbox_adapter.lua")

-- MVP targets Sandbox only (ADR-004); a later gamemode-adapter change picks
-- among adapters here instead of hardcoding SandboxAdapter.
AI_PLAYERS.Adapter = AI_PLAYERS.SandboxAdapter
