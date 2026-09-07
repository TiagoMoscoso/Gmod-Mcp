# AI Players Companion

The Companion is the out-of-process host the MCP client talks to, and the
process that bridges to Garry's Mod. See
[docs/architecture/companion.md](../docs/architecture/companion.md).

MCP tools currently read a mock, in-memory agent registry (no GMod bridge
yet — see [gmod-companion-bridge](../openspec/changes)).

## Requirements

- Python 3.12+

## Set up a virtual environment

```bash
cd companion
python3 -m venv .venv
source .venv/bin/activate
```

## Install

```bash
pip install -e .
```

## Run

```bash
ai-players-companion
# or: python -m ai_players_companion
```

This serves MCP over Streamable HTTP at `http://127.0.0.1:8765/mcp`, bound
to localhost only (ADR-005). It does not bind `0.0.0.0`: the Companion is a
local, unauthenticated process for MVP, so do not run it on a
publicly-reachable interface.

## Connect an MCP client

Point any Streamable HTTP-capable MCP client at the URL the entrypoint
prints. For example, a Claude Code `.mcp.json` entry:

```json
{
  "mcpServers": {
    "ai-players-companion": {
      "type": "http",
      "url": "http://127.0.0.1:8765/mcp"
    }
  }
}
```

`GET http://127.0.0.1:8765/health` returns `{"protocol_version": "1", "connected": <bool>}` for a quick liveness check without a full MCP handshake.

## Run tests

Companion unit tests run without a Garry's Mod process:

```bash
pip install -e ".[test]"
pytest ../tests/companion
```
