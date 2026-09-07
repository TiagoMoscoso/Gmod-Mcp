"""In-memory registry of AI Player agents.

Seedable in tests without a running GMod server (design.md Decisions:
`AgentRecord` + `AgentRegistry`; SQLite is explicitly rejected here as
Future). `gmod-companion-bridge` swaps this for bridge-backed data.
"""

from __future__ import annotations

from dataclasses import dataclass


class UnknownAgentError(LookupError):
    """Raised when a caller references an `agent_id` the registry does not have.

    MCP tools surface this as an `unknown_agent` failure rather than
    inventing an agent (mcp-server spec, "Unknown agent" scenario).
    """

    def __init__(self, agent_id: str) -> None:
        super().__init__(f"unknown_agent: {agent_id}")
        self.agent_id = agent_id


@dataclass(frozen=True)
class AgentRecord:
    """Identity, persona, capabilities, and lifecycle state for one AI Player.

    Exact JSON field names beyond these stay an open cosmetic detail
    (design.md Open Questions); this is the frozen-enough shape for MVP
    management tools.
    """

    agent_id: str
    name: str
    context: str
    capabilities: tuple[str, ...]
    state: str


class AgentRegistry:
    """Seedable, in-memory `agent_id` -> `AgentRecord` store (Registry pattern)."""

    def __init__(self) -> None:
        self._agents: dict[str, AgentRecord] = {}

    def seed(self, record: AgentRecord) -> None:
        """Insert or replace a record. Tests use this in place of a GMod bridge."""
        self._agents[record.agent_id] = record

    def list_agents(self) -> list[AgentRecord]:
        return list(self._agents.values())

    def get_agent(self, agent_id: str) -> AgentRecord:
        try:
            return self._agents[agent_id]
        except KeyError:
            raise UnknownAgentError(agent_id) from None
