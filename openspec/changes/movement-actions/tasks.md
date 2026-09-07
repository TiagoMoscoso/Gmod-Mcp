## 1. Nav spike and dispatcher

- [ ] 1.1 Time-box SPK-NAV-001 on `gm_construct`: PathFollower plus embodiment motor (`StartCommand` or NextBot loco) and verify the bot walks to a point without teleport
- [ ] 1.2 Implement ActionDispatcher mapping `move_to` / `follow` / `look_at` / `stop` to controllers and verify a second `move_to` replaces the first

## 2. MCP tools

- [ ] 2.1 Add Companion tools `move_to`, `follow`, `look_at`, `stop` with `agent_id` and target payload and verify they return `accepted` + `action_id` without waiting for arrival
- [ ] 2.2 Reject unknown agent, `capability_denied`, and `invalid_state` and verify each error code with a contract test
- [ ] 2.3 Assert the catalog still has no `press_w` / `move_mouse` / `press_attack` tools and verify the denylist test passes

## 3. Controllers and events

- [ ] 3.1 Implement MovementController for `move_to` and `follow` with navmesh and arrival tolerance and verify Walter reaches the player on `gm_construct`
- [ ] 3.2 Emit `target_reached`, `target_lost`, and `action_failed` (no mesh, stuck, invalid entity) into the event buffer and verify `get_recent_events` shows them
- [ ] 3.3 On missing navmesh, fail with `action_failed` and verify the entity did not teleport
- [ ] 3.4 Implement LookController for `look_at` and verify the AI Player faces the target
- [ ] 3.5 Ensure `say` does not cancel `follow` and `stop` does cancel locomotion and verify both on a listen server

## 4. Scenario A

- [ ] 4.1 Run the Scenario A checklist (spawn, bind, chat, `say`, `follow`) on `gm_construct` and verify Walter replies in chat and walks with the player (MVP definition of done for follow)
