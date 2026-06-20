----------------------------------------------------------------------
--- Combat Assistant (CA) Run Dexer User Interface Gump
--- Author: JohnB9
---
--- Version: 1.0.0  - Run Combat Bot User Interface with Dexer Config
---                   base configuration
---
--- Description: Running this script will run Combat Bot User Interface
---              starting with a Dexer main loop configuration
----------------------------------------------------------------------

-----------
--- Run ---
-----------

-- ========================================
-- Imported: CAConfigDexer
-- ========================================

LogConfig = {
    EnableDebugLog = false,
    DebugLogTick = 60,
    EnableDebugTick = false, -- Overrides MainLoopTick in debug mode (script will run much slower)
    DebugTick = 500,
    EnableOverheadMessages = false -- Enables overhead messages, if false then messages will be printed in journal
}

LogStaticConfig = {
    DatePattern = "%H:%M:%S",
    InfoTextColor    = 88,
    WarningTextColor = 34,
    ErrorTextColor   = 53,
    DebugTextColor   = 1153,
}

function CALog_setEnableDebugLog(val)
    LogConfig.EnableDebugLog = val
end

function CALog_setDebugLogTick(val)
    LogConfig.DebugLogTick = val
end

function CALog_setEnableDebugTick(val)
    LogConfig.EnableDebugTick = val
end

function CALog_setDebugTick(val)
    LogConfig.DebugTick = val
end

function CALog_setEnableOverheadMessages(val)
    LogConfig.EnableOverheadMessages = val
end

function CALog_setConfig(config)
    CALog_setEnableDebugLog(config.EnableDebugLog)
    CALog_setDebugLogTick(config.DebugLogTick)
    CALog_setEnableDebugTick(config.EnableDebugTick)
    CALog_setDebugTick(config.DebugTick)
    CALog_setEnableOverheadMessages(config.EnableOverheadMessages)
end

function CALog_adjustText(text)
    if not text or (type(text) ~= "string" and type(text) ~= "table") then
        text = "Variabel message to print needs to be a string or table"
    end
    if type(text) == "table" then
        text = table.concat(text, ", ")
    end
    return text
end

function CALog_adjustColor(color)
    if not color or type(color) ~= "number" then
        color = LogStaticConfig.InfoTextColor
    end
    return color
end

function CALog_overheadInternal(text, color)
    Messages.OverheadMobile(Player.Serial, CALog_adjustText(text), CALog_adjustColor(color))
end

function CALog_print(text, color)
    Messages.Print(CALog_adjustText(text), CALog_adjustColor(color))
end

function CALog_overhead(text, color, force)
    if force or LogConfig.EnableOverheadMessages then
        CALog_overheadInternal(text, color)
    else
        CALog_print(text, color)
    end
end

function CALog_mainInfo(text)
    CALog_overhead(text, LogStaticConfig.InfoTextColor, true)
end

function CALog_info(text)
    CALog_overhead(text, LogStaticConfig.InfoTextColor, false)
end

function CALog_warning(text)
    CALog_overhead(text, LogStaticConfig.WarningTextColor, false)
end

function CALog_error(text)
    CALog_overhead(text, LogStaticConfig.ErrorTextColor, false)
end

function CALog_debug(text)

    if not LogConfig.EnableDebugLog then
        return
    end

    local ok, timestamp = pcall(function()
        return os.date(LogStaticConfig.DatePattern, os.time()) .. "." .. string.format("%03d", os.time() * 1000 % 1000)
    end)

    if not ok then
        timestamp = os.time()
    end

    if LogConfig.EnableDebugTick and LogConfig.DebugTick > LogConfig.DebugLogTick then
        Pause(LogConfig.DebugTick - LogConfig.DebugLogTick)
    end

    Console.log("[" .. timestamp .. "] " .. text, LogStaticConfig.DebugTextColor)
end

TimeConfig = {
    ActionWaitTime = 1000 -- in milliseconds, how long to wait for actions like using items, targeting etc.
}

TimeState = {
    currentTickTime = math.floor(os.time() * 1000)
}

function CATime_getActionWaitTime()
    return TimeConfig.ActionWaitTime
end

function CATime_setActionWaitTime(val)
    TimeConfig.ActionWaitTime = val
end

function CATime_getCurrentTickTime()
    return TimeState.currentTickTime
end

function CATime_getCurrentTime()
    return math.floor(os.time() * 1000)
end

function CATime_updateCurrentTickTime()
    TimeState.currentTickTime = CATime_getCurrentTime()
    return TimeState.currentTickTime
end

function CATime_pauseUntil(callback, interval, timeout)
    local startTime = CATime_getCurrentTime()
    while (CATime_getCurrentTime() - startTime) < timeout do
        if callback() then
            return true
        end
        Pause(interval)
    end
    return false
end

function CATime_exceedsDuration(startTime, endTime, duration)
    if startTime == nil then
        return true
    end

    if endTime == nil then
        endTime = CATime_getCurrentTime()
    end

    if duration == nil then
        duration = 1000
    end

    return (endTime - startTime) >= duration
end

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
function IPLib_getUsesRemaining(item)
    return IPLib_getItemSingleValuePropertyNumber(item, uses_remaining_regex_str)
end

identification_charges_regex_str = "Identification Charges: (%d+)"
function IPLib_getIdentificationCharges(item)
    return IPLib_getItemSingleValuePropertyNumber(item, identification_charges_regex_str)
end

material_regex_str = "Material: (%w+)"
function IPLib_getMaterial(item)
    return IPLib_getItemSingleValueProperty(item, material_regex_str)
end

function IPLib_getItemDoubleValueProperty(item, doubleValuePropertyRegexStr)
    BaseLib_printIfDebug(debugEnabled, item.Properties)
    local cleanProperties = string.gsub(item.Properties, "<.->", "")
    BaseLib_printIfDebug(debugEnabled, cleanProperties)
    local regexMatchIter = string.gmatch(cleanProperties, doubleValuePropertyRegexStr)
    local lPropertyVal, rPropertyVal = regexMatchIter()
    if lPropertyVal == nil or rPropertyVal == nil then
        BaseLib_printIfDebug(debugEnabled, "Double Value Property = (nil)")
        return nil
    end
    BaseLib_printIfDebug(debugEnabled, "Double Value Property = (" .. lPropertyVal .. "," .. rPropertyVal .. ")")
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
    local items = BaseLib_findInInventory(itemID)
    ---local filter = { onground=false, graphics=0x0E21 }
    ---local items = Items.FindByFilter(filter)
    ---local items = Items.FindInContainer(Player.Backpack.Serial, itemID)
    if items then
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
    return IPLib_getItemWithLessSinglePropertyValue(itemID, uses_remaining_regex_str, itemAcceptPredicate)
end

function IPLib_equipItemWithLessUsesRemaining(itemID, itemName, itemAcceptPredicate)
    return IPLib_equipItemWithLessSinglePropertyValue(itemID, uses_remaining_regex_str, itemName, itemAcceptPredicate)
end

function IPLib_getItemWithLessIdentificationCharges(itemID, itemAcceptPredicate)
    return IPLib_getItemWithLessSinglePropertyValue(itemID, identification_charges_regex_str, itemAcceptPredicate)
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

function IPLib_getItemWithMostDurability(itemID)
    return IPLib_getItemWithMostDoublePropertyFirstValue(itemID, durability_regex_str)
end

function IPLib_equipItemWithLessDurability(itemID, itemName)
    return IPLib_equipItemWithLessDoublePropertyFirstValue(itemID, durability_regex_str, itemName)
end

ArmDisarmConfig = {
    Enable  = false, -- Rearms your weapon if you are disarmed
    AlwaysRearm = false, -- rearm without moving, warning will spam messages if you drag from hands
    AutoRearmOnMove = false,
    AutoRearmWithDelay = false
}

ArmDisarmStaticConfig = {
    durabilityDisarmThreshould = 0, -- will disarm player and avoid re-arm, if durability <= threshould
    layerOneHanded = 1,
    layerTwoHanded = 2,
    rearmBusrtRequestDelta = 500,
    rearmAtemptDelay = 5000
}

ArmDisarmState = {
    disarmed = nil,
    disarm = { x = 0, y = 0 },
    lastRightHand = nil,
    lastLeftHand = nil,
    lastRightHandEquipAtemptTime = 0,
    lastLeftHandEquipAtemptTime = 0,
    lastDisarmedTime = 0
}

function CAArmDisarm_setEnable(val)
    ArmDisarmConfig.Enable = val
end

function CAArmDisarm_setAlwaysRearm(val)
    ArmDisarmConfig.AlwaysRearm = val
end

function CAArmDisarm_setConfig(config)
    CAArmDisarm_setEnable(config.Enable)
    CAArmDisarm_setAlwaysRearm(config.AlwaysRearm)
    ArmDisarmConfig.AutoRearmOnMove = config.AutoRearmOnMove
    ArmDisarmConfig.AutoRearmWithDelay = config.AutoRearmWithDelay
end

function CAArmDisarm_disarmPlayer()

    if not ArmDisarmConfig.Enable then
        return
    end

    CALog_debug("Disarming player...")
    if ArmDisarmState.disarmed then
        CALog_debug("Player is already disarmed, skipping disarm.")
        return ArmDisarmState.disarmed
    end

    disarmState = { weapon = nil, hand = nil }
    weapon = Items.FindByLayer(2)
    if weapon then
        CALog_debug("Clearing right hand...")
        Player.ClearHands("right")
        Pause(CATime_getActionWaitTime())
    end
    disarmState = { weapon = weapon, hand = function() return Items.FindByLayer(2) end }

    ArmDisarmState.disarmed = disarmState

    return disarmState
end

function CAArmDisarm_equipWeaponIfDurabilityIsOk(weapon)

    if not weapon then
        CALog_error("No weapon to check...")
        return false
    end

    if not weapon.Properties then
        CALog_error("Have weapon, but no weapon properties...")
        return false
    end

    durability = IPLib_getDurability(weapon)
    if durability and durability[1] <= ArmDisarmStaticConfig.durabilityDisarmThreshould then
        CALog_warning("Weapon Durability Low")
        return false
    end

    return Player.Equip(weapon.Serial)
end

function CAArmDisarm_disarmPlayerIfWeaponDurabilityIsLow(replaceImmediately)

    if not ArmDisarmConfig.Enable then
        return
    end

    CALog_debug("Checking right-hand weapon durability...")
    rightWeapon = Items.FindByLayer(ArmDisarmStaticConfig.layerOneHanded)
    if rightWeapon and rightWeapon.Properties then
        CALog_debug("Have valid right-hand weapon: "..rightWeapon.Name)
        durability = IPLib_getDurability(rightWeapon)
        if durability and durability[1] <= ArmDisarmStaticConfig.durabilityDisarmThreshould then
            CALog_debug("Right-hand weapon durability low, disarming...")
            Player.ClearHands("left")
            clearState = true
            if replaceImmediately then
                replaceWeapon = IPLib_getItemWithMostDurability(rightWeapon.Graphic)
                replaceWeaponDurability = replaceWeapon~=nil and IPLib_getDurability(replaceWeapon)
                CALog_debug("Replace weapon: "..((replaceWeapon~=nil and ("found ("..replaceWeapon.Name..")")) or " not found..."))
                CALog_debug("Replace weapon durability: "..((replaceWeapon~=nil and replaceWeaponDurability~=nil and replaceWeaponDurability[1]) or " not found..."))
                if replaceWeapon and replaceWeaponDurability and replaceWeaponDurability[1] > ArmDisarmStaticConfig.durabilityDisarmThreshould then
                    Pause(2*CATime_getActionWaitTime())
                    CAArmDisarm_equipWeaponIfDurabilityIsOk(replaceWeapon)
                    ArmDisarmState.lastRightHand = replaceWeapon
                    clearState = false
                end
            end
            if clearState then
                ArmDisarmState.lastRightHand = nil
                ArmDisarmState.disarm.x = 0
                ArmDisarmState.disarm.y = 0
            end
            Pause(CATime_getActionWaitTime())
        end
    else
        if rightWeapon then
            CALog_debug("Have valid Properties in item")
        else
            CALog_debug("No valid right-hand weapon found")
        end
    end

    CALog_debug("Checking left-hand weapon durability...")
    leftWeapon = Items.FindByLayer(ArmDisarmStaticConfig.layerTwoHanded)

    if leftWeapon and leftWeapon.Properties then
        CALog_debug("Have valid left-hand weapon: "..leftWeapon.Name)
        durability = IPLib_getDurability(leftWeapon)
        if durability and durability[1] <= ArmDisarmStaticConfig.durabilityDisarmThreshould then
            CALog_debug("Left-hand weapon durability low, disarming...")
            Player.ClearHands("right")
            clearState = true
            if replaceImmediately then
                replaceWeapon = IPLib_getItemWithMostDurability(leftWeapon.Graphic)
                replaceWeaponDurability = replaceWeapon~=nil and IPLib_getDurability(replaceWeapon)
                CALog_debug("Replace weapon: "..((replaceWeapon~=nil and ("found ("..replaceWeapon.Name..")")) or " not found..."))
                CALog_debug("Replace weapon durability: "..((replaceWeapon~=nil and replaceWeaponDurability~=nil and replaceWeaponDurability[1]) or " not found..."))
                if replaceWeapon and replaceWeaponDurability and replaceWeaponDurability[1] > ArmDisarmStaticConfig.durabilityDisarmThreshould then
                    Pause(2*CATime_getActionWaitTime())
                    CAArmDisarm_equipWeaponIfDurabilityIsOk(replaceWeapon)
                    ArmDisarmState.lastLeftHand = replaceWeapon
                    clearState = false
                end
            end
            if clearState then
                ArmDisarmState.lastRightHand = nil
                ArmDisarmState.disarm.x = 0
                ArmDisarmState.disarm.y = 0
            end
            Pause(CATime_getActionWaitTime())
        end
    else
        if leftWeapon then
            CALog_debug("Have valid Properties in item")
        else
            CALog_debug("No valid left-hand weapon found")
        end
    end
end

function CAArmDisarm_rearmPlayer()

    if not ArmDisarmConfig.Enable then
        return
    end

    if not ArmDisarmState.disarmed or not ArmDisarmState.disarmed.weapon then
        CALog_debug("Player is not disarmed, skipping rearm.")
        return
    end

    CALog_debug("Rearming player...")
    while ArmDisarmState.disarmed.hand() == nil do
        if CAArmDisarm_equipWeaponIfDurabilityIsOk(ArmDisarmState.disarmed.weapon) then
            Pause(CATime_getActionWaitTime())
        end

    end

    ArmDisarmState.disarmed = nil
end

function CAArmDisarm_checkAndFixItemsErrorState()

    --- Check only when not Player.IsHidden
    if Player.IsHidden then
        return
    end

    rightHand = Items.FindByLayer(ArmDisarmStaticConfig.layerOneHanded)
    leftHand = Items.FindByLayer(ArmDisarmStaticConfig.layerTwoHanded)
    clientStartErrorState = (rightHand and not rightHand.Properties) or (leftHand and not leftHand.Properties)
    if clientStartErrorState and (rightHand or leftHand) then

        CALog_warning("Found inconssistant state, re-equiping both hand to recover state...")

        Player.ClearHands("both")
        Pause(CATime_getActionWaitTime())

        if rightHand then

            Player.Equip(rightHand.Serial)
            Pause(CATime_getActionWaitTime())
        end

        if leftHand and ((not rightHand) or (leftHand.Serial ~= rightHand.Serial)) then

            Player.Equip(leftHand.Serial)
            Pause(CATime_getActionWaitTime())
        end

        CALog_warning("Found inconssistant re-arm state: correction complete.")
        CAArmDisarm_disarmPlayerIfWeaponDurabilityIsLow(true)
    end
end

function CAArmDisarm_disarmed()

    if not ArmDisarmConfig.Enable then
        return
    end

    CALog_debug("Disarm detection running")
    CAArmDisarm_checkAndFixItemsErrorState()

    if ArmDisarmState.lastRightHand == nil then
        rightHand = Items.FindByLayer(ArmDisarmStaticConfig.layerOneHanded)
        if not rightHand then
            CALog_debug("No weapon in right hand")
        else
            ArmDisarmState.lastRightHand = rightHand
            CALog_debug("Weapon " .. (rightHand.Name or "No Weapon Name") .. " used as right hand")
        end
    else
        rightHand = Items.FindByLayer(ArmDisarmStaticConfig.layerOneHanded)
        if rightHand and rightHand.Serial ~= ArmDisarmState.lastRightHand.Serial then
            CALog_debug("Right hand weapon changed from: " .. (ArmDisarmState.lastRightHand.Name or "No Weapon Name") .. " to: "
            .. (rightHand.Name or "No Weapon Name"))

            ArmDisarmState.lastRightHand = nil
            ArmDisarmState.lastLeftHand = nil
            ArmDisarmState.disarm.x = 0
            ArmDisarmState.disarm.y = 0
        end
    end

    if ArmDisarmState.lastLeftHand == nil then
        leftHand = Items.FindByLayer(ArmDisarmStaticConfig.layerTwoHanded)
        if not leftHand then
            CALog_debug("No weapon in left hand")
        else
            ArmDisarmState.lastLeftHand = leftHand
            CALog_debug("Weapon " .. (leftHand.Name or "No Weapon Name") .. " used as left hand")
        end
    else
        leftHand = Items.FindByLayer(ArmDisarmStaticConfig.layerTwoHanded)
        if leftHand and leftHand.Serial ~= ArmDisarmState.lastLeftHand.Serial then
            CALog_debug("Left hand weapon changed from: " .. (ArmDisarmState.lastLeftHand.Name or "No Weapon Name") .. " to: "
            .. (leftHand.Name or "No Weapon Name"))

            ArmDisarmState.lastLeftHand = nil
            ArmDisarmState.lastRightHand = nil
            ArmDisarmState.disarm.x = 0
            ArmDisarmState.disarm.y = 0
        end
    end

    isDisarmed = ArmDisarmState.disarm.x > 0 or ArmDisarmState.disarm.y > 0
    playerMoved = (Player.X ~= ArmDisarmState.disarm.x or Player.Y ~= ArmDisarmState.disarm.y)
    CALog_debug("isDisarmed = "..tostring(isDisarmed)..", playerMoved = "..tostring(playerMoved)..", Player.X = "..Player.X..
    ", Player.y = "..Player.X..", disarm.x = "..ArmDisarmState.disarm.x..", disarm.y = "..ArmDisarmState.disarm.y)

    autoRearmTimerExpired = false
    if isDisarmed and ArmDisarmConfig.AutoRearmWithDelay then
        currentTickTime = CATime_getCurrentTickTime()

        if ArmDisarmState.lastDisarmedTime == 0 then
            CALog_warning("Rearming in "..(ArmDisarmStaticConfig.rearmAtemptDelay / 1000).."s")
            ArmDisarmState.lastDisarmedTime = currentTickTime
        end
    end

    if ArmDisarmState.lastDisarmedTime ~= 0 and CATime_exceedsDuration(ArmDisarmState.lastDisarmedTime, currentTickTime, ArmDisarmStaticConfig.rearmAtemptDelay) then
        ArmDisarmState.lastDisarmedTime = 0
        if isDisarmed then
            CALog_info("Rearming now...")
            autoRearmTimerExpired = true
        else
            CALog_info("Weapon already equiped...")
        end
    end

    atemptRearmPlayer = isDisarmed and (ArmDisarmConfig.AlwaysRearm or (ArmDisarmConfig.AutoRearmOnMove and playerMoved) or autoRearmTimerExpired)
    if atemptRearmPlayer then

        alreadyHasRightHand = Items.FindByLayer(ArmDisarmStaticConfig.layerOneHanded)
        if alreadyHasRightHand then
            CALog_debug("Weapon " .. ((ArmDisarmState.lastRightHand and ArmDisarmState.lastRightHand.Name) or "No Weapon Name") .. " already equipped in right hand")
        end

        canEquipRightHand = not alreadyHasRightHand and ArmDisarmState.lastRightHand and ArmDisarmState.lastRightHand.Serial
        if canEquipRightHand then
            CALog_debug("Trying to re-equip right hand weapon: " ..
            ((ArmDisarmState.lastRightHand and ArmDisarmState.lastRightHand.Name) or "No Weapon Name"))

            if CAArmDisarm_equipWeaponIfDurabilityIsOk(ArmDisarmState.lastRightHand) then

                CALog_info("Equipping right hand")
                ArmDisarmState.disarm.x = 0
                ArmDisarmState.disarm.y = 0

                Pause(CATime_getActionWaitTime())
            else
                CALog_warning("Equipping right hand failed")
                currentTickTime = CATime_getCurrentTickTime()
                if ArmDisarmState.lastRightHandEquipAtemptTime ~= 0 and not CATime_exceedsDuration(ArmDisarmState.lastRightHandEquipAtemptTime, currentTickTime, ArmDisarmStaticConfig.rearmBusrtRequestDelta) then
                    CALog_warning("Found inconssistant state, canceling...")
                    ArmDisarmState.lastRightHand = nil
                    ArmDisarmState.disarm.x = 0
                    ArmDisarmState.disarm.y = 0
                end
                ArmDisarmState.lastRightHandEquipAtemptTime = currentTickTime
            end
        end

        alreadyHasLeftHand = Items.FindByLayer(ArmDisarmStaticConfig.layerTwoHanded)
        if alreadyHasLeftHand then
            CALog_debug("Weapon " ..
            ((ArmDisarmState.lastLeftHand and ArmDisarmState.lastLeftHand.Name) or "No Weapon Name") .. " already equipped in left hand")
        end

        canEquipLeftHand = not alreadyHasLeftHand and ArmDisarmState.lastLeftHand and ArmDisarmState.lastLeftHand.Serial
        if canEquipLeftHand then
            CALog_debug("Trying to re-equip left hand weapon: " .. ((ArmDisarmState.lastLeftHand and ArmDisarmState.lastLeftHand.Name) or "No Weapon Name"))

            if CAArmDisarm_equipWeaponIfDurabilityIsOk(ArmDisarmState.lastLeftHand) then
                CALog_info("Equipping left hand")
                ArmDisarmState.disarm.x = 0
                ArmDisarmState.disarm.y = 0

                Pause(CATime_getActionWaitTime())
            else
                CALog_warning("Equipping left hand failed")
                currentTickTime = CATime_getCurrentTickTime()
                if ArmDisarmState.lastLeftHandEquipAtemptTime ~= 0 and not CATime_exceedsDuration(ArmDisarmState.lastLeftHandEquipAtemptTime, currentTickTime, ArmDisarmStaticConfig.rearmBusrtRequestDelta) then
                    CALog_warning("Found inconssistant state, canceling...")
                    ArmDisarmState.lastLeftHand = nil
                    ArmDisarmState.disarm.x = 0
                    ArmDisarmState.disarm.y = 0
                end
                ArmDisarmState.lastLeftHandEquipAtemptTime = currentTickTime
            end
        end
    end

    :: _end_ ::
    if not isDisarmed then
        if ArmDisarmState.lastRightHand and not Items.FindByLayer(ArmDisarmStaticConfig.layerOneHanded) then
            if ArmDisarmConfig.AutoRearmOnMove then
                CALog_warning("Right hand disarmed, move to equip")
            end
            ArmDisarmState.disarm.x = Player.X
            ArmDisarmState.disarm.y = Player.Y
        elseif ArmDisarmState.lastLeftHand and not Items.FindByLayer(ArmDisarmStaticConfig.layerTwoHanded) then
            if ArmDisarmConfig.AutoRearmOnMove then
                CALog_warning("Left hand disarmed, move to equip")
            end
            ArmDisarmState.disarm.x = Player.X
            ArmDisarmState.disarm.y = Player.Y
        end
    end
