## 1. Perception snapshot

- [ ] 1.1 Implement GLua snapshot builder (self, players, AI Players, entities, events) from the AI Player origin/eyes and verify it never serializes `ents.GetAll()` unfiltered
- [ ] 1.2 Apply distance, LOS, and hard caps with a `truncated` flag and verify a busy `gm_construct` observe stays under those caps
- [ ] 1.3 Omit SteamIDs and IPs from player records and verify a fixture snapshot has no those fields
- [ ] 1.4 Wire MCP `observe` and `get_self` over the bridge as live requests and verify unknown `agent_id` returns `unknown_agent`

## 2. Events

- [ ] 2.1 Add a per-agent ring buffer and MCP `get_recent_events` and verify a unit/contract test reads back inserted events
- [ ] 2.2 Reserve event types `player_said`, `target_reached`, `action_failed` in the schema and verify unknown types are not required for this change's tests

## 3. Chat

- [ ] 3.1 Hook player chat, filter by distance (Sandbox: ignore team), and append `player_said` with speaker id/name/text and verify "Walter come with me." appears in Walter's buffer when in range
- [ ] 3.2 Implement MCP `say` via SandboxAdapter/ChatRelay attributed to the AI Player name and verify other players see Walter's line, not the host's name
- [ ] 3.3 Reject `say` when state is not ACTIVE or `chat` capability is missing and verify `invalid_state` / `capability_denied`

## 4. Tests

- [ ] 4.1 Add Companion tests with a fake GMod observe payload (caps, truncated, no SteamID) and verify `pytest` covers `observe` / `get_self` / `get_recent_events` / `say` accept/reject without a full combat stack
