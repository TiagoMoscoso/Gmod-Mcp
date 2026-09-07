# Constraints

Hard limits and non-negotiables. Distinguishes engine facts from product choices.

## Product constraints (**Defined**)

- The agent-facing API is MCP, not a vendor-specific HTTP chat API in GLua.
- Actions are semantic. Frame-level mouse/keyboard tools are out of scope.
- Sandbox is the first supported gamemode. DarkRP/Helix are adapters, not core types.
- Native C++ is not the gameplay layer.
- Voice is not part of the first vertical slice.
- Arbitrary code execution is not an MCP tool.
- The project is intended as public open source on GitHub, with the GLua addon also published to the Steam Workshop.

## Engine and platform constraints (**Defined** as facts)

These are not product preferences. They constrain design.

### GLua cannot host a general TCP MCP server

Vanilla GLua has no supported listening socket API. **Proposed** consequence: the Companion hosts MCP. **Open:** how GMod talks to that Companion.

### `HTTP()` / `http.Fetch` and private IPs

GMod blocks some private-IP HTTP on listen and singleplayer servers. A naive "GLua polls `http://127.0.0.1`" bridge may fail without a workaround. This is a spike, not a solved transport. See [OQ-TRN-001](open-questions.md#oq-trn-001-gmod-companion-transport).

### Player bots cannot spawn in singleplayer

`player.CreateNextBot` consumes a player slot and does not work in true singleplayer. Bots are unauthed, must be removed with `Player:Kick`, and are controlled with `GM:StartCommand` / `CUserCmd`. See [OQ-BOT-001](open-questions.md#oq-bot-001-embodiment).

### Player slots

If embodiment is a player bot, the number of AI Players is bounded by `game.MaxPlayers()` minus human players.

### Navmesh

Pathfinding quality depends on the map's navmesh. `gm_construct` is the vertical-slice map because it typically has one. Missing-mesh policy is **Open**.

### Workshop vs dedicated servers

Steam Workshop auto-install is client/listen oriented. Linux `srcds` operators often install addons from collections or manually. Native modules must be placed in `garrysmod/lua/bin` with platform-specific names (`gmsv_*_win64.dll`, `gmsv_*_linux64.dll`).

### Binary module ABI

GMod binary modules follow Facepunch naming and `garrysmod_common` ABI rules. They are not ordinary DLLs you drop in `addons/`.

## Legal / distribution constraints (**Defined** as goals, details **Open**)

- Public GitHub requires a license ([OQ-DIST-001](open-questions.md#oq-dist-001-spdx-license)).
- Steam Workshop distribution must respect Steam subscriber agreement and chosen license compatibility.
- Do not ship secrets, API keys, or a default open MCP bind on `0.0.0.0` in a public addon.

## Explicit non-constraints

The following look like constraints but are **not** locked:

- Python 3.12, FastAPI, SQLite, whisper.cpp — **candidates** only
- TTS vendor
- Default LLM provider
- Maximum NPC count
- Exact hearing distance
- Autonomous exchange limits for NPC↔NPC talk
