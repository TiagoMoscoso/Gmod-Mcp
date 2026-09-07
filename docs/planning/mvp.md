# MVP — first vertical slice

**Status:** Scenario **Defined**. Cognition is Model A (external MCP client). Embodiment and transport remain spikes inside the slice, not extra product features.

If this circuit works, the project's fundamental hypothesis is validated:

> An external MCP agent can drive a GMod character with semantic actions while GMod owns motor control.

## Scenario A — Follow

1. Start `gm_construct` (listen server with player slots if embodiment requires it — **Open**).
2. Companion / MCP comes up.
3. Popup shows a real endpoint or an honest failure.
4. Spawn AI NPC.
5. Tool Gun:

   - Name: `Walter`
   - Context: `You are Walter, my mechanic friend.`

6. Bind.
7. MCP `list_agents` includes Walter.
8. Player chat: `Walter come with me.`
9. Agent receives the message (events or observe).
10. Agent calls `say`.
11. Agent calls `follow`.
12. Walter replies in chat.
13. Walter navigates to the player and keeps following.

## Scenario B — Combat

Player: `Kill that NPC.`

Walter must:

- observe the target
- select a weapon
- navigate
- aim (controller)
- attack

## Explicitly excluded

- Advanced memory
- STT / TTS
- Native voice capture
- NPC-to-NPC ConversationManager
- DarkRP / economy
- Pickup/use unless required to get a gun off the ground (**Hypothesis:** use spawn menu guns / given weapon)
- Multi-Walter stress test
- Public Internet MCP
- Steam Workshop publish (packaging may be prepared; publish is not the MVP proof)
- Companion-hosted LLM loops (required in **v2**, not here — [v2-backlog.md](v2-backlog.md))
- Playermodel picker and male/female voice picker (required in **v2**, not here)

## MVP tool set

`list_agents`, `get_agent`, `get_agent_status`, `observe`, `get_self`, `get_recent_events`, `move_to`, `follow`, `look_at`, `stop`, `say`, `equip_weapon`, `attack`, `stop_attack`.

## MVP UX

- Spawn Menu category
- Tool Gun left-click bind
- MCP popup
- Chat

Inspect, pause, capability checkboxes are not required to call M1 done.

## Definition of done

| Check | Pass |
| --- | --- |
| Inactive spawn | NPC does not roam on its own |
| Bind | Walter appears in `list_agents` |
| Chat round-trip | Player text visible to agent; `say` visible to player |
| Follow | Walter reaches the player via nav, not teleport |
| Combat | Designated NPC takes damage from Walter without MCP aim tools |
| No forbidden tools | No lua/shell/eval |
| Disconnect | Killing Companion does not leave a silently "intelligent" attacker (**Proposed** pass condition) |

## Failures that still teach

- Cannot follow because of missing navmesh → document, do not teleport
- Cannot spawn player bot in SP → embodiment decision
- Cannot HTTP to 127.0.0.1 → transport decision

Those are successful spikes, not excuses to add `press_w`.
