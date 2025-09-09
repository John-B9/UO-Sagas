----------------------------------------------------------------------
-- IP (Item Properties) Lib
-- Author: JohnB9
--
-- Description: Utility functions to handle item "Properties"
--     * Parse values from the "Properties" of an item
--     * Get the item with the "best properties"
----------------------------------------------------------------------

local bl = Import('BaseLib')

local debugEnabled = false

-----------------------------
-- Single Value Properties --
-----------------------------

local function getItemSingleValueProperty_(item, singleValuePropertyRegexStr)
    local regexMatchIter = string.gmatch(item.Properties, singleValuePropertyRegexStr)
    local propertyVal = regexMatchIter()
    if propertyVal == nil then
        bl.printIfDebug(debugEnabled, "Single Value Property = (nil)")
        return nil
    end
    bl.printIfDebug(debugEnabled, "Single Value Property = (" .. propertyVal .. ")")
    return tonumber(propertyVal)
end

-----------------------------------------
-- Single Value Properties (Instances) --
-----------------------------------------

local ueses_remaining_regex_str = "Uses Remaining: <.->(%d+)<.->"
local function getUsesRemaining_(item)
    return getItemSingleValueProperty_(item, ueses_remaining_regex_str)
end

local identification_charges_regex_str = "Identification Charges: (%d+)"
local function getIdentificationCharges_(item)
    return getItemSingleValueProperty_(item, identification_charges_regex_str)
end

-----------------------------
-- Double Value Properties --
-----------------------------

local function getItemDoubleValueProperty_(item, doubleValuePropertyRegexStr)
    local regexMatchIter = string.gmatch(item.Properties, doubleValuePropertyRegexStr)
    local lPropertyVal, rPropertyVal = regexMatchIter()
    if lPropertyVal == nil or rPropertyVal == nil then
        bl.printIfDebug(debugEnabled, "Double Value Property = (nil)")
        return nil
    end
    bl.printIfDebug(debugEnabled, "Double Value Property = (" .. lPropertyVal .. "," .. rPropertyVal .. ")")
    return { tonumber(lPropertyVal), tonumber(rPropertyVal) }
end

-----------------------------------------
-- Double Value Properties (Instances) --
-----------------------------------------

local contents_regex_str = "Contents: (%d+)/(%d+) Items"
local function getContents_(item)
    return getItemDoubleValueProperty_(item, contents_regex_str)
end

---------------
-- Best Item --
---------------

local function getItemWithBestPropertyValue_(itemID, propertyGetter, propertyFieldRegexStr, comparePredicate)
    local bestItem = nil
    local bestItemProperties = nil
    local items = Items.FindInContainer(Player.Backpack.Serial, itemID)
    for i, item in ipairs(items) do
        local itemProperties = propertyGetter(item, propertyFieldRegexStr)
        if bestItem == nil or comparePredicate(itemProperties, bestItemProperties) then
            bestItem = item
            bestItemProperties = itemProperties
        end
    end

    if bestItem == nil then
        Messages.Print("Found no item with ID = " .. itemID, 69, Player.Serial)
    end

    return bestItem
end

--------------------------------
-- Less Single Property Value --
--------------------------------

local function lessSinglePropertyValueComparePredicate_(lprop, rprop)
    return lprop <= rprop
end

local function getItemWithLessSinglePropertyValue_(itemID, fieldStr)
    return getItemWithBestPropertyValue_(itemID, getItemSingleValueProperty_, fieldStr,
        lessSinglePropertyValueComparePredicate_)
end

local function equipItemWithLessSinglePropertyValue_(itemID, fieldStr, itemName)
    local itemToEquip = getItemWithLessSinglePropertyValue_(itemID, fieldStr)
    if itemToEquip == nil then
        Messages.Print("Missing " .. itemName .. "...", 69, Player.Serial)
        return nil
    end
    Player.Equip(itemToEquip.Serial)
    return itemToEquip
end

--------------------------------------------
-- Less Single Property Value - Instances --
--------------------------------------------

local function getItemWithLessUsesRemaining_(itemID)
    return getItemWithLessSinglePropertyValue_(itemID, ueses_remaining_regex_str)
end

local function equipItemWithLessUsesRemaining_(itemID, itemName)
    return equipItemWithLessSinglePropertyValue_(itemID, ueses_remaining_regex_str, itemName)
end

local function getItemWithLessIdentificationCharges_(itemID)
    return getItemWithLessSinglePropertyValue_(itemID, identification_charges_regex_str)
end

--------------------------------
-- Less Double Property Value --
--------------------------------

local function lessPropertyFirstValueComparePredicate_(lprops, rprops)
    return lprops[1] <= rprops[1]
end

local function getItemWithLessDoublePropertyFirstValue_(itemID, fieldStr)
    return getItemWithBestPropertyValue_(itemID, getItemDoubleValueProperty_, fieldStr,
        lessPropertyFirstValueComparePredicate_)
end

local function mostPropertyFirstValueComparePredicate_(lprops, rprops)
    return lprops[1] >= rprops[1]
end

local function getItemWithMostDoublePropertyFirstValue_(itemID, fieldStr)
    return getItemWithBestPropertyValue_(itemID, getItemDoubleValueProperty_, fieldStr,
        mostPropertyFirstValueComparePredicate_)
end

--------------------------------------------
-- Less Double Property Value - Instances --
--------------------------------------------

local function getItemWithLessContent_(itemID)
    return getItemWithLessDoublePropertyFirstValue_(itemID, contents_regex_str)
end

local function getItemWithMostContent_(itemID)
    return getItemWithMostDoublePropertyFirstValue_(itemID, contents_regex_str)
end

------------
-- Export --
------------

local Obj = {
    getItemSingleValueProperty = getItemSingleValueProperty_,
    getUsesRemaining = getUsesRemaining_,
    getIdentificationCharges = getIdentificationCharges_,
    getItemDoubleValueProperty = getItemDoubleValueProperty_,
    getContents = getContents_,
    getItemWithLessSinglePropertyValue = getItemWithLessSinglePropertyValue_,
    equipItemWithLessSinglePropertyValue = equipItemWithLessSinglePropertyValue_,
    getItemWithLessUsesRemaining = getItemWithLessUsesRemaining_,
    equipItemWithLessUsesRemaining = equipItemWithLessUsesRemaining_,
    getItemWithLessIdentificationCharges = getItemWithLessIdentificationCharges_,
    getItemWithBestPropertyValue = getItemWithBestPropertyValue_,
    getItemWithLessDoublePropertyFirstValue = getItemWithLessDoublePropertyFirstValue_,
    getItemWithMostDoublePropertyFirstValue = getItemWithMostDoublePropertyFirstValue_,
    getItemWithLessContent = getItemWithLessContent_,
    getItemWithMostContent = getItemWithMostContent_
}

return Obj
