----------------------------------------------------------------------
-- CL (Crafting Leveling) Carpentry
-- Author: JohnB9
--
-- Description: To level up Carpentry
----------------------------------------------------------------------

local cll = Import('CLLib')

-- Crafting items by skill range
local CARPENTRY_ITEMS = {
    { name = "Barrel Staves", minSkill = 0.0, maxSkill = 10.9, category = 8, craft = 3, final = 2 },
    { name = "Barrel Lid",    minSkill = 11.0, maxSkill = 20.9, category = 8, craft = 10, final = 9 },
    { name = "Wooden Box",    minSkill = 21.0, maxSkill = 30.9, category = 22, craft = 3, final = 2 },
    { name = "Medium Crate",  minSkill = 31.0, maxSkill = 33.9, category = 22, craft = 17, final = 16 },
    { name = "Club",          minSkill = 34.0, maxSkill = 52.5, category = 29, craft = 24, final = 23 },
    { name = "Wooden Shield", minSkill = 52.6, maxSkill = 73.5, category = 29, craft = 31, final = 30 },
    { name = "Quarter Staff", minSkill = 73.6, maxSkill = 78.8, category = 29, craft = 3, final = 2 },
    { name = "Gnarled Staff", minSkill = 78.9, maxSkill = 99.9, category = 29, craft = 17, final = 16 }
}

-- User Settings
local config = {
	TOOL_ID = 0x1034,              -- Saw
	GUMP_ID = 2653346093,          -- Gump ID used by Carpentry
	MAKE_LAST_BUTTON_ID = 21,      -- "Make Last" button
    SKILL_TO_LEVEL = "Carpentry",
    ITEMS = CARPENTRY_ITEMS,
    PREWORK_FUNCTION = nil
}

cll.craftingLoop(config)