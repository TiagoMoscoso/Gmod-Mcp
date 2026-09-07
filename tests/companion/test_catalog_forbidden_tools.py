"""Requirement: Forbidden tools are absent.

AGENTS.md "Forbidden": execute_lua, shell, eval, run_console_command,
lua_run, and frame-level input tools must never appear in the MCP catalog.
"""

from __future__ import annotations

import pytest
from mcp.server.fastmcp import FastMCP

from ai_players_companion.agents.registry import AgentRegistry
from ai_players_companion.mcp.catalog import (
    FORBIDDEN_TOOL_NAMES,
    CatalogSafetyError,
    assert_no_forbidden_tools,
    registered_tool_names,
)
from ai_players_companion.mcp.server import build_server


def test_the_default_built_server_registers_no_forbidden_tools():
    app = build_server(AgentRegistry())

    assert_no_forbidden_tools(registered_tool_names(app))


@pytest.mark.parametrize("forbidden_name", sorted(FORBIDDEN_TOOL_NAMES))
def test_a_registered_forbidden_tool_fails_the_catalog_check(forbidden_name: str):
    app = FastMCP(name="test-server")

    @app.tool(name=forbidden_name)
    async def forbidden_tool() -> dict[str, str]:  # pragma: no cover - never called
        return {"status": "should not exist"}

    with pytest.raises(CatalogSafetyError, match=forbidden_name):
        assert_no_forbidden_tools(registered_tool_names(app))
