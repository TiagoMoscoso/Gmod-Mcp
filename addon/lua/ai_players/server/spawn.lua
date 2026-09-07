-- Tool Gun bind promotion (spec addon/toolgun-bind, docs/architecture/
-- gmod-runtime.md "Spawn Menu placement"). Spawn Menu can only place a
-- registered SENT/NPC class at a clicked position; it cannot place a
-- player.CreateNextBot bot directly (SPK-BOT-001). So NPCs > AI Players >
-- AI NPC places an INACTIVE placeholder SENT, and binding promotes it:
-- remove the placeholder, create the real player bot at its position, and
-- hand the new entity to Registry:Promote.
AI_PLAYERS = AI_PLAYERS or {}

-- Binds `name`/`context` onto `placeholderEntity` and promotes it to a
-- registered AI Player. Returns the new record, or nil plus an error
-- string ("invalid_target", "not_bindable", "invalid_bind", "no_player_slot").
function AI_PLAYERS.Bind(_ply, placeholderEntity, name, context)
    if not IsValid(placeholderEntity) then
        return nil, "invalid_target"
    end
    if not AI_PLAYERS.Registry:IsBindable(placeholderEntity) then
        return nil, "not_bindable"
    end
    if not name or name == "" or not context or context == "" then
        return nil, "invalid_bind"
    end

    local pos = placeholderEntity:GetPos()
    local ang = placeholderEntity:GetAngles()

    -- SPK-BOT-001: nil/invalid when the server has no free player slot, or
    -- is true singleplayer. Fail loudly rather than silently keep the
    -- placeholder inactive.
    local bot = player.CreateNextBot(name)
    if not IsValid(bot) then
        return nil, "no_player_slot"
    end

    local record, err = AI_PLAYERS.Registry:Promote(
        placeholderEntity,
        bot,
        name,
        context,
        AI_PLAYERS.MVP_CAPABILITIES
    )
    if not record then
        bot:Kick("ai_players_bind_failed")
        return nil, err
    end

    bot:SetPos(pos)
    bot:SetAngles(ang)
    -- Promote already moved the registry key off the placeholder, so its
    -- own OnRemove -> Registry:Forget call below is a no-op.
    placeholderEntity:Remove()

    return record
end
