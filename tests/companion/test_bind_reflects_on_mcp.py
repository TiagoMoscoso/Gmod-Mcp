"""Requirement: Bound agent appears on MCP (spec addon/toolgun-bind).

A Tool Gun bind upserts over the bridge (addon/lua/ai_players/server/
registry.lua Promote); this proves get_agent returns exactly what GLua
pushed, not a Companion-invented value (spec: "GLua is authority for
persona").
"""

from __future__ import annotations

import json

import pytest
from mcp.shared.memory import create_connected_server_and_client_session

from ai_players_companion.agents.registry import AgentRegistry
from ai_players_companion.mcp.server import build_server
from ai_players_companion.protocol import TYPE_REGISTRY_UPSERT, envelope
from ai_players_companion.transport.file_ipc import BridgePaths, FileIpcBridge


def _write(path, payload) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload), encoding="utf-8")


@pytest.mark.asyncio
async def test_get_agent_returns_the_bound_name_and_context(tmp_path) -> None:
    registry = AgentRegistry()
    paths = BridgePaths.from_gmod_data(tmp_path)
    bridge = FileIpcBridge(paths, registry=registry)
    paths.ensure()
    _write(
        paths.registry_upsert_path,
        envelope(
            TYPE_REGISTRY_UPSERT,
            {
                "agent": {
                    "agent_id": "agt_1",
                    "name": "Walter",
                    "context": "You are Walter, my mechanic friend.",
                    "capabilities": ["observe", "move", "chat", "combat"],
                    "state": "WAITING_FOR_AGENT",
                }
            },
        ),
    )

    bridge.poll_once()

    app = build_server(registry)
    async with create_connected_server_and_client_session(app) as client:
        result = await client.call_tool("get_agent", {"agent_id": "agt_1"})

    payload = json.loads(result.content[0].text)
    assert payload == {
        "agent_id": "agt_1",
        "name": "Walter",
        "context": "You are Walter, my mechanic friend.",
        "capabilities": ["observe", "move", "chat", "combat"],
        "state": "WAITING_FOR_AGENT",
    }
