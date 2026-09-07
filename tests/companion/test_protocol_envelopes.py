"""Bridge protocol envelope catalog tests."""

from __future__ import annotations

import pytest

from ai_players_companion.protocol import (
    BRIDGE_ENVELOPE_EXAMPLES,
    MVP_BRIDGE_MESSAGE_TYPES,
    PROTOCOL_VERSION,
    envelope,
)


def test_mvp_bridge_type_catalog_lists_every_message_type() -> None:
    assert MVP_BRIDGE_MESSAGE_TYPES == {
        "hello",
        "hello_ok",
        "hello_reject",
        "bridge_status",
        "registry_upsert",
        "registry_remove",
        "action_request",
        "action_result",
        "event",
        "observe_request",
        "observe_result",
    }


def test_bridge_examples_use_required_envelope_fields() -> None:
    assert set(BRIDGE_ENVELOPE_EXAMPLES) == MVP_BRIDGE_MESSAGE_TYPES
    for message_type, example in BRIDGE_ENVELOPE_EXAMPLES.items():
        assert set(example) == {"type", "protocol_version", "payload"}
        assert example["type"] == message_type
        assert example["protocol_version"] == PROTOCOL_VERSION
        assert isinstance(example["payload"], dict)


def test_envelope_rejects_unknown_message_type() -> None:
    with pytest.raises(ValueError, match="unknown bridge message type"):
        envelope("execute_lua", {})
