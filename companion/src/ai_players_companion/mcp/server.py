"""Assembles the Companion's MCP server.

SPK-MCP-001 confirmed Streamable HTTP on the official Python MCP SDK's
FastMCP class works with a generic client on 127.0.0.1 (see
docs/architecture/companion.md). ADR-003 forbids vendor-specific tools, so
`build_server` returns a plain FastMCP app: any MCP-compatible client can
speak to it.
"""

from __future__ import annotations

from mcp.server.fastmcp import FastMCP

from ai_players_companion.agents.registry import AgentRegistry
from ai_players_companion.mcp.catalog import (
    assert_no_character_scoped_tools,
    assert_no_forbidden_tools,
    registered_tool_names,
)
from ai_players_companion.mcp.tools import register_management_tools

# Matches the proposed URL in ADR-005 and the in-game popup. Never pass
# host="0.0.0.0" here for the MVP default: the Companion is a local,
# unauthenticated process (docs/architecture/companion.md Security posture).
DEFAULT_HOST = "127.0.0.1"
DEFAULT_PORT = 8765
DEFAULT_STREAMABLE_HTTP_PATH = "/mcp"


def build_server(
    registry: AgentRegistry | None = None,
    *,
    host: str = DEFAULT_HOST,
    port: int = DEFAULT_PORT,
    streamable_http_path: str = DEFAULT_STREAMABLE_HTTP_PATH,
) -> FastMCP:
    """Build a provider-agnostic FastMCP app bound to `host`/`port`.

    `registry` defaults to an empty `AgentRegistry` (the mock backing store;
    `gmod-companion-bridge` will pass a bridge-backed one instead).
    """
    app = FastMCP(
        name="ai-players-companion",
        host=host,
        port=port,
        streamable_http_path=streamable_http_path,
    )
    registry = registry if registry is not None else AgentRegistry()
    register_management_tools(app, registry)
    catalog = registered_tool_names(app)
    assert_no_forbidden_tools(catalog)
    assert_no_character_scoped_tools(
        tool_names=catalog,
        agent_names=[record.name for record in registry.list_agents()],
    )
    return app
