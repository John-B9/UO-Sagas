----------------------------------------------------------------------
--- IU (Item Usage) Identification Wand
--- Author: JohnB9
---
--- Description: Import this if you want to call 'useIdWand' from
---              another script
--- 
---              Accepts a callback function, to be executed after
---              identification is done
----------------------------------------------------------------------

-- ========================================
-- Imported: IPLib
-- ========================================

function BaseLib_printIfDebug(debug, stringToPrint)
    if debug then
        Console.debug(stringToPrint)

    end
end

debugEnabled = false

function IPLib_getItemSingleValueProperty(item, singleValuePropertyRegexStr)
    BaseLib_printIfDebug(debugEnabled, item.Properties)
    local cleanProperties = string.gsub(item.Properties, "<.->", "")
    BaseLib_printIfDebug(debugEnabled, cleanProperties)
    local regexMatchIter = string.gmatch(cleanProperties, singleValuePropertyRegexStr)
    local propertyVal = regexMatchIter()
    if propertyVal == nil then
        BaseLib_printIfDebug(debugEnabled, "Single Value Property = (nil)")
        return nil
    end
    BaseLib_printIfDebug(debugEnabled, "Single Value Property = (" .. propertyVal .. ")")
    return propertyVal
end

function IPLib_getItemSingleValuePropertyNumber(item, singleValuePropertyRegexStr)
    local propertyVal = IPLib_getItemSingleValueProperty(item, singleValuePropertyRegexStr)
    return tonumber(propertyVal)
end

uses_remaining_regex_str = "Uses Remaining: (%d+)"

identification_charges_regex_str = "Identification Charges: (%d+)"
function IPLib_getIdentificationCharges(item)
    return IPLib_getItemSingleValuePropertyNumber(item, identification_charges_regex_str)
end

material_regex_str = "Material: (%w+)"

contents_regex_str = "Contents: (%d+)/(%d+) Items"

durability_regex_str = "Durability: (%d+)/(%d+)"

function IPLib_getItemWithBestPropertyValue_singleID(itemID, propertyGetter, propertyFieldRegexStr, comparePredicate, itemAcceptPredicate)
    local bestItem = nil
    local bestItemProperties = nil
    local items = Items.FindInContainer(Player.Backpack.Serial, itemID)
    for i, item in ipairs(items) do
        BaseLib_printIfDebug(debugEnabled, itemAcceptPredicate)
        if itemAcceptPredicate == nil or itemAcceptPredicate(item) then
            local itemProperties = propertyGetter(item, propertyFieldRegexStr)
            if bestItem == nil or comparePredicate(itemProperties, bestItemProperties) then
                bestItem = item
                bestItemProperties = itemProperties
            end
        end
    end

    if bestItem == nil then
        BaseLib_printIfDebug(debugEnabled, "Found no item with ID = " .. itemID)
    end

    return bestItem
end

function IPLib_getItemWithBestPropertyValue_listOfIDs(listItemIDs, propertyGetter, propertyFieldRegexStr, comparePredicate, itemAcceptPredicate)
    local bestItemsAndProperties = {}
    for i, itemID in ipairs(listItemIDs) do
        local bestItemProperty = nil
        local bestItem = IPLib_getItemWithBestPropertyValue_singleID(itemID, propertyGetter, propertyFieldRegexStr, comparePredicate, itemAcceptPredicate)
        if bestItem ~= nil then
            bestItemProperty = propertyGetter(bestItem, propertyFieldRegexStr)
            bestItemsAndProperties[i] = { bestItem, bestItemProperty }
        else
            bestItemsAndProperties[i] = { nil, nil }
        end
    end
    bestBestItem = nil
    bestBestItemProperty = nil
    for _, element in ipairs(bestItemsAndProperties) do
        item = element[1]
        itemProperty = element[2]
        if item ~= nil then
            if bestBestItem == nil or comparePredicate(itemProperty, bestBestItemProperty) then
                bestBestItem = item
                bestBestItemProperty = itemProperty
            end
        end
    end
    return bestBestItem
end

function IPLib_getItemWithBestPropertyValue(itemIDOrListItemIDs, propertyGetter, propertyFieldRegexStr, comparePredicate, itemAcceptPredicate)
    if type(itemIDOrListItemIDs) == "number" then
        return IPLib_getItemWithBestPropertyValue_singleID(itemIDOrListItemIDs, propertyGetter, propertyFieldRegexStr, comparePredicate, itemAcceptPredicate)
    else
        return IPLib_getItemWithBestPropertyValue_listOfIDs(itemIDOrListItemIDs, propertyGetter, propertyFieldRegexStr, comparePredicate, itemAcceptPredicate)
    end
end

function IPLib_lessSinglePropertyValueComparePredicate(lprop, rprop)
    return lprop <= rprop
end

function IPLib_getItemWithLessSinglePropertyValue(itemID, fieldStr, itemAcceptPredicate)
    return IPLib_getItemWithBestPropertyValue(itemID, IPLib_getItemSingleValuePropertyNumber, fieldStr, IPLib_lessSinglePropertyValueComparePredicate, itemAcceptPredicate)
end

function IPLib_getItemWithLessIdentificationCharges(itemID, itemAcceptPredicate)
    return IPLib_getItemWithLessSinglePropertyValue(itemID, identification_charges_regex_str, itemAcceptPredicate)
end

-- End of: IPLib
-- ========================================

-----------------
--- Functions ---
-----------------

function useIdWand_(callback)

    --- get wand with less charges
    local wandGraphicIDs = { 3570, 3571, 3572, 3573 }
    wand = IPLib_getItemWithLessIdentificationCharges(wandGraphicIDs, nil)
    if wand == nil then
        Messages.Overhead("Missing Wand", 69, Player.Serial)
        return
    end

    --- use or drop at feet if no charges
    charges = IPLib_getIdentificationCharges(wand)
    if charges == 0 then
        Messages.Overhead("Wand out of charges", 69, Player.Serial)
        Messages.Overhead("Dropping wand", 69, Player.Serial)
        Player.PickUp(wand.Serial)
        Player.DropOnGround()
    else
        Messages.Overhead("Using ID Wand", 69, Player.Serial)
        Player.UseObject(wand.Serial)
    end
    Pause(500)

    --- handle callback
    if callback then
        callback()
    end

end

--------------
--- Export ---
--------------

Obj = {
    useIdWand = useIdWand_
}

return Obj