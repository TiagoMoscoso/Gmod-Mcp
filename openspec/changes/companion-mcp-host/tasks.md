## 1. MCP host spike

- [x] 1.1 Time-box SPK-MCP-001: stand up Streamable HTTP `/mcp` with the official Python MCP SDK or FastMCP and verify MCP Inspector (or equivalent generic client) can connect on `127.0.0.1`
- [x] 1.2 If Streamable HTTP fails, record stdio-vs-HTTP outcome in `docs/architecture/companion.md` and verify the written decision states which flavor the MVP Companion uses
- [x] 1.3 Bind the chosen listener to `127.0.0.1` (proposed port 8765) by default and verify it is not listening on `0.0.0.0`

## 2. Mock registry and management tools

- [x] 2.1 Implement an in-memory agent registry with `agent_id`, name, context, capabilities, and lifecycle state and verify a unit test can seed and list records without GMod
- [x] 2.2 Implement MCP tool `list_agents` against the registry and verify a connected client receives seeded agents including `agent_id`
- [ ] 2.3 Implement `get_agent` and `get_agent_status` keyed by `agent_id` and verify unknown ids return `unknown_agent`
- [ ] 2.4 Assert the tool catalog has no per-character-name tools and verify a test fails if a `walter_*` tool is registered

## 3. Safety and session

- [ ] 3.1 Keep a denylist of `execute_lua`, `shell`, `eval`, `run_console_command`, and frame-input names and verify a catalog test asserts none are registered
- [ ] 3.2 Track MCP client connected/disconnected and verify unit tests flip the flag on session start and end
- [ ] 3.3 Expose `PROTOCOL_VERSION` from the Companion process (health or handshake field) and verify it matches the scaffold constant `"1"`

## 4. Packaging and docs

- [ ] 4.1 Add Companion dependencies and a `companion-mcp` (or existing) entrypoint that serves MCP and verify `pip install -e companion/` then the entrypoint serves `/mcp` locally
- [ ] 4.2 Update `companion/README.md` with client config example pointing at the localhost URL and verify the README does not tell users to bind `0.0.0.0`
- [ ] 4.3 Run the Companion unit test suite in CI-local (`pytest`) and verify all new tests pass without a GMod process
