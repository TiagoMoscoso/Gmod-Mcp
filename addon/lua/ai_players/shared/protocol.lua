-- Protocol version this addon speaks.
if SERVER then
    AddCSLuaFile()
end

AI_PLAYERS_PROTOCOL_VERSION = "1"

AI_PLAYERS_BRIDGE_MESSAGE = {
    HELLO = "hello",
    HELLO_OK = "hello_ok",
    HELLO_REJECT = "hello_reject",
    BRIDGE_STATUS = "bridge_status",
    REGISTRY_UPSERT = "registry_upsert",
    REGISTRY_REMOVE = "registry_remove",
    ACTION_REQUEST = "action_request",
    ACTION_RESULT = "action_result",
    EVENT = "event",
    OBSERVE_REQUEST = "observe_request",
    OBSERVE_RESULT = "observe_result",
}

function AI_PLAYERS_BridgeEnvelope(messageType, payload)
    return {
        type = messageType,
        protocol_version = AI_PLAYERS_PROTOCOL_VERSION,
        payload = payload,
    }
end
