"""Requirement: WAITING_FOR_AGENT -> ACTIVE needs a connected MCP client, not
just a healthy bridge (design.md Decisions: "ACTIVE policy").

The bridge_status payload GLua polls must distinguish "file IPC bridge is
healthy" from "an MCP client session is actually connected", so the GLua
lifecycle registry can gate the ACTIVE transition on both.
"""

from __future__ import annotations

import json

import pytest
from mcp.shared.memory import create_connected_server_and_client_session

from ai_players_companion.agents.registry import AgentRegistry
from ai_players_companion.mcp.server import build_server
from ai_players_companion.mcp.session import SessionTracker
from ai_players_companion.protocol import TYPE_HELLO, envelope
from ai_players_companion.transport.file_ipc import BridgePaths, FileIpcBridge


def _read_status(paths: BridgePaths) -> dict:
    return json.loads(paths.status_path.read_text(encoding="utf-8"))


def test_status_reports_no_session_before_any_mcp_client_connects(tmp_path) -> None:
    session = SessionTracker()
    paths = BridgePaths.from_gmod_data(tmp_path)
    bridge = FileIpcBridge(paths, session=session)
    paths.ensure()
    paths.hello_path.write_text(json.dumps(envelope(TYPE_HELLO, {"source": "gmod"})), encoding="utf-8")

    bridge.poll_once()

    status = _read_status(paths)
    assert status["payload"]["ready"] is True
    assert status["payload"]["mcp_session_connected"] is False


@pytest.mark.asyncio
async def test_status_reports_session_connected_while_an_mcp_client_is_attached(tmp_path) -> None:
    session = SessionTracker()
    paths = BridgePaths.from_gmod_data(tmp_path)
    bridge = FileIpcBridge(paths, session=session)
    paths.ensure()
    paths.hello_path.write_text(json.dumps(envelope(TYPE_HELLO, {"source": "gmod"})), encoding="utf-8")
    bridge.poll_once()

    app = build_server(AgentRegistry(), session=session)
    async with create_connected_server_and_client_session(app):
        bridge._write_status(ready=True, state="healthy")
        assert _read_status(paths)["payload"]["mcp_session_connected"] is True

    bridge._write_status(ready=True, state="healthy")
    assert _read_status(paths)["payload"]["mcp_session_connected"] is False


def test_status_without_a_session_tracker_defaults_to_not_connected(tmp_path) -> None:
    paths = BridgePaths.from_gmod_data(tmp_path)
    bridge = FileIpcBridge(paths)
    paths.ensure()
    paths.hello_path.write_text(json.dumps(envelope(TYPE_HELLO, {"source": "gmod"})), encoding="utf-8")

    bridge.poll_once()

    assert _read_status(paths)["payload"]["mcp_session_connected"] is False
