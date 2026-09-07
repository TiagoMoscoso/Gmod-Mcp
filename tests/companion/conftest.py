"""Shared fixtures for Companion MCP host tests.

These tests must run without Garry's Mod (AGENTS.md "Companion tests must
run without Garry's Mod"). Where a test needs a live client/server round
trip, it uses a real Streamable HTTP socket so the localhost-bind
requirement (ADR-005) is exercised for real, not asserted from
configuration alone.
"""

from __future__ import annotations

import asyncio
from dataclasses import dataclass

import pytest_asyncio
import uvicorn
from mcp.server.fastmcp import FastMCP


@dataclass
class RunningServer:
    """A FastMCP app actually listening on a loopback socket."""

    app: FastMCP
    host: str
    port: int

    @property
    def url(self) -> str:
        return f"http://{self.host}:{self.port}{self.app.settings.streamable_http_path}"


@pytest_asyncio.fixture
async def run_server():
    """Factory fixture: serve a FastMCP app over real HTTP.

    Keeps the app's configured host (so the localhost-bind requirement is
    exercised for real) but always listens on port 0, an OS-assigned free
    port, so tests never collide with each other or a real Companion
    instance on the proposed port 8765.
    """
    tasks: list[asyncio.Task] = []
    servers: list[uvicorn.Server] = []

    async def start(app: FastMCP) -> RunningServer:
        config = uvicorn.Config(
            app.streamable_http_app(),
            host=app.settings.host,
            port=0,
            log_level="warning",
            lifespan="on",
        )
        server = uvicorn.Server(config)
        servers.append(server)
        tasks.append(asyncio.create_task(server.serve()))
        while not server.started:
            await asyncio.sleep(0.01)
        sock = server.servers[0].sockets[0]
        host, port = sock.getsockname()[:2]
        return RunningServer(app=app, host=host, port=port)

    yield start

    for server in servers:
        server.should_exit = True
    for task in tasks:
        try:
            await asyncio.wait_for(task, timeout=5)
        except asyncio.TimeoutError:  # pragma: no cover - defensive
            task.cancel()