end

EscapeConfig = {
    EnablePopPouch = true,
    EnableComand = false,
    EnableMoongate = true,
    MoongateGumpId = 585180759
}

CAEscape_EscapeState = {
    flaggedForPvp = false,
    moongate = {
        lastTickTime = nil,
        serial = nil,
        previousDistance = nil,
        messageShown = false
    },
}

CAEscape_EscapeCommandStaticConfig = {
    Command = "I shall return!", -- The command to say, make it unique to you
    Callback = function() -- Use the assistant and record your way of escaping and paste it below
        Player.UseObject('1110433901')
        Gumps.WaitForGump(1498407526, 1000)
        Gumps.PressButton(1498407526, 26)
        return true
    end
}

function CAEscape_setEnablePopPouch(val)
    EscapeConfig.EnablePopPouch = val
end

function CAEscape_setEnableComand(val)
    EscapeConfig.EnableComand = val
end

function CAEscape_setEnableMoongate(val)
    EscapeConfig.EnableMoongate = val
end

function CAEscape_setConfig(config)
    CAEscape_setEnablePopPouch(EscapeConfig.EnablePopPouch)
    CAEscape_setEnableComand(EscapeConfig.EnableComand)
    CAEscape_setEnableMoongate(EscapeConfig.EnableMoongate)
end

function CAEscape_popPouch()

    if not EscapeConfig.EnablePopPouch then
        return
    end

    if Journal.Contains("You are now PvP-Combat flagged!") then
        CAEscape_EscapeState.flaggedForPvp = true
    end

    if Journal.Contains("You are no longer PvP-Combat flagged!") then
        CAEscape_EscapeState.flaggedForPvp = false
    end

    CALog_debug("Checking pop-pouch...")
    if CAEscape_EscapeState.flaggedForPvp and Player.IsParalyzed and Journal.Contains("You cannot move!") then
        CALog_debug("Player is paralyzed, popping pouch.")
        CALog_info("Popping pouch")
        Player.PopPouch()
    end

end

function CAEscape_escape()

    if not EscapeConfig.EnableComand then
        return
    end

    if Player.IsDead then
        CALog_debug("Player is dead, skipping escape.")
        return
    end

    if Player.IsHidden then
        CALog_debug("Player is hiding, skipping escape.")
        return
    end

    command = CAEscape_EscapeCommandStaticConfig.Command
    if not Journal.Contains(command) then
        return
    end

    callback = CAEscape_EscapeCommandStaticConfig.Callback

    CALog_debug("Checking escape command...")
    if callback and type(callback) == "function" then
        CALog_debug("Running escape callback function")
        CATime_pauseUntil(callback, 50, CATime_getActionWaitTime())
    end

end

function CAEscape_moongate()

    if not EscapeConfig.EnableMoongate then
        return
    end

    currentTickTime = CATime_getCurrentTickTime()

    if not CATime_exceedsDuration(CAEscape_EscapeState.moongate.lastTickTime, currentTickTime, 1000) then
        CALog_debug("Moongate check is not ready yet, skipping")
        return
    end

    CALog_debug("Checking escape command...")
    CAEscape_EscapeState.moongate.lastTickTime = currentTickTime

    gate = Items.FindByName('Moongate')

    if not gate then
        CAEscape_EscapeState.moongate.serial = nil
        CAEscape_EscapeState.moongate.previousDistance = nil
        CAEscape_EscapeState.moongate.messageShown = false
        return
    end

    if CAEscape_EscapeState.moongate.serial ~= gate.Serial then
        CAEscape_EscapeState.moongate.serial = gate.Serial
        CAEscape_EscapeState.moongate.previousDistance = gate.Distance
        CAEscape_EscapeState.moongate.messageShown = false
        return
    end

    if CAEscape_EscapeState.moongate.previousDistance == nil then
        CAEscape_EscapeState.moongate.previousDistance = gate.Distance
    end

    movingTowardGate = gate.Distance < CAEscape_EscapeState.moongate.previousDistance
    isNearGate = gate.Distance <= 10
    movedAway = gate.Distance > 10

    if movedAway and CAEscape_EscapeState.moongate.messageShown then
        CAEscape_EscapeState.moongate.messageShown = false
        CALog_debug("Moved away from moongate, resetting message flag")
    end

    if (movingTowardGate or isNearGate) and not CAEscape_EscapeState.moongate.messageShown then
        CALog_info("Found moongate")
        CAEscape_EscapeState.moongate.messageShown = true
    end

    CAEscape_EscapeState.moongate.previousDistance = gate.Distance

    if gate.Distance > 2 then
        CALog_debug("Moongate is too far away, skipping")
        return
    end

    if Gumps.IsActive(EscapeConfig.MoongateGumpId) then
        CALog_info("Click destination")
    else
        Player.UseObject(gate.Serial)
    end

    if Gumps.WaitForGump(EscapeConfig.MoongateGumpId, CATime_getActionWaitTime()) then
        CALog_info("Trying to travel")
        Gumps.PressButton(EscapeConfig.MoongateGumpId, 1)
    end

end

CAPotionsHealing_CAPotionsTime_PotionsTimeStaticConfig = {
    Nightsight = {
        Name = "Nightsight",
        Duration = (300 + math.ceil(Skills.GetValue("Alchemy")*10)*3 + 1) * 1000, --- 300s base time + 3s per 0.1 point in alchemy skill + 1s buffer
        CheckFrequency = 5000 --- drink attempt frequency, when not sure if under buff effect
    },
    GreaterStrength = {
        Name = "Greater Stength",
        Duration = (120 + math.floor(Skills.GetValue("Alchemy"))*6 + 1) * 1000, --- 120s base time + 6s per 1 point in alchemy skill + 1s buffer
        Buff = 20 + math.floor(Skills.GetValue("Alchemy"))/10, --- 20 base + 1 per 10 points in alchemy skill
        CheckFrequency = 5000 --- drink attempt frequency, when not sure if under buff effect
    },
    GreaterAgility = {
        Name = "Greater Agility",
        Duration = (120 + math.floor(Skills.GetValue("Alchemy"))*6 + 1) * 1000, --- 120s base time + 6s per 1 point in alchemy skill + 1s buffer
        Buff = 20 + math.floor(Skills.GetValue("Alchemy"))/10, --- 20 base + 1 per 10 points in alchemy skill
        CheckFrequency = 5000 --- drink attempt frequency, when not sure if under buff effect
    },
    GreaterHeal = {
        Name = "Greater Heal",
        DrinkCooldown = 15 * 1000
    },
    GreaterCure = {
        Name = "Greater Cure"
    }
}

PotionsTimeState = {
    Nightsight = {
        lastCheckTickTime = nil
    },
    GreaterStrength = {
        lastCheckTickTime = nil
    },
    GreaterAgility = {
        lastCheckTickTime = nil
    },
    GreaterHeal = {
    },
    GreaterCure = {
    }
}

function CAPotionsTime_shouldAtemptToDrink(potionStaticConfig, potionState, lastDrinkTime)

    CALog_debug("Checking "..potionStaticConfig.Name.." buff")
    local currentTickTime = CATime_getCurrentTickTime()
    local exceedsDuration = CATime_exceedsDuration(lastDrinkTime, currentTickTime, potionStaticConfig.Duration)
    local durationReallyExpired = lastDrinkTime and exceedsDuration
    if lastDrinkTime and not exceedsDuration then
        CALog_debug("Already buffed: last drink tick ("..lastDrinkTime..
            "), current ("..currentTickTime..
            "), elapsed ("..(currentTickTime-lastDrinkTime)..
            "), target ("..potionStaticConfig.Duration..")")
        return false
    end

    checkOnColldown = potionState.lastCheckTickTime and not CATime_exceedsDuration(potionState.lastCheckTickTime, currentTickTime, potionStaticConfig.CheckFrequency)
    if not durationReallyExpired and checkOnColldown then
        CALog_debug("Check on cooldown")
        return false
    end
    potionState.lastCheckTickTime = currentTickTime

    return true
end

function CAPotionsTime_shouldAtemptToDrinkNightsight(lastDrinkTime)
    return CAPotionsTime_shouldAtemptToDrink(CAPotionsHealing_CAPotionsTime_PotionsTimeStaticConfig.Nightsight, PotionsTimeState.Nightsight, lastDrinkTime)
end

function CAPotionsTime_shouldAtemptToDrinkStrength(lastDrinkTime)
    return CAPotionsTime_shouldAtemptToDrink(CAPotionsHealing_CAPotionsTime_PotionsTimeStaticConfig.GreaterStrength, PotionsTimeState.GreaterStrength, lastDrinkTime)
end

function CAPotionsTime_shouldAtemptToDrinkAgility(lastDrinkTime)
    return CAPotionsTime_shouldAtemptToDrink(CAPotionsHealing_CAPotionsTime_PotionsTimeStaticConfig.GreaterAgility, PotionsTimeState.GreaterAgility, lastDrinkTime)
end

function CAPotionsTime_shouldAtemptToDrinkHeal(lastDrinkTime)
    local currentTickTime = CATime_getCurrentTickTime()
    if not CATime_exceedsDuration(lastDrinkTime, currentTickTime, CAPotionsHealing_CAPotionsTime_PotionsTimeStaticConfig.GreaterHeal.DrinkCooldown) then
        CALog_debug("Health potion recently drunk, skipping.")
        return false
    end
    return true
end

function CAPotionsTime_shouldAtemptToDrinkCure(lastDrinkTime, drinkCooldown)
    local currentTickTime = CATime_getCurrentTickTime()
    if not CATime_exceedsDuration(lastDrinkTime, currentTickTime, drinkCooldown) then
        CALog_debug("Cure potion recently drunk, skipping.")
        return false
    end
    return true
end

DrinkAtemptResult = {
    NO_DRINK_ATTEMPT = 0,
    DRINK_ATTEMPTED_BUT_FAILED = 1,
    DRANK_POTION = 2
}

CAPotionsDrink_PotionsDrinkStaticConfig = {
    WarningPauseTime = 60 * 1000
}

CAPotionsDrink_PotionsDrinkState = {
    lastOverHeadTime = 0
}

function CAPotionsDrink_drink(potionGraphicID, potionName, shouldAtemptDrinkPredicate, drinkSuccessfullPredicate, forced)

    if not drinkSuccessfullPredicate then
        CALog_error("CAPotionsDrink_drink: Missing drinkSuccessfullPredicate.")
        return DrinkAtemptResult.NO_DRINK_ATTEMPT, nil
    end

    if shouldAtemptDrinkPredicate and not shouldAtemptDrinkPredicate(forced) then
        return DrinkAtemptResult.NO_DRINK_ATTEMPT, nil
    end

    CALog_debug("Looking for a " .. potionName .. " potion...")
    potion = BaseLib_findInInventoryGetFirst(potionGraphicID)
    if not potion then
        currentTickTime = CATime_getCurrentTickTime()
        if CATime_exceedsDuration(CAPotionsDrink_PotionsDrinkState.lastOverHeadTime, currentTickTime, CAPotionsDrink_PotionsDrinkStaticConfig.WarningPauseTime) then
            CALog_warning("No " .. potionName .. " potions")
            CAPotionsDrink_PotionsDrinkState.lastOverHeadTime = currentTickTime
        end
        return DrinkAtemptResult.NO_DRINK_ATTEMPT, nil
    end

    alchemySkill = Skills.GetValue("Alchemy")
    if alchemySkill and alchemySkill < 80 then
        CALog_debug("Alchemy skill is below 80, disarming weapon to use strength potion.")
        CAArmDisarm_disarmPlayer()
    end

    CALog_debug("Using potion: " .. potionName)
    if not Player.UseObject(potion.Serial) then
        CALog_debug("Failed to use potion: " .. (potionName.Name or "No Potion Name"))
        return DrinkAtemptResult.DRINK_ATTEMPTED_BUT_FAILED, nil
    end

    if drinkSuccessfullPredicate() then
        CALog_debug("Successfully drank a " .. potionName .. " potion.")
        drinkTime = CATime_getCurrentTickTime()
        Pause(CATime_getActionWaitTime())
        return DrinkAtemptResult.DRANK_POTION, drinkTime
    end

    return DrinkAtemptResult.DRINK_ATTEMPTED_BUT_FAILED, nil
end

HealingPotionsConfig = {
    Enable = false, -- Drinks healing potions when bellow threshould
    HPDrinkThreshould = 20 -- in percentage, when to use heal potion
}

HealingPotionsStaticConfig = {
    Potion = 0x0f0c,
    Name = "Greater Heal"
}

HealingPotionsState = {
    lastDrinkTime = 0
}

function CAPotionsHealing_setEnable(val)
    HealingPotionsConfig.Enable = val
end

function CAPotionsHealing_setHPDrinkThreshould(val)
    HealingPotionsConfig.HPDrinkThreshould = val
end

function CAPotionsHealing_setConfig(config)
    CAPotionsHealing_setEnable(config.Enable)
    CAPotionsHealing_setHPDrinkThreshould(config.HPDrinkThreshould)
end

function CAPotionsHealing_shouldAtemptDrink(forced)
    if Player.IsHidden then
        CALog_debug("Player is hiding, skipping health potion.")
        return false
    end
    playerHpPercentage = BaseLib_getHpPercentage(Player)
    if not forced and (playerHpPercentage > HealingPotionsConfig.HPDrinkThreshould) then
        CALog_debug("Player HP is above health potion threshold, skipping health potion.")
        return false
    end
    CALog_debug("Player HP is below health potion threshold, drinking health potion.")
    if Player.IsPoisoned then
        CALog_debug("Player is poisoned, skipping health potion.")
        return false
    end
    if not forced and not CAPotionsTime_shouldAtemptToDrinkHeal(HealingPotionsState.lastDrinkTime) then
        CALog_debug("Health potion recently drunk, skipping.")
        return false
    end
    return true
end

function CAPotionsHealing_drinkSuccessfullPredicate()
    return CATime_pauseUntil(function () return Journal.Contains("You feel better") end, 50, CATime_getActionWaitTime())
end

function CAPotionsHealing_health(forced)
    if not HealingPotionsConfig.Enable then
        return
    end
    local potionDrinkState, lastDrinkTime = CAPotionsDrink_drink(HealingPotionsStaticConfig.Potion, HealingPotionsStaticConfig.Name, CAPotionsHealing_shouldAtemptDrink, CAPotionsHealing_drinkSuccessfullPredicate, forced)
    if lastDrinkTime then
        HealingPotionsState.lastDrinkTime = lastDrinkTime
    end
    return potionDrinkState == DrinkAtemptResult.DRANK_POTION
end

PotionsCureConfig = {
    Enable = false,
    ColldownTime = 1000 --- in milliseconds, overridable
}

CAPotionsCure_PotionsCureStaticConfig = {
    Potion = 0x0f07,
    Name = "Greater Cure"
}

CAPotionsCure_PotionsCureState = {
    lastDrinkTime = 0,
    isPoisoned = false
}

function CAPotionsCure_setEnable(val)
    PotionsCureConfig.Enable = val
end

function CAPotionsCure_setColldownTime(val)
    PotionsCureConfig.ColldownTime = val
end

function CAPotionsCure_setConfig(config)
    CAPotionsCure_setEnable(config.Enable)
    CAPotionsCure_setColldownTime(config.ColldownTime)
end

function CAPotionsCure_shouldAtemptDrink(forced)
    if Player.IsHidden then
        CALog_debug("Player is hiding, skipping cure.")
        return false
    end
    CALog_debug("Player is poisoned: " .. tostring(Player.IsPoisoned))
    if not Player.IsPoisoned then
        if CAPotionsCure_PotionsCureState.isPoisoned then
            CALog_info("Cured")
        end
        CAPotionsCure_PotionsCureState.isPoisoned = false
        CALog_debug("Player is not poisoned")
        return false
    end
    CAPotionsCure_PotionsCureState.isPoisoned = true
    if not CAPotionsTime_shouldAtemptToDrinkCure(CAPotionsCure_PotionsCureState.lastDrinkTime, PotionsCureConfig.ColldownTime) then
        CALog_debug("Cure potion recently drunk, skipping.")
        return false
    end
    return true
end

function CAPotionsCure_drinkSuccessfullPredicate()
    return CATime_pauseUntil(function() return Journal.Contains("You feel cured of poison") end, 50, CATime_getActionWaitTime())
end

function CAPotionsCure_cure(forced)
    if not PotionsCureConfig.Enable then
        return false
    end
    local potionDrinkState, lastDrinkTime = CAPotionsDrink_drink(CAPotionsCure_PotionsCureStaticConfig.Potion, CAPotionsCure_PotionsCureStaticConfig.Name, CAPotionsCure_shouldAtemptDrink, CAPotionsCure_drinkSuccessfullPredicate, forced)
    if lastDrinkTime then
        CALog_debug("Cure potion drank, saving last drink time.")
        CAPotionsCure_PotionsCureState.lastDrinkTime = lastDrinkTime
    end
    return potionDrinkState == DrinkAtemptResult.DRANK_POTION
end

BandageConfig = {
    Enable = false,                 --- Bandages player if HP is below BandageSelfHPThreshould or if poisoned and no cure potions
    BandageSelfHPThreshould = 99,   --- in percentage, when to use bandage
    BandageAllies = false,          --- Whether to attempt to bandage allies when player is not in need of bandaging
    BandageAlliesHPThreshould = 90, --- in percentage, when to use bandage
    AlliesSerials = {}              --- List of allies serials to bandage, if BandageAllies is true
}

BandageStaticConfig = {
    Bandages = { 0x00e21 },
    OverheadPauseTime = 0,          --- in ms, zero means only when beginning bandage
    WarningPauseTime = 60 * 1000
}

BandageState = {
    lastOverheadTime = 0,
    isBandaging = false,
    bandageTimeEnd = nil
}

function CABandage_setEnable(val)
    BandageConfig.Enable = val
end

