AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

-- Default citizen model from the SPK-BOT-001 spike environment. Exact
-- model is Open (design.md Open Questions); a later change can make this
-- configurable without touching lifecycle/registry logic.
local DEFAULT_MODEL = "models/kleiner.mdl"

function ENT:Initialize()
    self:SetModel(DEFAULT_MODEL)
    self:SetSolid(SOLID_BBOX)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetHealth(100)
    self:SetMaxHealth(100)

    -- Idle appearance only (design.md Decisions: "Inactive appearance").
    -- Exact sequence name is model-dependent; failing to find one just
    -- leaves the default bind pose, not a hard error.
    pcall(function() self:SetSequence("idle") end)

    -- spec addon/spawn-lifecycle: INACTIVE, no agent-driven autonomy, and
    -- not addressable as an MCP agent until a Tool Gun bind promotes it.
    AI_PLAYERS.Registry:TrackInactive(self)
end

-- Covers admin/Remover-tool deletion of a never-bound placeholder. A
-- promoted placeholder is already untracked by the time Bind removes it
-- (addon/lua/ai_players/server/spawn.lua), so this is then a no-op.
function ENT:OnRemove()
    AI_PLAYERS.Registry:Forget(self)
end
