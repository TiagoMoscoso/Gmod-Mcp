"""Shared bridge protocol constants and envelope examples."""

from __future__ import annotations

from typing import Any

PROTOCOL_VERSION = "1"

TYPE_HELLO = "hello"
TYPE_HELLO_OK = "hello_ok"
TYPE_HELLO_REJECT = "hello_reject"
TYPE_BRIDGE_STATUS = "bridge_status"
TYPE_REGISTRY_UPSERT = "registry_upsert"
TYPE_REGISTRY_REMOVE = "registry_remove"
TYPE_ACTION_REQUEST = "action_request"
TYPE_ACTION_RESULT = "action_result"
TYPE_EVENT = "event"
TYPE_OBSERVE_REQUEST = "observe_request"
TYPE_OBSERVE_RESULT = "observe_result"

MVP_BRIDGE_MESSAGE_TYPES = frozenset(
    {
        TYPE_HELLO,
        TYPE_HELLO_OK,
        TYPE_HELLO_REJECT,
        TYPE_BRIDGE_STATUS,
        TYPE_REGISTRY_UPSERT,
        TYPE_REGISTRY_REMOVE,
        TYPE_ACTION_REQUEST,
        TYPE_ACTION_RESULT,
        TYPE_EVENT,
        TYPE_OBSERVE_REQUEST,
        TYPE_OBSERVE_RESULT,
    }
)


def envelope(message_type: str, payload: dict[str, Any]) -> dict[str, Any]:
    """Build the required JSON envelope shape for bridge messages."""
    if message_type not in MVP_BRIDGE_MESSAGE_TYPES:
        raise ValueError(f"unknown bridge message type: {message_type}")
    return {
        "type": message_type,
        "protocol_version": PROTOCOL_VERSION,
        "payload": payload,
    }


BRIDGE_ENVELOPE_EXAMPLES: dict[str, dict[str, Any]] = {
    TYPE_HELLO: envelope(TYPE_HELLO, {"source": "gmod", "bridge": "file_ipc"}),
    TYPE_HELLO_OK: envelope(
        TYPE_HELLO_OK,
        {
            "source": "companion",
            "bridge": "file_ipc",
            "mcp_url": "http://127.0.0.1:8765/mcp",
        },
    ),
    TYPE_HELLO_REJECT: envelope(TYPE_HELLO_REJECT, {"reason": "protocol_mismatch"}),
    TYPE_BRIDGE_STATUS: envelope(TYPE_BRIDGE_STATUS, {"ready": True, "state": "healthy"}),
    TYPE_REGISTRY_UPSERT: envelope(
        TYPE_REGISTRY_UPSERT,
        {
            "agent": {
                "agent_id": "agent-walter-1",
                "name": "Walter",
                "context": "Grumpy mechanic.",
                "capabilities": ["say", "follow"],
                "state": "WAITING_FOR_AGENT",
            }
        },
    ),
    TYPE_REGISTRY_REMOVE: envelope(TYPE_REGISTRY_REMOVE, {"agent_id": "agent-walter-1"}),
    TYPE_ACTION_REQUEST: envelope(
        TYPE_ACTION_REQUEST,
        {
            "action_id": "act-1",
            "agent_id": "agent-walter-1",
            "action": "say",
            "params": {"text": "Hello."},
        },
    ),
    TYPE_ACTION_RESULT: envelope(
        TYPE_ACTION_RESULT,
        {
            "action_id": "act-1",
            "agent_id": "agent-walter-1",
            "accepted": True,
            "state": "running",
        },
    ),
    TYPE_EVENT: envelope(
        TYPE_EVENT,
        {
            "event_id": "evt-1",
            "agent_id": "agent-walter-1",
            "event": "player_said",
            "payload": {"text": "Walter, come here."},
        },
    ),
    TYPE_OBSERVE_REQUEST: envelope(
        TYPE_OBSERVE_REQUEST,
        {"request_id": "obs-1", "agent_id": "agent-walter-1"},
    ),
    TYPE_OBSERVE_RESULT: envelope(
        TYPE_OBSERVE_RESULT,
        {
            "request_id": "obs-1",
            "agent_id": "agent-walter-1",
            "snapshot": {"self": {"health": 100}, "events": []},
        },
    ),
}
