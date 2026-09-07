# Risks

**Status:** Identified. Severities are qualitative. No numeric SLOs.

## R-ENG-001 — Transport is blocked by GLua

**Risk:** Private-IP HTTP is blocked; no listen sockets in Lua.  
**Impact:** MVP cannot move actions into GMod.  
**Mitigation:** Spike file IPC vs native socket vs process stdio first ([SPK-TRN-001](technical-spikes.md)).  
**Related:** [OQ-TRN-001](../requirements/open-questions.md#oq-trn-001-gmod-companion-transport).

## R-ENG-002 — Embodiment fork

**Risk:** Player bots fail in singleplayer; NextBots fail at player gunplay.  
**Impact:** Spawn Menu UX vs combat MVP conflict.  
**Mitigation:** [SPK-BOT-001](technical-spikes.md); possibly require listen server for M1.  
**Related:** [OQ-BOT-001](../requirements/open-questions.md#oq-bot-001-embodiment).

## R-ENG-003 — Navmesh

**Risk:** Many maps have no nav. Follow looks broken.  
**Mitigation:** Vertical slice on `gm_construct`; fail with `action_failed` rather than teleport. Fallback locomotion **Open**.

## R-ENG-004 — LLM latency in combat

**Risk:** If the agent re-observes every shot, combat is sluggish.  
**Mitigation:** CombatController runs autonomously after `attack`; agent only starts/stops.  
**Related:** ADR-002.

## R-PROD-001 — Two-install UX

**Risk:** Workshop users subscribe, spawn NPCs, nothing thinks.  
**Impact:** Bad reviews, "broken addon."  
**Mitigation:** Honest popup, Setup Guide to GitHub, never fake MCP online.  
**Related:** ADR-006.

## R-PROD-002 — Workshop auto-update vs Companion lag

**Risk:** Lua updates, Companion does not; silent protocol break.  
**Mitigation:** Handshake + ERROR state ([OQ-DIST-004](../requirements/open-questions.md#oq-dist-004-version-coupling)).

## R-PROD-003 — Native binaries

**Risk:** AV flags, ABI breaks, Linux ds missing `lua/bin`.  
**Mitigation:** No native in MVP; later GitHub Releases, not Workshop-first.

## R-SEC-001 — Open MCP on public servers

**Risk:** Strangers drive combat bots; prompt injection via chat.  
**Mitigation:** Localhost default; public support delayed; capabilities; no lua tools.  
**Related:** [OQ-SEC-001](../requirements/open-questions.md#oq-sec-001-public-server-security).

## R-SEC-002 — Scope creep toward `lua_run`

**Risk:** Contributors add "just one debug execute" tool.  
**Mitigation:** NFR-SEC-001 is accepted; review ADRs.

## R-SEC-003 — License vs Steam

**Risk:** Chosen SPDX license conflicts with Workshop norms or binary deps.  
**Mitigation:** Decide [OQ-DIST-001](../requirements/open-questions.md#oq-dist-001-spdx-license) before going public.

## R-AGT-001 — Orchestration ambiguity

**Risk:** Building Model C loops during M1 stalls Walter-follows.  
**Status:** Reduced. MVP is A; C is a required v2 backlog, not a parallel implementation.  
**Mitigation:** [ADR-007](../architecture/decisions/ADR-007-mvp-model-a-v2-model-c.md), [v2-backlog.md](v2-backlog.md).  
**Related:** [OQ-AGT-001](../requirements/open-questions.md#oq-agt-001-agent-orchestration-model) (CLOSED).

## R-AGT-002 — Conversation loops

**Risk:** NPC↔NPC infinite chat.  
**Mitigation:** Do not ship NPC talk without ConversationManager.

## R-AGT-003 — Token cost

**Risk:** observe-spam bankrupts users or hits rate limits.  
**Mitigation:** Pull observe, caps, [OQ-PERF-001](../requirements/open-questions.md#oq-perf-001-rate-limiting).

## R-OPS-001 — Dedicated Linux ignored

**Risk:** Design only for Windows listen host.  
**Mitigation:** Platform NFR; ds install question kept open, not forgotten.

## R-SCOPE-001 — Over-engineering the framework

**Risk:** Adapters, memory, voice, professions before Walter can walk.  
**Mitigation:** M1 definition of done is tiny; extra folders in docs are maps, not work orders.
