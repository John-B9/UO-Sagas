----------------------------------------------------------------------
-- CL (Crafting Leveling) Bowcraft Fletching
-- Author: JohnB9
--
-- Description: To level up Bowcraft/Fletching
----------------------------------------------------------------------

local bl = Import('BaseLib')
local cll = Import('CLLib')

-- Constants
local bowcraftFletchingSkillStr = "Bowcraft/Fletching"
local shaftSkillThreshould = 35.0
local BOARDS_GRAPHIC = 0x1BD7

-- Crafting items by skill range
local BOWCRAFT_FLETCHING_ITEMS = {
    { name = "Shaft",          minSkill = 0.0, maxSkill = shaftSkillThreshould - 0.1, category = 1, craft = 10, final = 9 },
    { name = "Bow",            minSkill = shaftSkillThreshould, maxSkill = 64.9, category = 15, craft = 3, final = 2 },
    { name = "Crossbow",       minSkill = 65.0, maxSkill = 84.9, category = 15, craft = 10, final = 9 },
    { name = "Heavy Crossbow", minSkill = 85.0, maxSkill = 100.0, category = 15, craft = 17, final = 16 }
}

-- Pre-Work Function: pick one Board from the ground into Player Backpack
local function preWork()
    local bowcraftFletchingSkillLevel = bl.getSkillValue(bowcraftFletchingSkillStr)
    if bowcraftFletchingSkillLevel >= shaftSkillThreshould then
        -- No prework needed...
        return
    end
    return bl.findItemOnGroundPickAndDropInBackpack(BOARDS_GRAPHIC, 1)
end

-- User Settings
local config = {
	TOOL_ID = 0x1022,              -- Fletcher's Tools
	GUMP_ID = 2653346093,          -- Gump ID used by Bowcraft and Fletching
	MAKE_LAST_BUTTON_ID = 21,      -- "Make Last" button
    SKILL_TO_LEVEL = bowcraftFletchingSkillStr,
    ITEMS = BOWCRAFT_FLETCHING_ITEMS,
    PREWORK_FUNCTION = preWork
}

cll.craftingLoop(config)