function CABandage_setBandageHP(val)
    BandageConfig.BandageSelfHPThreshould = val
end

function CABandage_setConfig(config)
    CABandage_setEnable(config.Enable)
    CABandage_setBandageHP(config.BandageSelfHPThreshould)
    BandageConfig.BandageAllies = config.BandageAllies
    BandageConfig.BandageAlliesHPThreshould = config.BandageAlliesHPThreshould
    BandageConfig.AlliesSerials = config.AlliesSerials
end

function CABandage_bandageSelfEndTime(start)
    local delayMs = math.ceil((9.0 + 0.85 * ((130 - Player.Dex) / 20)) * 1000)
    local baseTime = start or CATime_getCurrentTickTime() or math.floor(os.time() * 1000)
    return baseTime + delayMs
end

function CABandage_bandageOtherEndTime(start)
    --local delayMs = math.ceil((9.0 + 0.85 * ((130 - Player.Dex) / 20)) * 1000)
    local delayMs = 5000
    local baseTime = start or CATime_getCurrentTickTime() or math.floor(os.time() * 1000)
    return baseTime + delayMs
end

function CABandage_getBandages()
    CALog_debug("Looking for bandages...")
    local bandages = BaseLib_findInInventory(BandageStaticConfig.Bandages)
    if not bandages or #bandages == 0 then
        if CATime_exceedsDuration(BandageState.lastOverheadTime, currentTickTime, BandageStaticConfig.WarningPauseTime) then
            CALog_warning("No bandages found")
            BandageState.lastOverheadTime = currentTickTime
        end
        return nil
    end

    bandageCount = #bandages > 1 and #bandages or 1
    CALog_debug("Have " .. bandageCount .. " bandage(s)...")
    return bandages
end

function CABandage_appyBandages(target)

    local bandages = CABandage_getBandages()
    if not bandages then
        return false
    end

    CALog_debug("Attempting to bandage...")
    isBandagingSuccessful = false
    for _, item in ipairs(bandages) do
        if not Player.UseObject(item.Serial) then
            CALog_debug("Unable to use bandage item.")
            goto continue
        end

        if not Target.WaitForTarget(1000) then
            CALog_debug("Targeting failed, unable to bandage.")
            goto continue
        end

        if target == nil then
            if Target.Self() then
                isBandagingSuccessful = true
                break
            end
        elseif Target.TargetSerial(target.Serial) then
            isBandagingSuccessful = true
            break
        end

        :: continue ::
    end

    if not isBandagingSuccessful then
        CALog_debug("Failed to bandage, the bandages found are probably in bank?")
        return false
    end

    isBandagingSuccessful = CATime_pauseUntil(function()
        return Journal.Contains("You begin applying the bandages.")
    end, 50, 500)

    if not isBandagingSuccessful then
        BandageState.isBandaging = false
        BandageState.lastBandageStart = nil
        return false
    end

    return true
end

function CABandage_bandageOther(currentTickTime)

    if not BandageConfig.BandageAllies then
        return
    end

    CALog_debug("Atempting to bandage allies...")
    for _, serial in ipairs(BandageConfig.AlliesSerials) do
        if serial == Player.Serial then
            goto continue
        end

        ally = Mobiles.FindBySerial(serial)

        if ally and ally.Hits > 0 and ally.Distance <= 1 then
            if BaseLib_getHpPercentage(ally) <= BandageConfig.BandageAlliesHPThreshould or ally.IsPoisoned then

                CALog_debug("Ally " .. ally.Name .. " needs bandage, attempting to bandage...")

                bandages = CABandage_getBandages()
                if not bandages then
                    return
                end

                isBandagingSuccessful = CABandage_appyBandages(ally)
                if not isBandagingSuccessful then
                    return
                end

                CALog_debug("Bandaging " .. ally.Name)

                if BandageStaticConfig.OverheadPauseTime == 0 then
                    CALog_info("Bandaging... " .. ally.Name)
                    BandageState.lastOverHeadTime = currentTickTime
                end

                BandageState.isBandaging = isBandagingSuccessful
                BandageState.lastBandageStart = currentTickTime
                BandageState.bandageTimeEnd = CABandage_bandageOtherEndTime(BandageState.lastBandageStart)
            end
        end
        ::continue::
    end
end

function CABandage_bandage()

    if not BandageConfig.Enable then
        return
    end

    currentTickTime = CATime_getCurrentTickTime()

    CALog_debug("Bandage running with main tick time")

    if Player.IsHidden then
        CALog_debug("Player is hiding, skipping bandage.")
        return
    end

    if BandageState.isBandaging then
        CALog_debug("Already healing, skipping bandage.")
        timeLeft = BandageState.bandageTimeEnd - currentTickTime

        if timeLeft > 0 and BandageStaticConfig.OverheadPauseTime > 0  then
            if CATime_exceedsDuration(BandageState.lastOverHeadTime, currentTickTime, BandageStaticConfig.OverheadPauseTime) then
                countdown = math.floor(timeLeft / 1000)
                if countdown >= 1 then
                    CALog_info("Bandaging " .. countdown .. "s")
                end
                BandageState.lastOverHeadTime = currentTickTime
            end
        end

        if currentTickTime > BandageState.bandageTimeEnd then
            BandageState.isBandaging = false
        end

        return
    end

    CALog_debug("Checking if bandaging is needed...")
    if Player.IsDead then
        CALog_debug("Cannot bandage while dead.")
        return
    end

    if Journal.Contains("You begin applying the bandages") then
        CALog_debug("Already manually bandaging, skipping.")
        BandageState.bandageTimeEnd = CABandage_bandageSelfEndTime(currentTickTime)
        BandageState.isBandaging = true
        return
    end

    playerHpPercentage = BaseLib_getHpPercentage(Player)
    if not Player.IsPoisoned and (playerHpPercentage >= BandageConfig.BandageSelfHPThreshould) then
        CALog_debug("Player not poisoned or HP is above threshold, no bandage needed.")
        CABandage_bandageOther(currentTickTime)
        return
    end

    if Player.IsPoisoned then
        CALog_debug("Using bandages due to previous poison.")
        CALog_info("Curing with bandage")
    end

    isBandagingSuccessful = CABandage_appyBandages(nil)
    if not isBandagingSuccessful then
        return
    end

    CALog_info("Bandaging self")

    if BandageStaticConfig.OverheadPauseTime == 0 then
        CALog_debug("Bandaging...")
        BandageState.lastOverHeadTime = currentTickTime
    end

    BandageState.isBandaging = isBandagingSuccessful
    BandageState.lastBandageStart = currentTickTime
    BandageState.bandageTimeEnd = CABandage_bandageSelfEndTime(BandageState.lastBandageStart)
end

SongOfHealingConfig = {
    Enable = false,
    FailWait = 30 * 1000, -- in ms, how long to retry if already under effects by manual cast
    Instruments = {"Drum", "Lute", "Tambourine", "Lap Harp" }
}

SongOfHealingState = {
    isActive = false,
    startTime = nil,
    endTime = nil,
    duration = 163 * 1000, -- Need to calculate based on music skill?
    lastWarningTickTime = nil,
    instrument = nil,
}

function CASongOfHealing_setEnable(val)
    SongOfHealingConfig.Enable = val
end

function CASongOfHealing_setFailWait(val)
    SongOfHealingConfig.FailWait = val
end

function CASongOfHealing_setInstruments(val)
    SongOfHealingConfig.Instruments = val
end

function CASongOfHealing_setConfig(config)
    CASongOfHealing_setEnable(config.Enable)
    CASongOfHealing_setFailWait(config.FailWait)
    CASongOfHealing_setInstruments(config.Instruments)
end

function startBuff(buffState, duration)
    buffState.isActive = true
    buffState.startTime = CATime_getCurrentTickTime()
    buffState.endTime = buffState.startTime + duration
end

function recentCast()
    return Journal.Contains("You play your hypnotic music, stopping the battle.") or Journal.Contains("You must wait a few seconds before you can play another song.") or Journal.Contains("Your song creates a healing aura around you.")
end

function CASongOfHealing_songOfHealing()

    if not SongOfHealingConfig.Enable then
        return
    end

    musicSkill = Skills.GetValue("Musicianship")
    if musicSkill and musicSkill > 0 then
        CALog_debug("Musicianship skill is " .. musicSkill .. ", proceeding with Song of Healing.")
    else
        CALog_debug("Musicianship skill is 0, skipping Song of Healing.")
        return
    end

    currentTickTime = CATime_getCurrentTickTime()
    if SongOfHealingState.isActive then
        if currentTickTime > SongOfHealingState.endTime then
            SongOfHealingState.isActive = false
            CALog_debug("Song of Healing ended.")
            return
        end
        CALog_debug("Waiting for Song of Healing to end in: " ..
        ((SongOfHealingState.endTime - currentTickTime) / 1000) .. " seconds.")
        return
    end

    if recentCast() then
        CALog_debug("Buff was recently cast, wait to retry")
        SongOfHealingState.isActive = true
        SongOfHealingState.startTime = currentTickTime
        recastWaitTime = 8
        SongOfHealingState.endTime = SongOfHealingState.startTime + recastWaitTime
        return
    end

    if not SongOfHealingState.instrument then
        instrument = nil
        for _, instrumentName in ipairs(SongOfHealingConfig.Instruments) do
            CALog_debug("Looking for instrument: " .. instrumentName)
            instrument = Items.FindByName(instrumentName)
            if instrument then
                CALog_debug("Found instrument: " .. instrument.Name)
                break
            end
        end

        if not instrument then
            CALog_debug("No instrument found in inventory")
            return
        end

        SongOfHealingState.instrument = instrument
    end

    CALog_debug("Casting Song of Healing...")
    if not Spells.Cast("SongOfHealing") then
        if CATime_exceedsDuration(SongOfHealingState.lastWarningTickTime, currentTickTime, SongOfHealingConfig.FailWait) then
            CALog_info("Recasting Song of Healing")
            CALog_debug("Failed to cast Song of Healing, waiting " .. (SongOfHealingConfig.FailWait / 1000) .. " seconds to retry.")
            SongOfHealingState.lastWarningTickTime = currentTickTime
        end
        startBuff(SongOfHealingState, SongOfHealingConfig.FailWait)
        return
    end

    castSuccess = CATime_pauseUntil(function()
        if Journal.Contains("You are already under the effects") then
            CALog_debug("Song was already active.")
            return false
        elseif Journal.Contains("Your song creates a healing aura around you.") then
            return true
        elseif Journal.Contains("What instrument shall you play?") then
            CALog_debug("Instrument depleeted, will look for a new one")
            SongOfHealingState.instrument = nil
            return false
        end
        return false
    end, 50, CATime_getActionWaitTime())

    if not castSuccess then
        if CATime_exceedsDuration(SongOfHealingState.lastWarningTickTime, currentTickTime, SongOfHealingConfig.FailWait) then
            CALog_info("Recasting Song of Healing")
            CALog_debug("Journal did not contain expectations for Song of Healing, waiting " .. (SongOfHealingConfig.FailWait / 1000)
            .. " seconds to retry.")
            SongOfHealingState.lastWarningTickTime = currentTickTime
        end
        startBuff(SongOfHealingState, SongOfHealingConfig.FailWait)
        return
    end

    startBuff(SongOfHealingState, SongOfHealingState.duration)
    CALog_info("Casted Song of Healing")
    CALog_debug("Song of Healing started.")
end

NightsightPotionsConfig = {
    Enable = false --- continuously drinks nightsight potions when missing that buff
}

CAPotionsNightsight_NightsightPotionsStaticConfig = {
    Potion = 0x0f06,
    Name = "Nightsight"
}

CAPotionsNightsight_NightsightPotionsState = {
    lastDrinkTime = nil
}

function CAPotionsNightsight_getEnable()
    return NightsightPotionsConfig.Enable
end

function CAPotionsNightsight_setEnable(val)
    NightsightPotionsConfig.Enable = val
end

function CAPotionsNightsight_setConfig(config)
    CAPotionsNightsight_setEnable(config.Enable)
end

function CAPotionsNightsight_shouldAtemptDrink(forced)
    if CAPotionsTime_shouldAtemptToDrinkNightsight(CAPotionsNightsight_NightsightPotionsState.lastDrinkTime) == false then
        return false
    end
    return true
end

function CAPotionsNightsight_drinkSuccessfullPredicate()
    return not CATime_pauseUntil(function() return Journal.Contains("You already have night sight") end, 50, CATime_getActionWaitTime())
end

function CAPotionsNightsight_nightsight(forced)
    if not NightsightPotionsConfig.Enable then
        return false
    end
    local potionDrinkState, lastDrinkTime = CAPotionsDrink_drink(CAPotionsNightsight_NightsightPotionsStaticConfig.Potion, CAPotionsNightsight_NightsightPotionsStaticConfig.Name, CAPotionsNightsight_shouldAtemptDrink, CAPotionsNightsight_drinkSuccessfullPredicate, forced)
    if lastDrinkTime then
        CAPotionsNightsight_NightsightPotionsState.lastDrinkTime = lastDrinkTime
    end
    if potionDrinkState == DrinkAtemptResult.DRINK_ATTEMPTED_BUT_FAILED then
        CALog_error("Must already have the nightsight buff...")
        CALog_error("We have no way to check when to reapply unless by drinking continuously (which makes no sense)")
        CALog_error("We'll disable the auto nightsight buff...")
        CALog_error("Just relaunch the Combat Assistant (or re-enable the buff via the UI), once the current night sight expires")
        CALog_debug("Already under nightsight effect, disabling auto-buff")
        CAPotionsNightsight_setEnable(false)
    end
    return potionDrinkState == DrinkAtemptResult.DRANK_POTION
end

StaminaPotionsConfig = {
    Enable = false,
    DrinkThreshould = 30 -- in percentage, when to drink stamina potion
}

CAPotionsStamina_StaminaPotionsStaticConfig = {
    Potion = 0x0f0b,
    Name = "Total Refresh"
}

CAPotionsStamina_StaminaPotionsState = {
    lastDrinkTime = nil
}

function CAPotionsStamina_setEnable(val)
    StaminaPotionsConfig.Enable = val
end

function CAPotionsStamina_setDrinkThreshould(val)
    StaminaPotionsConfig.DrinkThreshould = val
end

function CAPotionsStamina_setConfig(config)
    CAPotionsStamina_setEnable(config.Enable)
    CAPotionsStamina_setDrinkThreshould(config.DrinkThreshould)
end

function CAPotionsStamina_shouldAtemptDrink(forced)
    CALog_debug("Player stamina: " .. Player.Stam .. ", Max Stamina: " .. Player.MaxStam)
    if Player.Stam >= Player.MaxStam then
        CALog_debug("Player stamina is full, skipping stamina buff.")
        return false
    end
    staminaPercentage = (Player.Stam / Player.MaxStam) * 100
    if not forced and staminaPercentage > StaminaPotionsConfig.DrinkThreshould then
        CALog_debug("Player stamina is above " .. staminaPercentage .. "%, skipping stamina buff.")
        return false
    end
    return true
end

function CAPotionsStamina_drinkSuccessfullPredicate()
    return CATime_pauseUntil(function() return Journal.Contains("You feel invigorated") end, 50, CATime_getActionWaitTime())
end

function CAPotionsStamina_stamina(forced)
    if not StaminaPotionsConfig.Enable then
        return
    end
    local potionDrinkState, lastDrinkTime = CAPotionsDrink_drink(CAPotionsStamina_StaminaPotionsStaticConfig.Potion, CAPotionsStamina_StaminaPotionsStaticConfig.Name, CAPotionsStamina_shouldAtemptDrink, CAPotionsStamina_drinkSuccessfullPredicate, forced)
    if lastDrinkTime then
        CAPotionsStamina_StaminaPotionsState.lastDrinkTime = lastDrinkTime
    end
    return potionDrinkState == DrinkAtemptResult.DRANK_POTION
end

StrengthPotionsConfig = {
    Enable = false,
    BaseStr = 100,
    DrinkHeal = false
}

CAPotionsStrength_StrengthPotionsStaticConfig = {
    Potion = 0x0f09,
    Name = "Greater Strength"
}

CAPotionsStrength_StrengthPotionsState = {
    lastDrinkTime = nil
}

function CAPotionsStrength_setEnable(val)
    StrengthPotionsConfig.Enable = val
end

function CAPotionsStrength_setBaseStrength(val)
    StrengthPotionsConfig.BaseStrength = val
end

function CAPotionsStrength_setDrinkHeal(val)
    StrengthPotionsConfig.DrinkHeal = val
end

function CAPotionsStrength_setConfig(config)
    CAPotionsStrength_setEnable(config.Enable)
    CAPotionsStrength_setBaseStrength(config.BaseStrength)
    CAPotionsStrength_setDrinkHeal(config.DrinkHeal)
end

function CAPotionsStrength_shouldAtemptDrink(forced)
    --if CAPotionsTime_shouldAtemptToDrinkStrength(CAPotionsStrength_StrengthPotionsState.lastDrinkTime) == false then
    --    return false
    --end
    CALog_debug("Checking if strength is debuffed or dropped")
    if Player.Str > StrengthPotionsConfig.BaseStrength then
        CALog_debug("Player strength is above base strength, skipping strength buff.")
        return false
    end
    return true
end

function CAPotionsStrength_drinkSuccessfullPredicate()
    return CATime_pauseUntil(function() return Player.Str > StrengthPotionsConfig.BaseStrength end, 50, CATime_getActionWaitTime())
end

function CAPotionsStrength_strength(forced)
    if not StrengthPotionsConfig.Enable then
        return false
    end
    local drinkReturnVal, lastDrinkTime = CAPotionsDrink_drink(CAPotionsStrength_StrengthPotionsStaticConfig.Potion, CAPotionsStrength_StrengthPotionsStaticConfig.Name, CAPotionsStrength_shouldAtemptDrink, CAPotionsStrength_drinkSuccessfullPredicate, forced)
    drankPotion = (drinkReturnVal == DrinkAtemptResult.DRANK_POTION)
    if lastDrinkTime then
        CAPotionsStrength_StrengthPotionsState.lastDrinkTime = lastDrinkTime
    end
    if drankPotion and StrengthPotionsConfig.DrinkHeal then
        CALog_debug("Strength buffed, drinking health potion to recover right away.")
        CAPotionsHealing_health(true)
    end
    return drankPotion
end

AgilityPotionsConfig = {
    Enable = false,
    BaseAgility = 100,
    DrinkRefresh = false
}

CAPotionsAgility_AgilityPotionsStaticConfig = {
    Potion = 0x0f08,
    Name = "Greater Agility"
}

CAPotionsAgility_AgilityPotionsState = {
    lastDrinkTime = nil
}

function CAPotionsAgility_setEnable(val)
    AgilityPotionsConfig.Enable = val
end

function CAPotionsAgility_setBaseAgility(val)
    AgilityPotionsConfig.BaseAgility = val
end

function CAPotionsAgility_setDrinkRefresh(val)
    AgilityPotionsConfig.DrinkRefresh = val
end

function CAPotionsAgility_setConfig(config)
    CAPotionsAgility_setEnable(config.Enable)
    CAPotionsAgility_setBaseAgility(config.BaseAgility)
    CAPotionsAgility_setDrinkRefresh(config.DrinkRefresh)
end

function CAPotionsAgility_shouldAtemptDrink(forced)
    --if CAPotionsTime_shouldAtemptToDrinkAgility(CAPotionsAgility_AgilityPotionsState.lastDrinkTime) == false then
    --    return false
    --end
    CALog_debug("Checking if dexterity is debuffed or dropped")
    if Player.Dex > AgilityPotionsConfig.BaseAgility then
        CALog_debug("Player dexterity is above base value, skipping agility buff.")
        return false
    end
    return true
end

function CAPotionsAgility_drinkSuccessfullPredicate()
    return CATime_pauseUntil(function() return Player.Dex > AgilityPotionsConfig.BaseAgility end, 50, CATime_getActionWaitTime())
end

function CAPotionsAgility_agility(forced)
    if not AgilityPotionsConfig.Enable then
        return false
    end
    local drinkReturnVal, lastDrinkTime = CAPotionsDrink_drink(CAPotionsAgility_AgilityPotionsStaticConfig.Potion, CAPotionsAgility_AgilityPotionsStaticConfig.Name, CAPotionsAgility_shouldAtemptDrink, CAPotionsAgility_drinkSuccessfullPredicate, forced)
    drankPotion = (drinkReturnVal == DrinkAtemptResult.DRANK_POTION)
    if lastDrinkTime then
        CAPotionsAgility_AgilityPotionsState.lastDrinkTime = lastDrinkTime
    end
    if drankPotion and AgilityPotionsConfig.DrinkRefresh then
        CALog_debug("Agility buffed, drinking refresh potion to recover right away.")
        CAPotionsStamina_stamina(true)
    end
    return drankPotion
