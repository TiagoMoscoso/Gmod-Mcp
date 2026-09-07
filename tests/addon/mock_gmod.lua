-- Minimal Garry's Mod global stand-ins for boot-testing the AI Players
-- GLua module graph outside the engine. Extend as later tasks touch more
-- of the API surface; do not grow this into a full GMod re-implementation
-- (docs/architecture/components.md: "GLua tests are hard in-engine;
-- prefer a small mock").

local M = {}

function M.install(luaRoot, realm)
    SERVER = realm == "server"
    CLIENT = realm == "client"

    -- include() always resolves relative to the "lua/" folder, never to
    -- the caller's own directory. This mirrors real GMod behavior.
    function include(path)
        local chunk, err = loadfile(luaRoot .. path)
        if not chunk then
            error("include() failed to load " .. path .. ": " .. tostring(err), 2)
        end
        return chunk()
    end

    -- Real GMod networks the file to connected clients; boot tests only
    -- need the call to be a harmless no-op.
    function AddCSLuaFile(_path) end

    -- Convar flag bits are meaningless outside the engine; boot tests
    -- only need them to exist as numbers.
    FCVAR_ARCHIVE = 128
    FCVAR_REPLICATED = 8192

    local convars = {}

    function CreateConVar(name, default, _flags, _help)
        local value = tostring(default)
        local convar = {
            GetString = function() return value end,
            GetInt = function() return tonumber(value) end,
        }
        convars[name] = convar
        return convar
    end

    function GetConVar(name)
        return convars[name]
    end

    local dataRoot = os.getenv("AI_PLAYERS_TEST_DATA") or "/tmp/ai_players_glua_test_data"

    local function dataPath(path)
        return dataRoot .. "/" .. path
    end

    local function shellQuote(value)
        return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
    end

    file = {}

    function file.Exists(path, realmName)
        if realmName ~= "DATA" then
            return false
        end
        local handle = io.open(dataPath(path), "r")
        if handle then
            handle:close()
            return true
        end
        local ok = os.execute(string.format("[ -d %s ]", shellQuote(dataPath(path))))
        return ok == true or ok == 0
    end

    function file.CreateDir(path)
        os.execute(string.format("mkdir -p %s", shellQuote(dataPath(path))))
    end

    function file.Write(path, value)
        local fullPath = dataPath(path)
        local dir = fullPath:match("(.+)/[^/]+$")
        if dir then
            os.execute(string.format("mkdir -p %s", shellQuote(dir)))
        end
        local handle = assert(io.open(fullPath, "w"))
        handle:write(value)
        handle:close()
    end

    function file.Read(path, realmName)
        if realmName ~= "DATA" then
            return nil
        end
        local handle = io.open(dataPath(path), "r")
        if not handle then
            return nil
        end
        local value = handle:read("*a")
        handle:close()
        return value
    end

    function file.Delete(path)
        os.remove(dataPath(path))
    end

    util = {}

    function util.AddNetworkString(_name) end

    local function encodeJson(value)
        local valueType = type(value)
        if valueType == "table" then
            local parts = {}
            for key, item in pairs(value) do
                parts[#parts + 1] = encodeJson(tostring(key)) .. ":" .. encodeJson(item)
            end
            return "{" .. table.concat(parts, ",") .. "}"
        end
        if valueType == "string" then
            return string.format("%q", value)
        end
        if valueType == "boolean" or valueType == "number" then
            return tostring(value)
        end
        return "null"
    end

    function util.TableToJSON(value, _pretty)
        return encodeJson(value)
    end

    function util.JSONToTable(_value)
        return nil
    end

    timer = {}

    function timer.Create(_name, _delay, _repetitions, _callback) end
    function timer.Remove(_name) end

    net = {}

    function net.Start(_name) end
    function net.WriteString(_value) end
    function net.Broadcast() end
    function net.Receive(_name, _callback) end

    function IsValid(value)
        return value ~= nil and value.IsValid == true
    end

    function SetClipboardText(value)
        M.clipboard = value
    end
end

return M
