"""File IPC bridge used by the MVP GMod integration.

Garry's Mod can reliably read and write `garrysmod/data/` files from GLua, while
vanilla GLua cannot host sockets. This transport keeps bridge messages as small,
versioned JSON envelopes and leaves MCP hosting to the Companion HTTP server.
"""

from __future__ import annotations

import json
import threading
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Any

from ai_players_companion.agents.registry import AgentRecord, AgentRegistry
from ai_players_companion.protocol import (
    PROTOCOL_VERSION,
    TYPE_BRIDGE_STATUS,
    TYPE_HELLO,
    TYPE_HELLO_OK,
    TYPE_HELLO_REJECT,
    TYPE_REGISTRY_REMOVE,
    TYPE_REGISTRY_UPSERT,
    envelope,
)

BRIDGE_DIRNAME = "ai_players/bridge"


@dataclass(frozen=True)
class BridgePaths:
    """Concrete file paths for the file IPC bridge."""

    root: Path

    @classmethod
    def from_gmod_data(cls, gmod_data_dir: Path) -> "BridgePaths":
        return cls(gmod_data_dir / BRIDGE_DIRNAME)

    @property
    def gmod_out(self) -> Path:
        return self.root / "gmod_out"

    @property
    def companion_out(self) -> Path:
        return self.root / "companion_out"

    @property
    def hello_path(self) -> Path:
        return self.gmod_out / "hello.json"

    @property
    def hello_ok_path(self) -> Path:
        return self.companion_out / "hello_ok.json"

    @property
    def hello_reject_path(self) -> Path:
        return self.companion_out / "hello_reject.json"

    @property
    def status_path(self) -> Path:
        return self.companion_out / "status.json"

    @property
    def registry_upsert_path(self) -> Path:
        return self.gmod_out / "registry_upsert.json"

    @property
    def registry_remove_path(self) -> Path:
        return self.gmod_out / "registry_remove.json"

    def ensure(self) -> None:
        self.gmod_out.mkdir(parents=True, exist_ok=True)
        self.companion_out.mkdir(parents=True, exist_ok=True)


def _read_json(path: Path) -> dict[str, Any] | None:
    try:
        with path.open("r", encoding="utf-8") as handle:
            value = json.load(handle)
    except (FileNotFoundError, json.JSONDecodeError, OSError):
        return None
    return value if isinstance(value, dict) else None


def _write_json(path: Path, payload: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(path.suffix + ".tmp")
    with tmp.open("w", encoding="utf-8") as handle:
        json.dump(payload, handle, indent=2, sort_keys=True)
    tmp.replace(path)


class FileIpcBridge:
    """Polls GMod bridge files and answers the MVP hello handshake."""

    def __init__(
        self,
        paths: BridgePaths,
        *,
        registry: AgentRegistry | None = None,
        poll_interval: float = 0.25,
    ) -> None:
        self._paths = paths
        self._registry = registry if registry is not None else AgentRegistry()
        self._poll_interval = poll_interval
        self._stop = threading.Event()
        self._thread: threading.Thread | None = None
        self._last_hello_mtime_ns: int | None = None
        self._last_registry_upsert_mtime_ns: int | None = None
        self._last_registry_remove_mtime_ns: int | None = None

    @property
    def paths(self) -> BridgePaths:
        return self._paths

    def start(self) -> None:
        if self._thread is not None:
            return
        self._paths.ensure()
        self._write_status(ready=False, state="waiting_for_gmod")
        self._thread = threading.Thread(target=self._run, name="ai-players-file-ipc", daemon=True)
        self._thread.start()

    def stop(self) -> None:
        self._stop.set()
        if self._thread is not None:
            self._thread.join(timeout=2)

    def _run(self) -> None:
        while not self._stop.is_set():
            self.poll_once()
            self._stop.wait(self._poll_interval)

    def poll_once(self) -> None:
        self._poll_hello()
        self._poll_registry_upsert()
        self._poll_registry_remove()

    def _poll_hello(self) -> None:
        try:
            mtime_ns = self._paths.hello_path.stat().st_mtime_ns
        except FileNotFoundError:
            return
        if mtime_ns == self._last_hello_mtime_ns:
            return
        self._last_hello_mtime_ns = mtime_ns
        hello = _read_json(self._paths.hello_path)
        if not hello or hello.get("type") != TYPE_HELLO:
            self._reject("invalid_hello")
            return
        if hello.get("protocol_version") != PROTOCOL_VERSION:
            self._reject("protocol_mismatch")
            return
        payload = envelope(
            TYPE_HELLO_OK,
            {
                "source": "companion",
                "bridge": "file_ipc",
                "mcp_url": "http://127.0.0.1:8765/mcp",
            },
        )
        _write_json(self._paths.hello_ok_path, payload)
        self._write_status(ready=True, state="healthy")

    def _poll_registry_upsert(self) -> None:
        message = self._read_changed(
            self._paths.registry_upsert_path,
            "_last_registry_upsert_mtime_ns",
        )
        if message is None:
            return
        if message.get("type") != TYPE_REGISTRY_UPSERT or message.get("protocol_version") != PROTOCOL_VERSION:
            return
        agent = message.get("payload", {}).get("agent")
        if not isinstance(agent, dict):
            return
        try:
            record = AgentRecord(
                agent_id=str(agent["agent_id"]),
                name=str(agent["name"]),
                context=str(agent["context"]),
                capabilities=tuple(str(capability) for capability in agent["capabilities"]),
                state=str(agent["state"]),
            )
        except (KeyError, TypeError):
            return
        self._registry.upsert(record)

    def _poll_registry_remove(self) -> None:
        message = self._read_changed(
            self._paths.registry_remove_path,
            "_last_registry_remove_mtime_ns",
        )
        if message is None:
            return
        if message.get("type") != TYPE_REGISTRY_REMOVE or message.get("protocol_version") != PROTOCOL_VERSION:
            return
        agent_id = message.get("payload", {}).get("agent_id")
        if isinstance(agent_id, str):
            self._registry.remove(agent_id)

    def _read_changed(self, path: Path, attr_name: str) -> dict[str, Any] | None:
        try:
            mtime_ns = path.stat().st_mtime_ns
        except FileNotFoundError:
            return None
        if mtime_ns == getattr(self, attr_name):
            return None
        setattr(self, attr_name, mtime_ns)
        return _read_json(path)

    def _reject(self, reason: str) -> None:
        _write_json(
            self._paths.hello_reject_path,
            envelope(TYPE_HELLO_REJECT, {"reason": reason}),
        )
        self._write_status(ready=False, state=reason)

    def _write_status(self, *, ready: bool, state: str) -> None:
        _write_json(
            self._paths.status_path,
            envelope(
                TYPE_BRIDGE_STATUS,
                {
                    "ready": ready,
                    "state": state,
                    "updated_at": time.time(),
                },
            ),
        )
