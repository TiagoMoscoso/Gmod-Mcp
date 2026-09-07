# GMod runtime

**Status:** GLua owns gameplay. Embodiment and StartCommand details are **Open** / **Hypothesis** until spikes land.

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

## StartCommand / CUserCmd

If embodiment is a **player bot**:

- Create with `player.CreateNextBot`
- Drive with `GM:StartCommand`
- Move with `CUserCmd:SetForwardMove` / side move / buttons / view angles
- Path with `PathFollower` (player nextbots still need forward move)
- Remove with `Player:Kick`, never `Entity:Remove`
- **Cannot spawn in singleplayer**
- Consume player slots; bots are UnAuthed

If embodiment is a **NextBot SENT**:

- Spawn Menu NPC is natural
- Locomotion via NextBot loco
- Player weapons and sandbox gunplay are weaker / different

Do not pretend these are the same entity type. See [OQ-BOT-001](../requirements/open-questions.md#oq-bot-001-embodiment) and [SPK-BOT-001](../planning/technical-spikes.md).

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

True `game.SinglePlayer()` is hostile to player bots. The UX of "I launched Sandbox and spawned Walter" may require a listen server with extra slots. This must be documented to users once embodiment is chosen — not papered over.
