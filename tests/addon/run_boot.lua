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

    -- spec: addon/spawn-lifecycle "Stable agent_id after bind" / "Inactive
    -- unknown to MCP" (task 2.2). A plain table stands in for an Entity:
    -- Registry never calls entity methods, only uses it as a lookup key.
    local placeholder = { debugName = "placeholder" }
    AI_PLAYERS.Registry:TrackInactive(placeholder)

    if not AI_PLAYERS.Registry:IsBindable(placeholder) then
        io.stderr:write("a freshly spawned placeholder must be bindable\n")
        os.exit(1)
    end

    if next(AI_PLAYERS.Registry.byAgentId) ~= nil then
        io.stderr:write("an unbound spawn must not appear in the agent_id registry (list_agents equivalent)\n")
        os.exit(1)
    end

    local bot = { debugName = "bot" }
    local walter = AI_PLAYERS.Registry:Promote(
        placeholder,
        bot,
        "Walter",
        "You are Walter, my mechanic friend.",
        AI_PLAYERS.MVP_CAPABILITIES
    )
    if not walter or walter.agentId == nil or walter.name ~= "Walter"
        or walter.context ~= "You are Walter, my mechanic friend."
        or walter.state ~= AI_PLAYERS.State.WAITING_FOR_AGENT then
        io.stderr:write("a valid bind must record agent_id, name, context, and state\n")
        os.exit(1)
    end
    if AI_PLAYERS.Registry:GetByEntity(placeholder) ~= nil then
        io.stderr:write("promotion must move the record off the old placeholder key\n")
        os.exit(1)
    end
    if AI_PLAYERS.Registry:GetByEntity(bot) ~= walter then
        io.stderr:write("promotion must track the record under the new entity handle\n")
        os.exit(1)
    end
    if AI_PLAYERS.Registry:GetByAgentId(walter.agentId) ~= walter then
        io.stderr:write("a bound agent must be resolvable by agent_id\n")
        os.exit(1)
    end

    -- The registry pushes bound records over the bridge so Companion
    -- list_agents/get_agent reflect them (proven end to end against the
    -- same file shape by tests/companion/test_file_ipc_registry.py).
    local upsertRaw = file.Read(AI_PLAYERS.Bridge.RegistryUpsertPath, "DATA")
    if not upsertRaw or not string.find(upsertRaw, walter.agentId, 1, true)
        or not string.find(upsertRaw, "Walter", 1, true)
        or not string.find(upsertRaw, "combat", 1, true) then
        io.stderr:write("bind must upsert agent_id, name, and MVP capabilities over the bridge\n")
        os.exit(1)
    end

    -- spec: addon/spawn-lifecycle "Bind moves to waiting" / "Companion loss
    -- disconnects" (task 2.3). A healthy bridge with no MCP client attached
    -- is still a session drop (npc-lifecycle.md: "ACTIVE / PAUSED ->
    -- DISCONNECTED | Bridge or session drop"), not a silent "stay ACTIVE".
    AI_PLAYERS.CompanionStatus = AI_PLAYERS.CompanionState.DISCONNECTED
    AI_PLAYERS.Bridge.McpSessionConnected = false
    AI_PLAYERS.Registry:ReconcileLifecycle()
    if AI_PLAYERS.Registry:GetByAgentId(walter.agentId).state ~= AI_PLAYERS.State.WAITING_FOR_AGENT then
        io.stderr:write("reconcile must leave WAITING_FOR_AGENT alone while no client is connected\n")
        os.exit(1)
    end

    AI_PLAYERS.CompanionStatus = AI_PLAYERS.CompanionState.CONNECTED
    AI_PLAYERS.Bridge.McpSessionConnected = true
    AI_PLAYERS.Registry:ReconcileLifecycle()
    if AI_PLAYERS.Registry:GetByAgentId(walter.agentId).state ~= AI_PLAYERS.State.ACTIVE then
        io.stderr:write("reconcile must move WAITING_FOR_AGENT to ACTIVE once bridge and client are healthy\n")
        os.exit(1)
    end

    AI_PLAYERS.CompanionStatus = AI_PLAYERS.CompanionState.CONNECTED
    AI_PLAYERS.Bridge.McpSessionConnected = false
    AI_PLAYERS.Registry:ReconcileLifecycle()
    if AI_PLAYERS.Registry:GetByAgentId(walter.agentId).state ~= AI_PLAYERS.State.DISCONNECTED then
        io.stderr:write("reconcile must disconnect ACTIVE when no MCP client is attached, even if the bridge is healthy\n")
        os.exit(1)
    end

    AI_PLAYERS.CompanionStatus = AI_PLAYERS.CompanionState.DISCONNECTED
    AI_PLAYERS.Bridge.McpSessionConnected = false
    AI_PLAYERS.Registry:ReconcileLifecycle()
    if AI_PLAYERS.Registry:GetByAgentId(walter.agentId).state ~= AI_PLAYERS.State.DISCONNECTED then
        io.stderr:write("reconcile must keep DISCONNECTED while the bridge stays unhealthy\n")
        os.exit(1)
    end

    AI_PLAYERS.CompanionStatus = AI_PLAYERS.CompanionState.CONNECTED
    AI_PLAYERS.Bridge.McpSessionConnected = true
    AI_PLAYERS.Registry:ReconcileLifecycle()
    if AI_PLAYERS.Registry:GetByAgentId(walter.agentId).state ~= AI_PLAYERS.State.ACTIVE then
        io.stderr:write("reconcile must restore DISCONNECTED to ACTIVE once the bridge and client are both back\n")
        os.exit(1)
    end

    -- get_agent_status reflects state via the same bridge upsert file
    -- (proven end to end by tests/companion/test_get_agent_tools.py).
    local activeUpsertRaw = file.Read(AI_PLAYERS.Bridge.RegistryUpsertPath, "DATA")
    if not activeUpsertRaw or not string.find(activeUpsertRaw, "ACTIVE", 1, true) then
        io.stderr:write("the final state transition must be pushed over the bridge\n")
        os.exit(1)
    end

    -- spec: addon/spawn-lifecycle "Lifecycle gates actions" / "Disconnected
    -- NPC is not a silent attacker" (task 2.4). No movement/combat
    -- controller exists yet (design.md Non-Goals); this gate is what they
    -- will call instead of re-deriving the halt rule.
    for _, blockedState in ipairs({
        AI_PLAYERS.State.INACTIVE,
        AI_PLAYERS.State.WAITING_FOR_AGENT,
        AI_PLAYERS.State.PAUSED,
        AI_PLAYERS.State.ERROR,
        AI_PLAYERS.State.DISCONNECTED,
    }) do
        AI_PLAYERS.Registry:SetState(walter.agentId, blockedState)
        local canAct, reason = AI_PLAYERS.Registry:CanAct(walter.agentId, "move")
        if canAct or reason ~= "not_active" then
            io.stderr:write(string.format("%s must not be allowed to act\n", blockedState))
            os.exit(1)
        end
    end

    AI_PLAYERS.Registry:SetState(walter.agentId, AI_PLAYERS.State.ACTIVE)
    if not AI_PLAYERS.Registry:CanAct(walter.agentId, "combat") then
        io.stderr:write("ACTIVE with a granted capability must be allowed to act\n")
        os.exit(1)
    end
    local canActUngranted, ungrantedReason = AI_PLAYERS.Registry:CanAct(walter.agentId, "fly")
    if canActUngranted or ungrantedReason ~= "missing_capability" then
        io.stderr:write("ACTIVE without a granted capability must be rejected as missing_capability\n")
        os.exit(1)
    end
    local canActUnknown, unknownReason = AI_PLAYERS.Registry:CanAct("agt_does_not_exist", "move")
    if canActUnknown or unknownReason ~= "unknown_agent" then
        io.stderr:write("an unknown agent_id must be rejected as unknown_agent\n")
        os.exit(1)
    end

    -- spec: addon/spawn-lifecycle "Two bound NPCs have distinct ids" (2.5).
    local placeholderB = { debugName = "placeholderB" }
    AI_PLAYERS.Registry:TrackInactive(placeholderB)
    local botB = { debugName = "botB" }
    local shepherd = AI_PLAYERS.Registry:Promote(
        placeholderB,
        botB,
        "Shepherd",
        "You are Shepherd, a guard dog.",
        AI_PLAYERS.MVP_CAPABILITIES
    )
    if not shepherd or shepherd.agentId == nil or shepherd.agentId == walter.agentId
        or shepherd.name == walter.name then
        io.stderr:write("a second bind must get a distinct agent_id and name\n")
        os.exit(1)
    end
    if AI_PLAYERS.Registry:GetByAgentId(walter.agentId) == nil
        or AI_PLAYERS.Registry:GetByAgentId(shepherd.agentId) == nil then
        io.stderr:write("both bound agents must be simultaneously resolvable by agent_id (list_agents equivalent)\n")
        os.exit(1)
    end

    -- spec: "Removal drops the agent" — forgetting one must not touch the
    -- other (multi-agent data model, not a shared slot).
    AI_PLAYERS.Registry:Forget(botB)
    if AI_PLAYERS.Registry:GetByAgentId(shepherd.agentId) ~= nil then
        io.stderr:write("Forget must drop the targeted agent\n")
        os.exit(1)
    end
    if AI_PLAYERS.Registry:GetByAgentId(walter.agentId) == nil then
        io.stderr:write("forgetting one agent must not affect a distinct agent\n")
        os.exit(1)
    end
    local removeRaw = file.Read(AI_PLAYERS.Bridge.RegistryRemovePath, "DATA")
    if not removeRaw or not string.find(removeRaw, shepherd.agentId, 1, true) then
        io.stderr:write("forgetting a bound agent must remove it over the bridge\n")
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

    local publicBindModel = AI_PLAYERS.BuildCompanionPopupModel(
        AI_PLAYERS.CompanionState.CONNECTED,
        "http://0.0.0.0:8765/mcp"
    )
    if publicBindModel.copy_enabled or publicBindModel.mcp_url ~= nil then
        io.stderr:write("popup must never expose 0.0.0.0 as a client MCP URL\n")
        os.exit(1)
    end
end

print("ok: " .. realm .. " boot")
