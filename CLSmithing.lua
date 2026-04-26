----------------------------------------------------------------------
-- CL (Crafting Leveling) Smithing
-- Author: JohnB9
--
-- Description: To level up Smithing
----------------------------------------------------------------------

local bl = Import('BaseLib')
local cll = Import('CLLib')

-- Blacksmithing items by skill range
local SMITH_ITEMS = {
    { name = "Dagger",   		   minSkill = 00.0, maxSkill = 49.9, category = 36, craft = 17,  final = 16 },
    { name = "Ringmail Gloves",    minSkill = 50.0, maxSkill = 61.9, category = 1, craft = 3,  final = 2 },
    { name = "Platemail Gorget",   minSkill = 62.0, maxSkill = 79.9, category = 15, craft = 17,  final = 16, graphic_id =  5139 },
    { name = "Platemail Gloves",   minSkill = 80.0, maxSkill = 89.9, category = 15, craft = 10, final = 9, graphic_id =  5140 },
    { name = "Plate Arms",         minSkill = 90.0, maxSkill = 93.9, category = 15, craft = 3, final = 2, graphic_id =  5136 },
    { name = "Plate Legs",         minSkill = 94.0, maxSkill = 96.9, category = 15, craft = 24, final = 23, graphic_id =  5137 },
    { name = "Plate Tunic",        minSkill = 97.0, maxSkill = 120.0, category = 15, craft = 31, final = 30, graphic_id =  5141 },
}

-- Post-Work Function: smelt the crafted item back into ingots
local function postWork(config_)
    local smithItem = cll.getItemToCraft(config_)
    if not smithItem then
        Console.debug("No configured craft item!")
        return true
    end

    local itemToSmelt = bl.findInInventory(smithItem.graphic_id)
    if not itemToSmelt or #itemToSmelt == 0 then
        Console.debug("No item to smelt!")
        return true
    end

    for i, item in ipairs(itemToSmelt) do
        -- press Smelt Gump Button
        Gumps.PressButton(2653346093, 14)
        Target.WaitForTarget(1000)
        -- select crafted item
        Target.TargetSerial(item.Serial)
        Gumps.WaitForGump(2653346093, 1000)
        break
    end

    Pause(500)
    return true
end

-- User Settings
local config = {
    TOOL_ID = 0x13E3,              -- Smith's Hammer
    GUMP_ID = 2653346093,          -- Gump ID used by Blacksmithing
    MAKE_LAST_BUTTON_ID = 21,      -- "Make Last" button
    SKILL_TO_LEVEL = "Blacksmithy",
    ITEMS = SMITH_ITEMS,
    PREWORK_FUNCTION = nil,
    POSTWORK_FUNCTION = postWork
}

cll.craftingLoop(config)