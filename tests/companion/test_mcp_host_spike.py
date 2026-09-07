"""SPK-MCP-001: confirms Streamable HTTP on FastMCP works for a generic client.

No Garry's Mod involved: this drives the Companion's MCP server over a real
loopback socket with the SDK's own client, which is provider-agnostic in the
same way MCP Inspector is (ADR-003).
"""

from __future__ import annotations

import pytest
from mcp import ClientSession
from mcp.client.streamable_http import streamable_http_client

from ai_players_companion.mcp.server import build_server


@pytest.mark.asyncio
async def test_generic_client_can_connect_over_streamable_http(run_server):
    app = build_server(host="127.0.0.1", port=0)
    server = await run_server(app)

    assert server.host == "127.0.0.1"

    async with streamable_http_client(server.url) as (read, write, _get_session_id):
        async with ClientSession(read, write) as session:
            result = await session.initialize()

    assert result.protocolVersion
