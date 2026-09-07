# Open questions

Decisions that must not be made silently. Each item is **Open** unless later closed by an ADR.

Template: question, context, options, trade-offs, impact, when it must be decided.

**Recently closed:** [OQ-AGT-001](#oq-agt-001-agent-orchestration-model) — MVP Model A, v2 Model C required. [ADR-007](../architecture/decisions/ADR-007-mvp-model-a-v2-model-c.md), [v2-backlog.md](../planning/v2-backlog.md).

---

## Product identity

### OQ-NAME-001 — Final project name

**Status:** OPEN

**Question:** What is the public name (GitHub repo, Workshop title, Lua namespace)?

**Context:** "GMod AI Players" is provisional. Workshop search, GitHub slug, and `addon/` folder names should eventually match.

**Options:**

- Keep GMod AI Players
- Shorter brand (example shapes only: AI Players, MCP Bots — not recommendations)
- Codename now, rename before first Workshop publish

**Trade-offs:** Early Workshop/GitHub names are costly to change; Lua include paths even more so.

**Impact:** Repo name, Workshop metadata, addon identifier, documentation titles.

**Decision required:** before first public GitHub and Workshop listing.

---

### OQ-DIST-001 — SPDX license

**Status:** OPEN

**Question:** Which license covers the monorepo (and is it the same for Lua, Python, and C++)?

**Context:** Public GitHub is a **Defined** goal. Steam Workshop publish must be compatible with that license. Some licenses complicate binary modules or Steam distribution.

**Options:**

- MIT (permissive, easy reuse, including closed server packs)
- Apache-2.0 (patent clause)
- GPL-3.0 / LGPL (copyleft; Workshop and mixed binaries get harder)
- Dual license

**Trade-offs:** Permissive licenses maximize adoption; copyleft may deter some server networks; Steam's terms plus GPL is a known tension.

**Impact:** CONTRIBUTING, GitHub publish, Workshop legal text, third-party Companion reuse.

**Decision required:** before the repository is public.

---

## Distribution

### OQ-DIST-002 — Workshop payload

**Status:** OPEN

**Question:** What exactly goes into the Steam Workshop GMA?

**Context:** Workshop is excellent for GLua. Python cannot run from a GMA. Native modules in `lua/bin` are awkward on Workshop and platform-specific.

**Options:**

- Lua-only GMA (recommended **hypothesis**)
- Lua + materials/models/sounds
- Lua + native binaries (discouraged until proven)

**Trade-offs:** Lua-only keeps Workshop simple but Workshop-only users cannot talk to MCP until they install the Companion another way. Shipping DLLs in Workshop is fragile (AV, ABI, Linux ds).

**Impact:** [distribution.md](../planning/distribution.md), UX for missing Companion, release automation.

**Decision required:** before first Workshop upload; Lua-only can be the working assumption for docs.

---

### OQ-DIST-003 — How Workshop users get the Companion

**Status:** OPEN

**Question:** After subscribing on Steam, how does the user install and update the Companion?

**Context:** MCP will not run from GLua alone ([ADR-005](../architecture/decisions/ADR-005-mcp-hosted-by-companion.md) is **Proposed**).

**Options:**

- Documented manual install from GitHub (pip / venv)
- GitHub Releases with OS-specific binaries
- Optional installer / helper
- Companion as a separate non-Workshop download only
- Future: Steam-unrelated package managers

**Trade-offs:** Manual pip is honest but hostile to casual Workshop users. Frozen binaries raise signing, AV, and update problems.

**Impact:** Popup Setup Guide, onboarding drop-off, support burden.

**Decision required:** before claiming the Workshop listing is "playable" end-to-end.

---

### OQ-DIST-004 — Version coupling

**Status:** OPEN

**Question:** How must addon and Companion versions relate?

**Context:** Workshop auto-updates Lua. Companion does not. A newer addon talking an old Companion (or the reverse) will happen.

**Options:**

- Explicit protocol version in handshake; refuse on mismatch
- Backward-compatible protocol with feature flags
- Independent semver with a compatibility matrix in docs only

**Trade-offs:** Strict refuse is safe and annoying. Soft matrix is flexible and error-prone.

**Impact:** NFR-DIST-002, ERROR states, release process.

**Decision required:** before the second independently versioned release.

---

### OQ-DIST-005 — Native module distribution channel

**Status:** OPEN

**Question:** When the voice module exists, where do `gmsv_aivoice_*.dll` files come from?

**Context:** Modules live in `garrysmod/lua/bin`, not in a normal addon folder. Workshop inclusion is unreliable across Windows/Linux and client/server.

**Options:**

- GitHub Releases only
- Separate Workshop item (usually a bad fit)
- Bundled with Companion installer
- Not distributed until operators build from source

**Trade-offs:** Source-only is safest and least adopted. Releases need CI per ABI.

**Impact:** Voice milestone, Linux `srcds`, antivirus false positives.

**Decision required:** before native voice leaves "spike" status.

---

### OQ-DIST-006 — Dedicated server install path

**Status:** OPEN

**Question:** What is the supported install story for Linux `srcds`?

**Context:** Collections, FastDL, and `lua/bin` differ from a Windows listen-server Workshop subscribe.

**Options:**

- Git clone / release tarball documented for ds only
- Workshop collection + manual Companion
- Docker-style examples (may be overkill)

**Trade-offs:** Two install stories (listen vs dedicated) are inevitable; more than two is a docs failure.

**Impact:** Operators, [OQ-UX-001](#oq-ux-001-local-vs-dedicated-server-ux).

**Decision required:** before advertising dedicated-server support.

---

### OQ-DIST-007 — Workshop metadata

**Status:** OPEN

**Question:** Title, tags, thumbnail, visibility, required items?

**Context:** Not needed to write the specification. Needed to publish.

**Options:** n/a until branding ([OQ-NAME-001](#oq-name-001-final-project-name)).

**Decision required:** at first Workshop publish. Not an architecture blocker.

---

## MCP and transport

### OQ-MCP-001 — MCP authentication

**Status:** OPEN

**Question:** How is the MCP endpoint protected?

**Context:** A local `127.0.0.1` bind is a different threat model than `0.0.0.0` on a rented box. Public unauthenticated MCP would let strangers drive bots.

**Options:**

- Localhost only, no auth (dev/Sandbox)
- Shared token / bearer
- mTLS
- Operator-configured bind + firewall only

**Trade-offs:** Zero auth is fine on loopback and reckless on the public Internet.

**Impact:** Popup URL, dedicated servers, NFR-SEC-003.

**Decision required:** before any non-localhost bind is documented as supported.

---

### OQ-MCP-002 — Session-scoped vs `agent_id`

**Status:** OPEN

**Question:** Does every tool take `agent_id`, or can a session be bound to one AI Player?

**Context:** Spec currently prefers `move_to(agent_id, target)`. A client that *is* Walter might want implicit identity.

**Options:**

- Always explicit `agent_id` (simpler server, more tokens)
- `select_agent` then implicit
- One MCP connection per AI Player

**Trade-offs:** Explicit IDs multiplex well in one Claude Code session. Implicit IDs fit autonomous per-NPC processes.

**Impact:** MCP schema, [OQ-AGT-001](#oq-agt-001-agent-orchestration-model).

**Decision required:** before MCP schema freeze; MVP can use explicit `agent_id` as **Proposed**.

---

### OQ-MCP-003 — MCP transport flavor

**Status:** OPEN

**Question:** stdio vs Streamable HTTP vs SSE for the agent-facing MCP?

**Context:** Claude Code and other clients differ in what they prefer. The example URL is HTTP.

**Options:**

- Streamable HTTP at `/mcp` (**Proposed** to match the popup)
- stdio for local-only
- Both

**Trade-offs:** HTTP matches remote dedicated servers; stdio matches local process spawning.

**Impact:** Companion, Setup Guide.

**Decision required:** before Companion spike completes.

---

### OQ-TRN-001 — GMod ↔ Companion transport

**Status:** OPEN

**Question:** How do GLua and the Companion exchange actions, events, and state?

**Context:** GLua cannot listen. Private-IP HTTP is often blocked on listen/SP. Existing GMod MCP bridges use file IPC under `garrysmod/data/`. Binary websocket modules exist but add Workshop/ABI cost.

**Options:**

- File-based IPC (GMA-friendly, no extra DLL)
- GLua HTTP client to Companion (may fail on 127.0.0.1)
- Native socket / websocket module
- `gm_process`-style stdio to a child Companion

**Trade-offs:** Files are clumsy but proven. HTTP is clean when allowed. Native sockets help voice later but poison Lua-only Workshop.

**Impact:** Entire runtime, MVP feasibility, [technical-spikes.md](../planning/technical-spikes.md).

**Decision required:** before implementing the vertical slice. Highest-priority spike.

---

### OQ-TRN-002 — MCP local vs remote in production

**Status:** OPEN

**Question:** Is production MCP always on the game host, or can it sit on another machine?

**Context:** Listen server: Companion on the same PC. Dedicated: Companion on the box, or a remote operator's laptop (probably a bad idea).

**Options:**

- Same host only
- Same LAN with auth
- Arbitrary remote (reverse tunnel)

**Trade-offs:** Remote MCP multiplies auth and latency issues.

**Impact:** UX popup, security.

**Decision required:** before dedicated-server production claims.

---

## Agents

### OQ-AGT-001 — Agent orchestration model

**Status:** CLOSED

**Question:** Who "is" the agent for each NPC?

**Resolution:**

- **MVP = Model A.** One external MCP client multiplexes all AI Players via `agent_id`. The Companion does not call an LLM.
- **v2 = Model C (required).** Keep A as the default and **must** add optional Companion-hosted autonomy loops on the same semantic verbs. See [v2-backlog.md](../planning/v2-backlog.md) and [ADR-007](../architecture/decisions/ADR-007-mvp-model-a-v2-model-c.md).
- **Model B rejected** as the destination (Companion-only cognition, MCP as debug).

**Closed:** 2026-09-06

Remaining v2 sub-questions (providers, loop vs client precedence, cost) stay **Open** on [OQ-AGT-002](#oq-agt-002-default-autonomy), [OQ-AGT-003](#oq-agt-003-llm-cost-model), and the v2 backlog — they must not reopen A for MVP.

---

### OQ-AGT-002 — Default autonomy

**Status:** OPEN

**Question:** When ACTIVE, does the character act only when the agent calls tools, or also idle/wander?

**Context:** Tool Gun may expose an Autonomy field.

**Options:**

- Fully tool-driven (idle until a tool call)
- Low-autonomy idle animations only
- Goal-driven loop inside Companion

**Tied to:** [OQ-AGT-001](#oq-agt-001-agent-orchestration-model) (CLOSED: MVP is tool-driven Model A). Idle animations vs v2 loop autonomy remain **Open**. v2 loops must not be designed as default wander in MVP.

**Decision required:** before shipping an Autonomy control; MVP can be tool-driven.

---

### OQ-AGT-003 — LLM cost model

**Status:** OPEN

**Question:** Who pays for tokens, and how aggressive is observation?

**Context:** Combat and chatter can spam `observe`. MVP (Model A) has no in-repo LLM: the user's MCP client pays. v2 Model C reopens Companion-side keys.

**Options:**

- Entirely the user's MCP client (**Defined** for MVP)
- Companion-side provider keys (**v2**, when loops exist)
- Hard rate limits regardless (still **Open** for both phases)

**Decision required:** v2 before shipping unattended loops or public servers. Not an MVP blocker.

---

## Bots / GMod runtime

### OQ-BOT-001 — Embodiment

**Status:** OPEN

**Question:** Player bot, NextBot SENT, NPC, or hybrid?

**Context:** `player.CreateNextBot` matches `StartCommand` / weapons / follow-as-player, but **fails in singleplayer** and consumes slots. Spawn-menu "NPC" UX suggests a SENT. Vertical slice wants player-like combat.

**Options:**

- Player bots only (require listen/dedicated, `maxplayers > 1`)
- NextBot SENT only (better SP, weaker gunplay)
- Hybrid: SENT in SP, player bot when slots exist
- Spawn as SENT visually, possess a bot underneath (**Hypothesis**)

**Trade-offs:** This is the largest GMod-technical fork in the project.

**Impact:** Spawn Menu, slot limits, weapon sandbox, Kick-vs-Remove, singleplayer story.

**Decision required:** before bot spawn implementation. Spike **SPK-BOT-001**.

---

### OQ-BOT-002 — Behavior without an agent

**Status:** OPEN

**Question:** What does a bound AI Player do if no MCP client is connected?

**Context:** States WAITING_FOR_AGENT and DISCONNECTED.

**Options:**

- Freeze / idle
- Fall back to trivial NextBot wander
- Despawn
- Keep last controller action until it finishes, then idle

**Impact:** UX, safety (bots with guns).

**Decision required:** before multi-user Sandbox playtests.

---

### OQ-BOT-003 — Max AI Player count

**Status:** OPEN

**Question:** What is the cap?

**Context:** Player-slot embodiment implies a hard cap. NextBots are softer but still CPU/navmesh bound. Do not invent a number now.

**Options:** slot-derived vs configurable vs "until it lags"

**Decision required:** before public servers; not needed for one-Walter MVP.

---

### OQ-BOT-004 — Persistence across maps / sessions

**Status:** OPEN

**Question:** Do name, persona, memory, and `agent_id` survive `changelevel` and server restart?

**Context:** Memory is **Future**. Even persona bind might reset on map change.

**Options:**

- Session-only (MVP **Proposed**)
- SQLite per server
- Per-map vs global identities

**Decision required:** after MVP; before memory milestone.

---

## Actions and performance

### OQ-ACT-001 — Action queue / concurrency

**Status:** OPEN

**Question:** Can an AI Player have two semantic actions at once (`follow` + `say` vs `move_to` + `attack`)?

**Context:** Chat-and-walk should work. Two navigations should not.

**Options:**

- One locomotion action + one speech action in parallel (**Hypothesis**)
- Strict single action
- Priority preemption (`attack` cancels `follow`)

**Impact:** Controller design, MCP accept/reject.

**Decision required:** during movement/combat controller spike; MVP can allow say ∥ follow.

---

### OQ-PERF-001 — Rate limiting

**Status:** OPEN

**Question:** How often may `observe` / actions fire?

**Context:** Prevent tick-rate LLM spam and GMod hitching.

**Options:** token bucket per agent, min interval, server cvar

**Do not lock numbers yet.**

**Decision required:** before more than one AI Player in combat.

---

## Perception, conversation, memory, voice

### OQ-PER-001 — Perception caps

**Status:** OPEN

**Question:** Exact distance, max entities, LOS rules, ranking?

**Context:** Principle is bounded snapshots. Values are not chosen.

**Decision required:** during perception implementation; start with conservative hard caps in code, document after playtest.

---

### OQ-CNV-001 — ConversationManager parameters

**Status:** OPEN

**Question:** Hearing distance, cooldown, max autonomous exchanges, interest score, timeout?

**Context:** NPC↔NPC is **Future**. Do not freeze numbers.

**Decision required:** before NPC↔NPC implementation.

---

### OQ-MEM-001 — Memory model

**Status:** OPEN

**Question:** What is stored, where, and what is recalled into context?

**Context:** SQLite is a **candidate**. Alternatives: files, nothing until later, vector store (probably overkill).

**Options:** see [memory.md](../design/memory.md).

**Decision required:** before memory milestone, not before MVP.

---

### OQ-VOI-001 — STT engine

**Status:** OPEN

**Question:** whisper.cpp vs cloud STT vs other local models?

**Context:** Voice is **Future**. whisper.cpp is a candidate only.

**Decision required:** before Player→NPC voice.

---

### OQ-VOI-002 — TTS engine

**Status:** OPEN

**Context:** v2 Tool Gun must offer at least male and female output voices ([v2-backlog.md](../planning/v2-backlog.md) C7). The engine behind those labels is still unset.

**Options:**

- Local TTS
- Cloud TTS
- Provider-dependent / user-configured

**Decision required:** before NPC→Player voice output (v2 C7), not before MVP chat `say`.

---

### OQ-VOI-003 — Audio format and transport

**Status:** OPEN

**Question:** PCM rate/channels, Opus keep-or-decode, how audio leaves the native module?

**Decision required:** during native voice spike.

---

### OQ-VOI-004 — Source voice packet injection

**Status:** OPEN (investigation only)

**Question:** Should NPC speech ever become a real Source voice packet?

**Context:** Positional `EmitSound` is the planned first output. Injection is **not** an initial requirement.

**Decision required:** only if positional sound is insufficient. Treat as research.

---

## UX, permissions, platforms, security

### OQ-UX-001 — Local vs dedicated server UX

**Status:** OPEN

**Question:** What does the MCP popup show on a remote dedicated server?

**Context:** `127.0.0.1` is correct for a local Companion and wrong for a player connecting from elsewhere. Operators vs in-game players have different needs.

**Options:**

- In-game popup only on listen host
- Server console + config file for ds
- Separate "operator web UI" (**probably overkill**)

**Decision required:** before dedicated support.

---

### OQ-UX-002 — Tool Gun unbind

**Status:** OPEN

**Question:** How does the user unbind/reset an AI Player?

**Options:** alternate fire combo, C-panel button, undo spawn, `Kick` for player bots

**Decision required:** before Tool Gun polish; MVP can omit unbind if respawn is enough.

---

### OQ-UX-003 — Final UI

**Status:** OPEN

**Question:** Final layout, localization, Derma vs spawnlist, etc.

**Decision required:** ongoing; not an MVP blocker beyond bind + popup.

---

### OQ-CAP-001 — Permission system

**Status:** OPEN

**Question:** How are capabilities granted? Per NPC, per server, per admin group?

**Context:** Principle of explicit capabilities is **Defined**. Schema and UI are not.

**See:** [capabilities.md](../design/capabilities.md).

**Decision required:** before public servers; MVP can hardcode a Sandbox allow-list.

---

### OQ-PLT-001 — Windows / Linux support

**Status:** OPEN

**Question:** Which OS is first-class for Companion and (later) native modules?

**Context:** Many hosts play on Windows; many dedicated servers are Linux.

**Options:** Windows-first Companion, Linux ds first, both from day one

**Decision required:** before Companion packaging.

---

### OQ-SEC-001 — Public server security

**Status:** OPEN

**Question:** What is the threat model when this runs on a public Sandbox/RP server?

**Context:** MCP drive-by, prompt injection via chat, combat griefing, resource exhaustion.

**Options:** localhost MCP + admin-only bind, capability lockdown, never support public until review

**Decision required:** before any public-server claim. Out of MVP.

---

### OQ-GM-001 — Gamemode compatibility bar

**Status:** OPEN

**Question:** What does "Sandbox-first" mean when a server runs Sandbox-derived modes?

**Context:** Many servers are TTT, Prop Hunt, or heavily modified Sandbox.

**Decision required:** when the first adapter is designed; core should feature-detect, not assume vanilla hooks forever.
