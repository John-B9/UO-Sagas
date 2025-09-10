----------------------------------------------------------------------
-- Base Lib
-- Author: JohnB9
--
-- Mentions: Halesluker (stole some functions from Sagas Bot)
--           
--
-- Description: Generic utility functions for all scripts
----------------------------------------------------------------------

---------------
-- Functions --
---------------

local function findInInventory_(itemTypeID)

    local items = Items.FindByFilter({ graphics = itemTypeID, onground = false })
    if not items or #items == 0 then
        return nil
    end

    -- Filter out items that are not on player
    for i = #items, 1, -1 do
        if items[i].RootContainer ~= Player.Serial then
            table.remove(items, i)
        end
    end

    return items
end

local function findItemOnGround_(itemGraphicID)
    local filter = { onground = true, rangemax = 2, graphics = {itemGraphicID} }
    local list = Items.FindByFilter(filter)
    if #list > 0 then
        local board = list[1]
        Messages.Print("Found Board at X:"..board.X.." Y:"..board.Y)
        return board
    else
        Messages.Print("No Board (Graphic: 0x"..string.format("%X", itemGraphicID)..") found on the ground within range.")
        return nil
    end
end

local function findItemOnGroundPickAndDropInBackpack_(itemGraphicID, quantity)
    local item = findItemOnGround_(itemGraphicID)
    if item == nil then
        Messages.Print("Missing "..item.Name.." Raw Fish Steak in ground to cook!...")
        return false
    end
    
    local itemName = item.Name
    Messages.Print("Picking up "..quantity.." "..itemName)
    Player.PickUp(item.Serial, quantity)
    Pause(600)
    
    Messages.Print("Picking up "..quantity.." "..itemName.." into backpack...")
    Player.DropInBackpack()
    Pause(300)
    
    return true
end

local function getSkillValue_(skillNameStr)
    local skill = Skills.GetValue(skillNameStr)
    return tonumber(string.format("%.1f", skill))
end

local function printIfDebug_(debug, stringToPrint)
    if debug then
        Messages.Print(stringToPrint, 69, Player.Serial)
    end
end

------------
-- Export --
------------

local Obj = {
    findInInventory = findInInventory_,
    getSkillValue = getSkillValue_,
    printIfDebug = printIfDebug_,
    findItemOnGround = findItemOnGround_,
    findItemOnGroundPickAndDropInBackpack = findItemOnGroundPickAndDropInBackpack_
}

return Obj
