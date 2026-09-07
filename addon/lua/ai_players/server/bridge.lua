-- Server-side file IPC bridge to the Companion. GLua owns game state; the
-- Companion owns MCP and answers this handshake from garrysmod/data files.
AI_PLAYERS = AI_PLAYERS or {}

local Bridge = {}

Bridge.Root = "ai_players/bridge"
Bridge.GmodOut = Bridge.Root .. "/gmod_out"
Bridge.CompanionOut = Bridge.Root .. "/companion_out"
Bridge.HelloPath = Bridge.GmodOut .. "/hello.json"
Bridge.HelloOkPath = Bridge.CompanionOut .. "/hello_ok.json"
Bridge.HelloRejectPath = Bridge.CompanionOut .. "/hello_reject.json"
Bridge.StatusPath = Bridge.CompanionOut .. "/status.json"
Bridge.RegistryUpsertPath = Bridge.GmodOut .. "/registry_upsert.json"
Bridge.RegistryRemovePath = Bridge.GmodOut .. "/registry_remove.json"
Bridge.ActionRequestPath = Bridge.CompanionOut .. "/action_request.json"
Bridge.ActionResultPath = Bridge.GmodOut .. "/action_result.json"
Bridge.EventPath = Bridge.GmodOut .. "/event.json"
Bridge.ObserveRequestPath = Bridge.CompanionOut .. "/observe_request.json"
Bridge.ObserveResultPath = Bridge.GmodOut .. "/observe_result.json"
Bridge.StatusTimeoutSeconds = 2

local function ensureDir(path)
    if not file.Exists(path, "DATA") then
        file.CreateDir(path)
    end
end

local function writeJson(path, value)
    file.Write(path, util.TableToJSON(value, true))
end

local function readJson(path)
    local raw = file.Read(path, "DATA")
    if not raw then
        return nil
    end
    return util.JSONToTable(raw)
end

local function now()
    if CurTime then
        return CurTime()
    end
    return os.time()
end

function Bridge.ApplyStatusMessage(message, currentTime)
    if not message or message.protocol_version ~= AI_PLAYERS_PROTOCOL_VERSION then
        AI_PLAYERS.CompanionStatus = AI_PLAYERS.CompanionState.DISCONNECTED
        return false
    end

    local payload = message.payload or {}
    local updatedAt = tonumber(payload.updated_at)
    if updatedAt and currentTime - updatedAt > Bridge.StatusTimeoutSeconds then
        AI_PLAYERS.CompanionStatus = AI_PLAYERS.CompanionState.DISCONNECTED
        return false
    end

    if payload.ready == true and payload.state == "healthy" then
        AI_PLAYERS.CompanionStatus = AI_PLAYERS.CompanionState.CONNECTED
        return true
    end

    if payload.state == "protocol_mismatch" or payload.state == "invalid_hello" then
        AI_PLAYERS.CompanionStatus = AI_PLAYERS.CompanionState.ERROR
        return false
    end

    AI_PLAYERS.CompanionStatus = AI_PLAYERS.CompanionState.DISCONNECTED
    return false
end

function Bridge.PollStatus()
    if not file.Exists(Bridge.StatusPath, "DATA") then
        AI_PLAYERS.CompanionStatus = AI_PLAYERS.CompanionState.DISCONNECTED
        return false
    end

    return Bridge.ApplyStatusMessage(readJson(Bridge.StatusPath), now())
end

function Bridge.Start()
    ensureDir("ai_players")
    ensureDir(Bridge.Root)
    ensureDir(Bridge.GmodOut)
    ensureDir(Bridge.CompanionOut)

    file.Delete(Bridge.HelloOkPath)
    file.Delete(Bridge.HelloRejectPath)

    AI_PLAYERS.CompanionStatus = AI_PLAYERS.CompanionState.DISCONNECTED

    writeJson(Bridge.HelloPath, AI_PLAYERS_BridgeEnvelope(
        AI_PLAYERS_BRIDGE_MESSAGE.HELLO,
        {
            source = "gmod",
            bridge = "file_ipc",
        }
    ))

    timer.Create("AIPlayersBridgeHelloPoll", 0.5, 20, function()
        Bridge.PollStatus()

        local okMessage = file.Exists(Bridge.HelloOkPath, "DATA") and readJson(Bridge.HelloOkPath) or nil
        if okMessage and okMessage.type == AI_PLAYERS_BRIDGE_MESSAGE.HELLO_OK
            and okMessage.protocol_version == AI_PLAYERS_PROTOCOL_VERSION then
            AI_PLAYERS.CompanionStatus = AI_PLAYERS.CompanionState.CONNECTED
            timer.Remove("AIPlayersBridgeHelloPoll")
            return
        end

        local rejectMessage = file.Exists(Bridge.HelloRejectPath, "DATA") and readJson(Bridge.HelloRejectPath) or nil
        if rejectMessage and rejectMessage.type == AI_PLAYERS_BRIDGE_MESSAGE.HELLO_REJECT then
            AI_PLAYERS.CompanionStatus = AI_PLAYERS.CompanionState.ERROR
            timer.Remove("AIPlayersBridgeHelloPoll")
        end
    end)

    timer.Create("AIPlayersBridgeStatusPoll", 1, 0, function()
        Bridge.PollStatus()
    end)
end

function Bridge.UpsertAgent(record)
    writeJson(Bridge.RegistryUpsertPath, AI_PLAYERS_BridgeEnvelope(
        AI_PLAYERS_BRIDGE_MESSAGE.REGISTRY_UPSERT,
        {
            agent = record,
        }
    ))
end

function Bridge.RemoveAgent(agentId)
    writeJson(Bridge.RegistryRemovePath, AI_PLAYERS_BridgeEnvelope(
        AI_PLAYERS_BRIDGE_MESSAGE.REGISTRY_REMOVE,
        {
            agent_id = agentId,
        }
    ))
end

function Bridge.ReadActionRequest()
    if not file.Exists(Bridge.ActionRequestPath, "DATA") then
        return nil
    end

    local message = readJson(Bridge.ActionRequestPath)
    if not message or message.type ~= AI_PLAYERS_BRIDGE_MESSAGE.ACTION_REQUEST then
        return nil
    end

    if message.protocol_version ~= AI_PLAYERS_PROTOCOL_VERSION then
        return nil
    end

    return message.payload
end

function Bridge.WriteActionResult(result)
    writeJson(Bridge.ActionResultPath, AI_PLAYERS_BridgeEnvelope(
        AI_PLAYERS_BRIDGE_MESSAGE.ACTION_RESULT,
        result
    ))
end

function Bridge.EmitEvent(event)
    writeJson(Bridge.EventPath, AI_PLAYERS_BridgeEnvelope(
        AI_PLAYERS_BRIDGE_MESSAGE.EVENT,
        event
    ))
end

function Bridge.ReadObserveRequest()
    if not file.Exists(Bridge.ObserveRequestPath, "DATA") then
        return nil
    end

    local message = readJson(Bridge.ObserveRequestPath)
    if not message or message.type ~= AI_PLAYERS_BRIDGE_MESSAGE.OBSERVE_REQUEST then
        return nil
    end

    if message.protocol_version ~= AI_PLAYERS_PROTOCOL_VERSION then
        return nil
    end

    return message.payload
end

function Bridge.WriteObserveResult(result)
    writeJson(Bridge.ObserveResultPath, AI_PLAYERS_BridgeEnvelope(
        AI_PLAYERS_BRIDGE_MESSAGE.OBSERVE_RESULT,
        result
    ))
end

AI_PLAYERS.Bridge = Bridge

return Bridge
