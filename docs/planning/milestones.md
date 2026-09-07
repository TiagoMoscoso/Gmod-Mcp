# Milestones

**Status:** Order is **Defined** as intent. Dates are not committed.

M0 is this documentation pass.

## M0 — Specification

**Done when:** this `docs/` tree exists and open questions are catalogued.

No production code.

## M1 — Vertical slice (follow)

**Goal:** prove cognition/motor split on `gm_construct`.

- Companion hosts MCP (or the spike's chosen equivalent)
- Bridge GMod ↔ Companion
- Spawn inactive AI NPC
- Tool Gun bind (name + context)
- `list_agents` shows Walter
- Chat → `say` + `follow`
- Walter replies and follows using a MovementController

**Out:** memory, voice, NPC↔NPC, DarkRP, native module.

See [mvp.md](mvp.md). Apply order for the eight OpenSpec changes that implement M1 + M1b: [implementation-roadmap.md](implementation-roadmap.md).

## M1b — Vertical slice (combat)

Same Walter. Player: "Kill that NPC."

- `observe` target
- `equip_weapon`
- CombatController: navigate, aim, attack
- `stop_attack`

M1b may merge with M1 if embodiment spike says guns are cheap. If player bots vs NextBots split the work, keep M1b separate. In the OpenSpec split, combat is its own change (`combat-actions`) that can follow movement sequentially or run in parallel after perception.

## M2 — Multi-agent + capabilities + inspect

- Two AI Players with distinct personas
- Right-click inspect
- Pause/resume
- Capability flags (even if UI is crude)
- `use` / `get_entity` as time allows

Autonomy loops and LLM providers are **not** M2. They are v2. See [v2-backlog.md](v2-backlog.md).

## M3 — Conversations

- Hearing rules
- ConversationManager
- NPC↔NPC with hard caps

## M4 — Memory

- Persistence choice
- `remember` / `recall` / relationships
- Map-change identity policy

## M5 — Voice (technical pipeline)

Tool Gun male/female **preset UX** is committed on **v2** ([v2-backlog.md](v2-backlog.md) C7). This milestone is the capture/TTS engineering around that:

- Native capture spike actually ships or is rejected
- STT Player→NPC (**not** required to ship C7)
- TTS NPC→Player positional audio (needed for C7 to be audible)
- Source injection remains optional research

## M6 — Gamemode adapters

- GameAdapter extracted for real
- DarkRP and/or Helix as plugins
- Economy verbs stay out of core

## M7 — Public distribution hardening

- License
- GitHub public
- First Workshop GMA
- Version handshake
- Dedicated Linux notes
- Security pass for non-localhost MCP

M7 work can start in parallel after M1 (license, repo hygiene) but Workshop "it works" should not precede M1.

## v2 — Post-MVP backlog (required)

After the MVP path is proven, v2 **must** implement:

- Model C (optional Companion-hosted loops on the same tools)
- Tool Gun playermodel selection
- Tool Gun multiplayer voice selection with **male** and **female** options

Do not mix that work into the vertical slice. Full list: [v2-backlog.md](v2-backlog.md).

## Exit criteria vs feature greed

A milestone is done when its **hypothesis is tested**, not when every adjacent idea is built. Extra tools listed as "Soon" can slip without renaming M1.
