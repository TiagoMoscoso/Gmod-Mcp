## Purpose

Connects Garry's Mod and the Companion through a versioned bridge so MCP tools can reach the game, events can return, and the host UI only advertises MCP when the Companion is actually up.

## ADDED Requirements

### Requirement: Version handshake

The addon and Companion MUST exchange a protocol version during connection. If versions are incompatible, the bridge MUST fail closed (ERROR / not ready) rather than silently continue.

#### Scenario: Matching versions connect

- **WHEN** addon and Companion advertise the same protocol version
- **THEN** the bridge MUST become healthy

#### Scenario: Mismatch fails closed

- **WHEN** the addon protocol version does not match the Companion
- **THEN** the bridge MUST NOT be treated as ready and the client MUST NOT show MCP as online

### Requirement: Bidirectional game messages

The bridge MUST carry at least: registry updates, action requests from Companion to GMod, action accept/reject from GMod, event records from GMod to Companion, and observe request/response.

#### Scenario: Action request reaches GMod

- **WHEN** the Companion sends an action request for a known `agent_id` over a healthy bridge
- **THEN** GMod MUST receive the request payload including `agent_id` and action type

#### Scenario: Event reaches Companion

- **WHEN** GMod emits a bridge event (for example `player_said` fixture)
- **THEN** the Companion MUST store that event for later `get_recent_events` consumption

#### Scenario: Observe round-trip

- **WHEN** the Companion requests an observe snapshot for an `agent_id` over the bridge
- **THEN** GMod MUST reply with a snapshot payload (fixture allowed until perception-and-chat)

### Requirement: Companion unavailability is visible

If the Companion process is not reachable, the addon MUST treat the bridge as down. The client MUST NOT report a working MCP endpoint as ready.

#### Scenario: Companion not running

- **WHEN** the addon initializes and cannot complete handshake
- **THEN** the MCP popup (or equivalent) MUST show a not-ready state and MUST NOT present a copyable URL as live

#### Scenario: Companion dies after connect

- **WHEN** a healthy bridge loses the Companion
- **THEN** client status MUST switch to disconnected/not-ready within the addon's polling or timeout window

### Requirement: Honest MCP URL when healthy

After integration startup, if the Companion is hosting MCP, the host MUST be shown a copyable MCP endpoint URL.

#### Scenario: Healthy Companion shows URL

- **WHEN** handshake succeeds and the Companion MCP listener is up
- **THEN** the popup MUST show the localhost MCP URL and a copy action

#### Scenario: Setup Guide when Companion missing

- **WHEN** the Companion is not available
- **THEN** the UI MUST offer a Setup Guide target pointing at the project's GitHub documentation, not a fake success URL

### Requirement: Localhost default

The advertised MCP URL MUST use `127.0.0.1` (or localhost) for the MVP default. The addon MUST NOT advertise a `0.0.0.0` client URL.

#### Scenario: Popup URL is loopback

- **WHEN** the healthy popup renders the endpoint
- **THEN** the host portion MUST be a loopback address
