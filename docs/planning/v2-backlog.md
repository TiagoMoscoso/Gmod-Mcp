# v2 backlog

**Status:** **Defined** as committed post-MVP work. This file is **not** MVP scope. Do not implement it during M1–M1b.

v2 is the first release after the vertical slice. It is a backlog commitment, not a nice-to-have.

v2 has two jobs that must both ship:

1. Orchestration **Model C** (unattended loops on the same tools)
2. Tool Gun **presentation**: playermodel + multiplayer voice preset (male and female options)

## Decision that this file records

| Phase | Item | Status |
| --- | --- | --- |
| MVP | **Model A** — one external MCP client multiplexes AI Players via `agent_id` | **Defined** |
| MVP | Tool Gun: name + context only. Default appearance. Chat `say` only (no voice picker) | **Defined** |
| v2 | **Model C** — keep A, and **must** add optional Companion-hosted autonomy loops | **Defined** |
| v2 | Tool Gun: choose the AI Player **playermodel** | **Defined** |
| v2 | Tool Gun: choose the AI Player **voice** used in multiplayer, with male and female options | **Defined** |

See [ADR-007](../architecture/decisions/ADR-007-mvp-model-a-v2-model-c.md) for orchestration.

Model **B** (Companion-only cognition, MCP reduced to debug) is **not** the v2 target. v2 keeps bring-your-own MCP client as the default path.

## Why v2 exists

Model A stops thinking when the MCP client disconnects. That is acceptable for the vertical slice. It is not enough for:

- a dedicated server with AI Players while no IDE is open;
- unattended NPC↔NPC talk;
- operators who want “bind persona and leave them running.”

MVP also does not distinguish characters visually or by voice. Walter and Sarah can share a default citizen body and text chat. In multiplayer, v2 must let the host pick how the AI Player **looks** and **sounds**.

v2 must close those gaps **without** forking GLua controllers or inventing a second action API.

## What v2 must implement

### C1 — Same semantic surface

Autonomy loops shall call the **same** MCP-equivalent verbs the external client uses (`observe`, `follow`, `say`, `attack`, …), internally if needed.

GMod still owns motor control. The loop must not emit frame-level inputs.

### C2 — Optional per-AI-Player loop

Each AI Player may run with:

- **External only** (MVP behavior, still the default);
- **Companion loop** (unattended cognition);
- **Both** with a documented precedence (**Open** in v2 design: who wins if Claude Code and the loop both act).

Disconnecting Claude Code must not be required to use loops, and enabling loops must not break an attached MCP client.

### C3 — Provider adapters

Companion may call an LLM only through a **pluggable provider**, not a hardcoded Claude or OpenAI client in GLua or in the core dispatcher.

Keys and vendor choice stay out of the Workshop GMA.

### C4 — Lifecycle

Define how ACTIVE / DISCONNECTED / PAUSED interact with a running loop. A loop must honor pause, capabilities, and GameAdapter limits.

### C5 — Cost and rate limits

v2 must pick a policy for token spend and observe frequency for unattended loops. MVP leaves this to the external client ([OQ-AGT-003](../requirements/open-questions.md#oq-agt-003-llm-cost-model) reopens here).

### C6 — Playermodel in the Tool Gun

The Tool Gun C-panel **must** let the user select the AI Player's **player model** (the body other players see).

Applying or re-binding the tool applies that model to the player bot.

**Defined:** this is a v2 Tool Gun control, not an MVP field.

**Open:** exact model catalog (stock HL2 citizens vs Workshop playermodels vs a curated list). Do not freeze paths like `models/player/...` here.

MVP may keep the engine default model.

### C7 — Multiplayer voice preset (male / female)

The Tool Gun C-panel **must** let the user select the voice the AI Player uses in **multiplayer**, so other players can tell characters apart by ear.

**Defined:**

- At least **male** and **female** voice options
- Selection is per AI Player (Walter and Sarah can differ)
- Bound with the Tool Gun, same as name/context/model
- Used for NPC → player speech output (`speak` / TTS), not as a substitute for typed `say` in MVP

**Open** (do not invent in this pass):

- TTS engine / vendor ([OQ-VOI-002](../requirements/open-questions.md#oq-voi-002-tts-engine))
- How many named voices exist beyond the male/female split
- Whether output is positional `EmitSound` only or later Source voice injection ([OQ-VOI-004](../requirements/open-questions.md#oq-voi-004-source-voice-packet-injection))
- Player → NPC STT capture (still a later voice pipeline; C7 is **output preset UX**)

MVP has no voice picker and no TTS requirement.

## What v2 must not do

- Replace MCP as the operator/debug interface
- Put vendor SDKs in GLua
- Implement loops, playermodel pickers, or TTS voices during MVP “just a little”
- Treat Model B as a rewrite of the Companion
- Require STT / native voice capture in order to ship C6/C7 (output voice and model are independent of hearing the player)

## Suggested Companion shape (v2, not now)

```text
companion/
├── mcp/          # still hosts tools for external clients
├── autonomy/     # per-agent loops — v2
└── providers/    # pluggable LLM backends — v2; keep empty in MVP
```

## Open questions that belong to v2, not MVP

- Which LLM providers ship first
- Loop vs external-client conflict resolution
- Whether NPC↔NPC requires loops or can stay on a multiplexed client
- Default autonomy UI when a loop is enabled ([OQ-AGT-002](../requirements/open-questions.md#oq-agt-002-default-autonomy))
- Playermodel catalog
- Voice catalog beyond male / female
- TTS engine for the selected voice

## Implementation rule

If a change is only useful for unattended loops, playermodel picking, or voice presets, and is not needed for Walter + Claude Code on the default body with chat, it belongs here. Land it in v2, not in the vertical slice.
