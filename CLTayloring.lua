----------------------------------------------------------------------
--- CL (Crafting Leveling) Tailoring
--- Author: JohnB9
---
--- Description: To level up Tailoring
----------------------------------------------------------------------

local bl = Import('BaseLib')
local cll = Import('CLLib')
local ius = Import('IUScissors')

-----------------
--- Variables ---
-----------------

--- Tayloring items by skill range
local TAYLORING_ITEMS = {
    { name = "Doublet",   		   minSkill = 0.0, maxSkill = 20.6, category = 8, craft = 3,  final = 2 },
    { name = "Kilt",   		       minSkill = 20.7, maxSkill = 24.7, category = 15, craft = 17,  final = 21 },
    { name = "Short Pants",        minSkill = 24.8, maxSkill = 44.9, category = 15, craft = 3,  final = 2 },
    { name = "Full Apron",         minSkill = 45.0, maxSkill = 49.9, category = 22, craft = 17,  final = 16 },
    { name = "Oil Cloth",          minSkill = 50.0, maxSkill = 74.9, category = 22, craft = 24,  final = 23, graphic_id = nil },        --- No point in cutting
    { name = "Leather Sleeves",    minSkill = 75.0, maxSkill = 77.9, category = 43, craft = 24,  final = 23, graphic_id =  5069 },
    { name = "Leather Tunic",      minSkill = 78.0, maxSkill = 78.9, category = 43, craft = 38,  final = 37, graphic_id =  5068 },
    { name = "Studded Gorget",     minSkill = 79.0, maxSkill = 82.9, category = 50, craft = 3,  final = 2, graphic_id =  5078 },
    { name = "Studded Gloves",     minSkill = 83.0, maxSkill = 104.9, category = 50, craft = 10,  final = 9, graphic_id =  5077 },
    { name = "Studded Tunic",      minSkill = 105.0, maxSkill = 119.9, category = 50, craft = 31,  final = 30, graphic_id =  5083 }
}

--- Post-Work Function: cut the crafted item back into leather
local function postWork(config_)
    local taylorItem = cll.getItemToCraft(config_)
    if not taylorItem then
        Console.debug("No configured craft item!")
        return true
    end

    local itemToCut = bl.findInInventory(taylorItem.graphic_id)
    if not itemToCut or #itemToCut == 0 then
        Console.debug("No item to cut!")
        return true
    end

    for i, item in ipairs(itemToCut) do
        --- use scissors
        ius.useScissors(nil, true)
        Target.WaitForTarget(1000)
        --- select crafted item
        Target.TargetSerial(item.Serial)
        Gumps.WaitForGump(2653346093, 1000)
        break
    end

    Pause(500)
    return true
end

--- User Settings
local config = {
    TOOL_ID = 0x0F9D,              --- Sewing Kit
    GUMP_ID = 2653346093,          --- Gump ID used by Tayloring
    MAKE_LAST_BUTTON_ID = 21,      --- "Make Last" button
    SKILL_TO_LEVEL = "Tailoring",
    ITEMS = TAYLORING_ITEMS,
    PREWORK_FUNCTION = nil,
    POSTWORK_FUNCTION = postWork
}

-----------
--- Run ---
-----------

cll.craftingLoop(config)