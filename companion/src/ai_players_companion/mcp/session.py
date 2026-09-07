"""Tracks whether an MCP client session is currently connected.

mcp-server spec, "Session awareness": MVP is local Model A (one external
client, ADR-007), so a reference count is enough — no per-client identity,
no API keys (design.md Decisions: "Session flag, not multi-tenant auth").
"""

from __future__ import annotations

from collections.abc import AsyncIterator
from contextlib import asynccontextmanager


class SessionTracker:
    """Reference-counted connected/disconnected flag for MCP client sessions."""

    def __init__(self) -> None:
        self._active_sessions = 0

    @property
    def is_connected(self) -> bool:
        return self._active_sessions > 0

    def connect(self) -> None:
        self._active_sessions += 1

    def disconnect(self) -> None:
        self._active_sessions = max(0, self._active_sessions - 1)

    @asynccontextmanager
    async def track(self) -> AsyncIterator[None]:
        """Async context manager wired as the MCP server's `lifespan`.

        `mcp.server.lowlevel.Server.run` enters a fresh lifespan context for
        every session it serves (each Streamable HTTP session and each
        in-memory test session alike), so this is the exact connect/
        disconnect boundary regardless of transport.
        """
        self.connect()
        try:
            yield
        finally:
            self.disconnect()
