----------------------------------------------------------------------
--- IP (Item Properties) Lib
--- Author: JohnB9
---
--- Description: Utility functions to handle item "Properties"
---     * Parse values from the "Properties" of an item
---     * Get the item with the "best properties"
---     * Equip the item with the "best properties"
----------------------------------------------------------------------

local bl = Import('BaseLib')

local debugEnabled = false

-------------------------------
--- Single Value Properties ---
-------------------------------

local function getItemSingleValueProperty_(item, singleValuePropertyRegexStr)
    bl.printIfDebug(debugEnabled, item.Properties)
    local cleanProperties = string.gsub(item.Properties, "<.->", "")
    bl.printIfDebug(debugEnabled, cleanProperties)
    local regexMatchIter = string.gmatch(cleanProperties, singleValuePropertyRegexStr)
    local propertyVal = regexMatchIter()
    if propertyVal == nil then
        bl.printIfDebug(debugEnabled, "Single Value Property = (nil)")
        return nil
    end
    bl.printIfDebug(debugEnabled, "Single Value Property = (" .. propertyVal .. ")")
    return propertyVal
end

local function getItemSingleValuePropertyNumber_(item, singleValuePropertyRegexStr)
    local propertyVal = getItemSingleValueProperty_(item, singleValuePropertyRegexStr)
    return tonumber(propertyVal)
end

-------------------------------------------
--- Single Value Properties (Instances) ---
-------------------------------------------

local uses_remaining_regex_str = "Uses Remaining: (%d+)"
local function getUsesRemaining_(item)
    return getItemSingleValuePropertyNumber_(item, uses_remaining_regex_str)
end

local identification_charges_regex_str = "Identification Charges: (%d+)"
local function getIdentificationCharges_(item)
    return getItemSingleValuePropertyNumber_(item, identification_charges_regex_str)
end

local material_regex_str = "Material: (%w+)"
local function getMaterial_(item)
    return getItemSingleValueProperty_(item, material_regex_str)
end

-------------------------------
--- Double Value Properties ---
-------------------------------

local function getItemDoubleValueProperty_(item, doubleValuePropertyRegexStr)
    bl.printIfDebug(debugEnabled, item.Properties)
    local cleanProperties = string.gsub(item.Properties, "<.->", "")
    bl.printIfDebug(debugEnabled, cleanProperties)
    local regexMatchIter = string.gmatch(cleanProperties, doubleValuePropertyRegexStr)
    local lPropertyVal, rPropertyVal = regexMatchIter()
    if lPropertyVal == nil or rPropertyVal == nil then
        bl.printIfDebug(debugEnabled, "Double Value Property = (nil)")
        return nil
    end
    bl.printIfDebug(debugEnabled, "Double Value Property = (" .. lPropertyVal .. "," .. rPropertyVal .. ")")
    return { tonumber(lPropertyVal), tonumber(rPropertyVal) }
end

-------------------------------------------
--- Double Value Properties (Instances) ---
-------------------------------------------

local contents_regex_str = "Contents: (%d+)/(%d+) Items"
local function getContents_(item)
    return getItemDoubleValueProperty_(item, contents_regex_str)
end

local durability_regex_str = "Durability: (%d+)/(%d+)"
local function getDurability_(item)
    return getItemDoubleValueProperty_(item, durability_regex_str)
end

-----------------
--- Best Item ---
-----------------

local function getItemWithBestPropertyValue_singleID_(itemID, propertyGetter, propertyFieldRegexStr, comparePredicate, itemAcceptPredicate)
    local bestItem = nil
    local bestItemProperties = nil
    local items = Items.FindInContainer(Player.Backpack.Serial, itemID)
    for i, item in ipairs(items) do
        bl.printIfDebug(debugEnabled, itemAcceptPredicate)
        if itemAcceptPredicate == nil or itemAcceptPredicate(item) then
            local itemProperties = propertyGetter(item, propertyFieldRegexStr)
            if bestItem == nil or comparePredicate(itemProperties, bestItemProperties) then
                bestItem = item
                bestItemProperties = itemProperties
            end
        end
    end

    if bestItem == nil then
        bl.printIfDebug(debugEnabled, "Found no item with ID = " .. itemID)
    end

    return bestItem
end

local function getItemWithBestPropertyValue_listOfIDs_(listItemIDs, propertyGetter, propertyFieldRegexStr, comparePredicate, itemAcceptPredicate)
    local bestItemsAndProperties = {}
    for i, itemID in ipairs(listItemIDs) do
        local bestItemProperty = nil
        local bestItem = getItemWithBestPropertyValue_singleID_(itemID, propertyGetter, propertyFieldRegexStr, comparePredicate, itemAcceptPredicate)
        if bestItem ~= nil then
            bestItemProperty = propertyGetter(bestItem, propertyFieldRegexStr)
            bestItemsAndProperties[i] = { bestItem, bestItemProperty }
        else
            bestItemsAndProperties[i] = { nil, nil }
        end
    end
    local bestBestItem = nil
    local bestBestItemProperty = nil
    for _, element in ipairs(bestItemsAndProperties) do
        local item = element[1]
        local itemProperty = element[2]
        if item ~= nil then
            if bestBestItem == nil or comparePredicate(itemProperty, bestBestItemProperty) then
                bestBestItem = item
                bestBestItemProperty = itemProperty
            end
        end
    end
    return bestBestItem
end