end

EatFoodConfig = {
    Enable = false
}

CAEatFood_EatFoodStaticConfig = {
    EatCooldown = 15 * 60 * 1000, -- in ms, how often to eat food
    BuffFoods = {
        65340, --- Meat Feast
        65342 --- Fish Plate
    }
}

CAEatFood_EatFoodState = {
    lastEatTime = nil
}

function CAEatFood_setEnable(val)
    EatFoodConfig.Enable = val
end

function CAEatFood_setConfig(config)
    CAEatFood_setEnable(config.Enable)
end

function CAEatFood_eatFood()

    if true then
        --- Bugged: buff foods don't prevent eating if already under the effect
        return
    end

    if not EatFoodConfig.Enable then
        return
    end

    currentTickTime = CATime_getCurrentTickTime()
    if not CATime_exceedsDuration(CAEatFood_EatFoodState.lastEatTime, currentTickTime, CATime_getActionWaitTime()) then
        CALog_debug("Food check time is not ready, skipping.")
        return
    end

    if not CATime_exceedsDuration(CAEatFood_EatFoodState.lastEatTime, currentTickTime, CAEatFood_EatFoodStaticConfig.EatCooldown) then
        CALog_debug("Eat cooldown not met, skipping.")
        return
    end

    CALog_debug("Lookin for food...")
    foodToEat = nil
    for _, graphic in pairs(CAEatFood_EatFoodStaticConfig.BuffFoods) do
        found = BaseLib_findInInventory({graphic})
        if found and #found > 0 then
            for _, item in ipairs(found) do

                foodToEat = item
                goto eatfood
            end
        end
    end

    :: eatfood ::
    if not foodToEat then
        CALog_debug("No food items found in inventory.")
        return
    end

    CALog_debug("Attempting to eat: " .. (foodToEat.Name or "Unknown"))
    Player.UseObject(foodToEat.Serial)

    CALog_info("Finished eating")
    CAEatFood_EatFoodState.lastEatTime = currentTickTime

end

BuffsConfig = {
    Enable = false --- To enable/disable auto-buffs altogether
}

function CABuffs_setEnable(val)
    BuffsConfig.Enable = val
end

function CABuffs_setConfig(config)
    CABuffs_setEnable(config.Enable)
    CASongOfHealing_setConfig(config.SongOfHealing)
    CAPotionsNightsight_setConfig(config.Nightsight)
    CAPotionsStamina_setConfig(config.Stamina)
    CAPotionsStrength_setConfig(config.Strength)
    CAPotionsAgility_setConfig(config.Agility)
    CAEatFood_setConfig(config.EatFood)
end

function CABuffs_buffs()

    if not BuffsConfig.Enable then
        return
    end

    if Player.IsDead then
        CALog_debug("Player is dead, skipping buffs.")
        return
    end

    if Player.IsHidden then
        CALog_debug("Player is hiding, skipping buffs.")
        return
    end

    CALog_debug("Applying buffs.")
    CASongOfHealing_songOfHealing()
    CAPotionsNightsight_nightsight(false)
    CAPotionsStamina_stamina(false)
    CAPotionsStrength_strength(false)
    CAPotionsAgility_agility(false)
    CAEatFood_eatFood()

end

PeacemakingConfig = {
    Enable = false
}

CADebuffs_CAPeacemaking_PeacemakingState = {
    isActive = false,
    startTime = nil,
    endTime = nil
}

function CAPeacemaking_setEnable(val)
    PeacemakingConfig.Enable = val
end

function CAPeacemaking_setConfig(config)
    CAPeacemaking_setEnable(config.Enable)
end

function CAPeacemaking_peacemaking()

    if not PeacemakingConfig.Enable then
        return
    end

    skill = Skills.GetValue("Peacemaking")
    if not skill or not (skill > 0) then
        CALog_debug("No skill in peacemaking...")
        return
    end

    if recentCast() then
        CALog_debug("Resent cast, waiting to retry peacemaking.")
        CADebuffs_CAPeacemaking_PeacemakingState.isActive = true
        CADebuffs_CAPeacemaking_PeacemakingState.startTime = CATime_getCurrentTickTime()
        recastWaitTime = 8
        CADebuffs_CAPeacemaking_PeacemakingState.endTime = CADebuffs_CAPeacemaking_PeacemakingState.startTime + recastWaitTime
        return
    end

    if not Journal.Contains("You begin to play a soothing melody") or not Journal.Contains("That creature is already being calmed.") then
        CALog_debug("No Peacemaking song in progress, starting...")
        Spells.Cast("Peacemaking")
    end

end

DebuffsConfig = {
    Enable = false --
}

function CADebuffs_setEnable(val)
    DebuffsConfig.Enable = val
end

function CADebuffs_setConfig(config)
    CADebuffs_setEnable(config.Enable)
    CAPeacemaking_setConfig(config.Peacemaking)
end

function CADebuffs_debuffs()

    if not DebuffsConfig.Enable then
        return
    end

    CALog_debug("Buffs running")

    if Player.IsHidden then
        CALog_debug("Player is hiding, skipping buffs.")
        return
    end

    CAPeacemaking_peacemaking()

end

DetectPlayersConfig = {
    Enable = false
}

CADetectPlayers_DetectPlayersStaticConfig = {
    Players = { "oFrizz", "FloodgateUO", "Lespunk Strange", "Vector", "BTK", "RDY", "BRG", "URK" },
    AlertPauseTime = 10 * 1000 -- alert once per 10 seconds
}

CADetectPlayers_DetectPlayersState = {
    lastTickTime = 0,
    lastOverheadTime = 0
}

function CADetectPlayers_setEnable(val)
    DetectPlayersConfig.Enable = val
end

function CADetectPlayers_setConfig(config)
    CADetectPlayers_setEnable(config.Enable)
end

function CADetectPlayers_detectPlayers()

    if not DetectPlayersConfig.Enable then
        return
    end

    currentTickTime = CATime_getCurrentTickTime()

    CALog_debug("Hunting for players...")

    CADetectPlayers_DetectPlayersState.lastTickTime = currentTickTime

    isWarningTimeExceeded = CATime_exceedsDuration(CADetectPlayers_DetectPlayersState.lastOverheadTime, currentTickTime, CADetectPlayers_DetectPlayersStaticConfig.AlertPauseTime)
    if not isWarningTimeExceeded then
        CALog_debug("Last player detection notification was too recent, skipping")
        return
    end

    for index, playerName in ipairs(CADetectPlayers_DetectPlayersStaticConfig.Players) do
        CALog_debug("Looking for player " .. index .. "... ")
        if Journal.Contains(playerName) then
            CALog_info("Hunted player " .. playerName)
            CADetectPlayers_DetectPlayersState.lastOverheadTime = currentTickTime
        end
    end

end

ScavengeConfig = {
    Enable = false,
    Frequency = 0, -- milliseconds, zero means immediate
    LootItemsSerials = {
        0x0F3F,
        0x1BFB
    },
    LootItemsNames = {},
    DisallowGold = false,
    DisallowCleanBandage = false,
    DisallowBones = false,
    DisallowGrimoire = false,
    DisallowRibs = false
}

CAScavenge_GraphicIDs = {
    Gold = 0x0EED,
    CleanBandage = 0x0E21,
    Bones = 0x0F7E,
    Grimoire = 0x2D9D,
    Ribs = 0x09F1
}

CAScavenge_ScavengeState = {
    lastTickTime = 0
}

function CAScavenge_setEnable(val)
    ScavengeConfig.Enable = val
end

function CAScavenge_setFrequency(val)
    ScavengeConfig.Frequency = val
end

function CAScavenge_setLootItemsSerials(val)
    ScavengeConfig.LootItemsSerials = val
end

function CAScavenge_setLootItemsNames(val)
    ScavengeConfig.LootItemsNames = val
end

CAScavenge_graphicIdLootableSet = {}
CAScavenge_graphicIdToPriority = {}

function CAScavenge_setConfig(config)
    CAScavenge_setEnable(config.Enable)
    CAScavenge_setFrequency(config.Frequency)
    CAScavenge_setLootItemsSerials(config.LootItemsSerials)
    CAScavenge_setLootItemsNames(config.LootItemsNames)
    ScavengeConfig.DisallowGold = config.DisallowGold
    ScavengeConfig.DisallowCleanBandage = config.DisallowCleanBandage
    ScavengeConfig.DisallowBones = config.DisallowBones
    ScavengeConfig.DisallowGrimoire = config.DisallowGrimoire
    ScavengeConfig.DisallowRibs = config.DisallowRibs

    local haveGold = false
    local haveCleanBandage = false
    local haveBones = false
    local haveGrimoire = false
    local haveRibs = false
    CAScavenge_graphicIdLootableSet = {}
    CAScavenge_graphicIdToPriority = {}
    for i, graphic in ipairs(ScavengeConfig.LootItemsSerials) do

        if graphic == CAScavenge_GraphicIDs.Gold then
            haveGold = true
            if ScavengeConfig.DisallowGold then
                goto continue
            end
        end

        if graphic == CAScavenge_GraphicIDs.CleanBandage then
            haveCleanBandage = true
            if ScavengeConfig.DisallowCleanBandage then
                goto continue
            end
        end

        if graphic == CAScavenge_GraphicIDs.Bones then
            haveBones = true
            if ScavengeConfig.DisallowBones then
                goto continue
            end
        end

        if graphic == CAScavenge_GraphicIDs.Grimoire then
            haveGrimoire = true
            if ScavengeConfig.DisallowGrimoire then
                goto continue
            end
        end

        if graphic == CAScavenge_GraphicIDs.Ribs then
            haveRibs = true
            if ScavengeConfig.DisallowRibs then
                goto continue
            end
        end

        CAScavenge_graphicIdLootableSet[graphic] = true
        CAScavenge_graphicIdToPriority[graphic] = i

        ::continue::
    end

    if not haveGold and not ScavengeConfig.DisallowGold then
        CALog_debug("Manually adding gold to Scavenging list...")
        CAScavenge_graphicIdLootableSet[CAScavenge_GraphicIDs.Gold] = true
        CAScavenge_graphicIdToPriority[CAScavenge_GraphicIDs.Gold] = #ScavengeConfig.LootItemsSerials + 1
    end

    if not haveCleanBandage and not ScavengeConfig.DisallowCleanBandage then
        CALog_debug("Manually adding clean bandage to Scavenging list...")
        CAScavenge_graphicIdLootableSet[CAScavenge_GraphicIDs.CleanBandage] = true
        CAScavenge_graphicIdToPriority[CAScavenge_GraphicIDs.CleanBandage] = #ScavengeConfig.LootItemsSerials + 2
    end

    if not haveBones and not ScavengeConfig.DisallowBones then
        CALog_debug("Manually adding gold to Scavenging list...")
        CAScavenge_graphicIdLootableSet[CAScavenge_GraphicIDs.Bones] = true
        CAScavenge_graphicIdToPriority[CAScavenge_GraphicIDs.Bones] = #ScavengeConfig.LootItemsSerials + 3
    end

    if not haveGrimoire and not ScavengeConfig.DisallowGrimoire then
        CALog_debug("Manually adding gold to Scavenging list...")
        CAScavenge_graphicIdLootableSet[CAScavenge_GraphicIDs.Grimoire] = true
        CAScavenge_graphicIdToPriority[CAScavenge_GraphicIDs.Grimoire] = #ScavengeConfig.LootItemsSerials + 4
    end

    if not haveRibs and not ScavengeConfig.DisallowRibs then
        CALog_debug("Manually adding gold to Scavenging list...")
        CAScavenge_graphicIdLootableSet[CAScavenge_GraphicIDs.Ribs] = true
        CAScavenge_graphicIdToPriority[CAScavenge_GraphicIDs.Ribs] = #ScavengeConfig.LootItemsSerials + 5
    end

end

CORPSE_GRAPHIC = 0x2006
ACTION_DELAY = 800
corpseFilter = {
    graphics = {CORPSE_GRAPHIC},
    onground = true,
    rangemin = 0,
    rangemax = 2
}
fatAlertReadyMs = 0

function tableContains_(tbl, val)
    for _, value in ipairs(tbl) do
        if value == val then
            return true
        end
    end
    return false
end

processedCorpses = {}

function HasProcessedCorpse_(serial)
    return processedCorpses[serial] == true
end

function MarkCorpseProcessed_(serial)
    processedCorpses[serial] = true
end

function extractWeight_(item)
    -- Pattern explanation:
    -- .*- matches any character (including newlines due to how Lua handles this in patterns) zero or more times, as few as possible.
    -- (?:...) - this is a general regex concept, but not directly supported in standard Lua patterns.
    -- The approach below uses Lua's native patterns and capture groups.

    -- Attempt to match "Weight: " followed by 1-3 digits.
    -- 'Weight:%s*(%d%d?%d?)'
    -- %s* matches zero or more whitespace characters.
    -- (%d%d?%d?) captures 1, 2, or 3 digits.
    local weight_str = string.match(item.Properties, "Weight:%s*(%d%d?%d?) Stone")

    if weight_str then
        return tonumber(weight_str) -- Convert the captured string to a number
    else
        -- If the "Weight: " pattern isn't found, you might want to return nil or a default value
        -- depending on your specific needs when it's missing entirely.
        -- In this case, it returns nil, so you can handle it.
        return nil
    end
end

function WordCheckMultiple_(str1, keywordString)
    local lowerStr = string.lower(str1)
    for word in string.gmatch(keywordString, "%S+") do
        local lowerWord = string.lower(word)
        if not string.find(lowerStr, lowerWord, 1, true) then
            return false
        end
    end
    return true
end

function GetSortedItemList_()
    local seriableIdLootPriorityList = {}
    local itemList = Items.FindByFilter({onground=false})
    for index, item in ipairs(itemList) do
        if item.RootContainer == Player.Serial then
            goto continue
        end

        if item.RootContainer == Player.Backpack.Serial then
            goto continue
        end

        container = Items.FindBySerial(item.Container)

        if container == nil or container.Name == nil or string.find(container.Name:lower(), "corpse") == nil or container.Distance > 2 then
            goto continue
        end

        if item.Distance == nil or (item.Distance > 2 and item.Distance < 16) then
            goto continue
        end

        if item.IsLootable == false then
            goto continue
        end

        if item.Name == nil then
            goto continue
        end

        if item.Properties == nil then
            goto continue
        end

        if not CAScavenge_graphicIdLootableSet[item.Graphic] and not BaseLib_equalsAnyInTable(item.Name, ScavengeConfig.LootItemsNames) then
            goto continue
        end

        isLockedDown = WordCheckMultiple_(item.Properties, "Locked Down")
        if isLockedDown == true then
            goto continue
        end

        weight = extractWeight_(item)
        if weight ~= nil and weight + Player.Weight > Player.MaxWeight then

            if os.time() * 1000 > fatAlertReadyMs then

                Messages.OverheadMobile(Player.Serial, "too fat, big heavy .. no pick up " .. item.Name .. " (" .. tostring(weight) .. " stones)", 47)

                fatAlertReadyMs = (os.time() * 1000) + 5000
            end
            goto continue
        end

        table.insert(seriableIdLootPriorityList, item)
        ::continue::
    end

    table.sort(seriableIdLootPriorityList, function(a, b)
        local priorityA = CAScavenge_graphicIdToPriority[a.Graphic] or math.huge
        local priorityB = CAScavenge_graphicIdToPriority[b.Graphic] or math.huge
        if priorityA == priorityB then
            return (a.Name or "") < (b.Name or "")
        end
        return priorityA < priorityB
    end)

    return seriableIdLootPriorityList
end

function AutoLoot_()
    local sortedItemList = GetSortedItemList_()
    if #sortedItemList > 0 then
        for i, item in ipairs(sortedItemList) do
            Player.PickUp(sortedItemList[i].Serial, sortedItemList[i].Amount)
            Player.DropInBackpack()
            Pause(ACTION_DELAY)
        end
    end
end

function CAScavenge_scavenge()

    if not ScavengeConfig.Enable then
        return
    end

    currentTickTime = CATime_getCurrentTickTime()

    if not CATime_exceedsDuration(CAScavenge_ScavengeState.lastTickTime, currentTickTime, ScavengeConfig.Frequency) then
        CALog_debug("Scavenging is not ready yet, skipping this tick.")
        return
    end
    CAScavenge_ScavengeState.lastTickTime = currentTickTime

    CALog_debug("Scavenging...")
    processedCorpses = {}
    corpses = Items.FindByFilter(corpseFilter)
    for _, corpse in ipairs(corpses) do
        if not HasProcessedCorpse_(corpse.Serial) then

            AutoLoot_()

            MarkCorpseProcessed_(corpse.Serial)
        end
    end

end

CASkinn_IUScissors_messageHue = 42

function IUScissors_getScissors(verbose)
    local scissors = Items.FindByName('Scissors')
    if verbose and scissors == nil then
        Messages.OverheadMobile(Player.Serial, "Missing Scissors", CASkinn_IUScissors_messageHue)
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

CASkinn_IUSkinn_messageHue = 42
CASkinn_IUSkinn_skinning_knife_type_id = 65193

function IUSkinn_getSkinningKnife(verbose)
    local best_skinning_knife = IPLib_getItemWithLessUsesRemaining(CASkinn_IUSkinn_skinning_knife_type_id, nil)
    if verbose and best_skinning_knife == nil then
        Messages.OverheadMobile(Player.Serial, "Missing Skinning Knife", CASkinn_IUSkinn_messageHue)
    end
    return best_skinning_knife
end

function IUSkinn_useSkinningKnife(callback, verbose)
    local best_skinning_knife = IUSkinn_getSkinningKnife(verbose)
    if best_skinning_knife then
        Player.UseObject(best_skinning_knife.Serial)
    end
    if callback then
        callback()
    end
    return best_skinning_knife ~= nil
end

SkinnConfig = {
    Enable = false,
    NoisyMode = true,       --- To Log XOR Say when dropping or keeping a resource
    LeatherHuesToKeep = {
        --- 0x0000,         --- Regular
        --- 0x0973,         --- Dull Copper
        --- 0x0966,         --- Shadow Iron
        --- 0x096D,         --- Copper
        0x0972,             --- Bronze
        0x08A5,             --- Gold
        0x0979,             --- Agapite
        0x089F,             --- Verite
        0x08AB              --- Valorite
    }
}

SkinnStaticConfig = {
    CorpseFilter = {
        graphics = {0x2006},
        onground = true,
        rangemin = 0,
        rangemax = 2
    },
    CorpsesToSkip = {
        400,            --- Human
        401,            --- Female
    },
    WarningPauseTime = 10000
}

SkinnState = {
    lastOverHeadTime = 0
}

function CASkinn_setEnable(val)
    SkinnConfig.Enable = val
end

function CASkinn_setNoisyMode(val)
    SkinnConfig.NoisyMode = val
end

function CASkinn_setConfig(config)
    CASkinn_setEnable(config.Enable)
    CASkinn_setNoisyMode(config.NoisyMode)
    SkinnConfig.LeatherHuesToKeep = config.LeatherHuesToKeep
end

function CASkinn_announceFoundHide(hide, keep)
    local msgPrefix = keep and "+ " or "- "
    local msgSufix = keep and " +" or " -"
    if SkinnConfig.NoisyMode then
        Player.Say(msgPrefix .. hide.Name .. msgSufix, 48)
    else
        CALog_mainInfo(msgPrefix .. hide.Name .. " " .. msgSufix)
    end
end

processedCorpses = {}

function HasProcessedCorpse(serial)
    return processedCorpses[serial] == true
end

function MarkCorpseProcessed(serial)
    processedCorpses[serial] = true
end

