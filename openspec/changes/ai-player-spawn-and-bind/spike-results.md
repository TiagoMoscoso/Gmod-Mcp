## SPK-BOT-001 Result

Date: 2026-09-07

Environment:

- Garry's Mod launched from the local Steam Flatpak/Proton install (already running; not launched by this change).
- Sandbox listen server on `gm_construct`.
- 16-player local server, 1 human player connected before the spike ran.
- Spike script: `garrysmod/lua/autorun/server/sv_ai_players_spike_bot_001.lua` (throwaway, vanilla API only, not part of the addon or committed to the repo).
- Triggered once via `changelevel gm_construct` (autorun), report re-generated via a second run through `lua_openscript`.

Result — `player.CreateNextBot`:

- Spawn succeeded (`spawn_ok = true`), returned a real `Player` (`class = "player"`, `is_player = true`, `is_bot = true`, `steamid = "BOT"`).
- Consumed a player slot: player count went 1 → 2 on spawn (`slots_remaining_after_spawn = 14` of 16).
- Could be positioned (`SetPos` to an `info_player_start`) and given aim control (`SetEyeAngles`).
- Native weapon system works: `Give("weapon_pistol")` left the bot holding a real active weapon (`can_equip_native_weapon = true`, `active_weapon_class = "weapon_357"`).
- Removed with `Kick()`: still valid the same tick (`valid_immediately_after_kick = true`), gone one second later (`valid_1s_after_kick = false`, `player_count_after_kick = 1`). Confirms removal is asynchronous and must use `Kick`, not `Entity:Remove`.
- Multi-agent: two additional player bots spawned successfully and were mutually distinct (`player_bots_distinct = true`), consuming two more slots (`player_count_with_two_player_bots = 3`).

Result — native NextBot SENT (`ENT.Base = "base_nextbot"`, registered at runtime via `scripted_ents.Register`, no Workshop base):

- Spawn succeeded (`spawn_ok = true`), correctly not a player (`is_player = false`) and not flagged as a classic NPC (`is_npc = false`).
- Did not consume a player slot (`consumed_player_slot = false`), consistent with it being a plain entity.
- No native weapon/inventory API: `Entity:Give` is not available on a non-player NextBot (`can_equip_native_weapon = false`). Combat would require a hand-rolled attack behavior, not the player weapon system.
- `self:MoveToPos()` inside `RunBehaviour` returned `"failed"` (`move_result = "failed"`, `move_call_completed = true`). The spike spawned the NextBot at the entity-creation origin rather than a nav-validated start point (unlike the player bot, which was explicitly placed on `info_player_start`), so this result is not conclusive proof that NextBot pathing is broken on this map — it is recorded as-is and flagged as unresolved rather than treated as a settled negative.
- Removed with `Entity:Remove()`: valid immediately after the call in the same tick, confirmed gone half a second later (`valid_after_remove = false`).
- Multi-agent: two additional NextBot SENTs spawned successfully and were mutually distinct, with no player-slot cost.

Decision input:

- `player.CreateNextBot` is fully viable for M1 on this listen server: real player identity, real weapon/combat system, controllable aim, and multiple simultaneous bots, at the cost of one player slot per AI Player and requiring a listen/dedicated server (never true singleplayer).
- The native NextBot SENT avoids the slot cost but has no native weapon system (combat needs custom scripting) and produced an inconclusive movement result in this run.
- Given the vertical slice needs combat (`equip_weapon`, `attack`) without new MCP aim tools, and slots were abundant (14 of 16 free after one bot), player bot is the stronger M1 choice. NextBot SENT remains documented as the non-player-bot alternative, not selected for M1.

Relevant report excerpt (`garrysmod/data/ai_players/spikes/spk_bot_001_report.json`):

```json
{
  "summary": {
    "player_bot_consumed_player_slot": true,
    "nextbot_sent_can_equip_native_weapon": false,
    "player_bot_kick_removed_it": true,
    "nextbot_sent_consumed_player_slot": false,
    "nextbot_sent_move_result": "failed",
    "player_bot_can_equip_native_weapon": true,
    "nextbot_sent_remove_removed_it": true
  },
  "player_bot": {
    "consumed_player_slot": true,
    "api": "player.CreateNextBot",
    "max_players": 16,
    "is_player": true,
    "can_equip_native_weapon": true,
    "navmesh_loaded": true,
    "active_weapon_class": "weapon_357",
    "valid_1s_after_kick": false,
    "valid_immediately_after_kick": true,
    "kick_called": true,
    "spawn_ok": true,
    "is_bot": true,
    "steamid": "BOT"
  },
  "nextbot_sent": {
    "is_npc": false,
    "consumed_player_slot": false,
    "api": "scripted_ents.Register(ENT.Base = \"base_nextbot\")",
    "is_player": false,
    "valid_after_remove": false,
    "move_call_completed": true,
    "can_equip_native_weapon": false,
    "spawn_ok": true,
    "move_result": "failed"
  },
  "multi_agent": {
    "attempted": 2,
    "player_bots_distinct": true,
    "nextbots_distinct": true,
    "player_count_with_two_player_bots": 3
  },
  "map": "gm_construct",
  "gamemode": "sandbox",
  "is_dedicated": false,
  "is_singleplayer": false,
  "errors": []
}
```
