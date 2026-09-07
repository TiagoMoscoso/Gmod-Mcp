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

print("ok: " .. realm .. " boot")
