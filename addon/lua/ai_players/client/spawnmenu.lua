-- Spawn Menu entry (spec addon/spawn-lifecycle: "Inactive spawn from Spawn
-- Menu"). Puts the INACTIVE placeholder under NPCs > AI Players > AI NPC.
-- list.Set("NPC", ...) is the documented way to add a custom class to the
-- Spawn Menu's NPCs tab; it does not require the class to be a real NPC.
if CLIENT then
    list.Set("NPC", "ai_players_npc", {
        Name = "AI NPC",
        Class = "ai_players_npc",
        Category = "AI Players",
    })
end
