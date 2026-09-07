-- Spawn Menu placeholder for an AI Player (spec addon/spawn-lifecycle:
-- "Inactive spawn from Spawn Menu"). Garry's Mod's Spawn Menu can place a
-- registered entity class at a clicked position; it cannot place a
-- player.CreateNextBot bot directly (SPK-BOT-001, docs/architecture/
-- gmod-runtime.md "Spawn Menu placement"). This entity is that placeholder:
-- it stands idle and is promoted (removed + replaced by a real player bot)
-- on a successful Tool Gun bind.
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "AI NPC"
ENT.Author = "GMod AI Players"
ENT.Category = "AI Players"
ENT.Spawnable = true
ENT.AdminSpawnable = false
