# ADR-001 — Hybrid GLua / C++ / Python architecture

**Status:** Proposed  
**Date:** 2026-09-06

## Context

The product needs (1) deep Garry's Mod integration, (2) a modern MCP server, (3) later, voice capture that GLua cannot do well.

Implementing all three in one language is a poor fit:

- GLua is mandatory for entities, Tool Gun, `StartCommand`, and Workshop.
- Python (or similar) has MCP SDKs, async HTTP, and STT/TTS ecosystems.
- C++ binary modules can see voice packets and Opus.

## Decision (proposed)

Split into three layers:

- **GLua** — gameplay, world, UI, controllers
- **Companion** — MCP, routing, later memory/speech workers; Python is a **candidate**, not a lock
- **C++** — voice core only, **Future**

C++ extends GLua; it does not replace GLua.

## Consequences

- Dual/triple packaging (Workshop Lua vs GitHub Companion vs later DLLs)
- A bridge protocol is required ([OQ-TRN-001](../../requirements/open-questions.md#oq-trn-001-gmod-companion-transport))
- More moving parts for users (Companion missing UX)

## Alternatives not chosen

- **All GLua:** cannot host MCP or voice properly; invites `lua_run` MCP designs we reject
- **All C++ gameplay:** fights Workshop, iteration speed, and the "C++ extends GLua" rule
- **LLM inside Source:** couples vendors and stalls the game thread

## Follow-up

Companion language remains reversible until the first Companion spike. Native code stays out of MVP.
