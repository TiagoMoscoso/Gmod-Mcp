"""Requirement: Protocol version handshake (docs/architecture/companion.md).

`/health` exposes PROTOCOL_VERSION so the in-game popup (or any client) can
confirm the Companion speaks the expected bridge protocol before relying on
it, without needing a full MCP handshake.
"""

from __future__ import annotations

import httpx
import pytest

from ai_players_companion.agents.registry import AgentRegistry
from ai_players_companion.mcp.server import build_server
from ai_players_companion.protocol import PROTOCOL_VERSION


@pytest.mark.asyncio
async def test_health_reports_protocol_version_and_no_connected_client():
    app = build_server(AgentRegistry())
    transport = httpx.ASGITransport(app=app.streamable_http_app())

    async with httpx.AsyncClient(transport=transport, base_url="http://testserver") as client:
        response = await client.get("/health")

    assert response.status_code == 200
    assert response.json() == {"protocol_version": PROTOCOL_VERSION, "connected": False}


def test_protocol_version_matches_the_scaffold_constant():
    assert PROTOCOL_VERSION == "1"
