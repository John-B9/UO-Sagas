----------------------------------------------------------------------
--- CL (Crafting Leveling) Cooking
--- Author: JohnB9
---
--- Description: To level up Cooking
----------------------------------------------------------------------

local bl = Import('BaseLib')
local cll = Import('CLLib')


-----------------
--- Variables ---
-----------------

--- Constants
local cookingSkillStr = "Cooking"

--- Cooking items by skill range
local COOKING_ITEMS = {
    { name = "Fish Steak" , minSkill =   0.0, maxSkill = 109.9, category = 22, craft = 17, final = 16, material = 0x097A }, --- drop all fish steaks at your feet before crafting (!)
    { name = "Cut Of Ribs", minSkill = 110.0, maxSkill = 119.9, category = 22, craft = 38, final = 37, material = 0x09F1 }  --- drop all cut of raw ribs at your feet before crafting (!)
}

--- Pre-Work Function: pick one Raw fish Steak/Cut Of Raw Ribs from the ground into Player Backpack
local function preWork(config_)
    local cookItem = cll.getItemToCraft(config_)
    if not cookItem then
        Console.debug("No configured cook item!")
        return false
    end
    if not cookItem.material then
        Console.debug("No Pre-Work Needed!")
        return true
    end
    return bl.findItemOnGroundPickAndDropInBackpack(cookItem.material, 1)
end

--- User Settings
local config = {
    TOOL_ID = 0x097F,              -- Skillet
    GUMP_ID = 2653346093,          -- Gump ID used by Cooking
    MAKE_LAST_BUTTON_ID = 21,      -- "Make Last" button
    SKILL_TO_LEVEL = cookingSkillStr,
    ITEMS = COOKING_ITEMS,
    PREWORK_FUNCTION = preWork,
    POSTWORK_FUNCTION = nil
}

-----------
--- Run ---
-----------

cll.craftingLoop(config)