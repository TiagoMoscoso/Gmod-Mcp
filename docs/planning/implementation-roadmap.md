# Implementation roadmap (M1 + M1b)

**Status:** Planning. This is the apply order for OpenSpec changes that implement the first vertical slice. Dates are not committed.

Related: [mvp.md](mvp.md), [milestones.md](milestones.md), [technical-spikes.md](technical-spikes.md).

This document does **not** replace product specs. It answers: which change first, what can run in parallel, what gates the rest.

## MVP done when

From [mvp.md](mvp.md), on `gm_construct` (listen server if embodiment requires it):

| Check | Pass |
| --- | --- |
| Inactive spawn | NPC does not roam on its own |
| Bind | Walter appears in `list_agents` |
| Chat round-trip | Player text visible to agent; `say` visible to player |
| Follow | Walter reaches the player via nav, not teleport |
| Combat | Designated NPC takes damage from Walter without MCP aim tools |
| No forbidden tools | No lua/shell/eval/frame-input |
| Disconnect | Killing Companion does not leave a silently intelligent attacker |

## Change catalog

OpenSpec changes live under `openspec/changes/`. Apply with `/opsx-apply` (one change at a time). Each change already has `proposal.md`, `specs/`, `design.md`, and `tasks.md`.

Git: one change → worktree `.worktrees/<name>` on branch `change/<name>`; one `tasks.md` item → one commit; when that change’s tasks are done → pull request to `main` (see `AGENTS.md`). Parallel apply uses one worktree per change.

| # | Change | Specs | Closes |
| --- | --- | --- | --- |
| 1 | [`scaffold-monorepo`](../../openspec/changes/scaffold-monorepo/) | `repo/monorepo-layout` | Empty `addon/` + `companion/` + `tests/` split |
| 2 | [`companion-mcp-host`](../../openspec/changes/companion-mcp-host/) | `companion/mcp-server` | Localhost MCP + mock `list_agents` |
| 3 | [`gmod-addon-skeleton`](../../openspec/changes/gmod-addon-skeleton/) | `addon/runtime-bootstrap` | GLua load, SandboxAdapter stub |
| 4 | [`gmod-companion-bridge`](../../openspec/changes/gmod-companion-bridge/) | `bridge/protocol` | Transport + handshake + honest popup |
| 5 | [`ai-player-spawn-and-bind`](../../openspec/changes/ai-player-spawn-and-bind/) | `addon/spawn-lifecycle`, `addon/toolgun-bind` | Spawn, bind, registry, lifecycle |
| 6 | [`perception-and-chat`](../../openspec/changes/perception-and-chat/) | `addon/perception`, `addon/chat` | `observe` / events / `say` |
| 7 | [`movement-actions`](../../openspec/changes/movement-actions/) | `addon/movement` | Scenario A (follow) |
| 8 | [`combat-actions`](../../openspec/changes/combat-actions/) | `addon/combat` | Scenario B (M1b) |

## Dependency graph

```text
1 scaffold-monorepo
        |
        +------------------+
        v                  v
2 companion-mcp-host    3 gmod-addon-skeleton
        |                  |
        +--------+---------+
                 v
        4 gmod-companion-bridge
                 |
                 v
        5 ai-player-spawn-and-bind
                 |
                 v
        6 perception-and-chat
                 |
        +--------+---------+
        v                  v
7 movement-actions    8 combat-actions
        |                  ^
        +----- sequential -+  (one person: 7 then 8)
```

Solid arrows are hard dependencies (later change needs earlier artifacts in tree). The dashed human sequence: prove follow before combat if only one implementer.

## Waves

### Wave 0 — layout (serial)

**Apply:** `scaffold-monorepo`

**Blocks:** everything else (no `addon/` or `companion/` yet).

**Parallel:** none.

### Wave 1 — Python MCP and GLua bootstrap (parallel)

**Apply (parallel):** `companion-mcp-host` **and** `gmod-addon-skeleton`

| Change | Waits on | Unblocks |
| --- | --- | --- |
| companion-mcp-host | 1 | 4 (MCP side) |
| gmod-addon-skeleton | 1 | 4 (GLua side) |

They do not wait on each other. Two agents can apply in parallel, each in `.worktrees/<name>`. One person should still finish both before the bridge.

**Gate inside 2:** [SPK-MCP-001](technical-spikes.md) (Streamable HTTP vs stdio). If Python MCP SDK fails, stop and change Companion language **before** writing lots of tools.

### Wave 2 — bridge (serial, highest engineering risk)

**Apply:** `gmod-companion-bridge`

**Waits on:** 2 and 3.

**Gate:** [SPK-TRN-001](technical-spikes.md). File IPC vs `HTTP()` to `127.0.0.1` vs fallback. Run the spike on a **listen server**, not only dedicated.

**Blocks:** spawn/bind and every later gameplay change. Do not start Tool Gun work until hello/handshake works.

**Also gates UX:** popup must not lie ([SPK-HTTP-001](technical-spikes.md) is tasks in this change).

