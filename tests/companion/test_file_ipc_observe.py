"""File IPC observe request/result contract tests."""

from __future__ import annotations

import json
import threading
import time

import pytest
from mcp.shared.memory import create_connected_server_and_client_session

from ai_players_companion.agents.registry import AgentRecord, AgentRegistry
from ai_players_companion.mcp.server import build_server
from ai_players_companion.protocol import TYPE_OBSERVE_RESULT, envelope
from ai_players_companion.transport.file_ipc import BridgePaths, FileIpcBridge


def _read(path):
    return json.loads(path.read_text(encoding="utf-8"))


def _write(path, payload) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload), encoding="utf-8")


def test_observe_request_and_result_round_trip_with_fake_gmod_peer(tmp_path) -> None:
    paths = BridgePaths.from_gmod_data(tmp_path)
    bridge = FileIpcBridge(paths, poll_interval=0.01)
    paths.ensure()
    request_id = bridge.request_observe(agent_id="agent-walter-1", request_id="obs-1")

    request = _read(paths.observe_request_path)
    assert request["type"] == "observe_request"
    assert request["payload"] == {"request_id": "obs-1", "agent_id": "agent-walter-1"}

    snapshot = {"self": {"health": 100}, "events": []}
    _write(
        paths.observe_result_path,
        envelope(
            TYPE_OBSERVE_RESULT,
            {"request_id": request_id, "agent_id": "agent-walter-1", "snapshot": snapshot},
        ),
    )
    bridge.poll_once()

    assert bridge.get_observe_result("obs-1") == {
        "request_id": "obs-1",
        "agent_id": "agent-walter-1",
        "snapshot": snapshot,
    }


@pytest.mark.asyncio
async def test_mcp_observe_returns_fixture_snapshot_from_fake_gmod_peer(tmp_path) -> None:
    registry = AgentRegistry()
    registry.seed(
        AgentRecord(
            agent_id="agent-walter-1",
            name="Walter",
            context="Grumpy mechanic.",
            capabilities=("observe",),
            state="ACTIVE",
        )
    )
    paths = BridgePaths.from_gmod_data(tmp_path)
    bridge = FileIpcBridge(paths, registry=registry, poll_interval=0.01)
    paths.ensure()
    snapshot = {"self": {"health": 100, "weapon": "none"}, "events": []}

    def fake_gmod_peer() -> None:
        deadline = time.monotonic() + 2
        while time.monotonic() < deadline:
            if paths.observe_request_path.exists():
                request = _read(paths.observe_request_path)
                _write(
                    paths.observe_result_path,
                    envelope(
                        TYPE_OBSERVE_RESULT,
                        {
                            "request_id": request["payload"]["request_id"],
                            "agent_id": request["payload"]["agent_id"],
                            "snapshot": snapshot,
                        },
                    ),
                )
                return
            time.sleep(0.01)

    thread = threading.Thread(target=fake_gmod_peer)
    thread.start()
    app = build_server(registry, bridge=bridge)

    async with create_connected_server_and_client_session(app) as client:
        result = await client.call_tool("observe", {"agent_id": "agent-walter-1"})

    thread.join(timeout=2)
    payload = json.loads(result.content[0].text)
    assert payload["agent_id"] == "agent-walter-1"
    assert payload["snapshot"] == snapshot
