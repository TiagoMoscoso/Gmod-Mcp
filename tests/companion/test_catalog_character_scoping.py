"""Requirement: Character-agnostic management tools — "Tools are not named after characters".

mcp-server spec scenario: a client inspecting the catalog MUST NOT find a
tool whose name includes a character display name (example: `walter_move`).
"""

from __future__ import annotations

import pytest
from mcp.server.fastmcp import FastMCP

from ai_players_companion.mcp.catalog import (
    CatalogSafetyError,
    assert_no_character_scoped_tools,
    registered_tool_names,
)


def test_agent_id_scoped_tool_names_are_allowed():
    assert_no_character_scoped_tools(tool_names=["move_to", "list_agents"], agent_names=["Walter"])


def test_character_scoped_tool_name_is_rejected():
    with pytest.raises(CatalogSafetyError, match="walter_move"):
        assert_no_character_scoped_tools(tool_names=["walter_move"], agent_names=["Walter"])


def test_a_registered_walter_tool_fails_the_live_catalog_check():
    """Registering a `walter_*` tool on a real FastMCP app must fail the check."""
    app = FastMCP(name="test-server")

    @app.tool(name="walter_move")
    async def walter_move() -> dict[str, str]:  # pragma: no cover - never called
        return {"status": "moved"}

    with pytest.raises(CatalogSafetyError, match="walter_move"):
        assert_no_character_scoped_tools(tool_names=registered_tool_names(app), agent_names=["Walter"])
