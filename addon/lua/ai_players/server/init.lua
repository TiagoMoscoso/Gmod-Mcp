-- Server-only module root: registry, perception, controllers, bridge, chat,
-- and combat live here (see docs/architecture/gmod-runtime.md). This change
-- only establishes the include graph and the Sandbox adapter selection;
-- controllers and the bridge land in later changes.
AI_PLAYERS = AI_PLAYERS or {}