function CASkinn_skinn()

    if not SkinnConfig.Enable then
        return
    end

    corpses = Items.FindByFilter(SkinnStaticConfig.CorpseFilter)
    for _, corpse in ipairs(corpses) do

        hides = nil
        if HasProcessedCorpse(corpse.Serial) then
            CALog_debug("Skipping corpse: " .. (corpse.Name or "Unknown") .. "(already processed)")
            goto skip_corpse
        end

        if BaseLib_tableContains(SkinnStaticConfig.CorpsesToSkip, corpse.Amount) then
            CALog_debug("Skipping corpse: " .. (corpse.Name or "Unknown"))
            goto skip_corpse
        end

        Pause(1.5 * CATime_getActionWaitTime())

        if not IUSkinn_useSkinningKnife(nil, false) then
            if CATime_exceedsDuration(SkinnState.lastOverHeadTime, CATime_getCurrentTickTime(), SkinnStaticConfig.WarningPauseTime) then
                CALog_error("Failed to use skinning knife: " .. (corpse.Name or "Unknown") .. "...")
                SkinnState.lastOverHeadTime = CATime_getCurrentTickTime()
            end
            goto skip_corpse
        end
        CALog_info("Skinning corpse: " .. (corpse.Name or "Unknown"))
        Target.WaitForTarget(0.5 * CATime_getActionWaitTime(), false)
        Target.TargetSerial(corpse.Serial)
        Pause(0.5 * CATime_getActionWaitTime())

        Player.UseObject(corpse.Serial)
        Pause(0.5 * CATime_getActionWaitTime())

        hides = Items.FindByFilter({                                                                    --- For all hides
            graphics = {0x1079},
            onground = false
        })
        for _, hide in ipairs(hides) do

            if hide.RootContainer ~= Player.Serial then
                goto skip_hide
            end

            keepHide = BaseLib_tableContains(SkinnConfig.LeatherHuesToKeep, hide.Hue)
            if not keepHide then

                CASkinn_announceFoundHide(hide, false)
                Player.PickUp(hide.Serial, hide.Amount)
                Player.DropOnGround()
                Pause(0.5 * CATime_getActionWaitTime())
            else

                CASkinn_announceFoundHide(hide, true)
                if not IUScissors_useScissors(nil, false) then
                    if CATime_exceedsDuration(SkinnState.lastOverHeadTime, CATime_getCurrentTickTime(), SkinnStaticConfig.WarningPauseTime) then
                        CALog_error("Failed to use scissors: " .. (corpse.Name or "Unknown") .. "...")
                        SkinnState.lastOverHeadTime = CATime_getCurrentTickTime()
                    end
                    goto skip_corpse
                end
                Target.WaitForTarget(3000)
                Target.TargetSerial(hide.Serial)
                Pause(0.5 * CATime_getActionWaitTime())
            end

            :: skip_hide ::
        end

        :: skip_corpse ::
        MarkCorpseProcessed(corpse.Serial)
    end
end

function IPMaterialPredicates_itemIsOfIron(item)
    local itemMaterial = IPLib_getMaterial(item)
    BaseLib_printIfDebug(true, itemMaterial)
    if itemMaterial == "Iron" then
        return true
    end
    return false
end

function IPMaterialPredicates_itemIsOfShadow(item)
    local itemMaterial = IPLib_getMaterial(item)
    BaseLib_printIfDebug(true, itemMaterial)
    if itemMaterial == "Shadow" then
        return true
    end
    return false
end

function IPMaterialPredicates_itemIsOfCopper(item)
    local itemMaterial = IPLib_getMaterial(item)
    BaseLib_printIfDebug(true, itemMaterial)
    if itemMaterial == "Copper" then
        return true
    end
    return false
end

function IPMaterialPredicates_itemIsOfBronze(item)
    local itemMaterial = IPLib_getMaterial(item)
    BaseLib_printIfDebug(true, itemMaterial)
    if itemMaterial == "Bronze" then
        return true
    end
    return false
end

function IPMaterialPredicates_itemIsOfVerite(item)
    local itemMaterial = IPLib_getMaterial(item)
    BaseLib_printIfDebug(true, itemMaterial)
    if itemMaterial == "Verite" then
        return true
    end
    return false
end

function IPMaterialPredicates_itemIsOfValorite(item)
    local itemMaterial = IPLib_getMaterial(item)
    BaseLib_printIfDebug(true, itemMaterial)
    if itemMaterial == "Valorite" then
        return true
    end
    return false
end

IUMinerSwap_IUSwapItemInHand_debugEnabled = true

function IUSwapItemInHand_swapItemInHand(config, callback)

    --- Get items to swap
    local first_item = Items.FindByType(config.first.serial)
    local second_item = Items.FindByType(config.second.serial)

    --- Get item in hand
    local item_in_hand = Items.FindByLayer(1)
    if not item_in_hand then
        item_in_hand = Items.FindByLayer(2)
    end

    equipItemOfFirstType = true
    if item_in_hand ~= nil then

        BaseLib_printIfDebug(IUMinerSwap_IUSwapItemInHand_debugEnabled, "Have item in hand")

        Player.PickUp(item_in_hand.Serial)
        Player.DropInBackpack()
        Pause(500)

        itemInHandMatchesFirstType = true
        if first_item and first_item.Name then
            a = string.find(item_in_hand.Name, first_item.Name)
            b = string.find(first_item.Name, item_in_hand.Name)
            itemInHandMatchesFirstType = (a ~= nil or b ~= nil)
        end
        itemInHandVerifiesFirstTypeAcceptPredicate = not config.first.acceptPredicate or config.first.acceptPredicate(item_in_hand)
        BaseLib_printIfDebug(IUMinerSwap_IUSwapItemInHand_debugEnabled, "Have first type item: "..tostring(first_item ~= nil))
        BaseLib_printIfDebug(IUMinerSwap_IUSwapItemInHand_debugEnabled, "Item in hand of first type: "..tostring(itemInHandMatchesFirstType))
        BaseLib_printIfDebug(IUMinerSwap_IUSwapItemInHand_debugEnabled, "Item in hand of first type and verifies first type accept predicate evaluation: "..tostring(itemInHandVerifiesFirstTypeAcceptPredicate))

        if first_item == nil or (itemInHandMatchesFirstType and itemInHandVerifiesFirstTypeAcceptPredicate) then
            equipItemOfFirstType = false
        end

    end

    if first_item ~= nil and equipItemOfFirstType == true then
        BaseLib_printIfDebug(IUMinerSwap_IUSwapItemInHand_debugEnabled, "Equip First")
        config.first.equip()
        Pause(500)
    elseif second_item ~= nil then
        BaseLib_printIfDebug(IUMinerSwap_IUSwapItemInHand_debugEnabled, "Equip Second")
        config.second.equip()
        Pause(500)
    end

    if callback then
        callback()
    end

end

pickaxe_type_id = 3718
war_axe_type_id = 5040
war_hammer_type_id = 5177
pickaxeAcceptPredicate = nil
postSwapCallback = nil

function IUMinerSwap_equipPickaxe()
    local pickaxe = Items.FindByType(pickaxe_type_id)
    IPLib_equipItemWithLessUsesRemaining(pickaxe_type_id, pickaxe.Name, pickaxeAcceptPredicate)
end

function IUMinerSwap_equipWarAxeAndFight()
    local war_axe = Items.FindByType(war_axe_type_id)
    IPLib_equipItemWithLessDurability(war_axe_type_id, war_axe.Name)
    if postSwapCallback then
        Pause(500)
        postSwapCallback()
    end
end

function IUMinerSwap_equipWarHammerAndFight()
    local war_axe = Items.FindByType(war_hammer_type_id)
    IPLib_equipItemWithLessDurability(war_hammer_type_id, war_axe.Name)
    Pause(500)
    if postSwapCallback then
        postSwapCallback()
    end
end

config = {
    first = { serial = pickaxe_type_id, equip = IUMinerSwap_equipPickaxe , acceptPredicate = nil},
    second = { serial = war_axe_type_id, equip = IUMinerSwap_equipWarAxeAndFight , acceptPredicate = nil }
    --second = { serial = war_hammer_type_id, equip = equipWarHammerAndFight, acceptPredicate = nil  }
}

function IUMinerSwap_minerSwap(pickaxeAcceptPredicate_, callback)
    config.first.acceptPredicate = pickaxeAcceptPredicate_
    pickaxeAcceptPredicate = pickaxeAcceptPredicate_
    postSwapCallback = callback
    IUSwapItemInHand_swapItemInHand(config, callback)
end

IULumberjackSwap_hatchet_type_id = 3907
IULumberjackSwap_double_axe_type_id = 3915
IULumberjackSwap_hatchetAcceptPredicate = nil
IULumberjackSwap_postSwapCallback = nil

function IULumberjackSwap_equipHatchet()
    local hatchet = Items.FindByType(IULumberjackSwap_hatchet_type_id)
    IPLib_equipItemWithLessUsesRemaining(IULumberjackSwap_hatchet_type_id, hatchet.Name, IULumberjackSwap_hatchetAcceptPredicate)
end

function IULumberjackSwap_equipAxeAndFight()
    local axe = Items.FindByType(IULumberjackSwap_double_axe_type_id)
    Player.Equip(axe.Serial)
    if IULumberjackSwap_postSwapCallback then
        Pause(500)
        IULumberjackSwap_postSwapCallback()
    end
end

IULumberjackSwap_config = {
    first = { serial = IULumberjackSwap_hatchet_type_id, equip = IULumberjackSwap_equipHatchet, acceptPredicate = nil },
    second = { serial = IULumberjackSwap_double_axe_type_id, equip = IULumberjackSwap_equipAxeAndFight, acceptPredicate = nil }
}

function IULumberjackSwap_lumberjackSwap(hatchetAcceptPredicate_, callback)
    IULumberjackSwap_config.first.acceptPredicate = hatchetAcceptPredicate_
    IULumberjackSwap_hatchetAcceptPredicate = hatchetAcceptPredicate_
    IULumberjackSwap_postSwapCallback = callback
    IUSwapItemInHand_swapItemInHand(IULumberjackSwap_config, callback)
end

function IUIDWand_useIdWand(callback)

    --- get wand with less charges
    local wandGraphicIDs = { 3570, 3571, 3572, 3573 }
    wand = IPLib_getItemWithLessIdentificationCharges(wandGraphicIDs, nil)
    if wand == nil then
        Messages.Overhead("Missing Wand", 69, Player.Serial)
        return
    end

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

    if callback then
        callback()
    end

end

UserTriggeredCommandsConfig = {
    Enable = false,
    CommandStringPrefix = ""    --- The Log Prefix that commands are expecting as comming from you
    --Password = ""             --- For security: so others can't interract with your combat assistant!
                                --- Set and never share it
}

function CAUserTriggeredCommands_setEnable(val)
    UserTriggeredCommandsConfig.Enable = val
end

function CAUserTriggeredCommands_setCommandStringPrefix(val)
    UserTriggeredCommandsConfig.CommandStringPrefix = val
end

function CAUserTriggeredCommands_setConfig(config)
    CAUserTriggeredCommands_setEnable(config.Enable)
    CAUserTriggeredCommands_setCommandStringPrefix(config.CommandStringPrefix)
end

function CAUserTriggeredCommands_minerSwapIron()
    IUMinerSwap_minerSwap(IPMaterialPredicates_itemIsOfIron, nil)
end

function CAUserTriggeredCommands_minerSwapCopper()
    IUMinerSwap_minerSwap(IPMaterialPredicates_itemIsOfCopper, nil)
end

function CAUserTriggeredCommands_lumberjackSwapIron()
    IULumberjackSwap_lumberjackSwap(IPMaterialPredicates_itemIsOfIron, nil)
end

function CAUserTriggeredCommands_lumberjackSwapCopper()
    IULumberjackSwap_lumberjackSwap(IPMaterialPredicates_itemIsOfCopper, nil)
end

function CAUserTriggeredCommands_useSkinningKnife()
    IUSkinn_useSkinningKnife(nil, true)
end

function CAUserTriggeredCommands_useScissors()
    IUScissors_useScissors(nil, true)
end

function CAUserTriggeredCommands_useIdWand()
    IUIDWand_useIdWand(nil)
end

function CAUserTriggeredCommands_useMiningStart()
    --IUIDWand_useIdWand(nil)
end

function CAUserTriggeredCommands_useMiningStop()
    --IUIDWand_useIdWand(nil)
end

Commands = {
    { Keyword = "Miner Swap Iron", Callback = CAUserTriggeredCommands_minerSwapIron },
    { Keyword = "Miner Swap Copper", Callback = CAUserTriggeredCommands_minerSwapCopper },
    { Keyword = "Lumberjack Swap Iron", Callback = CAUserTriggeredCommands_lumberjackSwapIron },
    { Keyword = "Lumberjack Swap Copper", Callback = CAUserTriggeredCommands_lumberjackSwapCopper },
    { Keyword = "Skinn", Callback = CAUserTriggeredCommands_useSkinningKnife },
    { Keyword = "Scissors", Callback = CAUserTriggeredCommands_useScissors },
    { Keyword = "ID Wand", Callback = CAUserTriggeredCommands_useIdWand },
    { Keyword = "Let's Mine!", Callback = CAUserTriggeredCommands_useMiningStart },
    { Keyword = "I'm done minning...", Callback = CAUserTriggeredCommands_useMiningStop }
}

function CAUserTriggeredCommands_journalContainsCommand(keyword)
    local searchString = UserTriggeredCommandsConfig.CommandStringPrefix.." "..keyword
    CALog_debug("Searching for user triggered command: "..searchString)
    return Journal.Contains(searchString)
end

function CAUserTriggeredCommands_processUserCommands()

    if not UserTriggeredCommandsConfig.Enable then
        return
    end

    CALog_debug("Processing player triggered commands:")
    for _, command in ipairs(Commands) do
        if CAUserTriggeredCommands_journalContainsCommand(command.Keyword) then
            CALog_debug("Executing command: "..command.Keyword)
            command.Callback()
            Pause(CATime_getActionWaitTime())
        end
    end

end

AttackConfig = {
    Enable = false,
    Rangemax = 10,
    AllowMobilesExceptionsSerials = true,
    MobilesExceptionsSerials = nil,
    AllowMobilesExceptionsGraphicIDs = true,
    MobilesExceptionsGraphicIDs = nil,
    AllowMobilesExceptionsNames = true,
    MobilesExceptionsNames = nil,
    CheckFrequency = 3000
}

CAAttack_AttackState = {
    lastCheckTickTime = nil
}

function CAAttack_setEnable(val)
    AttackConfig.Enable = val
end

function CAAttack_setRangemax(val)
    AttackConfig.Rangemax = val
end

function CAAttack_setMobilesExceptionSerialsList(val)
    AttackConfig.MobilesExceptionsSerials = val
end

function CAAttack_setMobilesExceptionGraphicIDsList(val)
    AttackConfig.MobilesExceptionsGraphicIDs = val
end

function CAAttack_setMobilesExceptionNamesList(val)
    AttackConfig.MobilesExceptionsNames = val
end

function CAAttack_setCheckFrequency(val)
    AttackConfig.CheckFrequency = val
end

function CAAttack_setConfig(config)
    CAAttack_setEnable(config.Enable)
    CAAttack_setRangemax(config.Rangemax)
    AttackConfig.AllowMobilesExceptionsSerials = config.AllowMobilesExceptionsSerials
    CAAttack_setMobilesExceptionSerialsList(config.MobilesExceptionsSerials)
    AttackConfig.AllowMobilesExceptionsGraphicIDs = config.AllowMobilesExceptionsGraphicIDs
    CAAttack_setMobilesExceptionGraphicIDsList(config.MobilesExceptionsGraphicIDs)
    AttackConfig.AllowMobilesExceptionsNames = config.AllowMobilesExceptionsNames
    CAAttack_setMobilesExceptionNamesList(config.MobilesExceptionsNames)
    CAAttack_setCheckFrequency(config.CheckFrequency)
end

function CAAttack_nearestMosttHitMobileFirstComparePredicate(mobile_l, mobile_r)
    if mobile_l.Distance == mobile_r.Distance then
        if mobile_l.DiffHits == mobile_r.DiffHits then
            return (mobile_l.Name or "") < (mobile_r.Name or "")
        end
        return mobile_l.DiffHits > mobile_r.DiffHits
    end
    return mobile_l.Distance < mobile_r.Distance
end

function CAAttack_targetAcceptPredicate(mobile)

    if mobile.IsDead then
        return false
    end

    if mobile.NotorietyFlag == "Innocent" or mobile.NotorietyFlag == "Ally" or mobile.NotorietyFlag == "Invulnerable" then
        return false
    end

    if mobile.Graphic == 0x0009 and mobile.Hue == 0x0000 then
        return false
    end

    if AttackConfig.AllowMobilesExceptionsSerials and BaseLib_equalsAnyInTable(mobile.Serial, AttackConfig.MobilesExceptionsSerials) then
        return false
    end

    if AttackConfig.AllowMobilesExceptionsGraphicIDs and BaseLib_equalsAnyInTable(mobile.Graphic, AttackConfig.MobilesExceptionsGraphicIDs) then
        return false
    end

    if AttackConfig.AllowMobilesExceptionsNames and BaseLib_equalsAnyInTable(mobile.Name, AttackConfig.MobilesExceptionsNames) then
        return false
    end

    return true
end

function CAAttack_attackNearestEnemy()

    if AttackConfig.Enable == false then
        return false
    end

    currentTickTime = CATime_getCurrentTickTime()
    if CAAttack_AttackState.lastCheckTickTime and not CATime_exceedsDuration(CAAttack_AttackState.lastCheckTickTime, currentTickTime, AttackConfig.CheckFrequency) then
        CALog_debug("Attack on cooldown: last atack check tick ("..CAAttack_AttackState.lastCheckTickTime..
            "), current ("..currentTickTime..
            "), elapsed ("..(currentTickTime-CAAttack_AttackState.lastCheckTickTime)..
            "), target ("..AttackConfig.CheckFrequency..")")
        return false
    end
    CAAttack_AttackState.lastCheckTickTime = currentTickTime

    CALog_debug('Searching for attack targets')
    filter = { rangemax = AttackConfig.Rangemax, notorieties = { 0, 3, 4, 5, 6} }
    list = Mobiles.FindByFilter(filter)
    for index, mobile in ipairs(list) do
        CALog_debug('Found mobile ('..mobile.Name..') at location x:'..mobile.X..' y:'..mobile.Y)
    end

    CALog_debug('Removing unwanted targets')
    for i = #list, 1, -1 do
        if not CAAttack_targetAcceptPredicate(list[i]) then
            table.remove(list, i)
        end
    end

    mobileTarget = nil
    if #list > 0 then

        CALog_debug('Sorting attack targets')
        table.sort(list, CAAttack_nearestMosttHitMobileFirstComparePredicate)
        for index, mobile in ipairs(list) do
            CALog_debug('Found mobile ('..mobile.Name..') at location x:'..mobile.X..' y:'..mobile.Y)
        end

        CALog_debug('Choosing attack target')
        for index, mobile in ipairs(list) do
            if mobile.Serial ~= Player.Serial then
                mobileTarget = mobile
                break
            end
        end
    end

    if mobileTarget then
        CALog_debug('Attacking ('..mobileTarget.Name..') at location x:'..mobileTarget.X..' y:'..mobileTarget.Y)
        Player.Attack(mobileTarget.Serial)
    else
        CALog_debug('Found no target to attack')
    end

    return true
end

function CAAttack_attack()
    return CAAttack_attackNearestEnemy()
end

MainLoopState = {
    lastJournalTickTime = 0
}

function CAMainLoop_configureModules(config)
    CAArmDisarm_setConfig(config.modules.ArmDisarm)
    CAEscape_setConfig(config.modules.Escape)
    CAPotionsCure_setConfig(config.modules.CurePotions)
    CAPotionsHealing_setConfig(config.modules.HealingPotions)
    CABandage_setConfig(config.modules.Bandages)
    CABuffs_setConfig(config.modules.Buffs)
    CADebuffs_setConfig(config.modules.Debuffs)
    CADetectPlayers_setConfig(config.modules.DetectPlayers)
    CASkinn_setConfig(config.modules.Skinning)
    CAScavenge_setConfig(config.modules.Scavenging)
    CAAttack_setConfig(config.modules.Attack)
end

function CAMainLoop_configure(config)
    CATime_setActionWaitTime(config.time.ActionWaitTime)
    CALog_setConfig(config.debug)
    CAMainLoop_configureModules(config)
    CAUserTriggeredCommands_setConfig(config.userCommands)
end

function CAMainLoop_journalDependantActions()
    CAArmDisarm_disarmPlayerIfWeaponDurabilityIsLow(true)
    CAEscape_popPouch()
    CAEscape_escape()
    CAPotionsCure_cure(false)
    CAPotionsHealing_health(false)
    CABandage_bandage()
    CABuffs_buffs()
    CADebuffs_debuffs()
    CAArmDisarm_rearmPlayer()
    CADetectPlayers_detectPlayers()
end

function CAMainLoop_journalIndependantActions()
    CAArmDisarm_disarmed()
    CAAttack_attack()
    CASkinn_skinn()
    CAScavenge_scavenge()
    CAEscape_moongate()
end

function CAMainLoop_mainLoopInit(config)

    --- Configure and Greet
    CAMainLoop_configure(config)
    CALog_mainInfo("Sagas Combat Assistant")
    CALog_debug("Sagas Combat Assistant - Started")

    --- Start with a clean journal
    Journal.Clear()
end

function CAMainLoop_mainLoopIterate(config)

    local newTickTime = CATime_updateCurrentTickTime()
    CALog_debug("Main tick loop start")

    if Player.IsDead then
        CALog_debug("Player is dead, skipping main loop.")
        goto main_loop_iteration_end
    end

    CALog_debug("Before journal tick.")
    if CATime_exceedsDuration(MainLoopState.lastJournalTickTime, newTickTime, config.time.JournalTick) then
        CALog_debug("Journal tick time exceeded, processing journal...")
        CAMainLoop_journalDependantActions()
        MainLoopState.lastJournalTickTime = newTickTime
    end

    CAMainLoop_journalIndependantActions()
    CAUserTriggeredCommands_processUserCommands()
    CALog_debug("Main tick loop end")

    :: main_loop_iteration_end ::
    Journal.Clear()
    Pause(config.time.MainLoopTick)
