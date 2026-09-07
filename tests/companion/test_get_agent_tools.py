"""Requirement: Character-agnostic management tools — `get_agent` / `get_agent_status`.

Covers both the happy path (identity/persona/capabilities/state fields) and
the "Unknown agent" scenario: `unknown_agent`, no invented agent.
"""

from __future__ import annotations

import json

import pytest
from mcp.shared.memory import create_connected_server_and_client_session

from ai_players_companion.agents.registry import AgentRecord, AgentRegistry
from ai_players_companion.mcp.server import build_server


def _registry_with_walter() -> AgentRegistry:
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
    return registry


@pytest.mark.asyncio
async def test_get_agent_returns_identity_persona_capabilities_and_state():
    app = build_server(_registry_with_walter())

    async with create_connected_server_and_client_session(app) as client:
        result = await client.call_tool("get_agent", {"agent_id": "agent-walter-1"})

    assert result.isError is not True
    payload = json.loads(result.content[0].text)
    assert payload == {
        "agent_id": "agent-walter-1",
        "name": "Walter",
        "context": "A gruff but friendly sandbox guide.",
        "capabilities": ["say", "follow"],
        "state": "idle",
    }


@pytest.mark.asyncio
async def test_get_agent_status_returns_lifecycle_state():
    app = build_server(_registry_with_walter())

    async with create_connected_server_and_client_session(app) as client:
        result = await client.call_tool("get_agent_status", {"agent_id": "agent-walter-1"})

    assert result.isError is not True
    payload = json.loads(result.content[0].text)
    assert payload == {"agent_id": "agent-walter-1", "state": "idle"}


@pytest.mark.asyncio
@pytest.mark.parametrize("tool_name", ["get_agent", "get_agent_status"])
async def test_unknown_agent_id_fails_with_unknown_agent_error(tool_name: str):
    app = build_server(_registry_with_walter())

    async with create_connected_server_and_client_session(app) as client:
        result = await client.call_tool(tool_name, {"agent_id": "does-not-exist"})

    assert result.isError is True
    assert "unknown_agent" in result.content[0].text
