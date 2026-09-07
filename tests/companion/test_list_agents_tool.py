"""Requirement: Character-agnostic management tools — `list_agents`.

Uses the MCP SDK's in-memory client/server harness: a real `ClientSession`
against the real FastMCP app, without any socket or GMod process.
"""

from __future__ import annotations

import json

import pytest
from mcp.shared.memory import create_connected_server_and_client_session

from ai_players_companion.agents.registry import AgentRecord, AgentRegistry
from ai_players_companion.mcp.server import build_server


@pytest.mark.asyncio
async def test_connected_client_receives_seeded_agents():
    registry = AgentRegistry()
    registry.seed(
        AgentRecord(
            agent_id="agent-walter-1",
            name="Walter",
            context="A gruff but friendly sandbox guide.",
            capabilities=("say", "follow"),
            state="idle",
        )
    )
    app = build_server(registry)

    async with create_connected_server_and_client_session(app) as client:
        result = await client.call_tool("list_agents", {})

    assert result.isError is not True
    payload = json.loads(result.content[0].text)
    assert payload["agents"] == [
        {
            "agent_id": "agent-walter-1",
            "name": "Walter",
            "context": "A gruff but friendly sandbox guide.",
            "capabilities": ["say", "follow"],
            "state": "idle",
        }
    ]
