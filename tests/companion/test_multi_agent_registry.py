"""Requirement: Multi-agent registry (spec addon/spawn-lifecycle).

More than one AI Player can be registered at the same time, each with its
own agent_id and name, and list_agents returns all of them.
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


def _agent(agent_id: str, name: str) -> dict:
    return {
        "agent_id": agent_id,
        "name": name,
        "context": f"You are {name}.",
        "capabilities": ["observe", "move", "chat", "combat"],
        "state": "WAITING_FOR_AGENT",
    }


@pytest.mark.asyncio
async def test_two_bound_agents_both_appear_on_list_agents(tmp_path) -> None:
    registry = AgentRegistry()
    paths = BridgePaths.from_gmod_data(tmp_path)
    bridge = FileIpcBridge(paths, registry=registry)
    paths.ensure()

    # Sequential upserts, one poll apart: the file IPC bridge is a
    # single-slot mailbox per message type (one registry_upsert.json), so a
    # second write before the first is polled would overwrite it. Two real
    # Tool Gun binds are human-paced well past the 0.25s poll interval;
    # this proves the *data model* holds both, not the transport's
    # throughput under a burst it was never designed for.
    _write(paths.registry_upsert_path, envelope(TYPE_REGISTRY_UPSERT, {"agent": _agent("agt_1", "Walter")}))
    bridge.poll_once()
    _write(paths.registry_upsert_path, envelope(TYPE_REGISTRY_UPSERT, {"agent": _agent("agt_2", "Shepherd")}))
    bridge.poll_once()

    app = build_server(registry)
    async with create_connected_server_and_client_session(app) as client:
        result = await client.call_tool("list_agents", {})

    payload = json.loads(result.content[0].text)
    agent_ids = {agent["agent_id"] for agent in payload["agents"]}
    names = {agent["name"] for agent in payload["agents"]}
    assert agent_ids == {"agt_1", "agt_2"}
    assert names == {"Walter", "Shepherd"}
