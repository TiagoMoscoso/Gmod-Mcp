# AI Players Companion

**Status:** skeleton only. This process does not host MCP yet — see
[companion-mcp-host](../openspec/changes/companion-mcp-host) for that work.

The Companion is the out-of-process host the MCP client talks to, and the
process that bridges to Garry's Mod. See
[docs/architecture/companion.md](../docs/architecture/companion.md).

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

This prints the protocol version and a message that MCP is not hosted yet,
then exits `0`. It does not bind a port or serve `/mcp`.
