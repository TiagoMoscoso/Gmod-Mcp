# Conversations

**Status:** Player chat in/out for MVP is **Defined**. Selectable TTS output is **v2**. NPC↔NPC, STT, and numeric policy are **Future** / **Open**.

## Channels

| Channel | Phase |
| --- | --- |
| Player → NPC (typed chat) | MVP |
| NPC → Player (`say`) | MVP |
| NPC → NPC | **Future** |
| Player → NPC (voice) | **Future** |
| NPC → Player (TTS / `speak`) | **v2** (male/female Tool Gun preset; engine **Open**) |

## Hearing (**Future** for spatial rules; MVP may be simpler)

An NPC speaking should produce an event only for characters that could hear it: distance and gamemode rules (team chat, advert commands) when applicable.

MVP **Hypothesis:** all players on the server see `say` (normal Sandbox chat), and the speaking AI Player plus nearby agents get `player_said` / `ai_said` events. Do not freeze radii.

## Loop hazard

If Walter always replies to Sarah and Sarah always replies to Walter, tokens and chat spam diverge.

A **ConversationManager** is required before NPC↔NPC ships. It may live in GLua or Companion — **Open**.

## Concepts (no values yet)

| Concept | Role |
| --- | --- |
| `conversation_id` | Group turns |
| Turn-taking | One speaker at a time |
| Cooldown | Minimum time between autonomous replies |
| Interest score | Whether to join or stay silent |
| Max autonomous exchanges | Hard stop |
| Hearing distance | Who receives `ai_said` |
| Interruption | Damage / player speech breaks the loop |
| Speaker / listener | Roles |
| Conversation timeout | Idle end |

See [OQ-CNV-001](../requirements/open-questions.md#oq-cnv-001-conversationmanager-parameters).

## MVP chat path

1. Player says `Walter come with me.`
2. GLua records `player_said` with text, speaker id, optional addressee **Hypothesis** (name mention).
3. Agent reads events.
4. Agent `say` + `follow`.

Address parsing ("Walter, ...") is a convenience, not a requirement. The agent can filter.

## What not to do in MVP

- Simulated inner monologue tools
- Auto-chatter without player stimulus
- Cross-NPC debates
- Translating every `say` into TTS
