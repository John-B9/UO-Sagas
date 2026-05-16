----------------------------------------------------------------------
--- Base Lib
--- Author: JohnB9
---
--- Mentions: Halesluker (stole some functions from Sagas Bot)
---
---
--- Description: Generic utility functions for all scripts
----------------------------------------------------------------------

-----------------
--- Functions ---
-----------------

local function deepCopy_(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepCopy_(orig_key)] = deepCopy_(orig_value)
        end
        setmetatable(copy, deepCopy_(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

local function stringContainsAnySubString_(str, subStr)
    for i = 1, #subStr do
        if subStr[i] == str then
            return true
        end
    end
    return false
end

local function findInInventory_(itemTypeID)

    local items = Items.FindByFilter({ graphics = itemTypeID, onground = false })
    if not items or #items == 0 then
        return nil
    end

    --- Filter out items that are not on player
    for i = #items, 1, -1 do
        if items[i].RootContainer ~= Player.Serial then
            table.remove(items, i)
        end
    end

    return items
end

local function findInInventoryGetFirst_(itemTypeID)

    local items = findInInventory_(itemTypeID)
    if not items or #items == 0 then
        Console.debug("No item found in inventory ("..itemTypeID..").")
        return nil
    end
    Console.debug("Found " .. #items .. " items ("..itemTypeID..") in inventory.")

    local firstItem = nil
    for _, item in ipairs(items) do
        if item and item.Serial then
            firstItem = item
            break
        end
    end

    return firstItem
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
        Messages.Print("Found no item...")
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
        Console.debug(stringToPrint)
        ---Messages.Print(stringToPrint, 69, Player.Serial)
    end
end

local function getHpPercentage_()
    return (Player.Hits / Player.HitsMax) * 100
end

--------------
--- Export ---
--------------

local Obj = {
    deepCopy = deepCopy_,
    stringContainsAnySubString = stringContainsAnySubString_,
    findInInventory = findInInventory_,
    findInInventoryGetFirst = findInInventoryGetFirst_,
    getSkillValue = getSkillValue_,
    printIfDebug = printIfDebug_,
    findItemOnGround = findItemOnGround_,
    findItemOnGroundPickAndDropInBackpack = findItemOnGroundPickAndDropInBackpack_,
    getHpPercentage = getHpPercentage_
}

return Obj
