## 1. Combat spike

- [ ] 1.1 Time-box SPK-CBT-001 on the chosen embodiment: hold IN_ATTACK and set view angles toward an NPC with no MCP mouse tools and verify the NPC can take damage
- [ ] 1.2 Record go/no-go for Scenario B in `docs/planning/mvp.md` or the spike notes and verify the embodiment limitation (if any) is written down

## 2. Tools and dispatcher

- [ ] 2.1 Add MCP tools `equip_weapon`, `attack`, `stop_attack` with `agent_id` and verify async `accepted` + `action_id` on success
- [ ] 2.2 Reject `capability_denied`, `invalid_state`, `unknown_agent`, and unseen targets and verify contract tests for each
- [ ] 2.3 Make `attack` cancel `follow`/`move_to` and `stop`/`stop_attack` cancel combat and verify preemption on a listen server

## 3. CombatController

- [ ] 3.1 Implement CombatController (navigate, aim, fire) and verify a designated `gm_construct` NPC takes damage from Walter
- [ ] 3.2 Implement `equip_weapon` using a given/spawned weapon (no pickup unless the spike requires it) and verify the AI Player's active weapon changes
- [ ] 3.3 On Companion kill or DISCONNECTED, release attack buttons and idle and verify Walter does not keep firing
- [ ] 3.4 Emit combat-related events the agent can read (`action_failed`, damage/completion as available) and verify they appear in `get_recent_events`

## 4. Scenario B

- [ ] 4.1 Run Scenario B (`Kill that NPC.`) after Scenario A still passes and verify observe → equip → attack damages the target without MCP aim tools
- [ ] 4.2 Re-run the forbidden-tool catalog check and verify no lua/shell/eval/frame-input tools shipped
