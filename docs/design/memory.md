# Memory

**Status:** Persistent memory is **Future**. MVP uses persona strings + recent events only. Storage engine is **Open**.

## MVP (no memory subsystem)

The agent has:

- Bound **context/persona** (Tool Gun)
- `observe` snapshot
- `get_recent_events` ring buffer (ephemeral)

That is enough for Walter to follow and fight.

## Desired later concepts

| Concept | Intent |
| --- | --- |
| Agent identity | Stable `agent_id` / persona across maps — **Open** |
| Memories | "Tiago is my friend" |
| Relationships | Scores or tags toward players/AI Players |
| Conversations | Transcript summaries |
| Recent events | Already in MVP, maybe persisted |
| Current goals | "Follow Moscoso until told otherwise" |

## Candidate store: SQLite

**Candidate**, not decision.

Pros: zero ops, file next to Companion, good for one server.  
Cons: concurrent writers, backup, not a vector DB.

## Alternatives

| Option | Trade-off |
| --- | --- |
| JSON files | Simple, easy corruption |
| SQLite | Good default candidate |
| In-memory only | Dies on restart |
| Vector DB | Overkill until proven |
| GMod `sql` / `file.Write` | Ties memory to the game process; Workshop data folder quirks |

## What not to freeze

- Embedding model
- Memory extraction prompts
- TTL / forgetting curves
- Whether GLua or Companion is authoritative

Companion is the **Proposed** owner if memory is off-tick and SQL-shaped. GLua remains authority for live world facts.

## Injection into context

**Open:** `recall` tool vs automatic top-k memories stuffed into every `observe`. Automatic stuffing risks explosion ([NFR-PER-001](../requirements/non-functional-requirements.md#nfr-per-001)). **Hypothesis:** explicit `recall` plus a tiny automatic "relationship to speaker" line.

## Persistence vs maps

Even without "memory," operators may want Walter's persona to survive `changelevel`. That is identity persistence, not episodic memory. Tracked in [OQ-BOT-004](../requirements/open-questions.md#oq-bot-004-persistence-across-maps--sessions).
