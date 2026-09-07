-- Sandbox GameAdapter (ADR-004): the MVP default and the only adapter this
-- change ships. Server-only because combat/use rules are server-authoritative
-- (see docs/architecture/gmod-runtime.md "Gamemode adapters"). Sandbox-safe
-- defaults only; DarkRP/Helix rules do not belong here.
AI_PLAYERS.SandboxAdapter = AI_PLAYERS.GameAdapter.New()
