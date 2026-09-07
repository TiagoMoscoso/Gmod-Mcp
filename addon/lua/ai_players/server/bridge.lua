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

function Bridge.Start()
    ensureDir("ai_players")
    ensureDir(Bridge.Root)
    ensureDir(Bridge.GmodOut)
    ensureDir(Bridge.CompanionOut)

    file.Delete(Bridge.HelloOkPath)
    file.Delete(Bridge.HelloRejectPath)

    AI_PLAYERS.CompanionStatus = AI_PLAYERS.CompanionState.DISCONNECTED

    writeJson(Bridge.HelloPath, {
        type = AI_PLAYERS_BRIDGE_MESSAGE.HELLO,
        protocol_version = AI_PLAYERS_PROTOCOL_VERSION,
        payload = {
            source = "gmod",
            bridge = "file_ipc",
        },
    })

    timer.Create("AIPlayersBridgeHelloPoll", 0.5, 20, function()
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
end

AI_PLAYERS.Bridge = Bridge

return Bridge
