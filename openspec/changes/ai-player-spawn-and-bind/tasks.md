## 1. Embodiment spike

- [x] 1.1 Time-box SPK-BOT-001: `player.CreateNextBot` on a listen server (follow-ready body + slot/Kick behavior) versus a NextBot SENT from Spawn Menu and verify notes record which embodiment M1 uses
- [x] 1.2 Update `docs/architecture/gmod-runtime.md` (or the open question) with the spike output and verify the chosen spawn/remove APIs are written down (`Kick` vs `Remove`)

## 2. Spawn and lifecycle

- [ ] 2.1 Register Spawn Menu category `NPCs > AI Players > AI NPC` and verify placing it on `gm_construct` creates an INACTIVE entity
- [x] 2.2 Implement the registry (`agent_id`, name, context, capabilities, state, entity handle) and verify an unbound spawn is not listed on `list_agents`
- [x] 2.3 Implement state transitions INACTIVE → WAITING_FOR_AGENT → ACTIVE and ACTIVE → DISCONNECTED on bridge loss and verify `get_agent_status` reflects the state
- [x] 2.4 Halt locomotion/attack inputs in INACTIVE, WAITING_FOR_AGENT, PAUSED, ERROR, and DISCONNECTED and verify a disconnected NPC does not keep shooting or roaming
- [ ] 2.5 Support two simultaneous bound AI Players in the data model and verify `list_agents` returns two distinct `agent_id`s

## 3. Tool Gun bind

- [ ] 3.1 Add a Tool Gun SWEP with C-panel fields Name and Context and verify left-click on an INACTIVE NPC with both fields set registers an AI Player
- [ ] 3.2 Reject bind when name or context is empty and verify no `agent_id` is created
- [ ] 3.3 On successful bind, upsert the registry over the bridge and verify Companion `list_agents` and `get_agent` return Walter's name and context
- [ ] 3.4 Grant hardcoded capabilities `observe`, `move`, `chat`, `combat` at bind and verify `get_agent` lists them
- [ ] 3.5 On entity remove/Kick, delete the registry row and verify `list_agents` drops that `agent_id`

## 4. Docs for operators

- [ ] 4.1 Document listen-server / player-slot requirements (if player-bot embodiment won) in `addon/README.md` and verify a Sandbox user is told not to use true singleplayer when that is required
