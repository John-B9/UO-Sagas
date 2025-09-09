----------------------------------------------------------------------
-- CL (Crafting Leveling) Tailoring
-- Author: JohnB9
--
-- Description: To level up Tailoring
----------------------------------------------------------------------

local cll = Import('CLLib')

-- Tayloring items by skill range
local TAYLORING_ITEMS = {
    { name = "Doublet",   		   minSkill = 0.0, maxSkill = 20.6, category = 8, craft = 3,  final = 2 },
    { name = "Kilt",   		       minSkill = 20.7, maxSkill = 24.7, category = 15, craft = 17,  final = 21 },
    { name = "Short Pants",        minSkill = 24.8, maxSkill = 44.9, category = 15, craft = 3,  final = 2 },
    { name = "Full Apron",         minSkill = 45.0, maxSkill = 49.9, category = 22, craft = 17,  final = 16 },
    { name = "Oil Cloth",          minSkill = 50.0, maxSkill = 70.0, category = 22, craft = 24,  final = 23 },
}

-- User Settings
local config = {
	TOOL_ID = 0x0F9D,              -- Sewing Kit
	GUMP_ID = 2653346093,          -- Gump ID used by Tayloring
	MAKE_LAST_BUTTON_ID = 21,      -- "Make Last" button
    SKILL_TO_LEVEL = "Tailoring",
    ITEMS = TAYLORING_ITEMS,
    PREWORK_FUNCTION = nil
}

cll.craftingLoop(config)