# AGENTS.md

Instructions for coding agents (Cursor, Codex, Claude Code via `CLAUDE.md`, and others).
Humans should start at `README.md` and `docs/README.md`.

This is a public open-source project. Write **English** in artifacts, code, comments, docs, commit messages, and UI copy.

## Cold start

1. Read `README.md`, then `docs/README.md` (reading order listed there).
2. Read `openspec/config.yaml` before planning or implementing. It is injected into OpenSpec prompts; do not fork a second copy of it here.
3. Run `openspec list` and `openspec list --specs`. Do not start a parallel change that overlaps an active one.
4. Product truth is `docs/`. Cite IDs (`FR-BOT-001`, `ADR-002`, `OQ-MCP-001`) instead of restating whole documents.
5. Implementation lands through OpenSpec. Do not invent product scope because a directory is empty.

## What this repo is

**GMod AI Players** (provisional name; public name is Open — `OQ-NAME-001`): a Garry's Mod addon/framework. Players attach **external MCP clients** to in-game characters. Agents observe a **filtered** world and issue **semantic actions**. Garry's Mod owns motor control (navmesh, `StartCommand`, aiming). The LLM does not press keys every frame.

```text
MCP client  --MCP-->  Companion  --bridge-->  GMod (GLua [+ future C++ voice])
```

Current stage: specification-first. OpenSpec changes already exist under `openspec/changes/`; apply those instead of scaffolding the same work again.

## Layout

| Path | Role |
| --- | --- |
| `docs/` | Source of truth for product, architecture, ADRs, MVP, v2 |
| `openspec/` | Change proposals, delta specs, project agent context (`config.yaml`) |
| `addon/` | GLua Workshop GMA candidate (create via OpenSpec; do not put Python here) |
| `companion/` | Out-of-process MCP host (GitHub only; Python 3.12 candidate) |
| `tests/` | Companion / protocol tests that must not require Garry's Mod |
| `native/` | Future voice module only — omit until a voice change |

Dual distribution: GitHub is the full monorepo. Steam Workshop ships **only** `addon/`. Companion, docs, and native source never go inside a GMA.

## How to change the project

Use OpenSpec (`schema: spec-driven`): proposal → specs / design → tasks → apply → archive.

| Intent | Cursor | Claude Code | Codex |
| --- | --- | --- | --- |
| Think, do not implement | `/opsx-explore` | `/opsx:explore` | skill `openspec-explore` |
| Plan a change (no code) | `/opsx-propose` | `/opsx:propose` | skill `openspec-propose` |
| Continue artifacts | `/opsx-update` | `/opsx:update` | skill `openspec-update-change` |
| Implement `tasks.md` | `/opsx-apply` | `/opsx:apply` | skill `openspec-apply-change` |
| Merge specs after apply | `/opsx-archive` | `/opsx:archive` | skill `openspec-archive-change` |
| Refresh main specs | `/opsx-sync` | `/opsx:sync` | skill `openspec-sync-specs` |

Skills live in `.cursor/skills/`, `.claude/skills/`, and `.agents/skills/` (same OpenSpec skills, three install targets). Prefer the workflow above over ad-hoc edits.

**Planning is not implementation.** Propose/explore only write OpenSpec artifacts. Wait for an explicit apply (or a clear “implement this change”) before touching `addon/`, `companion/`, or production code.

Skip OpenSpec only for typo/comment fixes that do not change behavior, requirements, or public API. Feature work, MCP surface, layout, and architecture always go through a change.

CLI (repo root): `openspec status --change "<name>" --json`, `openspec instructions <artifact> --change "<name>" --json`, `openspec validate --specs`.

Capability IDs: `<layer>/<capability>` (`repo/…`, `addon/…`, `companion/…`, `protocol/…`). Reuse existing names when modifying.

## Git for OpenSpec changes

Standing authorization while working on a named OpenSpec change (do not wait for a second “please commit”):

| Unit | Git |
| --- | --- |
| One OpenSpec change | One branch `change/<name>` in worktree `.worktrees/<name>` — never `main` |
| One `tasks.md` checkbox | One Conventional Commit |
| All apply tasks done | Push and open a pull request to `main` |

### Isolation (worktree)

Parallel agents must not share a checkout. The primary tree stays on `main` as a hub. Each change runs in its own linked worktree.

Before propose, update, apply, or archive on change `<name>`:

1. Run `git worktree list`. If a worktree already has `change/<name>`, reuse it.
2. Otherwise add `.worktrees/<name>` from an up-to-date `main` (fetch first when the hub tree is clean):
   - Existing branch: `git worktree add ".worktrees/<name>" "change/<name>"`
   - New branch: `git worktree add -b "change/<name>" ".worktrees/<name>" main`
3. If git refuses because the branch is checked out in the primary tree: switch the primary to `main` only when that tree is clean, then retry. If the primary tree is dirty with **unrelated** files, stop.
4. Move the agent workspace to that worktree **before any edits**. In Cursor, call `move_agent_to_root` with the absolute worktree path. Elsewhere, use that directory as cwd for every command.
5. Do not edit the primary checkout for this change. Do not invent a second branch or a second worktree for the same change. Do not `git worktree remove` unless the user asks.
6. Never implement, propose, or archive a change on `main` or in the primary checkout.

### Commits (apply)

After each task: implement, verify, mark `- [x]`, then commit **only** that task (implementation + checkbox). English Conventional Commits (`feat`, `fix`, `docs`, `refactor`, `test`, `chore`). Subject states why; include the task id (for example `1.2`).

