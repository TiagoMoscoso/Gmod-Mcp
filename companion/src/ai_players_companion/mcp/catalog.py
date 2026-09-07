"""Guards the MCP tool catalog against character-scoped and forbidden tools.

mcp-server spec: "The server MUST NOT generate per-character-name tools"
and "MUST NOT expose execute_lua, shell, eval, run_console_command, or
frame-level input tools." One module owns both checks so a catalog test
can assert against it once instead of every tool module remembering the
rule on its own (AGENTS.md "Forbidden").
"""

from __future__ import annotations

from collections.abc import Iterable

from mcp.server.fastmcp import FastMCP


class CatalogSafetyError(RuntimeError):
    """Raised when the MCP tool catalog contains a forbidden or per-character tool."""


def assert_no_character_scoped_tools(tool_names: Iterable[str], agent_names: Iterable[str]) -> None:
    """Fail closed if any `tool_name` is scoped to a character display name.

    Tools act on a character only through an `agent_id` parameter (for
    example `walter_move` is never a tool name; `move_to(agent_id=...)` is).
    """
    lowered_agent_names = [name.lower() for name in agent_names if name]
    for tool_name in tool_names:
        lowered_tool_name = tool_name.lower()
        for agent_name in lowered_agent_names:
            if agent_name in lowered_tool_name:
                raise CatalogSafetyError(
                    f"tool '{tool_name}' is scoped to character '{agent_name}'; "
                    "tools must take agent_id instead of a per-character name"
                )


def registered_tool_names(server: FastMCP) -> list[str]:
    """Read the live tool catalog off a FastMCP instance.

    `FastMCP.list_tools` is async and does MCP-shape conversion, with no
    public synchronous accessor for plain names, so this is the one place
    that reaches into the private `_tool_manager`.
    """
    return [tool.name for tool in server._tool_manager.list_tools()]  # noqa: SLF001
