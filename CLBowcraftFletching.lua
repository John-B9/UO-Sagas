----------------------------------------------------------------------
--  CL (Crafting Leveling) Bowcraft Fletching
--  Author: JohnB9
-- 
--  Description: To level up Bowcraft/Fletching
----------------------------------------------------------------------

local bl = Import('BaseLib')
local cll = Import('CLLib')

-----------------
--- Variables ---
-----------------

--- Constants
local bowcraftFletchingSkillStr = "Bowcraft/Fletching"

--- Crafting items by skill range
local BOWCRAFT_FLETCHING_ITEMS = {
    { name = "Shaft",          minSkill =  0.0, maxSkill =  34.9, category =  1, craft = 10, final =  9, material = 0x1BD7 }, --- drop all boards at your feet before crafting (!)
    { name = "Bow",            minSkill = 35.0, maxSkill =  64.9, category = 15, craft =  3, final =  2, material = nil    },
    { name = "Crossbow",       minSkill = 65.0, maxSkill =  84.9, category = 15, craft = 10, final =  9, material = nil    },
    { name = "Heavy Crossbow", minSkill = 85.0, maxSkill = 119.9, category = 15, craft = 17, final = 16, material = nil    }
}

--- Pre-Work Function: pick one Board from the ground into Player Backpack (if needed)
local function preWork(config_)
    local craftItem = cll.getItemToCraft(config_)
    if not craftItem then
        Console.debug("No configured craft item!")
        return false
    end
    if not craftItem.material then
        Console.debug("No Pre-Work Needed!")
        return true
    end
    return bl.findItemOnGroundPickAndDropInBackpack(craftItem.material, 1)
end

--- User Settings
local config = {
    TOOL_ID = 0x1022,              -- Fletcher's Tools
    GUMP_ID = 2653346093,          -- Gump ID used by Bowcraft and Fletching
    MAKE_LAST_BUTTON_ID = 21,      -- "Make Last" button
    SKILL_TO_LEVEL = bowcraftFletchingSkillStr,
    ITEMS = BOWCRAFT_FLETCHING_ITEMS,
    PREWORK_FUNCTION = preWork,
    POSTWORK_FUNCTION = nil
}

-----------
--- Run ---
-----------

cll.craftingLoop(config)