end

function CAMainLoop_mainLoop(config)
    CAMainLoop_mainLoopInit(config)                   --- Init main loop
    while true do
        CAMainLoop_mainLoopIterate(config)            --- Iterate main loop
    end
end

CAUIGump_CAUIGumpLayout_CAUIGumpLayoutConstants = {
    ModuleEnableButtonPosX = 10,
    ModuleEnableButtonSizeX = 100,
    ModuleEnableButtonSizeY = 30,
    ModuleEnableLabelPosX = 140,
    ModuleRowPosYStart = 70,
    ModuleRowPosYIncrement = 50,
    ModuleRowPosYLabelAlignIncrement = 8,
    ModuleConfigButtonPosX = 220,
    ModuleConfigButtonSizeX = 30,
    ModuleConfigButtonSizeY = 30,
    ModuleConfigWindowStartPosX = 500,
    ModuleConfigWindowStartBasePosY = 200,
    ModuleConfigWindowSizeX = 90,
    ModuleConfigWindowFeatureEnableButtonPosX = 10,
    ModuleConfigWindowFeatureEnableButtonPosYStart = 40,
    ModuleConfigWindowFeatureEnableButtonPosYIncrement = 50,
    ModuleConfigWindowFeatureEnableButtonSizeX = 110,
    ModuleConfigWindowFeatureEnableButtonSizeY = 30
}

function CAUIGumpLayout_getLayoutConstants()
    return CAUIGump_CAUIGumpLayout_CAUIGumpLayoutConstants
end

function CAUIGumpLayout_createModuleEnableButtonAtRow(mainWindow, row, buttonText, sizeX, sizeY)
    CALog_debug('Initializing Module Enable "..buttonText.." Button (At Row: "..row..")...')
    local buttonPosX = CAUIGump_CAUIGumpLayout_CAUIGumpLayoutConstants.ModuleEnableButtonPosX
    local buttonPosY = CAUIGump_CAUIGumpLayout_CAUIGumpLayoutConstants.ModuleRowPosYStart + ((row -1) * CAUIGump_CAUIGumpLayout_CAUIGumpLayoutConstants.ModuleRowPosYIncrement)
    local buttonSizeX = (sizeX ~= nil and sizeX) or CAUIGump_CAUIGumpLayout_CAUIGumpLayoutConstants.ModuleEnableButtonSizeX
    local buttonSizeY = (sizeY ~= nil and sizeY) or CAUIGump_CAUIGumpLayout_CAUIGumpLayoutConstants.ModuleEnableButtonSizeY
    local button = mainWindow:AddButton(buttonPosX, buttonPosY, buttonText, buttonSizeX, buttonSizeY)
    return button
end

function CAUIGumpLayout_createModuleEnableLabelAtRow(mainWindow, row, labelText)
    CALog_debug('Initializing Module Enable Label (At Row: "..row..")...')
    local labelPosX = CAUIGump_CAUIGumpLayout_CAUIGumpLayoutConstants.ModuleEnableLabelPosX
    local labelPosY = CAUIGump_CAUIGumpLayout_CAUIGumpLayoutConstants.ModuleRowPosYStart + ((row -1) * CAUIGump_CAUIGumpLayout_CAUIGumpLayoutConstants.ModuleRowPosYIncrement) + CAUIGump_CAUIGumpLayout_CAUIGumpLayoutConstants.ModuleRowPosYLabelAlignIncrement
    local label = mainWindow:AddLabel(labelPosX, labelPosY, labelText)
    label:SetColor(0, 1, 0, 1)
    return label
end

function CAUIGumpLayout_createModuleConfigButtonAtRow(mainWindow, row)
    CALog_debug('Initializing Module Config Button (At Row: "..row..")...')
    local buttonPosX = CAUIGump_CAUIGumpLayout_CAUIGumpLayoutConstants.ModuleConfigButtonPosX
    local buttonPosY = CAUIGump_CAUIGumpLayout_CAUIGumpLayoutConstants.ModuleRowPosYStart + ((row -1) * CAUIGump_CAUIGumpLayout_CAUIGumpLayoutConstants.ModuleRowPosYIncrement)
    local buttonSizeX = CAUIGump_CAUIGumpLayout_CAUIGumpLayoutConstants.ModuleConfigButtonSizeX
    local buttonSizeY = CAUIGump_CAUIGumpLayout_CAUIGumpLayoutConstants.ModuleConfigButtonSizeY
    local button = mainWindow:AddButton(buttonPosX, buttonPosY, '+', buttonSizeX, buttonSizeY)
    return button
end

function CAUIGumpLayout_createModuleConfigWindow(windowIDString, windowHeader, numRows, row)
    CALog_debug('Creating Module Config window '..windowIDString..'...')
    local moduleConfigWindow = UI.CreateWindow(windowIDString, windowHeader)
    if not moduleConfigWindow then
        CALog_debug('Failed to create Module Config window '..windowIDString..'!')
        return nil
    end
    CALog_debug('Initializing Module Config window '..windowIDString..'...')
    posX = CAUIGump_CAUIGumpLayout_CAUIGumpLayoutConstants.ModuleConfigWindowStartPosX
    posY = CAUIGump_CAUIGumpLayout_CAUIGumpLayoutConstants.ModuleConfigWindowStartBasePosY + ((numRows - 1) * CAUIGump_CAUIGumpLayout_CAUIGumpLayoutConstants.ModuleConfigWindowFeatureEnableButtonPosYIncrement)
    moduleConfigWindow:SetPosition(posX, posY)
    moduleConfigWindowSizeY = CAUIGump_CAUIGumpLayout_CAUIGumpLayoutConstants.ModuleConfigWindowFeatureEnableButtonPosYStart + ((numRows - 1) * CAUIGump_CAUIGumpLayout_CAUIGumpLayoutConstants.ModuleConfigWindowFeatureEnableButtonPosYIncrement) + 50
    moduleConfigWindow:SetSize(CAUIGump_CAUIGumpLayout_CAUIGumpLayoutConstants.ModuleConfigWindowSizeX, moduleConfigWindowSizeY)
    moduleConfigWindow:Hide()
    return moduleConfigWindow
end

function CAUIGumpLayout_createModuleConfigWindowButtonAtRow(configWindow, row, buttonText, sizeX, sizeY)
    CALog_debug('Initializing Module Config Window "..buttonText.." Button (At Row: "..row..")...')
    local buttonPosX = CAUIGump_CAUIGumpLayout_CAUIGumpLayoutConstants.ModuleConfigWindowFeatureEnableButtonPosX
    local buttonPosY = CAUIGump_CAUIGumpLayout_CAUIGumpLayoutConstants.ModuleConfigWindowFeatureEnableButtonPosYStart + ((row -1) * CAUIGump_CAUIGumpLayout_CAUIGumpLayoutConstants.ModuleConfigWindowFeatureEnableButtonPosYIncrement)
    local buttonSizeX = (sizeX ~= nil and sizeX) or CAUIGump_CAUIGumpLayout_CAUIGumpLayoutConstants.ModuleConfigWindowFeatureEnableButtonSizeX
    local buttonSizeY = (sizeY ~= nil and sizeY) or CAUIGump_CAUIGumpLayout_CAUIGumpLayoutConstants.ModuleConfigWindowFeatureEnableButtonSizeY
    local button = configWindow:AddButton(buttonPosX, buttonPosY, buttonText, buttonSizeX, buttonSizeY)
    return button
end

CAUIGumpMainRow_CAUIGumpMainRowLayout = {
    TitleLabelPosX = 10,
    TitleLabelPosY = 40,
    ConfigButtonPosX = 175,
    ConfigButtonPosY = 35,
    ConfigButtonSizeX = 85,
    ConfigButtonSizeY = 25
}

CAUIGumpMainRow_RearmModeValues = {
    None = 1,
    Move = 2,
    Time = 3,
    MoveAndTime = 4
}

CAUIGumpMainRow_RearmModeStrings = {
    'Rearm (None)',
    'Rearm (On Move)',
    'Rearm (On Timer)',
    'Rearm (On Move + Timer)'
}

CAUIGumpMainRow_SkinnModeValues = {
    None = 1,
    All = 2,
    ShaddowPlus = 3,
    CopperPlus = 4,
    BronzePlus = 5,
    VeritePlus = 6,
    ValoritePlus = 7
}

CAUIGumpMainRow_SkinnModeStrings = {
    'Skinn (None)',
    'Skinn (All)',
    'Skinn (Shaddow +)',
    'Skinn (Copper +)',
    'Skinn (Bronze +)',
    'Skinn (Verite +)',
    'Skinn (Valorite +)'
}

CAUIGumpMainRow_LeatherHuesToKeepNone = {
}

CAUIGumpMainRow_LeatherHuesToKeepAll = {
    0x0000,             --- Regular
    ---0x0973,             --- Dull Copper
    0x0966,             --- Shadow Iron
    0x096D,             --- Copper
    0x0972,             --- Bronze
    ---0x08A5,             --- Gold
    ---0x0979,             --- Agapite
    0x089F,             --- Verite
    0x08AB              --- Valorite
}

CAUIGumpMainRow_LeatherHuesToKeepShadowPlus = {
    0x0966,             --- Shadow Iron
    0x096D,             --- Copper
    0x0972,             --- Bronze
    0x089F,             --- Verite
    0x08AB              --- Valorite
}

CAUIGumpMainRow_LeatherHuesToKeepCopperPlus = {
    0x096D,             --- Copper
    0x0972,             --- Bronze
    0x089F,             --- Verite
    0x08AB              --- Valorite
}

CAUIGumpMainRow_LeatherHuesToKeepBronzePlus = {
    0x0972,             --- Bronze
    0x089F,             --- Verite
    0x08AB              --- Valorite
}

CAUIGumpMainRow_LeatherHuesToKeepVeritePlus = {
    0x089F,             --- Verite
    0x08AB              --- Valorite
}

CAUIGumpMainRow_LeatherHuesToKeepValoritePlus = {
    0x08AB              --- Valorite
}

CAUIGumpMainRow_SkinnModeHueKeepTables = {
    CAUIGumpMainRow_LeatherHuesToKeepNone,
    CAUIGumpMainRow_LeatherHuesToKeepAll,
    CAUIGumpMainRow_LeatherHuesToKeepShadowPlus,
    CAUIGumpMainRow_LeatherHuesToKeepCopperPlus,
    CAUIGumpMainRow_LeatherHuesToKeepBronzePlus,
    CAUIGumpMainRow_LeatherHuesToKeepVeritePlus,
    CAUIGumpMainRow_LeatherHuesToKeepValoritePlus
}

CAUIGumpMainRowState = {
    MainConfigOpen = true,
    RearmMode = CAUIGumpMainRow_RearmModeValues.Move,
    SkinnMode = CAUIGumpMainRow_SkinnModeValues.None
}

function onconfigButtonPressed_(isChecked, button, window)
    CALog_debug('Main config button changed: '..tostring(isChecked))
    CAUIGumpMainRowState.MainConfigOpen = isChecked
    if isChecked then
        button:SetText('CONFIG (+)')
        window:Hide()
    else
        button:SetText('CONFIG (-)')
        window:Show()
    end
end

function onRearmModePressed_(button)
    CALog_debug('Rearm Mode button pressed...')
    CAUIGumpMainRowState.RearmMode = (CAUIGumpMainRowState.RearmMode == CAUIGumpMainRow_RearmModeValues.MoveAndTime and CAUIGumpMainRow_RearmModeValues.None) or CAUIGumpMainRowState.RearmMode+1
    button:SetText(CAUIGumpMainRow_RearmModeStrings[CAUIGumpMainRowState.RearmMode])
end

function onSkinnModePressed_(button)
    CALog_debug('Skinn Mode button pressed...')
    CAUIGumpMainRowState.SkinnMode = (CAUIGumpMainRowState.SkinnMode == CAUIGumpMainRow_SkinnModeValues.ValoritePlus and CAUIGumpMainRow_SkinnModeValues.None) or CAUIGumpMainRowState.SkinnMode+1
    button:SetText(CAUIGumpMainRow_SkinnModeStrings[CAUIGumpMainRowState.SkinnMode])
end

function CAUIGumpMainRow_processUIInteractions(configB, configW, rearmB, skinnB)
    if configB:WasClicked() then
        onconfigButtonPressed_(not CAUIGumpMainRowState.MainConfigOpen, configB, configW)
    end
    if rearmB:WasClicked() then
        onRearmModePressed_(rearmB)
    end
    if skinnB:WasClicked() then
        onSkinnModePressed_(skinnB)
    end
end

function CAUIGumpMainRow_updateCAConfigToCurrentUIConfig(CAConfigArmDisarm, CAConfigSkinning)
    CAConfigArmDisarm.Enable = CAUIGumpMainRowState.RearmMode ~= CAUIGumpMainRow_RearmModeValues.None
    CAConfigArmDisarm.AutoRearmOnMove = CAConfigArmDisarm.Enable and (CAUIGumpMainRowState.RearmMode == CAUIGumpMainRow_RearmModeValues.Move or CAUIGumpMainRowState.RearmMode == CAUIGumpMainRow_RearmModeValues.MoveAndTime)
    CAConfigArmDisarm.AutoRearmWithDelay = CAConfigArmDisarm.Enable and (CAUIGumpMainRowState.RearmMode == CAUIGumpMainRow_RearmModeValues.Time or CAUIGumpMainRowState.RearmMode == CAUIGumpMainRow_RearmModeValues.MoveAndTime)

    CAConfigSkinning.Enable = CAUIGumpMainRowState.SkinnMode ~= CAUIGumpMainRow_SkinnModeValues.None
    CAConfigSkinning.LeatherHuesToKeep = CAUIGumpMainRow_SkinnModeHueKeepTables[CAUIGumpMainRowState.SkinnMode]
end

function CAUIGumpMainRow_initUI(mainWindow)

    CALog_debug('Creating Scavenge UI...')

    local titleLabel = mainWindow:AddLabel(CAUIGumpMainRow_CAUIGumpMainRowLayout.TitleLabelPosX, CAUIGumpMainRow_CAUIGumpMainRowLayout.TitleLabelPosY, 'SAGAS Combat Assistant')
    titleLabel:SetColor(0.2, 0.8, 1, 1)

    local configButton = mainWindow:AddButton(CAUIGumpMainRow_CAUIGumpMainRowLayout.ConfigButtonPosX, CAUIGumpMainRow_CAUIGumpMainRowLayout.ConfigButtonPosY, 'CONFIG (+)', CAUIGumpMainRow_CAUIGumpMainRowLayout.ConfigButtonSizeX, CAUIGumpMainRow_CAUIGumpMainRowLayout.ConfigButtonSizeY)

    local configW = CAUIGumpLayout_createModuleConfigWindow('MainConfigWindow', 'Main Config', 2, 1)
    local rearmB = CAUIGumpLayout_createModuleConfigWindowButtonAtRow(configW, 1, CAUIGumpMainRow_RearmModeStrings[CAUIGumpMainRowState.RearmMode], 180, CAUIGumpLayout_getLayoutConstants().ModuleConfigWindowFeatureEnableButtonSizeY)
    local skinnB = CAUIGumpLayout_createModuleConfigWindowButtonAtRow(configW, 2, CAUIGumpMainRow_SkinnModeStrings[CAUIGumpMainRowState.SkinnMode], 180, CAUIGumpLayout_getLayoutConstants().ModuleConfigWindowFeatureEnableButtonSizeY)

    return titleLabel, configButton, configW, rearmB, skinnB
end

CAUIGumpRunConfig = {
    IterateCAMainLoop = false
}

CAUIGumpRun_mainWindowRunButtonSizeX = 80
CAUIGumpRun_mainWindowRunButtonSizeY = 30

function CAUIGumpRun_getIterateCAMainLoop()
    return CAUIGumpRunConfig.IterateCAMainLoop
end

function CAUIGumpRun_onRunCombatAssistantButtonPressed(isChecked, label)
    CALog_debug('Run Button changed: '..tostring(isChecked))
    CAUIGumpRunConfig.IterateCAMainLoop = isChecked
    if isChecked then
        label:SetText('Running...')
        label:SetColor(0, 1, 0, 1)
    else
        label:SetText('Stopped')
        label:SetColor(1, 0, 0, 1)
    end
end

function CAUIGumpRun_processUIInteractions(button, label)
    if button:WasClicked() then
        CAUIGumpRun_onRunCombatAssistantButtonPressed(not CAUIGumpRunConfig.IterateCAMainLoop, label)
    end
end

function CAUIGumpRun_initUI(mainWindow, row)
    CALog_debug('Creating Run Button UI...')
    local button = CAUIGumpLayout_createModuleEnableButtonAtRow(mainWindow, row, 'Run', CAUIGumpRun_mainWindowRunButtonSizeX, CAUIGumpRun_mainWindowRunButtonSizeY)
    local label = CAUIGumpLayout_createModuleEnableLabelAtRow(mainWindow, row, 'Stopped')
    label:SetColor(1, 0, 0, 1)
    return button, label
end

CAUIGumpHeal_HealPotsModeValues = {
    None = 1,
    TenPercent = 2,
    TwentyPercent = 3,
    ThirtyPercent = 4,
    FiftyPercent = 5
}

CAUIGumpHeal_HealPotsPercentageThreshoulds = {
    0,
    10,
    20,
    30,
    50
}

CAUIGumpHeal_HealPotsModeStrings = {
    'Heal Pots (Disabled)',
    'Heal Pots (10% HP)',
    'Heal Pots (20% HP)',
    'Heal Pots (30% HP)',
    'Heal Pots (50% HP)'
}

CAUIGumpHealConfig = {
    OverrideWithNoHeal = false,
    ConfigWindowOpen = true,
    BandageSelf = true,
    BandageOther = true,
    HealPotsMode = CAUIGumpHeal_HealPotsModeValues.TwentyPercent,
    HealPotsAfterStrPot = true,
    CurePots = false
}

function onHealButtonPressed_(isChecked, label)
    CALog_debug('Heal button pressed: '..tostring(isChecked))
    CAUIGumpHealConfig.OverrideWithNoHeal = not isChecked
    if isChecked then
        label:SetText('Enabled')
        label:SetColor(0, 1, 0, 1)
    else
        label:SetText('Disabled')
        label:SetColor(1, 0, 0, 1)
    end
end

function onHealConfigButtonPressed_(isChecked, button, window)
    CALog_debug('Heal config button pressed: '..tostring(isChecked))
    CAUIGumpHealConfig.ConfigWindowOpen = isChecked
    if isChecked then
        button:SetText('+')
        window:Hide()
    else
        button:SetText('-')
        window:Show()
    end
end

function onBandageSelfButtonPressed_(isChecked, button)
    CALog_debug('Bandage Self button pressed: '..tostring(isChecked))
    CAUIGumpHealConfig.BandageSelf = isChecked
    if isChecked then
        button:SetText('Bandage Self (Y)')
    else
        button:SetText('Bandage Self (N)')
    end
end

function onBandageOtherButtonPressed_(isChecked, button)
    CALog_debug('Bandage Other button pressed: '..tostring(isChecked))
    CAUIGumpHealConfig.BandageOther = isChecked
    if isChecked then
        button:SetText('Bandage Others (Y)')
    else
        button:SetText('Bandage Others (N)')
    end
end

function onHealPotsModeButtonPressed_(button)
    CALog_debug('Healing Pots Mode button pressed...')
    CAUIGumpHealConfig.HealPotsMode = (CAUIGumpHealConfig.HealPotsMode == CAUIGumpHeal_HealPotsModeValues.FiftyPercent and CAUIGumpHeal_HealPotsModeValues.None) or CAUIGumpHealConfig.HealPotsMode+1
    button:SetText(CAUIGumpHeal_HealPotsModeStrings[CAUIGumpHealConfig.HealPotsMode])
end

function onHealPotAfterStrenghPotButtonPressed_(isChecked, button)
    CALog_debug('Use Heal after Strength button pressed: '..tostring(isChecked))
    CAUIGumpHealConfig.HealPotsAfterStrPot = isChecked
    if isChecked then
        button:SetText('Heal On Str (Y)')
    else
        button:SetText('Heal On Str (N)')
    end
end

function onCurePotsModeButtonPressed_(isChecked, button)
    CALog_debug('Use Cure button pressed: '..tostring(isChecked))
    CAUIGumpHealConfig.CurePots = isChecked
    if isChecked then
        button:SetText('Use Cure (Y)')
    else
        button:SetText('Use Cure (N)')
    end
