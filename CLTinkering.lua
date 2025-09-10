----------------------------------------------------------------------
-- CL (Crafting Leveling) Tinkering
-- Author: JohnB9
--
-- Description: To level up Tinkering
----------------------------------------------------------------------

local cll = Import('CLLib')

-- Tinkering items by skill range
local TINKER_ITEMS = {
    { name = "Fork",        minSkill = 30.0, maxSkill = 49.9, category = 15, craft = 38, final = 37 },
    { name = "Bartap",      minSkill = 50.0, maxSkill = 69.9, category = 8, craft = 24, final = 23 },
    { name = "Spyglass",    minSkill = 70.0, maxSkill = 100.0, category = 22, craft = 38, final = 37 }
    --{ name = "Scales",      minSkill = 90.0, maxSkill = 100.0, category = 22, craft = 17, final = 16 }
}

-- User Settings
local config = {
	TOOL_ID = 0x1EB8,              -- Tinkers Tools
	GUMP_ID = 2653346093,          -- Gump ID used by Tinkering
	MAKE_LAST_BUTTON_ID = 21,      -- "Make Last" button
    SKILL_TO_LEVEL = "Tinkering",
    ITEMS = TINKER_ITEMS,
    PREWORK_FUNCTION = nil
}

cll.craftingLoop(config)