local function getItemWithBestPropertyValue_(itemIDOrListItemIDs, propertyGetter, propertyFieldRegexStr, comparePredicate, itemAcceptPredicate)
    if type(itemIDOrListItemIDs) == "number" then
        return getItemWithBestPropertyValue_singleID_(itemIDOrListItemIDs, propertyGetter, propertyFieldRegexStr, comparePredicate, itemAcceptPredicate)
    else
        return getItemWithBestPropertyValue_listOfIDs_(itemIDOrListItemIDs, propertyGetter, propertyFieldRegexStr, comparePredicate, itemAcceptPredicate)
    end
end

----------------------------------
--- Less Single Property Value ---
----------------------------------

local function lessSinglePropertyValueComparePredicate_(lprop, rprop)
    return lprop <= rprop
end

local function getItemWithLessSinglePropertyValue_(itemID, fieldStr, itemAcceptPredicate)
    return getItemWithBestPropertyValue_(itemID, getItemSingleValuePropertyNumber_, fieldStr, lessSinglePropertyValueComparePredicate_, itemAcceptPredicate)
end

local function equipItemWithLessSinglePropertyValue_(itemID, fieldStr, itemName, itemAcceptPredicate)
    local itemToEquip = getItemWithLessSinglePropertyValue_(itemID, fieldStr, itemAcceptPredicate)
    if itemToEquip == nil then
        Messages.Print("Missing " .. itemName .. "...", 69, Player.Serial)
        return nil
    end
    Player.Equip(itemToEquip.Serial)
    return itemToEquip
end

----------------------------------------------
--- Less Single Property Value - Instances ---
----------------------------------------------

local function getItemWithLessUsesRemaining_(itemID, itemAcceptPredicate)
    return getItemWithLessSinglePropertyValue_(itemID, uses_remaining_regex_str, itemAcceptPredicate)
end

local function equipItemWithLessUsesRemaining_(itemID, itemName, itemAcceptPredicate)
    return equipItemWithLessSinglePropertyValue_(itemID, uses_remaining_regex_str, itemName, itemAcceptPredicate)
end

local function getItemWithLessIdentificationCharges_(itemID, itemAcceptPredicate)
    return getItemWithLessSinglePropertyValue_(itemID, identification_charges_regex_str, itemAcceptPredicate)
end

----------------------------------
--- Less Double Property Value ---
----------------------------------

local function lessPropertyFirstValueComparePredicate_(lprops, rprops)
    return lprops[1] <= rprops[1]
end

local function getItemWithLessDoublePropertyFirstValue_(itemID, fieldStr)
    return getItemWithBestPropertyValue_(itemID, getItemDoubleValueProperty_, fieldStr, lessPropertyFirstValueComparePredicate_, nil)
end

local function mostPropertyFirstValueComparePredicate_(lprops, rprops)
    return lprops[1] >= rprops[1]
end

local function getItemWithMostDoublePropertyFirstValue_(itemID, fieldStr)
    return getItemWithBestPropertyValue_(itemID, getItemDoubleValueProperty_, fieldStr, mostPropertyFirstValueComparePredicate_, nil)
end

local function equipItemWithLessDoublePropertyFirstValue_(itemID, fieldStr, itemName)
    local itemToEquip = getItemWithLessDoublePropertyFirstValue_(itemID, fieldStr)
    if itemToEquip == nil then
        Messages.Print("Missing " .. itemName .. "...", 69, Player.Serial)
        return nil
    end
    Player.Equip(itemToEquip.Serial)
    return itemToEquip
end

----------------------------------------------
--- Less Double Property Value - Instances ---
----------------------------------------------

local function getItemWithLessContent_(itemID)
    return getItemWithLessDoublePropertyFirstValue_(itemID, contents_regex_str)
end

local function getItemWithMostContent_(itemID)
    return getItemWithMostDoublePropertyFirstValue_(itemID, contents_regex_str)
end

local function equipItemWithLessDurability_(itemID, itemName)
    return equipItemWithLessDoublePropertyFirstValue_(itemID, durability_regex_str, itemName)
end

--------------
--- Export ---
--------------

local Obj = {
    getItemSingleValueProperty = getItemSingleValueProperty_,
    getItemSingleValuePropertyNumber = getItemSingleValuePropertyNumber_,
    getMaterial = getMaterial_,
    getUsesRemaining = getUsesRemaining_,
    getIdentificationCharges = getIdentificationCharges_,
    getItemDoubleValueProperty = getItemDoubleValueProperty_,
    getContents = getContents_,
    getDurability = getDurability_,
    getItemWithLessSinglePropertyValue = getItemWithLessSinglePropertyValue_,
    equipItemWithLessSinglePropertyValue = equipItemWithLessSinglePropertyValue_,
    getItemWithLessUsesRemaining = getItemWithLessUsesRemaining_,
    equipItemWithLessUsesRemaining = equipItemWithLessUsesRemaining_,
    getItemWithLessIdentificationCharges = getItemWithLessIdentificationCharges_,
    getItemWithBestPropertyValue = getItemWithBestPropertyValue_,
    getItemWithLessDoublePropertyFirstValue = getItemWithLessDoublePropertyFirstValue_,
    getItemWithMostDoublePropertyFirstValue = getItemWithMostDoublePropertyFirstValue_,
    equipItemWithLessDoublePropertyFirstValue = equipItemWithLessDoublePropertyFirstValue_,
    getItemWithLessContent = getItemWithLessContent_,
    getItemWithMostContent = getItemWithMostContent_,
    equipItemWithLessDurability = equipItemWithLessDurability_
}

return Obj