end

function CAUIGumpHeal_processUIInteractions(enableB, enableL, configB, configW, bandageSB, bandageOB, healPMB, healPASPB, curePB)
    if enableB:WasClicked() then
        onHealButtonPressed_(CAUIGumpHealConfig.OverrideWithNoHeal, enableL)
    end
    if configB:WasClicked() then
        onHealConfigButtonPressed_(not CAUIGumpHealConfig.ConfigWindowOpen, configB, configW)
    end
    if bandageSB:WasClicked() then
        onBandageSelfButtonPressed_(not CAUIGumpHealConfig.BandageSelf, bandageSB)
    end
    if bandageOB:WasClicked() then
        onBandageOtherButtonPressed_(not CAUIGumpHealConfig.BandageOther, bandageOB)
    end
    if healPMB:WasClicked() then
        onHealPotsModeButtonPressed_(healPMB)
    end
    if healPASPB:WasClicked() then
        onHealPotAfterStrenghPotButtonPressed_(not CAUIGumpHealConfig.HealPotsAfterStrPot, healPASPB)
    end
    if curePB:WasClicked() then
        onCurePotsModeButtonPressed_(not CAUIGumpHealConfig.CurePots, curePB)
    end
end

function CAUIGumpHeal_updateCAConfigToCurrentUIConfig(CAConfigBandages, CAConfigCurePotions, CAConfigHealingPotions, CAConfigBuffsStrength)

    if not CAUIGumpHealConfig.OverrideWithNoHeal then
        CAConfigBandages.Enable = CAUIGumpHealConfig.BandageSelf
        CAConfigBandages.BandageAllies = CAUIGumpHealConfig.BandageOther
        CAConfigHealingPotions.Enable = CAUIGumpHealConfig.HealPotsMode ~= CAUIGumpHeal_HealPotsModeValues.None
        CAConfigHealingPotions.HPDrinkThreshould = CAUIGumpHeal_HealPotsPercentageThreshoulds[CAUIGumpHealConfig.HealPotsMode]
        CAConfigBuffsStrength.DrinkHeal = CAUIGumpHealConfig.HealPotsAfterStrPot
        CAConfigCurePotions.Enable = CAUIGumpHealConfig.CurePots
    else
        CAConfigBandages.Enable = false
        CAConfigBandages.BandageAllies = false
        CAConfigHealingPotions.Enable = false
        CAConfigHealingPotions.HPDrinkThreshould = 0
        CAConfigBuffsStrength.DrinkHeal = false
        CAConfigCurePotions.Enable = false
    end
end

function CAUIGumpHeal_initUI(mainWindow, row)
    CALog_debug('Creating Healing UI...')
    local enableB = CAUIGumpLayout_createModuleEnableButtonAtRow(mainWindow, row, 'Heal')
    local enableL = CAUIGumpLayout_createModuleEnableLabelAtRow(mainWindow, row, 'Enabled')
    ---enableL:SetColor(1, 0, 0, 1)
    local configB = CAUIGumpLayout_createModuleConfigButtonAtRow(mainWindow, row)
    local configW = CAUIGumpLayout_createModuleConfigWindow('healConfigWindow', 'Heal Config', 5, row)
    local bandageSB = CAUIGumpLayout_createModuleConfigWindowButtonAtRow(configW, 1, 'Bandage Self (Y)', 140, CAUIGumpLayout_getLayoutConstants().ModuleConfigWindowFeatureEnableButtonSizeY)
    local bandageOB = CAUIGumpLayout_createModuleConfigWindowButtonAtRow(configW, 2, 'Bandage Others (Y)', 140, CAUIGumpLayout_getLayoutConstants().ModuleConfigWindowFeatureEnableButtonSizeY)
    local healPMB = CAUIGumpLayout_createModuleConfigWindowButtonAtRow(configW, 3, CAUIGumpHeal_HealPotsModeStrings[CAUIGumpHealConfig.HealPotsMode], 180, CAUIGumpLayout_getLayoutConstants().ModuleConfigWindowFeatureEnableButtonSizeY)
    local healPASPB = CAUIGumpLayout_createModuleConfigWindowButtonAtRow(configW, 4, 'Heal On Str (N)', 140, CAUIGumpLayout_getLayoutConstants().ModuleConfigWindowFeatureEnableButtonSizeY)
    local curePB = CAUIGumpLayout_createModuleConfigWindowButtonAtRow(configW, 5, 'Use Cure (N)', 140, CAUIGumpLayout_getLayoutConstants().ModuleConfigWindowFeatureEnableButtonSizeY)
    return enableB, enableL, configB, configW, bandageSB, bandageOB, healPMB, healPASPB, curePB
end

CAUIGumpBuffs_StaminaPotsModeValues = {
    None = 1,
    FiftyPercent = 2,
    SixtyPercent = 3,
    SeventyPercent = 4,
    EightyPercent = 5
}

CAUIGumpBuffs_StaminaPotsModeThreshoulds = {
    0,
    50,
    60,
    70,
    80
}

CAUIGumpBuffs_StaminaPotsModeStrings = {
    'Stamina Pots (Disabled)',
    'Stamina Pots (50% STA)',
    'Stamina Pots (60% STA)',
    'Stamina Pots (70% STA)',
    'Stamina Pots (80% STA)'
}

CAUIGumpBuffsState = {
    OverrideWithNoBuffs = true,
    ConfigWindowOpen = true,
    EnableNightsight = true,
    EnableStrength = true,
    EnableAgility = true,
    HealPotsAfterStrPot = true,
    StaminaPotsMode = CAUIGumpBuffs_StaminaPotsModeValues.SixtyPercent
}

function CAUIGumpBuffs_onOverrideWithNoBuffsButtonPressed(isChecked, label)
    CALog_debug('Buffs disabled checkbox changed: '..tostring(isChecked))
    CAUIGumpBuffsState.OverrideWithNoBuffs = not isChecked
    if isChecked then
        label:SetText('Enabled')
        label:SetColor(0, 1, 0, 1)
    else
        label:SetText('Disabled')
        label:SetColor(1, 0, 0, 1)
    end
end

function onBuffsConfigButtonPressed_(isChecked, button, window)
    CALog_debug('Buffs config button pressed: '..tostring(isChecked))
    CAUIGumpBuffsState.ConfigWindowOpen = isChecked
    if isChecked then
        button:SetText('+')
        window:Hide()
    else
        button:SetText('-')
        window:Show()
    end
end

function onNightsightButtonPressed_(isChecked, button)
    CALog_debug('Nightsight button pressed: '..tostring(isChecked))
    CAUIGumpBuffsState.EnableNightsight = isChecked
    if isChecked then
        button:SetText('Nightsight (Y)')
    else
        button:SetText('Nightsight (N)')
    end
end

function onStrengthButtonPressed_(isChecked, button)
    CALog_debug('Strength button pressed: '..tostring(isChecked))
    CAUIGumpBuffsState.EnableStrength = isChecked
    if isChecked then
        button:SetText('Strength (Y)')
    else
        button:SetText('Strength (N)')
    end
end

function onAgilityButtonPressed_(isChecked, button)
    CALog_debug('Agility button pressed: '..tostring(isChecked))
    CAUIGumpBuffsState.EnableAgility = isChecked
    if isChecked then
        button:SetText('Agility (Y)')
    else
        button:SetText('Agility (N)')
    end
end

function onStaminaPotAfterStrenghPotButtonPressed_(isChecked, button)
    CALog_debug('Use Stamina Pot after Agility Pot button pressed: '..tostring(isChecked))
    CAUIGumpHealConfig.HealPotsAfterStrPot = isChecked
    if isChecked then
        button:SetText('Refresh On Agi (Y)')
    else
        button:SetText('Refresh On Agi (N)')
    end
end

function onStaminaPotsModeButtonPressed_(button)
    CALog_debug('Stamina Pots Mode button pressed...')
    CAUIGumpBuffsState.StaminaPotsMode = (CAUIGumpBuffsState.StaminaPotsMode == CAUIGumpBuffs_StaminaPotsModeValues.EightyPercent and CAUIGumpBuffs_StaminaPotsModeValues.None) or CAUIGumpBuffsState.StaminaPotsMode+1
    button:SetText(CAUIGumpBuffs_StaminaPotsModeStrings[CAUIGumpBuffsState.StaminaPotsMode])
end

function CAUIGumpBuffs_processUIInteractions(enableB, enableL, configB, configW, nightsightB, strengthB, agilityB, staminaPAAPB, staminaPMB)
    if enableB:WasClicked() then
        CAUIGumpBuffs_onOverrideWithNoBuffsButtonPressed(CAUIGumpBuffsState.OverrideWithNoBuffs, enableL)
    end
    if configB:WasClicked() then
        onBuffsConfigButtonPressed_(not CAUIGumpBuffsState.ConfigWindowOpen, configB, configW)
    end
    if nightsightB:WasClicked() then
        onNightsightButtonPressed_(not CAUIGumpBuffsState.EnableNightsight, nightsightB)
    end
    if strengthB:WasClicked() then
        onStrengthButtonPressed_(not CAUIGumpBuffsState.EnableStrength, strengthB)
    end
    if agilityB:WasClicked() then
        onAgilityButtonPressed_(not CAUIGumpBuffsState.EnableAgility, agilityB)
    end
    if staminaPAAPB:WasClicked() then
        onStaminaPotAfterStrenghPotButtonPressed_(not CAUIGumpBuffsState.HealPotsAfterStrPot, staminaPAAPB)
    end
    if staminaPMB:WasClicked() then
        onStaminaPotsModeButtonPressed_(staminaPMB)
    end
end

function CAUIGumpBuffs_updateCAConfigToCurrentUIConfig(CAConfigBuffs)
    CAConfigBuffs.Enable = not CAUIGumpBuffsState.OverrideWithNoBuffs
    CAConfigBuffs.Nightsight.Enable = CAUIGumpBuffsState.EnableNightsight
    CAConfigBuffs.Strength.Enable = CAUIGumpBuffsState.EnableStrength
    CAConfigBuffs.Agility.Enable = CAUIGumpBuffsState.EnableAgility
    CAConfigBuffs.Stamina.Enable = CAUIGumpBuffsState.StaminaPotsMode ~= CAUIGumpBuffs_StaminaPotsModeValues.None
    CAConfigBuffs.Stamina.DrinkThreshould = CAUIGumpBuffs_StaminaPotsModeThreshoulds[CAUIGumpBuffsState.StaminaPotsMode]
end

function CAUIGumpBuffs_initUI(mainWindow, row)
    CALog_debug('Creating Buffs UI...')
    local enableB = CAUIGumpLayout_createModuleEnableButtonAtRow(mainWindow, row, 'Buffs')
    local enableL = CAUIGumpLayout_createModuleEnableLabelAtRow(mainWindow, row, 'Disabled')
    enableL:SetColor(1, 0, 0, 1)
    local configB = CAUIGumpLayout_createModuleConfigButtonAtRow(mainWindow, row)
    local configW = CAUIGumpLayout_createModuleConfigWindow('buffsConfigWindow', 'Buffs Config', 5, row)
    local nightsightB = CAUIGumpLayout_createModuleConfigWindowButtonAtRow(configW, 1, 'Nightsight (Y)')
    local strengthB = CAUIGumpLayout_createModuleConfigWindowButtonAtRow(configW, 2, 'Strength (Y)')
    local agilityB = CAUIGumpLayout_createModuleConfigWindowButtonAtRow(configW, 3, 'Agility (Y)')
    local staminaPAAPB = CAUIGumpLayout_createModuleConfigWindowButtonAtRow(configW, 4, 'Refresh On Agi (Y)', 140, CAUIGumpLayout_getLayoutConstants().ModuleConfigWindowFeatureEnableButtonSizeY)
    local staminaPMB = CAUIGumpLayout_createModuleConfigWindowButtonAtRow(configW, 5, CAUIGumpBuffs_StaminaPotsModeStrings[CAUIGumpBuffsState.StaminaPotsMode], 180, CAUIGumpLayout_getLayoutConstants().ModuleConfigWindowFeatureEnableButtonSizeY)
    return enableB, enableL, configB, configW, nightsightB, strengthB, agilityB, staminaPAAPB, staminaPMB
end

CAUIGumpCommandsConfig = {
    OverrideWithNoCommands = false
}

function CAUIGumpCommands_onOverrideWithNoCommandsButtonPressed(isChecked, label)
    CALog_debug('Commands disabled checkbox changed: '..tostring(isChecked))
    CAUIGumpCommandsConfig.OverrideWithNoCommands = not isChecked
    if isChecked then
        label:SetText('Enabled')
        label:SetColor(0, 1, 0, 1)
    else
        label:SetText('Disabled')
        label:SetColor(1, 0, 0, 1)
    end
end

function CAUIGumpCommands_processUIInteractions(button, label)
    if button:WasClicked() then
        CAUIGumpCommands_onOverrideWithNoCommandsButtonPressed(CAUIGumpCommandsConfig.OverrideWithNoCommands, label)
    end
end

function CAUIGumpCommands_updateCAConfigToCurrentUIConfig(CAConfigCommands)
    CAConfigCommands.Enable = not CAUIGumpCommandsConfig.OverrideWithNoCommands
end

function CAUIGumpCommands_initUI(mainWindow, row)
    CALog_debug('Creating Commands UI...')
    local button = CAUIGumpLayout_createModuleEnableButtonAtRow(mainWindow, row, 'Commands')
    local label = CAUIGumpLayout_createModuleEnableLabelAtRow(mainWindow, row, 'Enabled')
    return button, label
end

CAUIGumpAttackConfig = {
    OverrideWithNoAttacks = true,
    ConfigWindowOpen = true,
    AttackRangeMax = 5,
    AttackExceptionsMode = true
}

function CAUIGumpAttack_onAttackButtonPressed(isChecked, label)
    CALog_debug('Attack disabled checkbox changed: '..tostring(isChecked))
    CAUIGumpAttackConfig.OverrideWithNoAttacks = not isChecked
    if isChecked then
        label:SetText('Enabled')
        label:SetColor(0, 1, 0, 1)
    else
        label:SetText('Disabled')
        label:SetColor(1, 0, 0, 1)
    end
end

function onAttackConfigButtonPressed_(isChecked, button, window)
    CALog_debug('Attack config button pressed: '..tostring(isChecked))
    CAUIGumpAttackConfig.ConfigWindowOpen = isChecked
    if isChecked then
        button:SetText('+')
        window:Hide()
    else
        button:SetText('-')
        window:Show()
    end
end

function onAttackRangeMaxButtonPressed_(button)
    CALog_debug('Attack Range Max button pressed: '..tostring(isChecked))
    CAUIGumpAttackConfig.AttackRangeMax = (CAUIGumpAttackConfig.AttackRangeMax == 11 and 1) or CAUIGumpAttackConfig.AttackRangeMax+2
    button:SetText('Range ('..CAUIGumpAttackConfig.AttackRangeMax..')')
end

function onAttackExceptionsModeButtonPressed_(isChecked, button)
    CALog_debug('Attack Mode button pressed: '..tostring(isChecked))
    CAUIGumpAttackConfig.AttackExceptionsMode = isChecked
    if isChecked then
        button:SetText('Exceptions (ID + Names)')
    else
        button:SetText('Exceptions (None)')
    end
end

function CAUIGumpAttack_processUIInteractions(enableB, enableL, configB, configW, rangeMB, attackEB)
    if enableB:WasClicked() then
        CAUIGumpAttack_onAttackButtonPressed(CAUIGumpAttackConfig.OverrideWithNoAttacks, enableL)
    end
    if configB:WasClicked() then
        onAttackConfigButtonPressed_(not CAUIGumpAttackConfig.ConfigWindowOpen, configB, configW)
    end
    if rangeMB:WasClicked() then
        onAttackRangeMaxButtonPressed_(rangeMB)
    end
    if attackEB:WasClicked() then
        onAttackExceptionsModeButtonPressed_(not CAUIGumpAttackConfig.AttackExceptionsMode, attackEB)
    end
end

function CAUIGumpAttack_updateCAConfigToCurrentUIConfig(CAConfigAttack)
    CAConfigAttack.Enable = not CAUIGumpAttackConfig.OverrideWithNoAttacks
    CAConfigAttack.Rangemax = CAUIGumpAttackConfig.AttackRangeMax
    CAConfigAttack.AllowMobilesExceptionsGraphicIDs = CAUIGumpAttackConfig.AttackExceptionsMode
    CAConfigAttack.AllowMobilesExceptionsNames = CAUIGumpAttackConfig.AttackExceptionsMode
end

function CAUIGumpAttack_initUI(mainWindow, row)
    CALog_debug('Creating Attack UI...')
    local enableB = CAUIGumpLayout_createModuleEnableButtonAtRow(mainWindow, row, 'Attack')
    local enableL = CAUIGumpLayout_createModuleEnableLabelAtRow(mainWindow, row, 'Disabled')
    enableL:SetColor(1, 0, 0, 1)
    local configB = CAUIGumpLayout_createModuleConfigButtonAtRow(mainWindow, row)
    local configW = CAUIGumpLayout_createModuleConfigWindow('attackConfigWindow', 'Attack Config', 2, row)
    local rangeMB = CAUIGumpLayout_createModuleConfigWindowButtonAtRow(configW, 1, 'Range ('..CAUIGumpAttackConfig.AttackRangeMax..')')
    local attackEB = CAUIGumpLayout_createModuleConfigWindowButtonAtRow(configW, 2, 'Exceptions (ID + Names)', 180, CAUIGumpLayout_getLayoutConstants().ModuleConfigWindowFeatureEnableButtonSizeY)
    return enableB, enableL, configB, configW, rangeMB, attackEB
end

CAUIGumpScavengeConfig = {
    OverrideWithNoScavenger = true,
    ConfigWindowOpen = true,
    ScavengeGold = true,
    ScavengeCleanBandages = true,
    ScavengeBones = true,
    ScavengeGrimoire = true,
    ScavengeRibs = true
}

function onScavengeButtonPressed_(isChecked, label)
    CALog_debug('Scavenger disabled checkbox changed: '..tostring(isChecked))
    CAUIGumpScavengeConfig.OverrideWithNoScavenger = not isChecked
    if isChecked then
        label:SetText('Enabled')
        label:SetColor(0, 1, 0, 1)
    else
        label:SetText('Disabled')
        label:SetColor(1, 0, 0, 1)
    end
end

function onScavengerConfigButtonPressed_(isChecked, button, window)
    CALog_debug('Scavenger config checkbox changed: '..tostring(isChecked))
    CAUIGumpScavengeConfig.ConfigWindowOpen = isChecked
    if isChecked then
        button:SetText('+')
        window:Hide()
    else
        button:SetText('-')
        window:Show()
    end
end

function onScavengerGoldButtonPressed_(isChecked, button)
    CALog_debug('Scavenger allow gold checkbox changed: '..tostring(isChecked))
    CAUIGumpScavengeConfig.ScavengeGold = isChecked
    if isChecked then
        button:SetText('Gold (Y)')
    else
        button:SetText('Gold (N)')
    end
end

function onScavengerBandagesButtonPressed_(isChecked, button)
    CALog_debug('Scavenger allow bandages checkbox changed: '..tostring(isChecked))
    CAUIGumpScavengeConfig.ScavengeCleanBandages = isChecked
    if isChecked then
        button:SetText('Bandages (Y)')
    else
        button:SetText('Bandages (N)')
    end
end

function onScavengerBonesButtonPressed_(isChecked, button)
    CALog_debug('Scavenger allow bones checkbox changed: '..tostring(isChecked))
    CAUIGumpScavengeConfig.ScavengeBones = isChecked
    if isChecked then
        button:SetText('Bones (Y)')
    else
        button:SetText('Bones (N)')
    end
end

function onScavengerGrimoireButtonPressed_(isChecked, button)
    CALog_debug('Scavenger allow grimoire checkbox changed: '..tostring(isChecked))
    CAUIGumpScavengeConfig.ScavengeGrimoire = isChecked
    if isChecked then
        button:SetText('Grimoires (Y)')
    else
        button:SetText('Grimoires (N)')
    end
end

function onScavengerRibsButtonPressed_(isChecked, button)
    CALog_debug('Scavenger allow grimoire checkbox changed: '..tostring(isChecked))
    CAUIGumpScavengeConfig.ScavengeRibs = isChecked
    if isChecked then
        button:SetText('Ribs (Y)')
    else
        button:SetText('Ribs (N)')
    end
end

