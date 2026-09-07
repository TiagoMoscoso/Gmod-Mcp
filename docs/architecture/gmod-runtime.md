# GMod runtime

**Status:** GLua owns gameplay. Embodiment for M1 is **Accepted**: player bot via `player.CreateNextBot`, confirmed by `SPK-BOT-001` in the `ai-player-spawn-and-bind` change (see [OQ-BOT-001](../requirements/open-questions.md#oq-bot-001-embodiment)). Other StartCommand details remain **Hypothesis** until later spikes land.

## Role

Garry's Mod is the source of truth for the world: entities, players, damage, navmesh, chat, weapons, and gamemode hooks.

It executes semantic actions **deterministically** through controllers.

It does **not** host MCP (**Proposed**, [ADR-005](decisions/ADR-005-mcp-hosted-by-companion.md)).

It does **not** call LLM HTTP APIs as the architecture.

## Tick vs cognition

`Think`, `StartCommand`, and PathFollower updates run at engine rates.

Agent decisions run rarely, off-tick, through the Companion.

Controllers persist across many ticks until they finish, fail, or are preempted.

## Controllers (**Proposed** names)

| Controller | Started by | Owns |
| --- | --- | --- |
| MovementController | `move_to`, `follow`, `stop` | Path, stuck detection, arrival tolerance |
| LookController | `look_at` | View/aim angles over time |
| CombatController | `attack`, `stop_attack`, `equip_weapon` | Weapon select, aim, IN_ATTACK, reload later |
| InteractionController | `use`, `pickup`, `drop` | **Soon** |

Speech (`say`) is a short relay, not a locomotion controller. **Hypothesis:** `say` can run in parallel with follow.

## Embodiment (Accepted for M1)

**Accepted:** the AI Player entity for M1 is a **player bot** created with `player.CreateNextBot`.

`SPK-BOT-001` ran on the live `gm_construct` listen server (16 slots) and confirmed:

- Spawn succeeds and returns a real `Player` (`IsPlayer() == true`, `IsBot() == true`).
- It consumes one player slot per AI Player (14 of 16 remained free after the first spawn; a second and third bot spawned without issue).
- It gets the real player weapon/inventory system: `Give("weapon_pistol")` leaves it holding a genuine active weapon, so `equip_weapon` / `attack` (`combat-actions` change) can reuse player weapon APIs instead of hand-rolled combat.
- Aim is controllable (`SetEyeAngles`), and it is driven every tick through `GM:StartCommand` / `CUserCmd` like any other player bot.
- Removal is asynchronous and must use `Player:Kick`, never `Entity:Remove`: the entity is still valid the same tick `Kick` is called, and gone about a second later.

### Rejected as M1 primary: native NextBot SENT

`SPK-BOT-001` also spawned a runtime-registered `ENT.Base = "base_nextbot"` SENT on the same server. It spawns without a player-slot cost, but:

- It has no native weapon/inventory API (`Entity:Give` is not available on a non-player entity) — combat would need a fully hand-rolled attack behavior instead of reusing player weapons.
- Its `self:MoveToPos()` call returned `"failed"` in the spike run. The spike positioned the player bot on a nav-validated `info_player_start` but spawned the NextBot at the raw entity-creation origin, so this result does not prove NextBot pathing is broken on this map — it is an open, unresolved data point, not a settled rejection reason on its own.

Given the vertical slice needs `equip_weapon` / `attack` without new MCP aim tools, and player slots were abundant in the spike, player bot is the stronger M1 choice. NextBot SENT is not used as the driven AI Player embodiment for M1, but the engine still uses a SENT for one purpose: see "Spawn Menu placement" below.

### Spawn Menu placement

Garry's Mod's Spawn Menu places registered `SENT`/`SWEP`/`NPC` classes at a world position; it does not have a mechanism to place a `player.CreateNextBot` bot at a clicked location. `NPCs > AI Players > AI NPC` therefore places a lightweight **INACTIVE placeholder SENT**, not the final player bot. A Tool Gun bind (`ai-player-spawn-and-bind` change) promotes that placeholder: it removes the SENT (`Entity:Remove`, no player slot was ever consumed) and calls `player.CreateNextBot` at the placeholder's position to create the real, registered AI Player. Removal rules therefore differ by lifecycle stage of the same conceptual AI Player: `Entity:Remove` for an unbound placeholder, `Player:Kick` for a bound/promoted player bot.

### StartCommand / CUserCmd

- Create with `player.CreateNextBot`
- Drive with `GM:StartCommand`
- Move with `CUserCmd:SetForwardMove` / side move / buttons / view angles
- Path with `PathFollower` (player nextbots still need forward move)
- Remove with `Player:Kick`, never `Entity:Remove`
- **Cannot spawn in singleplayer**; requires a listen or dedicated server with a free player slot
- Consume player slots; bots are UnAuthed

Do not pretend a promoted player bot and its unbound placeholder SENT are the same entity type across their lifecycle. See [OQ-BOT-001](../requirements/open-questions.md#oq-bot-001-embodiment) and [SPK-BOT-001](../planning/technical-spikes.md).

## Perception

Computed server-side in GLua from the AI Player's origin/eyes.

Push a compact snapshot to the Companion when `observe` is requested, and/or maintain a recent-event buffer.

Do not serialize the entity list of `ents.GetAll()`.

## Chat

Hook player chat, apply **Proposed** filters (distance, maybe team), append `player_said` events.

`say` uses the gamemode's chat path so other players see it as coming from the AI Player.

## Gamemode adapters

```text
GameAdapter
├── SandboxAdapter    -- MVP
├── DarkRPAdapter     -- Future
└── HelixAdapter      -- Future
```

Core asks the adapter: can this entity be used? is combat allowed here? how do we print chat?

SandboxAdapter implements move, observe, talk, combat, use.

DarkRPAdapter would add buy/sell/arrest/fine/heal/repair/jobs without those types leaking into `ai_players/bot`.

## Client vs server

| Realm | **Proposed** duties |
| --- | --- |
| Server | Registry, perception, controllers, bridge, chat, combat |
| Client | Popup, Tool Gun C-panel, inspect UI, later 3D voice playback |

The native voice module is **Proposed** server-side for capture.

## Singleplayer warning

True `game.SinglePlayer()` is hostile to player bots. Embodiment is now chosen (player bot, above), so "I launched Sandbox and spawned Walter" requires a listen server or dedicated server with a free player slot; true singleplayer cannot bind an AI Player. This is documented for operators in [addon/README.md](../../addon/README.md).
