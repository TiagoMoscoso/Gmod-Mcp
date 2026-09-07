"""File IPC registry message contract tests."""

from __future__ import annotations

import json

import pytest
from mcp.shared.memory import create_connected_server_and_client_session

from ai_players_companion.agents.registry import AgentRegistry
from ai_players_companion.mcp.server import build_server
from ai_players_companion.protocol import TYPE_REGISTRY_REMOVE, TYPE_REGISTRY_UPSERT, envelope
from ai_players_companion.transport.file_ipc import BridgePaths, FileIpcBridge


def _write(path, payload) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload), encoding="utf-8")


@pytest.mark.asyncio
async def test_registry_upsert_from_gmod_is_visible_to_list_agents(tmp_path) -> None:
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
                    "agent_id": "agent-walter-1",
                    "name": "Walter",
                    "context": "Grumpy mechanic.",
                    "capabilities": ["say", "follow"],
                    "state": "WAITING_FOR_AGENT",
                }
            },
        ),
    )

    bridge.poll_once()

    app = build_server(registry)
    async with create_connected_server_and_client_session(app) as client:
        result = await client.call_tool("list_agents", {})

    payload = json.loads(result.content[0].text)
    assert payload["agents"] == [
        {
            "agent_id": "agent-walter-1",
            "name": "Walter",
            "context": "Grumpy mechanic.",
            "capabilities": ["say", "follow"],
            "state": "WAITING_FOR_AGENT",
        }
    ]


def test_registry_remove_from_gmod_forgets_agent(tmp_path) -> None:
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
                    "agent_id": "agent-walter-1",
                    "name": "Walter",
                    "context": "Grumpy mechanic.",
                    "capabilities": ["say"],
                    "state": "ACTIVE",
                }
            },
        ),
    )
    bridge.poll_once()
    _write(paths.registry_remove_path, envelope(TYPE_REGISTRY_REMOVE, {"agent_id": "agent-walter-1"}))

    bridge.poll_once()

    assert registry.list_agents() == []