function CAUIGumpScavenge_processUIInteractions(enableB, enableL, configB, configW, goldB, bandagesB, bonesB, grimoireB, ribsB)
    if enableB:WasClicked() then
        onScavengeButtonPressed_(CAUIGumpScavengeConfig.OverrideWithNoScavenger, enableL)
    end
    if configB:WasClicked() then
        onScavengerConfigButtonPressed_(not CAUIGumpScavengeConfig.ConfigWindowOpen, configB, configW)
    end
    if goldB:WasClicked() then
        onScavengerGoldButtonPressed_(not CAUIGumpScavengeConfig.ScavengeGold, goldB)
    end
    if bandagesB:WasClicked() then
        onScavengerBandagesButtonPressed_(not CAUIGumpScavengeConfig.ScavengeCleanBandages, bandagesB)
    end
    if bonesB:WasClicked() then
        onScavengerBonesButtonPressed_(not CAUIGumpScavengeConfig.ScavengeBones, bonesB)
    end
    if grimoireB:WasClicked() then
        onScavengerGrimoireButtonPressed_(not CAUIGumpScavengeConfig.ScavengeGrimoire, grimoireB)
    end
    if ribsB:WasClicked() then
        onScavengerRibsButtonPressed_(not CAUIGumpScavengeConfig.ScavengeRibs, ribsB)
    end
end

function CAUIGumpScavenge_updateCAConfigToCurrentUIConfig(CAConfigScavenge)
    CAConfigScavenge.Enable = not CAUIGumpScavengeConfig.OverrideWithNoScavenger
    CAConfigScavenge.DisallowGold = not CAUIGumpScavengeConfig.ScavengeGold
    CAConfigScavenge.DisallowCleanBandages = not CAUIGumpScavengeConfig.ScavengeCleanBandages
    CAConfigScavenge.DisallowBones = not CAUIGumpScavengeConfig.ScavengeBones
    CAConfigScavenge.DisallowGrimoire = not CAUIGumpScavengeConfig.ScavengeGrimoire
    CAConfigScavenge.DisallowRibs = not CAUIGumpScavengeConfig.ScavengeRibs
end

function CAUIGumpScavenge_initUI(mainWindow, row)
    CALog_debug('Creating Scavenge UI...')
    local enableB = CAUIGumpLayout_createModuleEnableButtonAtRow(mainWindow, row, 'Scavenge')
    local enableL = CAUIGumpLayout_createModuleEnableLabelAtRow(mainWindow, row, 'Disabled')
    enableL:SetColor(1, 0, 0, 1)
    local configB = CAUIGumpLayout_createModuleConfigButtonAtRow(mainWindow, row)
    local configW = CAUIGumpLayout_createModuleConfigWindow('scavengerConfigWindow', 'Scavenge Config', 5, row)
    local goldB = CAUIGumpLayout_createModuleConfigWindowButtonAtRow(configW, 1, 'Gold (Y)')
    local bandagesB = CAUIGumpLayout_createModuleConfigWindowButtonAtRow(configW, 2, 'Bandages (Y)')
    local bonesB = CAUIGumpLayout_createModuleConfigWindowButtonAtRow(configW, 3, 'Bones (Y)')
    local grimoireB = CAUIGumpLayout_createModuleConfigWindowButtonAtRow(configW, 4, 'Grimoires (Y)')
    local ribsB = CAUIGumpLayout_createModuleConfigWindowButtonAtRow(configW, 5, 'Ribs (Y)')
    return enableB, enableL, configB, configW, goldB, bandagesB, bonesB, grimoireB, ribsB
end

CAUI = {
    mainWindow = nil,
    titleLabel = nil,
    configButton = nil,
    Config = {
        window = nil,
        rearmButton = nil,
        skinnButton = nil
    },
    Run = {
        enableButton = nil,
        enableLabel = nil
    },
    Commands = {
        enableButton = nil,
        enableLabel = nil
    },
    Attack = {
        enableButton = nil,
        enableLabel = nil,
        configButton = nil,
        Config = {
            window = nil,
            rangeMaxButton = nil,
            exceptionModeButton = nil
        }
    },
    Heal = {
        enableButton = nil,
        enableLabel = nil,
        configButton = nil,
        Config = {
            window = nil,
            bandageSelfButton = nil,
            bandageOtherButton = nil,
            healPotionsModeButton = nil,
            healPotionAfterStrengthPotionButton = nil,
            curePotionsButton = nil
        }
    },
    Buffs = {
        enableButton = nil,
        enableLabel = nil,
        configButton = nil,
        Config = {
            window = nil,
            enableNightsight = nil,
            enableStrength = nil,
            enableAgility = nil,
            refreshAfterAgility = nil,
            staminaPotionsModeButton = nil
        }
    },
    Scavenge = {
        enableButton = nil,
        enableLabel = nil,
        configButton = nil,
        Config = {
            window = nil,
            activateGoldButton = nil,
            activateBandagesButton = nil,
            activateBonesButton = nil,
            activateGrimoireButton = nil,
            activateRibsButton = nil
        }
    }
}

CAUIMainWindowLayout = {
    StartPosX = 200,
    StartPosY = 200,
    SizeXOffset = 20,
    SizeYOffset = 20,
    NumberOfModules = 6     --- Must match the current #modules
}

CAUIMainWindowState = {
    nightsightUIChanged = false
}

function CAUIGump_processUIGumpInteractions()
    local nightsightUIEnabled = CAUIGumpBuffsState.EnableNightsight
    CAUIGumpMainRow_processUIInteractions(CAUI.configButton, CAUI.Config.window, CAUI.Config.rearmButton, CAUI.Config.skinnButton)
    CAUIGumpRun_processUIInteractions(CAUI.Run.enableButton, CAUI.Run.enableLabel)                     --- Run
    CAUIGumpCommands_processUIInteractions(CAUI.Commands.enableButton, CAUI.Commands.enableLabel)      --- Commands
    CAUIGumpAttack_processUIInteractions(CAUI.Attack.enableButton, CAUI.Attack.enableLabel, CAUI.Attack.configButton, CAUI.Attack.Config.window, CAUI.Attack.Config.rangeMaxButton, CAUI.Attack.Config.exceptionModeButton)                                                                                                                            --- Attack
    CAUIGumpHeal_processUIInteractions(CAUI.Heal.enableButton, CAUI.Heal.enableLabel, CAUI.Heal.configButton, CAUI.Heal.Config.window, CAUI.Heal.Config.bandageSelfButton, CAUI.Heal.Config.bandageOtherButton, CAUI.Heal.Config.healPotionsModeButton, CAUI.Heal.Config.healPotionAfterStrengthPotionButton, CAUI.Heal.Config.curePotionsButton)      --- Heal
    CAUIGumpBuffs_processUIInteractions(CAUI.Buffs.enableButton, CAUI.Buffs.enableLabel, CAUI.Buffs.configButton, CAUI.Buffs.Config.window, CAUI.Buffs.Config.enableNightsight, CAUI.Buffs.Config.enableStrength, CAUI.Buffs.Config.enableAgility, CAUI.Buffs.Config.refreshAfterAgility, CAUI.Buffs.Config.staminaPotionsModeButton)                  --- Buffs
    CAUIGumpScavenge_processUIInteractions(CAUI.Scavenge.enableButton, CAUI.Scavenge.enableLabel, CAUI.Scavenge.configButton, CAUI.Scavenge.Config.window, CAUI.Scavenge.Config.activateGoldButton, CAUI.Scavenge.Config.activateBandagesButton, CAUI.Scavenge.Config.activateBonesButton, CAUI.Scavenge.Config.activateGrimoireButton, CAUI.Scavenge.Config.activateRibsButton)                    --- Scavenge
    nightsightUIChanged = nightsightUIEnabled ~= CAUIGumpBuffsState.EnableNightsight

end

function CAUIGump_updateCombatAssistantConfig(CAConfig)

    --- Override UI values to CA Config
    CAUIGumpMainRow_updateCAConfigToCurrentUIConfig(CAConfig.modules.ArmDisarm, CAConfig.modules.Skinning)     --- Main
    CAUIGumpCommands_updateCAConfigToCurrentUIConfig(CAConfig.userCommands)                                    --- Commands
    CAUIGumpAttack_updateCAConfigToCurrentUIConfig(CAConfig.modules.Attack)                                    --- Attack
    CAUIGumpHeal_updateCAConfigToCurrentUIConfig(CAConfig.modules.Bandages, CAConfig.modules.CurePotions, CAConfig.modules.HealingPotions, CAConfig.modules.Buffs.Strength)    --- Heal
    CAUIGumpBuffs_updateCAConfigToCurrentUIConfig(CAConfig.modules.Buffs)                                      --- Buffs
    CAUIGumpScavenge_updateCAConfigToCurrentUIConfig(CAConfig.modules.Scavenging)                              --- Scavenge

    --- Because of internal error, nightsight may disable itself (don't override that part, unless there is a user interaction)
    if not nightsightUIChanged then
        CAConfig.modules.Buffs.Nightsight.Enable = CAPotionsNightsight_getEnable()
        onNightsightButtonPressed_(CAPotionsNightsight_getEnable(), CAUI.Buffs.Config.enableNightsight)
    end

    CAMainLoop_configure(CAConfig)

    CALog_debug(''
    ..'Updating Combat Assistant Config:'
    ..'\n - Buffs Enabled: '..tostring(CAConfig.modules.Buffs.Enable)
    ..'\n - User Commands Enabled: '..tostring(CAConfig.userCommands.Enable)
    ..'\n - Attack Enabled: '..tostring(CAConfig.modules.Attack.Enable)
    ..'\n - Scavenging Enabled: '..tostring(CAConfig.modules.Scavenging.Enable)
    )
end

function CAUIGump_initMainWindow()

    CALog_debug('Initializing main gump...')
    CAUI.mainWindow = UI.CreateWindow('CAUI.mainWindow', 'SAGAS Combat Assistant')
    if not CAUI.mainWindow then
        CALog_debug('Failed to create main gump!')
        return
    end

    CALog_debug('Initializing Main Window...')
    furthestElementX = CAUIGumpLayout_getLayoutConstants().ModuleConfigButtonPosX + CAUIGumpLayout_getLayoutConstants().ModuleConfigButtonSizeX
    furthestElementY = CAUIGumpLayout_getLayoutConstants().ModuleRowPosYStart + CAUIGumpLayout_getLayoutConstants().ModuleRowPosYIncrement * (CAUIMainWindowLayout.NumberOfModules -1) + CAUIGumpLayout_getLayoutConstants().ModuleEnableButtonSizeY
    CAUI.mainWindow:SetPosition(CAUIMainWindowLayout.StartPosX, CAUIMainWindowLayout.StartPosY)
    CAUI.mainWindow:SetSize(furthestElementX + CAUIMainWindowLayout.SizeXOffset, furthestElementY + CAUIMainWindowLayout.SizeYOffset)

    CALog_debug("Window created and ready!")
end

function CAUIGump_initModules()
    CAUI.titleLabel, CAUI.configButton, CAUI.Config.window, CAUI.Config.rearmButton, CAUI.Config.skinnButton = CAUIGumpMainRow_initUI(CAUI.mainWindow)
    CAUI.Run.enableButton , CAUI.Run.enableLabel = CAUIGumpRun_initUI(CAUI.mainWindow, 1)                      --- Run
    CAUI.Commands.enableButton , CAUI.Commands.enableLabel = CAUIGumpCommands_initUI(CAUI.mainWindow, 2)       --- Commands
    CAUI.Attack.enableButton, CAUI.Attack.enableLabel, CAUI.Attack.configButton, CAUI.Attack.Config.window, CAUI.Attack.Config.rangeMaxButton, CAUI.Attack.Config.exceptionModeButton = CAUIGumpAttack_initUI(CAUI.mainWindow, 3)                                                                                                                          --- Attack
    CAUI.Heal.enableButton, CAUI.Heal.enableLabel, CAUI.Heal.configButton, CAUI.Heal.Config.window, CAUI.Heal.Config.bandageSelfButton, CAUI.Heal.Config.bandageOtherButton, CAUI.Heal.Config.healPotionsModeButton, CAUI.Heal.Config.healPotionAfterStrengthPotionButton, CAUI.Heal.Config.curePotionsButton = CAUIGumpHeal_initUI(CAUI.mainWindow, 4)    --- Heal
    CAUI.Buffs.enableButton, CAUI.Buffs.enableLabel, CAUI.Buffs.configButton, CAUI.Buffs.Config.window, CAUI.Buffs.Config.enableNightsight, CAUI.Buffs.Config.enableStrength, CAUI.Buffs.Config.enableAgility, CAUI.Buffs.Config.refreshAfterAgility, CAUI.Buffs.Config.staminaPotionsModeButton = CAUIGumpBuffs_initUI(CAUI.mainWindow, 5)                --- Buffs
    CAUI.Scavenge.enableButton, CAUI.Scavenge.enableLabel, CAUI.Scavenge.configButton, CAUI.Scavenge.Config.window, CAUI.Scavenge.Config.activateGoldButton, CAUI.Scavenge.Config.activateBandagesButton, CAUI.Scavenge.Config.activateBonesButton, CAUI.Scavenge.Config.activateGrimoireButton, CAUI.Scavenge.Config.activateRibsButton = CAUIGumpScavenge_initUI(CAUI.mainWindow, 6)                  --- Scavenge
end

function CAUIGump_initMainGump()
    CAUIGump_initMainWindow()
    CAUIGump_initModules()
end

function CAUIGump_runGump(CAConfig)

    CALog_debug('Starting Combat Assistant Iteration!')
    UI.DestroyAllWindows()          --- Cleanup
    CAUIGump_initMainGump()                 --- Init main gump (create UI, set up event handlers, etc)
    CAMainLoop_mainLoopInit(CAConfig)     --- Initialize main loop (configure modules, etc)
    while true do

        CAUIGump_processUIGumpInteractions()                --- Check for UI changes
        CAUIGump_updateCombatAssistantConfig(CAConfig)      --- Process Update

        --- Is the Combat Assistant set to run?
        if CAUIGumpRun_getIterateCAMainLoop() then

            CALog_debug('Starting Combat Assistant Iteration!')
            CAUI.Run.enableLabel:SetText('Running...')                --- Starting Iteration
            CAUI.Run.enableLabel:SetColor(1, 0.5, 0, 1)               --- Orange

            CAMainLoop_mainLoopIterate(CAConfig)                      --- Iterate main loop once (process actions, etc)

            CALog_debug('Combat Assistant Iteration Done!')
            CAUI.Run.enableLabel:SetText('Running...')                --- Iteration Done
            CAUI.Run.enableLabel:SetColor(0, 1, 0, 1)                 --- Green

        else
            CALog_debug('Combat Assistant Disabled!')
        end

        Pause(50)
    end
end

DexerMainLoopConfig = {
    time = {
        ActionWaitTime = 1000,  --- in milliseconds, how long to wait for actions like using items, targeting etc.
                                --- Adjust ActionWaitTime if you experience issues, set it longer, ex. 1500 on high ping
        MainLoopTick = 60,      --- in milliseconds
        JournalTick = 0,        --- milliseconds, zero means immediate
    },
    debug = {
        EnableDebugLog = true,          --- enable console log
        DebugLogTick = 60,              --- in milliseconds
        EnableDebugTick = false,        --- <<== (TURN ON TO FOR DEBUGGING): forces a slower exececution
        DebugTick = 500,                --- slower exececution tick frequency
        EnableOverheadMessages = false  --- Enables overhead messages, if false then messages will be printed in journal
    },
    modules = {
        ArmDisarm = {
            Enable = true,              --- Re-arms once moved char when disarmed, disarms if weapon durability too low
            AlwaysRearm = false,        --- rearm without moving, warning will spam messages if you drag from hands
            AutoRearmOnMove = true,     --- Auto-rearm atempt everytime you move
            AutoRearmWithDelay = false  --- Auto-rearm atempt with a delay
        },
        Escape = {
            EnablePopPouch = true,  --- Pops pouch if you are paralyzed in PvP mode
            EnableComand = false,   --- Saying escape and the escape command in the escape config will port you
            EnableMoongate = true   --- Opens moongate if you are near one
        },
        CurePotions = {
            Enable = false,          --- Cures poison with potions first (can be a waste of potions)
            ColldownTime = 1000     --- in milliseconds
        },
        HealingPotions = {
            Enable = true,          --- Drink a healling potion if health too low
            HPDrinkThreshould = 20  --- in percentage, when to use heal potion
        },
        Bandages = {
            Enable = true,                  --- Bandages player if HP is below BandageSelfHPThreshould or if poisoned and no cure potions
            BandageSelfHPThreshould = 99,   --- in percentage, when to use bandage
            BandageAllies = true,           --- Whether to attempt to bandage allies when player is not in need of bandaging
            BandageAlliesHPThreshould = 90, --- in percentage, when to use bandage
            AlliesSerials = {}              --- List of allies serials to bandage, if BandageAllies is true
        },
        Buffs = {
            Enable = true,              --- Enables automatic buffs, see bellow (disable if you prefer to use manually)
            SongOfHealing = {
                Enable = false,
                FailWait = 30 * 1000,   --- in ms, how long to retry if already under effects by manual cast
                Instruments = {"Drum", "Lute", "Tambourine", "Lap Harp" }
            },
            Nightsight = {
                Enable = true   --- Drink nightsight potion if not buffed already
            },
            Stamina = {
                Enable = true,          --- Drink stamina potion when bellow a threshould
                DrinkThreshould = 60    --- in percentage, when to drink stamina potion
            },
            Strength = {
                Enable = true,          --- Drink strength potion if not buffed already
                BaseStrength = 100,
                DrinkHeal = true
            },
            Agility = {
                Enable = true,          --- Drink potion potion if not buffed already
                BaseAgility = 81,       --- Because of full plate (without gorget: using luck gear)
                DrinkRefresh = true
            },
            EatFood = {
                Enable = false   --- BUGGED: Buff foods don't prevent eating if already under the effect
            }
        },
        Debuffs = {
            Enable = false,     --- Enables automatic debuffs, see bellow (disable if you prefer to use manually)
            Peacemaking = {
                Enable = false
            }
        },
        DetectPlayers = {
            Enable = false  --- Alerts you when a player from the hunt list is visible
        },
        Skinning = {
            Enable = false,
            NoisyMode = true,       --- To Log XOR Say when dropping or keeping a resource
            LeatherHuesToKeep = {
                --- 0x0000,         --- Regular
                --- 0x0973,         --- Dull Copper
                --- 0x0966,         --- Shadow Iron
                --- 0x096D,         --- Copper
                0x0972,             --- Bronze
                0x08A5,             --- Gold
                0x0979,             --- Agapite
                0x089F,             --- Verite
                0x08AB              --- Valorite
            }
        },
        Scavenging = {
            Enable = false,         --- Scavenges items from the ground, only arrows, add more if needed
            Frequency = 0,          --- milliseconds, zero means immediate
            LootItemsSerials = {    --- List of items to scavenge
                0x0F3F,
                0x1BFB
            },
            LootItemsNames = {},            --- Use if serial not available
            DisallowGold = false,           --- Toggle scavenging gold
            DisallowCleanBandage = false,   --- Toggle scavenging clean bandages
            DisallowBones = false,          --- Toggle scavenging bones
            DisallowGrimoire = false,       --- Toggle scavenging grimoires
            DisallowRibs = false            --- Toggle scavenging ribs
        },
        Attack = {
            Enable = false,                             --- Attacks nearby enemies automatically
            Rangemax = 10,                              --- Attack search range
            AllowMobilesExceptionsSerials = true,       --- Allow Mobiles Serials to ignore
            MobilesExceptionsSerials = {},              --- Mobiles Serials to ignore (add friends so to not attack should they become grey)
            AllowMobilesExceptionsGraphicIDs = true,    --- Allow Mobiles Mobiles GraphicIDs to ignore
            MobilesExceptionsGraphicIDs = {},           --- Mobiles GraphicIDs to ignore (don't kill: cows, dogs...)
            AllowMobilesExceptionsNames = true,         --- Allow Mobiles Mobiles Names to ignore
            MobilesExceptionsNames = {},                --- Mobiles Names to ignore (use if don't have serial or graphic available)
            CheckFrequency = 500                        --- in milliseconds, how often to check for new targets, adjust if needed
        }
    },
    userCommands = {
        Enable = true,  --- Parse and process user commands (via journal)
        CommandStringPrefix = "(DEXER)"
    }
}

function CAConfigDexer_run()
    CAMainLoop_mainLoop(DexerMainLoopConfig)
end

function CAConfigDexer_runUiGump()
    CAUIGump_runGump(DexerMainLoopConfig)
end

function CAConfigDexer_runWithCommandsDisabled()
    DexerMainLoopConfig.userCommands.Enable = false
    CAMainLoop_mainLoop(DexerMainLoopConfig)
end

function CAConfigDexer_runWithBuffsDisabled()
    DexerMainLoopConfig.modules.Buffs.Enable = false
    CAMainLoop_mainLoop(DexerMainLoopConfig)
end

-- End of: CAConfigDexer
-- ========================================

CAConfigDexer_runUiGump()