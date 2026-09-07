"""Assembles the Companion's MCP server.

SPK-MCP-001 confirmed Streamable HTTP on the official Python MCP SDK's
FastMCP class works with a generic client on 127.0.0.1 (see
docs/architecture/companion.md). ADR-003 forbids vendor-specific tools, so
`build_server` returns a plain FastMCP app: any MCP-compatible client can
speak to it.
"""

from __future__ import annotations

from mcp.server.fastmcp import FastMCP

# Matches the proposed URL in ADR-005 and the in-game popup. Never pass
# host="0.0.0.0" here for the MVP default: the Companion is a local,
# unauthenticated process (docs/architecture/companion.md Security posture).
DEFAULT_HOST = "127.0.0.1"
DEFAULT_PORT = 8765
DEFAULT_STREAMABLE_HTTP_PATH = "/mcp"


def build_server(
    *,
    host: str = DEFAULT_HOST,
    port: int = DEFAULT_PORT,
    streamable_http_path: str = DEFAULT_STREAMABLE_HTTP_PATH,
) -> FastMCP:
    """Build a provider-agnostic FastMCP app bound to `host`/`port`."""
    return FastMCP(
        name="ai-players-companion",
        host=host,
        port=port,
        streamable_http_path=streamable_http_path,
    )
