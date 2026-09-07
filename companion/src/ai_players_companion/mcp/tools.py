"""Character-agnostic MCP management tools, keyed by `agent_id`.

mcp-server spec, "Character-agnostic management tools": tools act on a
character only through `agent_id`, never a per-character tool name.
"""

from __future__ import annotations

from typing import Any

from mcp.server.fastmcp import FastMCP

from ai_players_companion.agents.registry import AgentRecord, AgentRegistry

MANAGEMENT_TOOL_NAMES = frozenset({"list_agents", "get_agent", "get_agent_status"})


def _agent_to_dict(record: AgentRecord) -> dict[str, Any]:
    return {
        "agent_id": record.agent_id,
        "name": record.name,
        "context": record.context,
        "capabilities": list(record.capabilities),
        "state": record.state,
    }


def register_management_tools(server: FastMCP, registry: AgentRegistry) -> None:
    """Register `list_agents` / `get_agent` / `get_agent_status` against `registry`."""

    @server.tool(name="list_agents")
    async def list_agents() -> dict[str, Any]:
        """List every AI Player agent the Companion currently knows about."""
        return {"agents": [_agent_to_dict(record) for record in registry.list_agents()]}

    @server.tool(name="get_agent")
    async def get_agent(agent_id: str) -> dict[str, Any]:
        """Return identity, persona/context, capabilities, and state for one agent.

        Raises an `unknown_agent` error if `agent_id` is not registered.
        """
        return _agent_to_dict(registry.get_agent(agent_id))

    @server.tool(name="get_agent_status")
    async def get_agent_status(agent_id: str) -> dict[str, Any]:
        """Return the lifecycle state for one agent.

        Raises an `unknown_agent` error if `agent_id` is not registered.
        """
        record = registry.get_agent(agent_id)
        return {"agent_id": record.agent_id, "state": record.state}
