# ADR-002 — Semantic agent actions instead of frame-level controls

**Status:** Accepted  
**Date:** 2026-09-06

## Context

It is tempting to expose `press_w`, `move_mouse`, and `press_attack` so any LLM can "play" GMod like a human.

That couples the model to tick rate, wastes tokens, aims poorly, and fights prediction/`StartCommand`.

## Decision

Agents may only issue **semantic** actions: `observe`, `move_to`, `follow`, `look_at`, `use`, `pickup`, `drop`, `equip_weapon`, `attack`, `reload`, `stop`, `say`, `speak`.

Garry's Mod runs controllers that own navmesh, pathfinding, `CUserCmd`, obstacles, arrival, and aiming.

The LLM receives events such as `target_reached`, `target_lost`, `action_failed`, `took_damage`, `player_said`.

This cognition/motor split is a **central architectural requirement**.

## Consequences

- MCP stays small and gamemode-extensible
- Combat quality depends on controller engineering, not prompt cleverness
- Some twitch play is impossible (intentional)
- Actions must be async ([FR-ACT-004](../../requirements/functional-requirements.md#fr-act-004))

## Alternatives not chosen

- Frame-level input API
- Hybrid "semantic plus raw cmd override" as a default (unsafe and easy to misuse)

A debug-only raw overlay is not part of this ADR and would need a separate, denied-by-default decision.
