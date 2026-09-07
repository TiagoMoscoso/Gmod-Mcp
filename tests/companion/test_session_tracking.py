"""Requirement: Session awareness.

`Server.run()` enters a fresh lifespan per session for both real Streamable
HTTP sessions and the SDK's in-memory test transport, so exercising this
over the in-memory harness proves the same connect/disconnect boundary a
real client triggers, without a socket or GMod.
"""

from __future__ import annotations

import pytest
from mcp.shared.memory import create_connected_server_and_client_session

from ai_players_companion.agents.registry import AgentRegistry
from ai_players_companion.mcp.server import build_server


def test_session_starts_disconnected():
    app = build_server(AgentRegistry())

    assert app.session.is_connected is False


@pytest.mark.asyncio
async def test_session_flips_connected_then_disconnected_around_a_client():
    app = build_server(AgentRegistry())

    assert app.session.is_connected is False

    async with create_connected_server_and_client_session(app):
        assert app.session.is_connected is True

    assert app.session.is_connected is False
