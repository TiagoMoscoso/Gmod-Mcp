# Product vision

**Status:** **Defined** for intent; name, license, and exact packaging remain **Open** where noted.

## One-sentence pitch

GMod AI Players is a Garry's Mod addon and framework that lets players attach external AI agents, via MCP, to in-game characters that perceive the world and act through high-level semantic actions.

## Problem

Sandbox and roleplay servers already spawn NPCs and bots. Those characters are either scripted, NextBot-dumb, or fully player-controlled. There is no clean, provider-agnostic way to:

- give a character a persona;
- let an external agent observe a **filtered** slice of the world;
- let that agent issue **game-meaningful** actions;
- keep motor control inside Garry's Mod;
- support several such characters at once;
- extend the same core into DarkRP, Helix, or other gamemodes later.

Existing GMod MCP experiments often expose arbitrary Lua execution. That is useful for developers and unacceptable as a default for this product. See [NFR-SEC-001](../requirements/non-functional-requirements.md).

## Audience

| Audience | What they want |
| --- | --- |
| Sandbox players | Spawn a character, bind a persona, talk to it, have it follow and fight |
| Server operators | Dedicated-server install, capability limits, no silent RCE surface |
| Addon developers | Adapters, new capabilities, gamemode plugins without forking core |
| Agent authors | A stable MCP tool set, not a Claude-specific or OpenAI-specific API |

## Product principles

1. **MCP is the agent interface.** The core does not call a vendor SDK from GLua. **Defined.**
2. **Cognition ≠ motor control.** The LLM never drives per-frame inputs. **Defined.** See [ADR-002](../architecture/decisions/ADR-002-semantic-actions.md).
3. **Provider-agnostic.** Claude Code, Codex, and other MCP clients are examples, not dependencies. **Defined.** See [ADR-003](../architecture/decisions/ADR-003-provider-agnostic-mcp.md).
4. **Sandbox first, adapters later.** Core verbs stay gamemode-neutral. **Defined.** See [ADR-004](../architecture/decisions/ADR-004-sandbox-first-adapters.md).
5. **C++ extends GLua; it does not replace it.** Native code is for things GLua cannot do well (especially voice). **Defined** as principle; native work is **Future**.
6. **Capability-based agency.** Agents only get tools the AI Player is allowed to use. **Defined** as security principle; the permission UI is **Open**.
7. **Framework, not a one-off NPC.** New capabilities, professions, adapters, voices, and providers should be additive. **Defined** as direction; avoid over-engineering the MVP.
8. **Public dual distribution.** GitHub is the full project; Steam Workshop is the GLua install channel. **Defined.** See [ADR-006](../architecture/decisions/ADR-006-dual-distribution.md).

## Central proposal (user-facing)

The addon initializes an integration layer. A popup tells the user where MCP is reachable, for example:

```text
http://127.0.0.1:8765/mcp
```

**Proposed:** that URL is served by the Companion, not by GLua. **Open:** transport, bind address, and authentication. See [ADR-005](../architecture/decisions/ADR-005-mcp-hosted-by-companion.md) and [OQ-MCP-001](../requirements/open-questions.md#oq-mcp-001-mcp-authentication).

The user configures any MCP client, spawns an AI NPC from the Spawn Menu, configures it with the Tool Gun, and binds it. Multiple AI Players can exist, each with its own name and context. **MVP:** that MCP client is the only thinker ([ADR-007](../architecture/decisions/ADR-007-mvp-model-a-v2-model-c.md)). Unattended Companion loops are **v2**, required: [v2-backlog.md](../planning/v2-backlog.md).

Example personas (illustrative, not requirements):

- **Walter** — grumpy sarcastic mechanic; likes machines and cars.
- **Sarah** — calm pragmatic medic; avoids violence and helps the injured.

They must be able to coexist as independent agents. NPC-to-NPC conversation is **Future**.

## Success for the first slice

If a player on `gm_construct` can bind Walter, say "Walter come with me," hear a chat reply, and be followed — and in a second test get Walter to attack a designated NPC — the core hypothesis is validated. See [mvp.md](../planning/mvp.md).

## Out of vision for v1 thinking

These remain interesting but are not the product's identity:

- Replacing NextBot AI in general
- Being a generic GMod Lua REPL for coding agents
- Being a full RP gamemode
- Injecting fake Source voice packets as a launch requirement
