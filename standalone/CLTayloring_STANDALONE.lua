----------------------------------------------------------------------
--- CL (Crafting Leveling) Tailoring
--- Author: JohnB9
---
--- Description: To level up Tailoring
----------------------------------------------------------------------

-- ========================================
-- Imported: BaseLib
-- ========================================

function BaseLib_deepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[BaseLib_deepCopy(orig_key)] = BaseLib_deepCopy(orig_value)
        end
        setmetatable(copy, BaseLib_deepCopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

function BaseLib_equalsAnyInTable(value, tableToCompare)
    for i = 1, #tableToCompare do
        if tableToCompare[i] == value then
            return true
        end
    end
    return false
end

function BaseLib_tableContains(tbl, val)
    for _, value in ipairs(tbl) do
        if value == val then
            return true
        end
    end
    return false
end

function BaseLib_findInInventory(itemTypeID)

    local items = Items.FindByFilter({ graphics = itemTypeID, onground = false })
    if not items or #items == 0 then
        return nil
    end

    for i = #items, 1, -1 do
        if items[i].RootContainer ~= Player.Serial then
            table.remove(items, i)
        end
    end

    return items
end

function BaseLib_findInInventoryGetFirst(itemTypeID)

    local items = BaseLib_findInInventory(itemTypeID)
    if not items or #items == 0 then
        Console.debug("No item found in inventory ("..itemTypeID..").")
        return nil
    end
    Console.debug("Found " .. #items .. " items ("..itemTypeID..") in inventory.")

    firstItem = nil
    for _, item in ipairs(items) do
        if item and item.Serial then
            firstItem = item
            break
        end
    end

    return firstItem
end

function BaseLib_findItemOnGround(itemGraphicID)
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

function BaseLib_findItemOnGroundPickAndDropInBackpack(itemGraphicID, quantity)
    local item = BaseLib_findItemOnGround(itemGraphicID)
    if item == nil then
        Messages.Print("Found no item...")
        return false
    end

    itemName = item.Name
    Messages.Print("Picking up "..quantity.." "..itemName)
    Player.PickUp(item.Serial, quantity)
    Pause(600)

    Messages.Print("Picking up "..quantity.." "..itemName.." into backpack...")
    Player.DropInBackpack()
    Pause(300)

    return true
end

function BaseLib_getSkillValue(skillNameStr)
    local skill = Skills.GetValue(skillNameStr)
    return tonumber(string.format("%.1f", skill))
end

function BaseLib_printIfDebug(debug, stringToPrint)
    if debug then
        Console.debug(stringToPrint)
        ---Messages.Print(stringToPrint, 69, Player.Serial)
    end
end

function BaseLib_getHpPercentage(player)
    return (player.Hits / player.HitsMax) * 100
end

-- End of: BaseLib
-- ========================================

-- ========================================
-- Imported: CLLib
-- ========================================

CLLib_IPLib_debugEnabled = false

function IPLib_getItemSingleValueProperty(item, singleValuePropertyRegexStr)
    BaseLib_printIfDebug(CLLib_IPLib_debugEnabled, item.Properties)
    local cleanProperties = string.gsub(item.Properties, "<.->", "")
    BaseLib_printIfDebug(CLLib_IPLib_debugEnabled, cleanProperties)
    local regexMatchIter = string.gmatch(cleanProperties, singleValuePropertyRegexStr)
    local propertyVal = regexMatchIter()
    if propertyVal == nil then
        BaseLib_printIfDebug(CLLib_IPLib_debugEnabled, "Single Value Property = (nil)")
        return nil
    end
    BaseLib_printIfDebug(CLLib_IPLib_debugEnabled, "Single Value Property = (" .. propertyVal .. ")")
    return propertyVal
end

function IPLib_getItemSingleValuePropertyNumber(item, singleValuePropertyRegexStr)
    local propertyVal = IPLib_getItemSingleValueProperty(item, singleValuePropertyRegexStr)
    return tonumber(propertyVal)
end

CLLib_IPLib_uses_remaining_regex_str = "Uses Remaining: (%d+)"
function IPLib_getUsesRemaining(item)
    return IPLib_getItemSingleValuePropertyNumber(item, CLLib_IPLib_uses_remaining_regex_str)
end

CLLib_IPLib_identification_charges_regex_str = "Identification Charges: (%d+)"
function IPLib_getIdentificationCharges(item)
    return IPLib_getItemSingleValuePropertyNumber(item, CLLib_IPLib_identification_charges_regex_str)
end

material_regex_str = "Material: (%w+)"
function IPLib_getMaterial(item)
    return IPLib_getItemSingleValueProperty(item, material_regex_str)
end

function IPLib_getItemDoubleValueProperty(item, doubleValuePropertyRegexStr)
    BaseLib_printIfDebug(CLLib_IPLib_debugEnabled, item.Properties)
    local cleanProperties = string.gsub(item.Properties, "<.->", "")
    BaseLib_printIfDebug(CLLib_IPLib_debugEnabled, cleanProperties)
    local regexMatchIter = string.gmatch(cleanProperties, doubleValuePropertyRegexStr)
    local lPropertyVal, rPropertyVal = regexMatchIter()
    if lPropertyVal == nil or rPropertyVal == nil then
        BaseLib_printIfDebug(CLLib_IPLib_debugEnabled, "Double Value Property = (nil)")
        return nil
    end
    BaseLib_printIfDebug(CLLib_IPLib_debugEnabled, "Double Value Property = (" .. lPropertyVal .. "," .. rPropertyVal .. ")")
    return { tonumber(lPropertyVal), tonumber(rPropertyVal) }
end

contents_regex_str = "Contents: (%d+)/(%d+) Items"
function IPLib_getContents(item)
    return IPLib_getItemDoubleValueProperty(item, contents_regex_str)
end

durability_regex_str = "Durability: (%d+)/(%d+)"
function IPLib_getDurability(item)
    return IPLib_getItemDoubleValueProperty(item, durability_regex_str)
end

function IPLib_getItemWithBestPropertyValue_singleID(itemID, propertyGetter, propertyFieldRegexStr, comparePredicate, itemAcceptPredicate)
    local bestItem = nil
    local bestItemProperties = nil
    local items = Items.FindInContainer(Player.Backpack.Serial, itemID)
    for i, item in ipairs(items) do
        BaseLib_printIfDebug(CLLib_IPLib_debugEnabled, itemAcceptPredicate)
        if itemAcceptPredicate == nil or itemAcceptPredicate(item) then
            local itemProperties = propertyGetter(item, propertyFieldRegexStr)
            if bestItem == nil or comparePredicate(itemProperties, bestItemProperties) then
                bestItem = item
                bestItemProperties = itemProperties
            end
        end
    end

    if bestItem == nil then
        BaseLib_printIfDebug(CLLib_IPLib_debugEnabled, "Found no item with ID = " .. itemID)
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

function IPLib_equipItemWithLessSinglePropertyValue(itemID, fieldStr, itemName, itemAcceptPredicate)
    local itemToEquip = IPLib_getItemWithLessSinglePropertyValue(itemID, fieldStr, itemAcceptPredicate)
    if itemToEquip == nil then
        Messages.Print("Missing " .. itemName .. "...", 69, Player.Serial)
        return nil
    end
    Player.Equip(itemToEquip.Serial)
    return itemToEquip
end

function IPLib_getItemWithLessUsesRemaining(itemID, itemAcceptPredicate)
    return IPLib_getItemWithLessSinglePropertyValue(itemID, CLLib_IPLib_uses_remaining_regex_str, itemAcceptPredicate)
end

function IPLib_equipItemWithLessUsesRemaining(itemID, itemName, itemAcceptPredicate)
    return IPLib_equipItemWithLessSinglePropertyValue(itemID, CLLib_IPLib_uses_remaining_regex_str, itemName, itemAcceptPredicate)
end

function IPLib_getItemWithLessIdentificationCharges(itemID, itemAcceptPredicate)
    return IPLib_getItemWithLessSinglePropertyValue(itemID, CLLib_IPLib_identification_charges_regex_str, itemAcceptPredicate)
end

function IPLib_lessPropertyFirstValueComparePredicate(lprops, rprops)
    return lprops[1] <= rprops[1]
end

function IPLib_getItemWithLessDoublePropertyFirstValue(itemID, fieldStr)
    return IPLib_getItemWithBestPropertyValue(itemID, IPLib_getItemDoubleValueProperty, fieldStr, IPLib_lessPropertyFirstValueComparePredicate, nil)
end

function IPLib_mostPropertyFirstValueComparePredicate(lprops, rprops)
    return lprops[1] >= rprops[1]
end

function IPLib_getItemWithMostDoublePropertyFirstValue(itemID, fieldStr)
    return IPLib_getItemWithBestPropertyValue(itemID, IPLib_getItemDoubleValueProperty, fieldStr, IPLib_mostPropertyFirstValueComparePredicate, nil)
end

function IPLib_equipItemWithLessDoublePropertyFirstValue(itemID, fieldStr, itemName)
    local itemToEquip = IPLib_getItemWithLessDoublePropertyFirstValue(itemID, fieldStr)
    if itemToEquip == nil then
        Messages.Print("Missing " .. itemName .. "...", 69, Player.Serial)
        return nil
    end
    Player.Equip(itemToEquip.Serial)
    return itemToEquip
end

function IPLib_getItemWithLessContent(itemID)
    return IPLib_getItemWithLessDoublePropertyFirstValue(itemID, contents_regex_str)
end

function IPLib_getItemWithMostContent(itemID)
    return IPLib_getItemWithMostDoublePropertyFirstValue(itemID, contents_regex_str)
end

function IPLib_equipItemWithLessDurability(itemID, itemName)
    return IPLib_equipItemWithLessDoublePropertyFirstValue(itemID, durability_regex_str, itemName)
end

Colors = {
    ALERT = 33,
    WARNING = 48,
    CAUTION = 53,
    ACTION = 67,
    CONFIRM = 73,
    INFO = 84,
    STATUS = 93
}

function CLLib_getItemToCraft(config)
    local skill = BaseLib_getSkillValue(config.SKILL_TO_LEVEL)
    local itemToCraft = nil
    for _, item in ipairs(config.ITEMS) do
        if skill >= item.minSkill and skill <= item.maxSkill then
            itemToCraft = item
            break
        end
    end
    return itemToCraft
end

function CLLib_printInitialStartUpGreeting(config)
    Messages.Print("___________________________________", Colors.INFO)
    Messages.Print("Train Crating Assistant Script v0.2.0 ("..config.SKILL_TO_LEVEL..")", Colors.INFO)
    Messages.Print("___________________________________", Colors.INFO)
end

lastItem = nil
function CLLib_craftItem(config)
    local tool = IPLib_getItemWithLessUsesRemaining(config.TOOL_ID, nil)
    if not tool then
        Messages.Overhead("No "..config.SKILL_TO_LEVEL.." Tools!", Colors.ALERT, Player.Serial)
        return false
    end

    itemToCraft = CLLib_getItemToCraft(config)
    if not itemToCraft then
        Messages.Overhead("No item matches current skill level!", Colors.ALERT, Player.Serial)
        return false
    end

    if config.PREWORK_FUNCTION ~= nil then
        success = config.PREWORK_FUNCTION()
            if success == false then
                Messages.Overhead("Pre-Work failed for Crafting ("..config.SKILL_TO_LEVEL..")!...", Colors.ALERT, Player.Serial)
                return false
            end
        end

        Player.UseObject(tool.Serial)
        if not Gumps.WaitForGump(config.GUMP_ID, 1000) then
            Messages.Overhead("Failed to open Crafting ("..config.SKILL_TO_LEVEL..") menu!", Colors.ALERT, Player.Serial)
            return false
        end

        if lastItem ~= itemToCraft.name then
            Gumps.PressButton(config.GUMP_ID, itemToCraft.category)
            Pause(600)
            Gumps.PressButton(config.GUMP_ID, itemToCraft.craft)
            Pause(600)
            Gumps.PressButton(config.GUMP_ID, itemToCraft.final)
            lastItem = itemToCraft.name
        else
            Pause(500)
            Gumps.PressButton(config.GUMP_ID, config.MAKE_LAST_BUTTON_ID)
        end

        Messages.Overhead("Crafting: " .. itemToCraft.name, Colors.ACTION, Player.Serial)
        Pause(3000)

        if config.POSTWORK_FUNCTION ~= nil then
            success = config.POSTWORK_FUNCTION(config)
                if success == false then
                    Messages.Overhead("Post-Work failed for Crafting ("..config.SKILL_TO_LEVEL..")!...", Colors.ALERT, Player.Serial)
                    return false
                end
            end

            return true
        end

        function CLLib_craftingLoop(config)
            CLLib_printInitialStartUpGreeting(config)
            while true do
                local crafted = CLLib_craftItem(config)
                if not crafted then
                    break
                end
            end
        end

-- End of: CLLib
-- ========================================

-- ========================================
-- Imported: IUScissors
-- ========================================

IUScissors_messageHue = 42

function IUScissors_getScissors(verbose)
    local scissors = Items.FindByName('Scissors')
    if verbose and scissors == nil then
        Messages.OverheadMobile(Player.Serial, "Missing Scissors", IUScissors_messageHue)
    end
    return scissors
end

function IUScissors_useScissors(callback, verbose)
    local scissors = IUScissors_getScissors(verbose)
    if scissors then
        Player.UseObject(scissors.Serial)
    end
    if callback then
        callback()
    end
    return scissors ~= nil
end

-- End of: IUScissors
-- ========================================

-----------------
--- Variables ---
-----------------

--- Tayloring items by skill range
TAYLORING_ITEMS = {
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
function postWork(config_)
    local taylorItem = CLLib_getItemToCraft(config_)
    if not taylorItem then
        Console.debug("No configured craft item!")
        return true
    end

    itemToCut = BaseLib_findInInventory(taylorItem.graphic_id)
    if not itemToCut or #itemToCut == 0 then
        Console.debug("No item to cut!")
        return true
    end

    for i, item in ipairs(itemToCut) do
        --- use scissors
        IUScissors_useScissors(nil, true)
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
config = {
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

CLLib_craftingLoop(config)