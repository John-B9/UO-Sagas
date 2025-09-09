----------------------------------------------------------------------
-- CL (Crafting Leveling) Smithing
-- Author: JohnB9
--
-- Description: To level up Smithing
----------------------------------------------------------------------

local cll = Import('CLLib')

-- Blacksmithing items by skill range
local SMITH_ITEMS = {
    { name = "Dagger",   		   minSkill = 00.0, maxSkill = 49.9, category = 36, craft = 17,  final = 16 },
    { name = "Ringmail Gloves",    minSkill = 50.0, maxSkill = 61.9, category = 1, craft = 3,  final = 2 },
    { name = "Platemail Gorget",   minSkill = 62.0, maxSkill = 79.9, category = 15, craft = 17,  final = 16 },
    { name = "Platemail Gloves",   minSkill = 80.0, maxSkill = 89.9, category = 15, craft = 10, final = 9 },
    { name = "Plate Arms",         minSkill = 90.0, maxSkill = 93.9, category = 15, craft = 3, final = 2 },
    { name = "Plate Legs",         minSkill = 94.0, maxSkill = 96.9, category = 15, craft = 24, final = 23 },
    { name = "Plate Tunic",        minSkill = 97.0, maxSkill = 100.0, category = 15, craft = 31, final = 30 },
}

-- User Settings
local config = {
	TOOL_ID = 0x13E3,              -- Smith's Hammer
	GUMP_ID = 2653346093,          -- Gump ID used by Blacksmithing
	MAKE_LAST_BUTTON_ID = 21,      -- "Make Last" button
    SKILL_TO_LEVEL = "Blacksmithy",
    ITEMS = SMITH_ITEMS,
    PREWORK_FUNCTION = nil
}

cll.craftingLoop(config)