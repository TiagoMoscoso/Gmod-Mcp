"""File IPC action and event message contract tests."""

from __future__ import annotations

import json

from ai_players_companion.protocol import TYPE_ACTION_RESULT, TYPE_EVENT, envelope
from ai_players_companion.transport.file_ipc import BridgePaths, FileIpcBridge


def _read(path):
    return json.loads(path.read_text(encoding="utf-8"))


def _write(path, payload) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload), encoding="utf-8")


def test_action_request_and_result_round_trip_with_fake_gmod_peer(tmp_path) -> None:
    paths = BridgePaths.from_gmod_data(tmp_path)
    bridge = FileIpcBridge(paths)
    paths.ensure()

    bridge.request_action(
        action_id="act-1",
        agent_id="agent-walter-1",
        action="say",
        params={"text": "Hello."},
    )

    request = _read(paths.action_request_path)
    assert request["type"] == "action_request"
    assert request["payload"] == {
        "action_id": "act-1",
        "agent_id": "agent-walter-1",
        "action": "say",
        "params": {"text": "Hello."},
    }

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

    assert bridge.get_action_result("act-1") == {
        "action_id": "act-1",
        "agent_id": "agent-walter-1",
        "accepted": True,
        "state": "running",
    }


def test_event_from_fake_gmod_peer_is_stored_for_recent_events(tmp_path) -> None:
    paths = BridgePaths.from_gmod_data(tmp_path)
    bridge = FileIpcBridge(paths)
    paths.ensure()
    event = {
        "event_id": "evt-1",
        "agent_id": "agent-walter-1",
        "event": "player_said",
        "payload": {"text": "Walter, come here."},
    }

    _write(paths.event_path, envelope(TYPE_EVENT, event))
    bridge.poll_once()

    assert bridge.recent_events() == [event]
