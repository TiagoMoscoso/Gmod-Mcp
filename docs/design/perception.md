# Perception

**Status:** Filtered perception is **Defined**. Caps, LOS details, and JSON field names are **Proposed** / **Open**.

## Problem

Dumping `ents.GetAll()` into an LLM context explodes tokens, leaks wallhacks, and invites the model to micromanage junk props.

## Principles (**Defined**)

1. The agent never receives all map entities.
2. Snapshots are computed from the AI Player's senses, not from a god camera.
3. Relevance beats completeness: current action, recent events, nearby players, other AI Players, interactables.
4. Recently changed and recently eventful entities outrank static scenery.
5. Observation is a pull tool in MVP, not a per-tick stream.

## Proposed snapshot shape

```json
{
  "self": {},
  "visible_players": [],
  "visible_ai_players": [],
  "visible_entities": [],
  "recent_events": []
}
```

Field names may change. The grouping is the requirement.

### `self` (**Proposed**)

Position, angles, health, armor, weapon, alive, lifecycle state, current action, velocity, on-ground. No full inventory dump unless a later adapter needs it.

### Players / AI Players

Enough to talk or follow: `entindex` or opaque id, name, distance, ducking, alive, team if meaningful. No IP addresses, SteamIDs in MVP **Proposed** omit (privacy on public servers — **Open** for dedicated).

### Entities

Class, name if any, distance, coarse category (npc, prop, weapon, door, other), maybe health. Not every bone.

## Filters to consider (**not numbered yet**)

| Filter | Role |
| --- | --- |
| Distance | Hard radius |
| Visibility / LOS | Trace from eyes |
| Entity relevance | Weapons, NPCs, named props over debris |
| Player relevance | Alive > dead; recent speakers first |
| AI Player relevance | Always interesting within radius |
| Recently changed | Door opened, prop broken |
| Recent events | Chat, damage |
| Current objective | Follow target pinned even at range **Hypothesis** |

Exact meters and max array lengths: [OQ-PER-001](../requirements/open-questions.md#oq-per-001-perception-caps).

## Anti-explosion rules (**Proposed**)

- Hard cap on each array
- Truncate with a `truncated: true` flag so the agent knows it is blind to overflow
- Coarse positions (do not send sub-millimeter vectors if it bloats JSON — optional later)
- No material/model path spam
- No recursive parent chains

## Events vs observe

`observe` is spatial.

`get_recent_events` is temporal.

MVP should include `player_said`, action outcomes, and enough combat feedback. Do not log every footstep.

## Cheating

LOS filtering is a product/fairness choice. Sandbox god-NPCs might skip LOS later via a capability `omniscient` — **Future**, denied by default.

## Implementation locus

**Proposed:** GLua computes traces; Companion does not raycast. Companion may still drop fields to fit token budgets, but must not invent entities.
