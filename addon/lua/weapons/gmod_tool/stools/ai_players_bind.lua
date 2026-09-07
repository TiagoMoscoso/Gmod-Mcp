-- Tool Gun bind (spec addon/toolgun-bind: "Tool Gun left-click bind").
-- Left-click on an INACTIVE AI NPC applies the C-panel's Name and Context
-- and promotes it to a registered AI Player. This is a real Tool Gun mode
-- (TOOL.Category / gmod_tool stool), not a separate weapon, so it uses the
-- same Q-menu / C-panel the rest of the Tool Gun already provides.
TOOL.Category = "AI Players"
TOOL.Name = "#tool.ai_players_bind.name"

TOOL.ClientConVar["name"] = ""
TOOL.ClientConVar["context"] = ""

if CLIENT then
    language.Add("tool.ai_players_bind.name", "AI Player Bind")
    language.Add("tool.ai_players_bind.desc", "Bind a name and persona onto an inactive AI NPC to register it as an AI Player.")
    language.Add("tool.ai_players_bind.name.label", "Name")
    language.Add("tool.ai_players_bind.context.label", "Context")
end

-- spec: "Bind Walter", "Bind requires name and context". Runs server-side
-- only; the predicted client-side call is a no-op beam/animation trigger.
function TOOL:LeftClick(trace)
    if not SERVER then
        return true
    end

    local ply = self:GetOwner()
    local name = self:GetClientInfo("name")
    local context = self:GetClientInfo("context")

    local record, err = AI_PLAYERS.Bind(ply, trace.Entity, name, context)
    if not record then
        if IsValid(ply) then
            ply:ChatPrint("[AI Players] Bind failed: " .. tostring(err))
        end
        return false
    end

    if IsValid(ply) then
        ply:ChatPrint(string.format("[AI Players] Bound '%s' as %s", record.name, record.agentId))
    end
    return true
end

function TOOL:RightClick(_trace)
    return false
end

if CLIENT then
    function TOOL.BuildCPanel(panel)
        panel:Help("#tool.ai_players_bind.desc")
        panel:TextEntry("#tool.ai_players_bind.name.label", "ai_players_bind_name")
        panel:TextEntry("#tool.ai_players_bind.context.label", "ai_players_bind_context")
    end
end
