#!/usr/bin/env lua
-- Boots the AI Players GLua module graph against a mock GMod environment
-- for one realm, or both realms when called with no argument. Fails
-- loudly (nonzero exit, message on stderr) on any Lua error so a
-- developer or CI can prove "a Sandbox listen server loads with no Lua
-- error" without an actual Garry's Mod install.

local scriptDir = arg[0]:match("(.*/)") or "./"
local realm = arg[1]

if not realm then
    local interpreter = arg[-1] or "lua"
    for _, r in ipairs({ "server", "client" }) do
        local ok = os.execute(string.format("%s %s %s", interpreter, arg[0], r))
        -- Lua 5.1/LuaJIT return the raw status code; 5.2+ returns
        -- (true, "exit", code) on success. Normalize both.
        if ok ~= true and ok ~= 0 then
            os.exit(1)
        end
    end
    os.exit(0)
end

if realm ~= "server" and realm ~= "client" then
    io.stderr:write("usage: lua run_boot.lua [server|client]\n")
    os.exit(1)
end

local repoRoot = scriptDir .. "../../"
local luaRoot = repoRoot .. "addon/lua/"

local mock = dofile(scriptDir .. "mock_gmod.lua")
mock.install(luaRoot, realm)

local entryPoint = realm == "server"
    and "autorun/server/sv_ai_players_init.lua"
    or "autorun/client/cl_ai_players_init.lua"

local ok, err = pcall(include, entryPoint)
if not ok then
    io.stderr:write(string.format("addon failed to boot on %s: %s\n", realm, tostring(err)))
    os.exit(1)
end

-- spec: Configuration surface without live bind — the Companion host
-- convar must default to loopback, never a public bind address.
local companionHost = GetConVar("ai_players_companion_host"):GetString()
if companionHost ~= "127.0.0.1" then
    io.stderr:write(string.format(
        "ai_players_companion_host must default to 127.0.0.1, got %s\n",
        companionHost
    ))
    os.exit(1)
end

-- spec: Sandbox adapter boundary — server init must select the Sandbox
-- adapter implementation.
if realm == "server" then
    local adapterName = AI_PLAYERS.Adapter and AI_PLAYERS.Adapter.Name
    if adapterName ~= "sandbox" then
        io.stderr:write(string.format(
            "server init must select the sandbox GameAdapter, got %s\n",
            tostring(adapterName)
        ))
        os.exit(1)
    end

    AI_PLAYERS.Bridge.ApplyStatusMessage({
        protocol_version = AI_PLAYERS_PROTOCOL_VERSION,
        payload = {
            ready = true,
            state = "healthy",
            updated_at = 10,
        },
    }, 10)
    if AI_PLAYERS.CompanionStatus ~= AI_PLAYERS.CompanionState.CONNECTED then
        io.stderr:write("fresh healthy Companion status must become connected\n")
        os.exit(1)
    end

    AI_PLAYERS.Bridge.ApplyStatusMessage({
        protocol_version = "mismatch",
        payload = {
            ready = true,
            state = "healthy",
            updated_at = 10,
        },
    }, 10)
    if AI_PLAYERS.CompanionStatus ~= AI_PLAYERS.CompanionState.DISCONNECTED then
        io.stderr:write("protocol mismatch status must become disconnected\n")
        os.exit(1)
    end

    AI_PLAYERS.Bridge.ApplyStatusMessage({
        protocol_version = AI_PLAYERS_PROTOCOL_VERSION,
        payload = {
            ready = true,
            state = "healthy",
            updated_at = 1,
        },
    }, 10)
    if AI_PLAYERS.CompanionStatus ~= AI_PLAYERS.CompanionState.DISCONNECTED then
        io.stderr:write("stale Companion status must become disconnected\n")
        os.exit(1)
    end

    AI_PLAYERS.Bridge.ApplyStatusMessage({
        protocol_version = AI_PLAYERS_PROTOCOL_VERSION,
        payload = {
            ready = false,
            state = "protocol_mismatch",
            updated_at = 10,
        },
    }, 10)
    if AI_PLAYERS.CompanionStatus ~= AI_PLAYERS.CompanionState.ERROR then
        io.stderr:write("handshake rejection must become error\n")
        os.exit(1)
    end
end

-- spec: No false MCP-ready UX — the client must default to disconnected.
if realm == "client" then
    if AI_PLAYERS.CompanionStatus ~= AI_PLAYERS.CompanionState.DISCONNECTED then
        io.stderr:write(string.format(
            "client must default CompanionStatus to disconnected, got %s\n",
            tostring(AI_PLAYERS.CompanionStatus)
        ))
        os.exit(1)
    end

    local offlineModel = AI_PLAYERS.BuildCompanionPopupModel(AI_PLAYERS.CompanionState.DISCONNECTED, "")
    if offlineModel.copy_enabled or offlineModel.mcp_url ~= nil then
        io.stderr:write("offline popup must not expose a copyable MCP URL\n")
        os.exit(1)
    end
    if not offlineModel.setup_guide_enabled or offlineModel.setup_guide_url == nil then
        io.stderr:write("offline popup must expose the Setup Guide target\n")
        os.exit(1)
    end

    local onlineModel = AI_PLAYERS.BuildCompanionPopupModel(
        AI_PLAYERS.CompanionState.CONNECTED,
        "http://127.0.0.1:8765/mcp"
    )
    if not onlineModel.copy_enabled or onlineModel.mcp_url ~= "http://127.0.0.1:8765/mcp" then
        io.stderr:write("online popup must expose a copyable MCP URL\n")
        os.exit(1)
    end
    if onlineModel.setup_guide_enabled then
        io.stderr:write("online popup must not prefer the Setup Guide over the live URL\n")
        os.exit(1)
    end
end

print("ok: " .. realm .. " boot")
