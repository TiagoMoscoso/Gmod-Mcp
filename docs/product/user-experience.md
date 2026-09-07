# User experience

**Status:** **Defined** for the intended loop; many control bindings, copy, and remote-server flows are **Proposed** or **Open**.

## Primary loop (Sandbox, local)

**Defined** sequence:

1. User starts the server or listen session.
2. The addon initializes its integration layer.
3. A popup reports that the MCP endpoint is available (example: `http://127.0.0.1:8765/mcp`).
4. The user configures Claude Code, Codex, or another MCP client.
5. Spawn Menu: `NPCs > AI Players > AI NPC`.
6. User places an AI NPC on the map.
7. The NPC is born **INACTIVE** — no autonomy.
8. User selects the addon's Tool Gun.
9. In the tool's C-panel the user sets at least name and context/persona. Playermodel, voice (male/female), autonomy, and capabilities are **v2** or later — see [v2-backlog.md](../planning/v2-backlog.md).
10. User left-clicks the NPC.
11. The NPC is registered as an AI Player.
12. The connected agent can observe and control that NPC.
13. Several NPCs may exist at once, each with its own persona.

**Proposed:** the popup also shows Companion connection state (`Connected` / `Disconnected`) and buttons `Copy MCP URL` and `Setup Guide`.

**Open:** local Sandbox vs dedicated remote server need different UX. A `127.0.0.1` URL is useless to a remote MCP client. See [OQ-UX-001](../requirements/open-questions.md#oq-ux-001-local-vs-dedicated-server-ux).

## MCP status popup

**Proposed** copy:

```text
AI PLAYERS

MCP Server Online

Endpoint:
http://127.0.0.1:8765/mcp

[ Copy MCP URL ]
[ Setup Guide ]

Agent:
Connected / Disconnected
```

**Proposed** extra states to design, not specified in detail yet:

- Companion not installed (Workshop-only user)
- Companion installed but not running
- Protocol version mismatch between addon and Companion
- MCP bound but no client connected
- MCP client connected

The Setup Guide **Proposed** points at the GitHub README, because the Companion does not ship in the Workshop GMA. See [distribution.md](../planning/distribution.md).

## Spawn Menu

**Defined** information architecture:

```text
NPCs
└── AI Players
    └── AI NPC
```

Additional spawnables (medic preset, hostile preset) are **Future**.

## Tool Gun

**Defined:** a Tool Gun is the bind/configure surface for an AI NPC.

**Proposed** C-panel fields:

| Field | MVP | Notes |
| --- | --- | --- |
| Name | yes | Character display name |
| Context | yes | Persona prompt / brief |
| Player model | **v2** | Body other players see. Catalog **Open**. [C6](../planning/v2-backlog.md) |
| Voice | **v2** | Multiplayer speech preset. At least male and female. [C7](../planning/v2-backlog.md) |
| Autonomy | **v2** | Related to Model C loops; default **Open** |
| Capabilities | later | **Proposed** after vertical slice |

MVP example:

```text
Name:
Walter

Context:
You are Walter, a grumpy, sarcastic,
and extremely competent mechanic.
```

**v2** C-panel **must** add, in addition to name and context:

```text
Player model:
[ select model ]

Voice:
( ) Male
( ) Female
```

Exact model list and extra named voices are **Open**. Male/female as the minimum voice split is **Defined**. TTS engine is still [OQ-VOI-002](../requirements/open-questions.md#oq-voi-002-tts-engine).

### Mouse bindings

**Proposed** (not locked):

| Input | Action |
| --- | --- |
| Left click | Bind / apply configuration to NPC |
| Right click | Inspect AI NPC (status, persona, last error) |
| Reload | Pause / resume |
| Alternative combo | Unbind / reset — **Open** |

See [OQ-UX-002](../requirements/open-questions.md#oq-ux-002-tool-gun-unbind).

Inspect is **Proposed** for soon-after-MVP; the vertical slice only needs bind.

## Inactive vs bound

Until bind, the entity must not start an agent loop. **Defined.**

What the entity looks like while INACTIVE (frozen statue, idle animation, default NextBot) is **Open**. See [OQ-BOT-002](../requirements/open-questions.md#oq-bot-002-behavior-without-agent).

## Multi-character

**Defined:** several AI Players may be registered at once. Each has its own name, context, and `agent_id`.

**MVP (Model A):** one external MCP client drives them all through `agent_id`. How the *client* prompts itself to juggle Walter vs Sarah is a prompting concern, not a second GMod API.

**v2:** optional Companion loops so characters can think without that client. See [v2-backlog.md](../planning/v2-backlog.md).

## Chat

**Defined** for MVP: player typed chat can be delivered as an event the agent may act on. The agent replies with `say`.

Voice in and out is **v2** for selectable output presets (male/female) and **Future** for STT capture. NPC-to-NPC hearing is **Future**.

## Failure UX

**Proposed** surfaces (no final art):

- ERROR state visible on inspect
- DISCONNECTED when the Companion or MCP client drops
- Chat or overlay hint if the user talks to an unbound NPC

Exact UI chrome is **Open**. See [OQ-UX-003](../requirements/open-questions.md#oq-ux-003-final-ui).
