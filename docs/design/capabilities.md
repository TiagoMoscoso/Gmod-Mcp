# Capabilities

**Status:** Explicit capability gating is **Defined**. Schema, UI, and defaults are **Proposed** / **Open**.

## Why

A medic persona should not get `attack` by accident. A public server should not let a visitor-bound NPC `pickup` the world. MCP must not be a superuser API.

## Rule (**Defined**)

The agent may only use tools allowed by the intersection of:

1. Global server policy (**Open**)
2. That AI Player's capability set
3. Current lifecycle state
4. GameAdapter (gamemode may forbid combat)

Missing capability → `accepted: false`, `error: capability_denied`.

## Proposed capability names

| Capability | Tools (approx.) | MVP default **Hypothesis** |
| --- | --- | --- |
| `observe` | observe, get_self, get_recent_events | on |
| `move` | move_to, follow, look_at, stop | on |
| `chat` | say | on |
| `combat` | equip_weapon, attack, stop_attack, reload | on for Walter slice; should become optional |
| `interact` | use, pickup, drop | off until Soon |
| `speak` | speak | off (**Future**) |
| `memory` | remember, recall, set_relationship | off (**Future**) |
| `admin` | none defined | never via MCP |

Do not add `lua` or `console` capabilities.

## Tool Gun

**Proposed** later: checkboxes on the C-panel.

MVP may hardcode Sandbox allow-list (`observe`, `move`, `chat`, `combat`) to keep the vertical slice small ([OQ-CAP-001](../requirements/open-questions.md#oq-cap-001-permission-system)).

## Grant models (**Open**)

- Per NPC at bind time
- Server cvars
- Admin ULX/SAM groups
- Gamemode adapter overlay (DarkRP: citizens cannot arrest)

## Autonomy vs capabilities

Autonomy ([OQ-AGT-002](../requirements/open-questions.md#oq-agt-002-default-autonomy)) is how often the character acts. Capabilities are what it is allowed to do. Keep them separate.

## Professions (**Future**)

A "medic" preset is a bundle of persona + capabilities (`observe`, `move`, `chat`, `interact`) minus `combat`. Presets must not fork the core; they are data.
