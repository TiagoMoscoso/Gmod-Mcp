# Technical spikes

Spikes are time-boxed experiments. They produce a decision for an **Open** question, not production polish.

## SPK-TRN-001 — GMod ↔ Companion transport

**Decides:** [OQ-TRN-001](../requirements/open-questions.md#oq-trn-001-gmod-companion-transport)  
**When:** before M1 implementation  
**Try:**

- File IPC under `garrysmod/data/` (known GMod MCP pattern)
- `HTTP()` to `127.0.0.1` on listen vs dedicated vs SP
- Optional tiny native/websocket module

**Output:** chosen transport + failure modes written back into `companion.md`.

## SPK-MCP-001 — MCP host

**Decides:** [OQ-MCP-003](../requirements/open-questions.md#oq-mcp-003-mcp-transport-flavor) and whether Python SDK/FastAPI is enough  
**When:** with SPK-TRN-001  
**Try:** Streamable HTTP `/mcp` vs stdio; one tool `list_agents` mocked.

**Output:** Companion candidate confirmed or replaced.

## SPK-BOT-001 — Embodiment

**Decides:** [OQ-BOT-001](../requirements/open-questions.md#oq-bot-001-embodiment)  
**When:** before spawn/combat code freezes  
**Try:**

- `player.CreateNextBot` on a listen server: follow + crowbar/gun
- NextBot SENT from Spawn Menu in singleplayer
- Document slot and Kick behavior

**Output:** embodiment for M1 (may be "listen server + player bot only").

## SPK-NAV-001 — Path follow via controllers

**Decides:** stuck detection approach; not a product option list  
**When:** during M1  
**Try:** PathFollower + StartCommand forward move on `gm_construct`; missing-nav failure.

**Output:** MovementController sketch.

## SPK-CBT-001 — Combat aim inside a controller

**Decides:** whether M1b is feasible with chosen embodiment  
**When:** after SPK-BOT-001  
**Try:** `attack` holds IN_ATTACK and sets view angles toward an NPC; no MCP mouse tools.

**Output:** go/no-go for Scenario B in the same milestone.

## SPK-HTTP-001 — Popup URL truthfulness

**Decides:** what FR-UX-001 can honestly display  
**When:** with Companion process lifecycle  
**Try:** Companion down, up, wrong port.

**Output:** state machine for the popup.

## SPK-WS-001 — gmad packaging

**Decides:** [OQ-DIST-002](../requirements/open-questions.md#oq-dist-002-workshop-payload) Lua-only hypothesis  
**When:** before first Workshop upload (can wait until after M1)  
**Try:** `addon/` packed without companion/docs; mounts in GMod.

**Output:** packaging script notes in [distribution.md](distribution.md).

## Spikes not to run yet

- Opus/VAD
- Source voice injection
- DarkRP buy/arrest
- Vector memory
- Autonomous multi-NPC loops (required in **v2**, not a spike for M1 — [v2-backlog.md](v2-backlog.md))

Those wait for their milestones.
