"""End-to-end file IPC contract coverage with a fake GMod peer."""

from __future__ import annotations

import json

from ai_players_companion.protocol import (
    TYPE_ACTION_RESULT,
    TYPE_EVENT,
    TYPE_HELLO,
    TYPE_OBSERVE_RESULT,
    envelope,
)
from ai_players_companion.transport.file_ipc import BridgePaths, FileIpcBridge


def _read(path):
    return json.loads(path.read_text(encoding="utf-8"))


def _write(path, payload) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload), encoding="utf-8")


def test_file_ipc_contract_covers_hello_mismatch_action_event_and_observe(tmp_path) -> None:
    paths = BridgePaths.from_gmod_data(tmp_path)
    bridge = FileIpcBridge(paths, poll_interval=0.01)
    paths.ensure()

    _write(paths.hello_path, envelope(TYPE_HELLO, {"source": "gmod", "bridge": "file_ipc"}))
    bridge.poll_once()
    assert _read(paths.hello_ok_path)["type"] == "hello_ok"
    assert _read(paths.status_path)["payload"]["state"] == "healthy"

    mismatch_paths = BridgePaths.from_gmod_data(tmp_path / "mismatch")
    mismatch_bridge = FileIpcBridge(mismatch_paths)
    mismatch_paths.ensure()
    _write(mismatch_paths.hello_path, {"type": TYPE_HELLO, "protocol_version": "old", "payload": {}})
    mismatch_bridge.poll_once()
    assert _read(mismatch_paths.hello_reject_path)["payload"]["reason"] == "protocol_mismatch"
    assert _read(mismatch_paths.status_path)["payload"]["ready"] is False

    bridge.request_action(
        action_id="act-1",
        agent_id="agent-walter-1",
        action="say",
        params={"text": "Hello."},
    )
    assert _read(paths.action_request_path)["payload"]["agent_id"] == "agent-walter-1"
    _write(
        paths.action_result_path,
        envelope(
            TYPE_ACTION_RESULT,
            {
                "action_id": "act-1",
                "agent_id": "agent-walter-1",
                "accepted": True,
                "state": "running",
            },
        ),
    )
    bridge.poll_once()
    assert bridge.get_action_result("act-1")["accepted"] is True

    event = {
        "event_id": "evt-1",
        "agent_id": "agent-walter-1",
        "event": "player_said",
        "payload": {"text": "Walter, come here."},
    }
    _write(paths.event_path, envelope(TYPE_EVENT, event))
    bridge.poll_once()
    assert bridge.recent_events() == [event]

    request_id = bridge.request_observe(agent_id="agent-walter-1", request_id="obs-1")
    assert _read(paths.observe_request_path)["payload"]["request_id"] == request_id
    snapshot = {"self": {"health": 100}, "events": [event]}
    _write(
        paths.observe_result_path,
        envelope(
            TYPE_OBSERVE_RESULT,
            {"request_id": request_id, "agent_id": "agent-walter-1", "snapshot": snapshot},
        ),
    )
    bridge.poll_once()
    assert bridge.get_observe_result(request_id)["snapshot"] == snapshot
