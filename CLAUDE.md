@AGENTS.md

# Claude Code

Claude Code loads this file, not `AGENTS.md`. The import above is the shared source of truth for Cursor, Codex, and Claude Code. Put **Claude-only** routing here. Do not duplicate product rules.

Personal overrides: `CLAUDE.local.md` (gitignored; do not commit). Do not `@`-import `docs/` or `openspec/config.yaml` from this file — those are large and already pointed from `AGENTS.md` / OpenSpec.

## Slash commands (OpenSpec)

Commands live in `.claude/commands/opsx/`. Namespaces become `/opsx:<name>`:

| Command | When |
| --- | --- |
| `/opsx:explore` | Think through an idea. No implementation. |
| `/opsx:propose` | Create a change and all planning artifacts. No production code. |
| `/opsx:update` | Continue or revise artifacts on an existing change. |
| `/opsx:apply` | Implement `tasks.md` for a named change. |
| `/opsx:archive` | Merge delta specs into `openspec/specs/` after apply. |
| `/opsx:sync` | Refresh main specs from a change without the full archive flow. |

Matching skills: `.claude/skills/openspec-*`. Prefer the slash command when the user invokes `/opsx:…`; use the skill when the user describes the same intent in prose.

## Default stance

- Specification-first. If the user asks to build gameplay, MCP, or layout, run the OpenSpec propose flow unless they named an existing change to **apply**.
- Explore and propose are planning-only. Do not start coding in the same turn.
- OpenSpec git: one change → worktree `.worktrees/<name>` on branch `change/<name>`; one `tasks.md` item → one commit; apply complete → PR to `main`. See AGENTS.md.
- Use plan mode for architecture, transport, and embodiment work (`OQ-TRN-001`, `OQ-BOT-001`, new ADRs).
- Do not use Claude-specific APIs, Anthropic SDKs, or Claude-branded MCP tools in GLua or the Companion core. MCP stays provider-agnostic (`ADR-003`).

## Verify

- After editing OpenSpec config or artifacts: `openspec doctor` and `openspec validate` (plus `--specs` when main specs changed).
- In a Claude session, `/context` should list this `CLAUDE.md` under memory files.
