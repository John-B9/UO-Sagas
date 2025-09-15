---------------
-- FUNCTIONS --
---------------

local debugEnabled = false

local function printIfDebug_(debug, stringToPrint)
    if debug then
        Messages.Print(stringToPrint, 69, Player.Serial)
    end
end

local function getItemSingleValueProperty_(item, singleValuePropertyRegexStr)
    local regexMatchIter = string.gmatch(item.Properties, singleValuePropertyRegexStr)
    local propertyVal = regexMatchIter()
    if propertyVal == nil then
        printIfDebug_(debugEnabled, "Single Value Property = (nil)")
        return nil
    end
    printIfDebug_(debugEnabled, "Single Value Property = (" .. propertyVal .. ")")
    return tonumber(propertyVal)
end

local function lessSinglePropertyValueComparePredicate_(lprop, rprop)
    return lprop <= rprop
end

local function getItemWithBestPropertyValue_singleID_(itemID, propertyGetter, propertyFieldRegexStr, comparePredicate)
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
        printIfDebug_(debugEnabled, "Found no item with ID = " .. itemID)
    end

    return bestItem
end

local function getItemWithBestPropertyValue_listOfIDs_(listItemIDs, propertyGetter, propertyFieldRegexStr, comparePredicate)
    local bestItemsAndProperties = {}
    for i, itemID in ipairs(listItemIDs) do
        local bestItemProperty = nil
        local bestItem = getItemWithBestPropertyValue_singleID_(itemID, propertyGetter, propertyFieldRegexStr, comparePredicate)
        if bestItem ~= nil then
            bestItemProperty = propertyGetter(bestItem, propertyFieldRegexStr)
        end
        bestItemsAndProperties[i] = { bestItem, bestItemProperty }
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

local function getItemWithBestPropertyValue_(itemIDOrListItemIDs, propertyGetter, propertyFieldRegexStr, comparePredicate)
    if type(itemIDOrListItemIDs) == "number" then
        return getItemWithBestPropertyValue_singleID_(itemIDOrListItemIDs, propertyGetter, propertyFieldRegexStr, comparePredicate)
    else
        return getItemWithBestPropertyValue_listOfIDs_(itemIDOrListItemIDs, propertyGetter, propertyFieldRegexStr, comparePredicate)
    end
end

local function getItemWithLessSinglePropertyValue_(itemID, fieldStr)
    return getItemWithBestPropertyValue_(itemID, getItemSingleValueProperty_, fieldStr,
        lessSinglePropertyValueComparePredicate_)
end

local identification_charges_regex_str = "Identification Charges: (%d+)"

local function getItemWithLessIdentificationCharges_(itemID)
    return getItemWithLessSinglePropertyValue_(itemID, identification_charges_regex_str)
end

local function getIdentificationCharges_(item)
    return getItemSingleValueProperty_(item, identification_charges_regex_str)
end

----------
-- MAIN --
----------

local wandGraphicIDs = { 3570, 3571, 3572, 3573 }
wand = getItemWithLessIdentificationCharges_(wandGraphicIDs)
if wand == nil then
    Messages.Overhead("Missing Wand", 69, Player.Serial)
    return
end

charges = getIdentificationCharges_(wand)
if charges == 0 then
    Messages.Overhead("Wand out of charges", 69, Player.Serial)
    Messages.Overhead("Dropping wand", 69, Player.Serial)
    Player.PickUp(wand.Serial)
    Player.DropOnGround()
else
    Messages.Overhead("Using ID Wand", 69, Player.Serial)
    Player.UseObject(wand.Serial)
end