Do not batch multiple tasks into one commit. Do not `--no-verify`, `--amend` unless the commit rules allow it, or force-push.

Propose/update: stay in `.worktrees/<name>` and make **one** Conventional Commit when the planning artifacts for that invocation are complete. Do not open a PR until apply is finished unless the user only asked for planning review.

Archive: stay in `.worktrees/<name>`. One Conventional Commit after specs merge; push so the PR updates.

### Pull request

When apply reaches all tasks complete:

1. From `.worktrees/<name>`, `git push -u origin HEAD` if the branch is not on origin.
2. Open a PR targeting `main` with `gh pr create` if none exists for this branch. Return the URL.
3. Suggest archive in the same worktree (another commit on the PR). Do not merge unless the user asks.

Typo/comment fixes that skip OpenSpec still need an explicit commit request. Do not commit secrets.

## Architecture (do not violate)

Locked enough to implement (see ADRs in `docs/architecture/decisions/`):

- **MCP is the only agent API.** No vendor SDK in GLua. No Claude- or OpenAI-specific tools. (`ADR-003`)
- **Cognition ≠ motor control.** Semantic actions in; controllers execute. (`ADR-002`)
- Tools take `agent_id`. Never `walter_move`.
- Missing capability → **reject**, do not execute.
- Sandbox first. DarkRP/Helix are `GameAdapter`s, not core types. (`ADR-004`)
- C++ extends GLua; it does not replace gameplay. (`ADR-001`)
- **MVP = Model A** (external MCP client only). **v2 = Model C** (optional Companion loops on the **same** verbs). Model B is rejected. (`ADR-007`)
- Proposed MCP URL: `http://127.0.0.1:8765/mcp`. Bind loopback. Do not default to `0.0.0.0`. (`ADR-005`)

Status labels in docs: **Defined** / **Proposed** / **Hypothesis** / **Future** / **Open**. Do not silently decide an **Open** question (`docs/requirements/open-questions.md`). Spikes live in `docs/planning/technical-spikes.md`.

## Forbidden

Never add, including as “debug” tools, without a new ADR:

- `execute_lua`, `shell`, `eval`, `run_console_command`, `lua_run`
- Frame-level input: `press_w`, `move_mouse`, `press_attack`
- API keys, LLM vendor secrets, or an unauthenticated public MCP bind
- Companion / Python / docs / native binaries inside the Workshop GMA tree

## Phasing

- **MVP** (`docs/planning/mvp.md`): spawn inactive AI NPC, Tool Gun bind (name + context), MCP popup, chat round-trip, `say`, `follow`, then combat (`equip_weapon`, `attack`) without MCP aim tools. Map: `gm_construct`.
- **MVP tools:** `list_agents`, `get_agent`, `get_agent_status`, `observe`, `get_self`, `get_recent_events`, `move_to`, `follow`, `look_at`, `stop`, `say`, `equip_weapon`, `attack`, `stop_attack`.
- Long actions are **async**: accept work; completion via events (`target_reached`, `action_failed`, `player_said`, …).
- **v2** (`docs/planning/v2-backlog.md`): Companion autonomy loops, provider adapters, Tool Gun playermodel, male/female voice preset. Keep `providers/` empty until a v2 change.
- **Future:** STT, native capture, persistent memory, NPC↔NPC ConversationManager, DarkRP/Helix verbs.
- If a change is only useful for unattended loops, playermodel picking, or voice presets, it is v2 — do not land it in the vertical slice.

Engine facts: vanilla GLua cannot host MCP HTTP; GMod may block private-IP HTTP (`OQ-TRN-001`); `player.CreateNextBot` fails in true singleplayer (`OQ-BOT-001`); no navmesh → document, do not teleport; SPDX license is Open (`OQ-DIST-001`) — do not invent MIT/GPL.

## Engineering bar

- **SOLID:** one reason to change per module; extend via adapters, capabilities, and new controllers — not a god dispatcher. Depend on protocols (MCP tools, `GameAdapter`, registry), not vendor SDKs or DarkRP types.
- **Clean code:** small functions, intention-revealing names, no dead code, no magic strings for tool names / `agent_id`.
- **Patterns only where they fit:** Adapter (`GameAdapter`), Command (semantic actions), Strategy (movement/combat/look controllers), Registry (`agent_id` → AI Player), Observer (events → `observe` / `get_recent_events`), Facade (MCP tools in front of the bridge).
- Comments explain **why**, invariants, and engine constraints — not the next line. Public modules and MCP tools get brief docs (purpose, params, errors, phase).
- Tests prove spec behavior. Companion tests must run **without** Garry's Mod.
- Fail closed on protocol mismatch, missing Companion, or denied capability.
- Conventional Commits in English: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`. OpenSpec apply is standing authorization for one worktree per change, one commit per task, and a PR to `main` (see **Git for OpenSpec changes**). Other work still waits for an explicit commit request.

## Commands (when the trees exist)

There is no production addon/Companion in a docs-only checkout. After `scaffold-monorepo` / Companion apply:

- Companion: follow `companion/README.md` (expected: Python 3.12, `pyproject.toml`).
- GLua: load `addon/` as a GMod addon; do not invent a Python runtime inside GMod.
- Prefer `openspec validate` and package unit tests over in-engine guesses.

Do not add CI, LICENSE, or Workshop publish as drive-by work (`OQ-DIST-001` is still Open).

## Glossary (keep these words)

**AI Player**, **Agent**, **Agent ID**, **Companion**, **Controller**, **Capability**, **GameAdapter**, **MCP**, **semantic action**, **persona/context**. Definitions: `docs/glossary.md`.
