-- Server-side AI Player registry (Registry pattern, design.md Decisions).
-- Authoritative for identity, persona, capabilities, and lifecycle state;
-- the Companion only caches what this module pushes over the bridge
-- (spec addon/toolgun-bind: "GLua is authority for persona").
AI_PLAYERS = AI_PLAYERS or {}

-- npc-lifecycle.md states. INACTIVE entities are tracked here for bind
-- validation but are never pushed to the bridge (spec addon/spawn-lifecycle:
-- "Inactive unknown to MCP").
AI_PLAYERS.State = {
    INACTIVE = "INACTIVE",
    WAITING_FOR_AGENT = "WAITING_FOR_AGENT",
    ACTIVE = "ACTIVE",
    PAUSED = "PAUSED",
    ERROR = "ERROR",
    DISCONNECTED = "DISCONNECTED",
}

-- Hardcoded MVP grant (design.md Decisions: "Capabilities hardcoded... No
-- UI"). A future change adds a real capability picker.
AI_PLAYERS.MVP_CAPABILITIES = { "observe", "move", "chat", "combat" }

local Registry = {}
Registry.__index = Registry

local nextAgentSequence = 0

-- Opaque, never the display name or SteamID (design.md Decisions: "agent_id
-- format"). An incrementing counter is enough for one server session; MVP
-- has no persistence across maps (OQ-BOT-004).
local function generateAgentId()
    nextAgentSequence = nextAgentSequence + 1
    return string.format("agt_%d", nextAgentSequence)
end

function Registry.New()
    return setmetatable({
        byEntity = {},
        byAgentId = {},
    }, Registry)
end

function Registry:ToBridgeRecord(record)
    return {
        agent_id = record.agentId,
        name = record.name,
        context = record.context,
        capabilities = record.capabilities,
        state = record.state,
    }
end

-- Spawn Menu placement (spec addon/spawn-lifecycle: "Inactive spawn from
-- Spawn Menu"). Tracked locally only; never synced to the bridge.
function Registry:TrackInactive(entity)
    local record = {
        entity = entity,
        agentId = nil,
        name = nil,
        context = nil,
        capabilities = {},
        state = AI_PLAYERS.State.INACTIVE,
    }
    self.byEntity[entity] = record
    return record
end

function Registry:IsBindable(entity)
    local record = self.byEntity[entity]
    return record ~= nil and record.state == AI_PLAYERS.State.INACTIVE
end

-- Tool Gun bind promotion (spec addon/toolgun-bind: "Tool Gun left-click
-- bind"). Moves the tracked record from the INACTIVE placeholder entity to
-- the promoted entity, assigns a stable agent_id, and syncs to the bridge.
-- Caller is responsible for actually removing/replacing the placeholder
-- entity; this only updates the data model.
function Registry:Promote(oldEntity, newEntity, name, context, capabilities)
    local record = self.byEntity[oldEntity]
    if not record or record.state ~= AI_PLAYERS.State.INACTIVE then
        return nil, "not_bindable"
    end
    if not name or name == "" or not context or context == "" then
        return nil, "invalid_bind"
    end

    self.byEntity[oldEntity] = nil

    record.entity = newEntity
    record.agentId = generateAgentId()
    record.name = name
    record.context = context
    record.capabilities = capabilities or {}
    record.state = AI_PLAYERS.State.WAITING_FOR_AGENT

    self.byEntity[newEntity] = record
    self.byAgentId[record.agentId] = record

    AI_PLAYERS.Bridge.UpsertAgent(self:ToBridgeRecord(record))

    return record
end

function Registry:GetByAgentId(agentId)
    return self.byAgentId[agentId]
end

function Registry:GetByEntity(entity)
    return self.byEntity[entity]
end

function Registry:SetState(agentId, state)
    local record = self.byAgentId[agentId]
    if not record then
        return nil, "unknown_agent"
    end
    record.state = state
    AI_PLAYERS.Bridge.UpsertAgent(self:ToBridgeRecord(record))
    return record
end

-- Removal drops the agent (spec addon/spawn-lifecycle: "Removal drops the
-- agent"). A never-bound INACTIVE record has no agentId, so there is
-- nothing to tell the bridge about.
function Registry:Forget(entity)
    local record = self.byEntity[entity]
    if not record then
        return
    end

    self.byEntity[entity] = nil
    if record.agentId then
        self.byAgentId[record.agentId] = nil
        AI_PLAYERS.Bridge.RemoveAgent(record.agentId)
    end
end

AI_PLAYERS.Registry = Registry.New()

return AI_PLAYERS.Registry
