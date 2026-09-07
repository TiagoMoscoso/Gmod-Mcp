"""Requirement: Localhost MCP endpoint (ADR-005).

The Companion MUST bind 127.0.0.1 by default and MUST NOT default to
0.0.0.0, even though FastMCP itself would happily bind any host it is given.
"""

from __future__ import annotations

import pytest

from ai_players_companion.mcp.server import (
    DEFAULT_HOST,
    DEFAULT_PORT,
    DEFAULT_STREAMABLE_HTTP_PATH,
    build_server,
)


def test_default_settings_are_loopback_only():
    app = build_server()

    assert DEFAULT_HOST == "127.0.0.1"
    assert DEFAULT_PORT == 8765
    assert DEFAULT_STREAMABLE_HTTP_PATH == "/mcp"
    assert app.settings.host == "127.0.0.1"
    assert app.settings.host != "0.0.0.0"
    assert app.settings.port == 8765


@pytest.mark.asyncio
async def test_default_host_actually_binds_loopback_not_all_interfaces(run_server):
    """A real socket check: catches a future default drifting to "0.0.0.0" or "" (all interfaces)."""
    app = build_server()
    server = await run_server(app)

    assert server.host == "127.0.0.1"
