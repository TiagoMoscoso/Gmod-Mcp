# ADR-004 — Sandbox-first core with gamemode adapters

**Status:** Accepted  
**Date:** 2026-09-06

## Context

DarkRP, Helix, and other RP modes are desirable later. Encoding `TEAM_POLICE`, door ownership, or `buyDoor` in the core registry would freeze the project into one economy.

## Decision

The core implements gamemode-neutral verbs: move, observe, talk, combat, use.

A `GameAdapter` interface maps those verbs (and permissions) onto the running mode.

`SandboxAdapter` ships first.

`DarkRPAdapter` / `HelixAdapter` may later add `buy`, `sell`, `arrest`, `fine`, `heal`, `repair`, jobs — as plugins, not as core types.

## Consequences

- Feature detection and adapter registration are required
- Some Sandbox-derived modes will misbehave until an adapter exists ([OQ-GM-001](../../requirements/open-questions.md#oq-gm-001-gamemode-compatibility-bar))
- Core PRs that `if DarkRP then` in movement code should be rejected

## Alternatives not chosen

- DarkRP-first product
- Per-gamemode forks of the whole addon
