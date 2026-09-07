## Purpose

Loads the GLua addon as a Sandbox-first Workshop-shaped runtime with a gamemode adapter stub, without spawning AI Players or advertising a live MCP endpoint.

## ADDED Requirements

### Requirement: Conventional GMod addon load

The addon MUST load via `lua/autorun` on both client and server and MUST include shared, server, and client modules under `lua/ai_players/`. Loading MUST succeed on the Sandbox gamemode without requiring other addons.

#### Scenario: Listen server Sandbox load

- **WHEN** a listen server starts Sandbox with the addon mounted
- **THEN** the addon MUST initialize without Lua errors and MUST create its namespace modules

#### Scenario: Engine paths not internal-only

- **WHEN** a packager inspects `addon/lua/`
- **THEN** autorun, and later entity/weapon folders, MUST use GMod-conventional paths (`lua/autorun`, not a non-engine custom loader)

### Requirement: Sandbox adapter boundary

Core GLua MUST NOT import DarkRP, Helix, or other gamemode-specific types. Gamemode-specific behavior MUST go through a `GameAdapter` interface whose MVP implementation is a Sandbox adapter stub.

#### Scenario: Core has no DarkRP requires

- **WHEN** a developer searches `addon/lua/ai_players/` for DarkRP identifiers
- **THEN** core modules MUST NOT `include` or `require` DarkRP files or types

#### Scenario: Sandbox adapter is the default

- **WHEN** the addon initializes on Sandbox
- **THEN** it MUST select the Sandbox adapter implementation

### Requirement: No false MCP-ready UX

Until the Companion bridge reports a healthy endpoint, the addon MUST NOT present a working MCP URL as ready.

#### Scenario: Fresh load without Companion

- **WHEN** the addon loads and the Companion is not connected
- **THEN** the client MUST NOT show an "MCP Server Online" state with a copyable live URL

### Requirement: Configuration surface without live bind

The addon MUST expose configuration (convars or equivalent) for Companion host, port, and path so later bridge work can read them. Defaults MUST match the proposed localhost MCP example without implying the server is up.

#### Scenario: Defaults are localhost

- **WHEN** a server operator inspects default convars
- **THEN** host MUST default to `127.0.0.1` and MUST NOT default to a public interface
