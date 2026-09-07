## 1. Transport spike

- [ ] 1.1 Time-box SPK-TRN-001 on a Sandbox listen server: file IPC under `garrysmod/data/` vs `HTTP()` to `127.0.0.1` and verify one path can send a hello and receive hello_ok
- [ ] 1.2 Write the chosen transport and failure modes into `docs/architecture/companion.md` and verify the doc states the winner and what was rejected
- [ ] 1.3 Implement that transport on both Companion and GLua and verify a hello round-trip works with the real addon plus Companion process

## 2. Protocol

- [ ] 2.1 Define JSON envelopes (`type`, `protocol_version`, payload) for handshake, registry, action, event, and observe and verify a schema/example file or module lists every type used in MVP
- [ ] 2.2 Implement handshake using the shared protocol version constant and verify matching versions become healthy and mismatched versions fail closed
- [ ] 2.3 Implement registry upsert/remove messages and verify a fixture upsert is visible to Companion `list_agents` (replacing or sitting behind the mock registry)
- [ ] 2.4 Implement action_request / action_result and event messages and verify a contract test with a fake GMod peer round-trips both without a full game
- [ ] 2.5 Implement observe_request / observe_result with a fixture snapshot and verify the Companion can return that payload to a caller

## 3. Health and popup

- [ ] 3.1 Detect Companion missing, handshake failure, and Companion death after connect and verify status becomes not-ready in each case
- [ ] 3.2 Show the in-game popup (or equivalent) with copyable MCP URL only when Companion MCP is actually listening and verify FR-UX-001 copy works on a healthy session
- [ ] 3.3 When Companion is missing, show not-ready plus Setup Guide to GitHub and verify no live URL is advertised (FR-UX-003, SPK-HTTP-001)
- [ ] 3.4 Ensure advertised URL host is loopback and verify it is never `0.0.0.0`

## 4. Tests

- [ ] 4.1 Add Python contract tests for hello, mismatch, action, event, and observe using a fake GMod transport peer and verify `pytest` passes without launching Garry's Mod
