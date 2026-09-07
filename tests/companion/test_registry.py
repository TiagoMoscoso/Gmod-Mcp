"""Requirement: Testable without Garry's Mod.

Pure in-memory unit tests: no MCP, no sockets, no GMod.
"""

from __future__ import annotations

import pytest

from ai_players_companion.agents.registry import AgentRecord, AgentRegistry, UnknownAgentError


def _walter() -> AgentRecord:
    return AgentRecord(
        agent_id="agent-walter-1",
        name="Walter",
        context="A gruff but friendly sandbox guide.",
        capabilities=("say", "follow"),
        state="idle",
    )


def test_seed_then_list_returns_the_seeded_agent():
    registry = AgentRegistry()
    registry.seed(_walter())

    agents = registry.list_agents()

    assert agents == [_walter()]


def test_get_agent_returns_the_matching_record():
    registry = AgentRegistry()
    registry.seed(_walter())

    record = registry.get_agent("agent-walter-1")

    assert record.name == "Walter"
    assert record.capabilities == ("say", "follow")


def test_get_agent_raises_unknown_agent_for_missing_id():
    registry = AgentRegistry()

    with pytest.raises(UnknownAgentError) as exc_info:
        registry.get_agent("does-not-exist")

    assert exc_info.value.agent_id == "does-not-exist"
    assert "unknown_agent" in str(exc_info.value)


def test_list_agents_on_empty_registry_returns_empty_list():
    registry = AgentRegistry()

    assert registry.list_agents() == []
