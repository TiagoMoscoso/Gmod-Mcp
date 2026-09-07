"""File IPC bridge handshake contract tests."""

from __future__ import annotations

import json

from ai_players_companion.protocol import (
    PROTOCOL_VERSION,
    TYPE_HELLO,
    TYPE_HELLO_OK,
    TYPE_HELLO_REJECT,
    envelope,
)
from ai_players_companion.transport.file_ipc import BridgePaths, FileIpcBridge


def _read_json(path):
    return json.loads(path.read_text(encoding="utf-8"))


def test_file_ipc_handshake_accepts_matching_protocol_version(tmp_path) -> None:
    paths = BridgePaths.from_gmod_data(tmp_path)
    bridge = FileIpcBridge(paths)
    paths.ensure()
    paths.hello_path.write_text(
        json.dumps(envelope(TYPE_HELLO, {"source": "gmod", "bridge": "file_ipc"})),
        encoding="utf-8",
    )

    bridge.poll_once()

    hello_ok = _read_json(paths.hello_ok_path)
    assert hello_ok["type"] == TYPE_HELLO_OK
    assert hello_ok["protocol_version"] == PROTOCOL_VERSION
    assert hello_ok["payload"]["mcp_url"] == "http://127.0.0.1:8765/mcp"

    status = _read_json(paths.status_path)
    assert status["payload"]["ready"] is True
    assert status["payload"]["state"] == "healthy"


def test_file_ipc_handshake_rejects_mismatched_protocol_version(tmp_path) -> None:
    paths = BridgePaths.from_gmod_data(tmp_path)
    bridge = FileIpcBridge(paths)
    paths.ensure()
    paths.hello_path.write_text(
        json.dumps({"type": TYPE_HELLO, "protocol_version": "mismatch", "payload": {}}),
        encoding="utf-8",
    )

    bridge.poll_once()

    assert not paths.hello_ok_path.exists()
    reject = _read_json(paths.hello_reject_path)
    assert reject["type"] == TYPE_HELLO_REJECT
    assert reject["protocol_version"] == PROTOCOL_VERSION
    assert reject["payload"]["reason"] == "protocol_mismatch"

    status = _read_json(paths.status_path)
    assert status["payload"]["ready"] is False
    assert status["payload"]["state"] == "protocol_mismatch"
