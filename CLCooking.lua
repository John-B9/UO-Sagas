----------------------------------------------------------------------
-- CL (Crafting Leveling) Cooking
-- Author: JohnB9
--
-- Description: To level up Cooking
----------------------------------------------------------------------

local bl = Import('BaseLib')
local cll = Import('CLLib')

-- Constants
local cookingSkillStr = "Cooking"
local fishSteakSkillThreshould = 70.0
local RAW_FISH_GRAPHIC = 0x097A

-- Cooking items by skill range
local COOKING_ITEMS = {
    { name = "Fish Steaks", minSkill = 0.0, maxSkill = fishSteakSkillThreshould - 0.1, category = 22, craft = 17, final = 16 }
}

-- Pre-Work Function: pick one Raw fish Steak from the ground into Player Backpack
local function preWork()
    local cookingSkillLevel = bl.getSkillValue(cookingSkillStr)
    if cookingSkillLevel >= fishSteakSkillThreshould then
        -- No prework needed...
        return
    end
    return bl.findItemOnGroundPickAndDropInBackpack(RAW_FISH_GRAPHIC, 1)
end

-- User Settings
local config = {
	TOOL_ID = 0x097F,              -- Skillet
	GUMP_ID = 2653346093,          -- Gump ID used by Cooking
	MAKE_LAST_BUTTON_ID = 21,      -- "Make Last" button
    SKILL_TO_LEVEL = cookingSkillStr,
    ITEMS = COOKING_ITEMS,
    PREWORK_FUNCTION = preWork
}

cll.craftingLoop(config)