# ADR-006 — Dual distribution: public GitHub and Steam Workshop

**Status:** Proposed  
**Date:** 2026-09-06

## Context

The project is intended to be public open source **and** discoverable to Garry's Mod players.

Steam Workshop is the default install path for GLua addons. It is a bad runtime for Python and a fragile one for `gmsv_*.dll` modules.

GitHub is the right home for a monorepo, issues, Companion, native source, and docs.

## Decision (proposed)

| Channel | Ships |
| --- | --- |
| Public GitHub | Entire monorepo (source of truth) |
| Steam Workshop | Derived GLua addon (`addon/` → GMA) |

Companion and native binaries are **not** assumed to live inside the GMA ([NFR-DIST-001](../../requirements/non-functional-requirements.md#nfr-dist-001)).

The addon must remain **Workshop-extractable**: packaging must not require `docs/` or `companion/` in the GMA.

Workshop-only users must see a truthful Companion-missing state and a Setup Guide pointing at GitHub.

## Consequences

- Two version numbers to worry about ([OQ-DIST-004](../../requirements/open-questions.md#oq-dist-004-version-coupling))
- License must be chosen before GitHub is public ([OQ-DIST-001](../../requirements/open-questions.md#oq-dist-001-spdx-license))
- Linux dedicated servers still need a documented non-Workshop path

## Alternatives not chosen

- GitHub only (poor GMod discovery)
- Workshop only (cannot legally/practically ship the whole stack)
- Shipping Python inside the GMA (does not run)

## Follow-up

Accept after license + Lua-only GMA confirmation. Companion install UX remains **Open**.