### Wave 3 — spawn and bind (serial)

**Apply:** `ai-player-spawn-and-bind`

**Waits on:** 4.

**Gate:** [SPK-BOT-001](technical-spikes.md) (player bot vs NextBot SENT). Output decides Kick vs Remove, singleplayer warning, and whether M1b guns are cheap.

**Blocks:** perception (needs a real entity and `agent_id`).

Inspect / pause / unbind stay out (M2).

### Wave 4a — perception and chat (serial)

**Apply:** `perception-and-chat`

**Waits on:** 5.

**Unblocks:** 7 and 8.

No spike catalog entry; still time-box caps/LOS constants rather than debating meters.

### Wave 4b — movement (Scenario A)

**Apply:** `movement-actions`

**Waits on:** 6.

**Gate:** [SPK-NAV-001](technical-spikes.md) on `gm_construct`. Missing nav → `action_failed`, never teleport.

**Done means:** Scenario A checklist in this change's `tasks.md`.

### Wave 4c — combat (Scenario B / M1b)

**Apply:** `combat-actions`

**Waits on:** 6 (must observe a target). **Soft wait on 7:** ActionDispatcher preemption is easier if movement already exists.

**Gate:** [SPK-CBT-001](technical-spikes.md) after embodiment. If SENT cannot gun, M1b may require player-bot embodiment — that is a successful spike, not a reason to add `press_attack`.

**Parallel with 7:** yes, if two people, after 6, and they agree on ActionDispatcher ownership (prefer one owner).

## Recommended apply order

### One person

```text
/opsx-apply  scaffold-monorepo
/opsx-apply  companion-mcp-host
/opsx-apply  gmod-addon-skeleton
/opsx-apply  gmod-companion-bridge      ← stop if transport spike fails
/opsx-apply  ai-player-spawn-and-bind   ← stop if embodiment is unusable
/opsx-apply  perception-and-chat
/opsx-apply  movement-actions           ← Scenario A
/opsx-apply  combat-actions             ← Scenario B
```

Do not start the next change's apply until the current change's tasks (including its spike) are done. A failed spike is a documentation/ADR update, not a silent workaround.

### Two people

| Person A (Companion / protocol) | Person B (GLua) |
| --- | --- |
| 1 together (short) | 1 together |
| 2 `companion-mcp-host` | 3 `gmod-addon-skeleton` |
| 4 together (transport needs both) | 4 together |
|  | 5 spawn/bind (A supports registry API) |
| 6 tools + contract tests | 6 GLua snapshot + chat hooks |
|  | 7 movement **then** 8 combat, or split 7/8 after dispatcher interface is written |

Do not parallelize 4. Do not parallelize 5 with 4. Parallel agents never share a checkout; each change has its own `.worktrees/<name>`.

## Spike gates (what they unlock)

| Spike | Lives in change | Unlocks | Failure mode |
| --- | --- | --- | --- |
| SPK-MCP-001 | 2 | HTTP `/mcp` or documented stdio gap | Swap Companion stack; keep folder `companion/` |
| SPK-TRN-001 | 4 | All GMod↔agent gameplay | File IPC or other fallback; no native module in MVP |
| SPK-HTTP-001 | 4 (popup tasks) | Honest FR-UX-001 | Never fake a live URL |
| SPK-BOT-001 | 5 | Spawn, bind, later combat fidelity | Listen server + player bot, or SENT with weaker guns |
| SPK-NAV-001 | 7 | Scenario A | Fail `action_failed`; do not teleport |
| SPK-CBT-001 | 8 | Scenario B | Go/no-go; do not add mouse tools |

[SPK-WS-001](technical-spikes.md) (gmad) waits until after M1. Not in this roadmap.

## Explicitly out of this roadmap

Do not sneak these into the eight changes:

- Voice STT/TTS, native module, playermodel picker
- Persistent memory, NPC↔NPC ConversationManager
- DarkRP / Helix adapters
- Model C Companion LLM loops / `providers/`
- Tool Gun inspect, pause/resume, unbind, capability checkboxes
- Steam Workshop publish, SPDX license, public `0.0.0.0` MCP
- `use` / `pickup` / `reload` / `get_entity` (Soon / M2)

Those belong to [milestones.md](milestones.md) M2+ and [v2-backlog.md](v2-backlog.md).

## Assumptions recorded in the changes

- Companion language: Python 3.12 candidate (spike may replace).
- MCP URL: `http://127.0.0.1:8765/mcp`.
- MVP capabilities hardcoded: `observe`, `move`, `chat`, `combat`.
- User starts the Companion; GMod does not spawn it.
- JSON MCP stays embodiment-agnostic.

## How to use this file

1. Read [mvp.md](mvp.md) once.
2. Apply change 1 in worktree `.worktrees/<name>` (one commit per `tasks.md` item). When that change’s tasks are done, open a PR to `main`.
3. After each change, run that change's Scenario/spike verification before opening the next `/opsx-apply`.
4. When 7 is green, Scenario A is the product hypothesis test. When 8 is green, the MVP slice is complete.
