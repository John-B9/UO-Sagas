----------------------------------------------------------------------
--- Combat Assistant (CA) Run Dexer
--- Author: JohnB9
---
--- Version: 1.0.0  - Run Combat Bot with Dexer Config
---
--- Description: Running this script will run Combat Bot with a Dexer
---              main loop configuration
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
    DisallowCleanBandages = false,
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
    ScavengeConfig.DisallowCleanBandages = config.DisallowCleanBandages
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
            if ScavengeConfig.DisallowCleanBandages then
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

    if not haveCleanBandage and not ScavengeConfig.DisallowCleanBandages then
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

CAUIGump_CAUIGumpLayoutBase_CAUIGumpLayoutConstants = {
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

function CAUIGumpLayoutBase_getLayoutConstants()
    return CAUIGump_CAUIGumpLayoutBase_CAUIGumpLayoutConstants
end

function CAUIGumpLayoutBase_createModuleEnableButtonAtRow(mainWindow, row, buttonText, sizeX, sizeY)
    CALog_debug('Initializing Module Enable "..buttonText.." Button (At Row: "..row..")...')
    local buttonPosX = CAUIGump_CAUIGumpLayoutBase_CAUIGumpLayoutConstants.ModuleEnableButtonPosX
    local buttonPosY = CAUIGump_CAUIGumpLayoutBase_CAUIGumpLayoutConstants.ModuleRowPosYStart + ((row -1) * CAUIGump_CAUIGumpLayoutBase_CAUIGumpLayoutConstants.ModuleRowPosYIncrement)
    local buttonSizeX = (sizeX ~= nil and sizeX) or CAUIGump_CAUIGumpLayoutBase_CAUIGumpLayoutConstants.ModuleEnableButtonSizeX
    local buttonSizeY = (sizeY ~= nil and sizeY) or CAUIGump_CAUIGumpLayoutBase_CAUIGumpLayoutConstants.ModuleEnableButtonSizeY
    local button = mainWindow:AddButton(buttonPosX, buttonPosY, buttonText, buttonSizeX, buttonSizeY)
    return button
end

function CAUIGumpLayoutBase_createModuleEnableLabelAtRow(mainWindow, row, labelText)
    CALog_debug('Initializing Module Enable Label (At Row: "..row..")...')
    local labelPosX = CAUIGump_CAUIGumpLayoutBase_CAUIGumpLayoutConstants.ModuleEnableLabelPosX
    local labelPosY = CAUIGump_CAUIGumpLayoutBase_CAUIGumpLayoutConstants.ModuleRowPosYStart + ((row -1) * CAUIGump_CAUIGumpLayoutBase_CAUIGumpLayoutConstants.ModuleRowPosYIncrement) + CAUIGump_CAUIGumpLayoutBase_CAUIGumpLayoutConstants.ModuleRowPosYLabelAlignIncrement
    local label = mainWindow:AddLabel(labelPosX, labelPosY, labelText)
    label:SetColor(0, 1, 0, 1)
    return label
end

function CAUIGumpLayoutBase_createModuleConfigButtonAtRow(mainWindow, row)
    CALog_debug('Initializing Module Config Button (At Row: "..row..")...')
    local buttonPosX = CAUIGump_CAUIGumpLayoutBase_CAUIGumpLayoutConstants.ModuleConfigButtonPosX
    local buttonPosY = CAUIGump_CAUIGumpLayoutBase_CAUIGumpLayoutConstants.ModuleRowPosYStart + ((row -1) * CAUIGump_CAUIGumpLayoutBase_CAUIGumpLayoutConstants.ModuleRowPosYIncrement)
    local buttonSizeX = CAUIGump_CAUIGumpLayoutBase_CAUIGumpLayoutConstants.ModuleConfigButtonSizeX
    local buttonSizeY = CAUIGump_CAUIGumpLayoutBase_CAUIGumpLayoutConstants.ModuleConfigButtonSizeY
    local button = mainWindow:AddButton(buttonPosX, buttonPosY, '+', buttonSizeX, buttonSizeY)
    return button
end

function CAUIGumpLayoutBase_createModuleConfigWindow(windowIDString, windowHeader, numRows, row)
    CALog_debug('Creating Module Config window '..windowIDString..'...')
    local moduleConfigWindow = UI.CreateWindow(windowIDString, windowHeader)
    if not moduleConfigWindow then
        CALog_debug('Failed to create Module Config window '..windowIDString..'!')
        return nil
    end
    CALog_debug('Initializing Module Config window '..windowIDString..'...')
    posX = CAUIGump_CAUIGumpLayoutBase_CAUIGumpLayoutConstants.ModuleConfigWindowStartPosX
    posY = CAUIGump_CAUIGumpLayoutBase_CAUIGumpLayoutConstants.ModuleConfigWindowStartBasePosY + ((numRows - 1) * CAUIGump_CAUIGumpLayoutBase_CAUIGumpLayoutConstants.ModuleConfigWindowFeatureEnableButtonPosYIncrement)
    moduleConfigWindow:SetPosition(posX, posY)
    moduleConfigWindowSizeY = CAUIGump_CAUIGumpLayoutBase_CAUIGumpLayoutConstants.ModuleConfigWindowFeatureEnableButtonPosYStart + ((numRows - 1) * CAUIGump_CAUIGumpLayoutBase_CAUIGumpLayoutConstants.ModuleConfigWindowFeatureEnableButtonPosYIncrement) + 50
    moduleConfigWindow:SetSize(CAUIGump_CAUIGumpLayoutBase_CAUIGumpLayoutConstants.ModuleConfigWindowSizeX, moduleConfigWindowSizeY)
    moduleConfigWindow:Hide()
    return moduleConfigWindow
end

function CAUIGumpLayoutBase_createModuleConfigWindowButtonAtRow(configWindow, row, buttonText, sizeX, sizeY)
    CALog_debug('Initializing Module Config Window "..buttonText.." Button (At Row: "..row..")...')
    local buttonPosX = CAUIGump_CAUIGumpLayoutBase_CAUIGumpLayoutConstants.ModuleConfigWindowFeatureEnableButtonPosX
    local buttonPosY = CAUIGump_CAUIGumpLayoutBase_CAUIGumpLayoutConstants.ModuleConfigWindowFeatureEnableButtonPosYStart + ((row -1) * CAUIGump_CAUIGumpLayoutBase_CAUIGumpLayoutConstants.ModuleConfigWindowFeatureEnableButtonPosYIncrement)
    local buttonSizeX = (sizeX ~= nil and sizeX) or CAUIGump_CAUIGumpLayoutBase_CAUIGumpLayoutConstants.ModuleConfigWindowFeatureEnableButtonSizeX
    local buttonSizeY = (sizeY ~= nil and sizeY) or CAUIGump_CAUIGumpLayoutBase_CAUIGumpLayoutConstants.ModuleConfigWindowFeatureEnableButtonSizeY
    local button = configWindow:AddButton(buttonPosX, buttonPosY, buttonText, buttonSizeX, buttonSizeY)
    return button
end

CAUIGumpMainRow_CAUIGumpLogicBase_ColorOptions = {
    Green = 1,
    Orange = 2,
    Red = 3
}

CAUIGumpMainRow_CAUIGumpLogicBase_ColorValues = {
    { 0,   1, 0, 1 },
    { 1, 0.5, 0, 1 },
    { 1,   0, 0, 1 }
}

SharedVisibilityConfigWindowsCloseFunctions = {}

function CAUIGumpLogicBase_getColorOptions()
    return CAUIGumpMainRow_CAUIGumpLogicBase_ColorOptions
end

function CAUIGumpLogicBase_registerSharedVisibilityConfigWindowsCloseFunction(closeFunction)
    table.insert(SharedVisibilityConfigWindowsCloseFunctions, closeFunction)
end

function CAUIGumpLogicBase_setLabelColor(label, colorOption)
    local colorValues = CAUIGumpMainRow_CAUIGumpLogicBase_ColorValues[colorOption]
    label:SetColor(colorValues[1], colorValues[2], colorValues[3], colorValues[4])
end

function CAUIGumpLogicBase_logButtonPressEvent(buttonEventLogStr, currentStateStr, newStateStr)
    CALog_debug(buttonEventLogStr..' button pressed: '..currentStateStr..' -> '..newStateStr)
end

function CAUIGumpLogicBase_onConfigMenuButtonPressed(currentState, configB, configW, buttonEventLogStr, closeOtherCWs, configBClosedStr, configBOpenStr)
    local newState = not currentState
    CAUIGumpLogicBase_logButtonPressEvent(buttonEventLogStr, tostring(currentState), tostring(newState))
    if newState then
        configB:SetText(configBClosedStr or '+')
        configW:Hide()
    else
        if closeOtherCWs then
            for _, closeFunction in ipairs(SharedVisibilityConfigWindowsCloseFunctions) do
                closeFunction()
            end
        end
        configB:SetText(configBOpenStr or '-')
        configW:Show()
    end
    return newState
end

function CAUIGumpLogicBase_onEnumStateButtonPressed(currentState, lastValue, enumStrings, button, buttonEventLogStr)
    local newState  = (currentState == lastValue and 1) or currentState+1
    CAUIGumpLogicBase_logButtonPressEvent(buttonEventLogStr, enumStrings[currentState], enumStrings[newState])
    button:SetText(enumStrings[newState])
    return newState
end

function CAUIGumpLogicBase_onLabeledBooleanButtonPressed(currentState, label, buttonEventLogStr, trueStateVals, falseStateVals)
    local newState = not currentState
    CAUIGumpLogicBase_logButtonPressEvent(buttonEventLogStr, tostring(currentState), tostring(newState))
    local text = (newState and trueStateVals[1]) or falseStateVals[1]
    local colorOption = (newState and trueStateVals[2]) or falseStateVals[2]
    label:SetText(text)
    CAUIGumpLogicBase_setLabelColor(label, colorOption)
    return newState
end

function CAUIGumpLogicBase_onEnabledDisabledButtonPressed(currentState, label, buttonEventLogStr)
    return CAUIGumpLogicBase_onLabeledBooleanButtonPressed(currentState, label, buttonEventLogStr, { 'Enabled', CAUIGumpMainRow_CAUIGumpLogicBase_ColorOptions.Green }, { 'Disabled', CAUIGumpMainRow_CAUIGumpLogicBase_ColorOptions.Red })
end

function CAUIGumpLogicBase_getBoonleanButtonStateDisplayStr(state, buttonDescriptionStr)
    return buttonDescriptionStr .. ((state and ' (Y)') or ' (N)')
end

function CAUIGumpLogicBase_onBooleanButtonPressed(currentState, button, buttonDescriptionStr, buttonEventLogStr)
    local newState = not currentState
    CAUIGumpLogicBase_logButtonPressEvent(buttonEventLogStr or buttonDescriptionStr, tostring(currentState), tostring(newState))
    local text = CAUIGumpLogicBase_getBoonleanButtonStateDisplayStr(newState, buttonDescriptionStr)
    button:SetText(text)
    return newState
end

CAUIGumpMainRowLayout = {
    TitleLabelPosX = 10,
    TitleLabelPosY = 40,
    ConfigButtonPosX = 175,
    ConfigButtonPosY = 35,
    ConfigButtonSizeX = 85,
    ConfigButtonSizeY = 25
}

CAUIGMR = {
    mainWindow = nil,
    titleLabel = nil,
    configButton = nil,
    Config = {
        window = nil,
        rearmButton = nil,
        skinnButton = nil
    }
}

RearmModeValues = {
    None = 1,
    Move = 2,
    Time = 3,
    MoveAndTime = 4
}

RearmModeStrings = {
    'Rearm (None)',
    'Rearm (On Move)',
    'Rearm (On Timer)',
    'Rearm (On Move + Timer)'
}

SkinnModeValues = {
    None = 1,
    All = 2,
    ShaddowPlus = 3,
    CopperPlus = 4,
    BronzePlus = 5,
    VeritePlus = 6,
    Valorite = 7
}

SkinnModeStrings = {
    'Skinn (None)',
    'Skinn (All)',
    'Skinn (Shaddow +)',
    'Skinn (Copper +)',
    'Skinn (Bronze +)',
    'Skinn (Verite +)',
    'Skinn (Valorite)'
}

LeatherHuesToKeepNone = {
}

LeatherHuesToKeepAll = {
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

LeatherHuesToKeepShadowPlus = {
    0x0966,             --- Shadow Iron
    0x096D,             --- Copper
    0x0972,             --- Bronze
    0x089F,             --- Verite
    0x08AB              --- Valorite
}

LeatherHuesToKeepCopperPlus = {
    0x096D,             --- Copper
    0x0972,             --- Bronze
    0x089F,             --- Verite
    0x08AB              --- Valorite
}

LeatherHuesToKeepBronzePlus = {
    0x0972,             --- Bronze
    0x089F,             --- Verite
    0x08AB              --- Valorite
}

LeatherHuesToKeepVeritePlus = {
    0x089F,             --- Verite
    0x08AB              --- Valorite
}

LeatherHuesToKeepValorite = {
    0x08AB              --- Valorite
}

SkinnModeHueKeepTables = {
    LeatherHuesToKeepNone,
    LeatherHuesToKeepAll,
    LeatherHuesToKeepShadowPlus,
    LeatherHuesToKeepCopperPlus,
    LeatherHuesToKeepBronzePlus,
    LeatherHuesToKeepVeritePlus,
    LeatherHuesToKeepValorite
}

CAUIGumpMainRowState = {
    MainConfigClosed = true,
    RearmMode = RearmModeValues.Move,
    SkinnMode = SkinnModeValues.None
}

function CAUIGumpMainRow_updateMainConfigWindow(targetValue, closeOtherCWs)
    CAUIGumpMainRowState.MainConfigClosed = CAUIGumpLogicBase_onConfigMenuButtonPressed(not targetValue, CAUIGMR.configButton, CAUIGMR.Config.window, 'Main Config', closeOtherCWs, 'CONFIG (+)', 'CONFIG (-)')
end

function CAUIGumpMainRow_closeMainConfigWindow()
    CAUIGumpMainRow_updateMainConfigWindow(true, false)
end

function CAUIGumpMainRow_processConfigMenuButtonInteractions()
    if CAUIGMR.configButton:WasClicked() then
        CAUIGumpMainRow_updateMainConfigWindow(not CAUIGumpMainRowState.MainConfigClosed, true)
    end
end

function CAUIGumpMainRow_processRearmModeButtonInteractions()
    if CAUIGMR.Config.rearmButton:WasClicked() then
        CAUIGumpMainRowState.RearmMode = CAUIGumpLogicBase_onEnumStateButtonPressed(CAUIGumpMainRowState.RearmMode, RearmModeValues.MoveAndTime, RearmModeStrings, CAUIGMR.Config.rearmButton, 'Rearm Mode')
    end
end

function CAUIGumpMainRow_processSkinnModeButtonInteractions()
    if CAUIGMR.Config.skinnButton:WasClicked() then
        CAUIGumpMainRowState.SkinnMode = CAUIGumpLogicBase_onEnumStateButtonPressed(CAUIGumpMainRowState.SkinnMode, SkinnModeValues.Valorite, SkinnModeStrings, CAUIGMR.Config.skinnButton, 'Skinning Mode')
    end
end

function CAUIGumpMainRow_processUIInteractions()
    CAUIGumpMainRow_processConfigMenuButtonInteractions()
    CAUIGumpMainRow_processRearmModeButtonInteractions()
    CAUIGumpMainRow_processSkinnModeButtonInteractions()
end

function CAUIGumpMainRow_updateCAConfigToCurrentUIConfig(CAConfig)
    local armDisarmConfig = CAConfig.modules.ArmDisarm
    local armDisarmEnabled = CAUIGumpMainRowState.RearmMode ~= RearmModeValues.None
    local rearmOnMove = CAUIGumpMainRowState.RearmMode == RearmModeValues.Move or CAUIGumpMainRowState.RearmMode == RearmModeValues.MoveAndTime
    local rearmOnDelay = CAUIGumpMainRowState.RearmMode == RearmModeValues.Time or CAUIGumpMainRowState.RearmMode == RearmModeValues.MoveAndTime
    armDisarmConfig.Enable = armDisarmEnabled
    armDisarmConfig.AutoRearmOnMove = armDisarmEnabled and rearmOnMove
    armDisarmConfig.AutoRearmWithDelay = armDisarmEnabled and rearmOnDelay

    local skinningConfig = CAConfig.modules.Skinning
    local skinningEnabled = CAUIGumpMainRowState.SkinnMode ~= SkinnModeValues.None
    skinningConfig.Enable = skinningEnabled
    skinningConfig.LeatherHuesToKeep = SkinnModeHueKeepTables[CAUIGumpMainRowState.SkinnMode]
end

function CAUIGumpMainRow_initUI(mainWindow)
    CALog_debug('Creating Main Row UI...')
    CAUIGMR.titleLabel = mainWindow:AddLabel(CAUIGumpMainRowLayout.TitleLabelPosX, CAUIGumpMainRowLayout.TitleLabelPosY, 'SAGAS Combat Assistant')
    CAUIGMR.titleLabel:SetColor(0.2, 0.8, 1, 1)
    CAUIGMR.configButton = mainWindow:AddButton(CAUIGumpMainRowLayout.ConfigButtonPosX, CAUIGumpMainRowLayout.ConfigButtonPosY, 'CONFIG (+)', CAUIGumpMainRowLayout.ConfigButtonSizeX, CAUIGumpMainRowLayout.ConfigButtonSizeY)
    CAUIGMR.Config.window = CAUIGumpLayoutBase_createModuleConfigWindow('MainConfigWindow', 'Main Config', 2, 1)
    CAUIGumpLogicBase_registerSharedVisibilityConfigWindowsCloseFunction(CAUIGumpMainRow_closeMainConfigWindow)
    CAUIGMR.Config.rearmButton = CAUIGumpLayoutBase_createModuleConfigWindowButtonAtRow(CAUIGMR.Config.window, 1, RearmModeStrings[CAUIGumpMainRowState.RearmMode], 180, CAUIGumpLayoutBase_getLayoutConstants().ModuleConfigWindowFeatureEnableButtonSizeY)
    CAUIGMR.Config.skinnButton = CAUIGumpLayoutBase_createModuleConfigWindowButtonAtRow(CAUIGMR.Config.window, 2, SkinnModeStrings[CAUIGumpMainRowState.SkinnMode], 180, CAUIGumpLayoutBase_getLayoutConstants().ModuleConfigWindowFeatureEnableButtonSizeY)
end

CAUIGumpRun_CAUIGumpRunLayout = {
    RunButtonSizeX = 80,
    RunButtonSizeY = 30
}

CAUIGumpRun_CAUIGR = {
    enableButton = nil,
    enableLabel = nil
}

CAUIGumpRunConfig = {
    IterateCAMainLoop = false
}

function CAUIGumpRun_getIterateCAMainLoop()
    return CAUIGumpRunConfig.IterateCAMainLoop
end

function CAUIGumpRun_processRunButtonInteractions()
    if CAUIGumpRun_CAUIGR.enableButton:WasClicked() then
        CAUIGumpRunConfig.IterateCAMainLoop = CAUIGumpLogicBase_onLabeledBooleanButtonPressed(CAUIGumpRunConfig.IterateCAMainLoop, CAUIGumpRun_CAUIGR.enableLabel, 'Run', {'Running...', CAUIGumpLogicBase_getColorOptions().Green}, {'Stopped', CAUIGumpLogicBase_getColorOptions().Red})
    end
end

function CAUIGumpRun_processUIInteractions()
    CAUIGumpRun_processRunButtonInteractions()
end

function CAUIGumpRun_initUI(mainWindow, row)
    CALog_debug('Creating Run Button UI...')
    CAUIGumpRun_CAUIGR.enableButton = CAUIGumpLayoutBase_createModuleEnableButtonAtRow(mainWindow, row, 'Run', CAUIGumpRun_CAUIGumpRunLayout.RunButtonSizeX, CAUIGumpRun_CAUIGumpRunLayout.RunButtonSizeY)
    CAUIGumpRun_CAUIGR.enableLabel = CAUIGumpLayoutBase_createModuleEnableLabelAtRow(mainWindow, row, 'Stopped')
    CAUIGumpLogicBase_setLabelColor(CAUIGumpRun_CAUIGR.enableLabel, CAUIGumpLogicBase_getColorOptions().Red)
end

function CAUIGumpRun_startIteration()
    CALog_debug('Starting Combat Assistant Iteration!')
    CAUIGumpRun_CAUIGR.enableLabel:SetText('Running...')                --- Starting Iteration
    CAUIGumpLogicBase_setLabelColor(CAUIGumpRun_CAUIGR.enableLabel, CAUIGumpLogicBase_getColorOptions().Orange)
end

function CAUIGumpRun_endIteration()
    CALog_debug('Combat Assistant Iteration Done!')
    CAUIGumpRun_CAUIGR.enableLabel:SetText('Running...')                --- Iteration Done
    CAUIGumpLogicBase_setLabelColor(CAUIGumpRun_CAUIGR.enableLabel, CAUIGumpLogicBase_getColorOptions().Green)
end

CAUIGumpHeal_CAUIGH = {
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
}

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
    HealEnabled = true,
    ConfigWindowClosed = true,
    BandageSelf = true,
    BandageOther = true,
    HealPotsMode = CAUIGumpHeal_HealPotsModeValues.TwentyPercent,
    HealPotsAfterStrPot = true,
    CurePots = false
}

function CAUIGumpHeal_processHealButtonInteractions()
    if CAUIGumpHeal_CAUIGH.enableButton:WasClicked() then
        CAUIGumpHealConfig.HealEnabled = CAUIGumpLogicBase_onEnabledDisabledButtonPressed(CAUIGumpHealConfig.HealEnabled, CAUIGumpHeal_CAUIGH.enableLabel, 'Heal')
    end
end

function CAUIGumpHeal_updateHealConfigWindow(targetValue, closeOtherCWs)
    CAUIGumpHealConfig.ConfigWindowClosed = CAUIGumpLogicBase_onConfigMenuButtonPressed(not targetValue, CAUIGumpHeal_CAUIGH.configButton, CAUIGumpHeal_CAUIGH.Config.window, 'Heal Config', closeOtherCWs)
end

function CAUIGumpHeal_closeHealConfigWindow()
    CAUIGumpHeal_updateHealConfigWindow(true, false)
end

function CAUIGumpHeal_processHealConfigButtonInteractions()
    if CAUIGumpHeal_CAUIGH.configButton:WasClicked() then
        CAUIGumpHeal_updateHealConfigWindow(not CAUIGumpHealConfig.ConfigWindowClosed, true)
    end
end

function CAUIGumpHeal_processBandageSelfButtonInteractions()
    if CAUIGumpHeal_CAUIGH.Config.bandageSelfButton:WasClicked() then
        CAUIGumpHealConfig.BandageSelf = CAUIGumpLogicBase_onBooleanButtonPressed(CAUIGumpHealConfig.BandageSelf, CAUIGumpHeal_CAUIGH.Config.bandageSelfButton, 'Bandage Self')
    end
end

function CAUIGumpHeal_processBandageOtherButtonInteractions()
    if CAUIGumpHeal_CAUIGH.Config.bandageOtherButton:WasClicked() then
        CAUIGumpHealConfig.BandageOther = CAUIGumpLogicBase_onBooleanButtonPressed(CAUIGumpHealConfig.BandageOther, CAUIGumpHeal_CAUIGH.Config.bandageOtherButton, 'Bandage Other')
    end
end

function CAUIGumpHeal_processHealPotionsModeButtonInteractions()
    if CAUIGumpHeal_CAUIGH.Config.healPotionsModeButton:WasClicked() then
        CAUIGumpHealConfig.HealPotsMode = CAUIGumpLogicBase_onEnumStateButtonPressed(CAUIGumpHealConfig.HealPotsMode, CAUIGumpHeal_HealPotsModeValues.FiftyPercent, CAUIGumpHeal_HealPotsModeStrings, CAUIGumpHeal_CAUIGH.Config.healPotionsModeButton, 'Healing Potions Mode')
    end
end

function CAUIGumpHeal_processHealPotionAfterStrengthPotionButtonInteractions()
    if CAUIGumpHeal_CAUIGH.Config.healPotionAfterStrengthPotionButton:WasClicked() then
        CAUIGumpHealConfig.HealPotsAfterStrPot = CAUIGumpLogicBase_onBooleanButtonPressed(CAUIGumpHealConfig.HealPotsAfterStrPot, CAUIGumpHeal_CAUIGH.Config.healPotionAfterStrengthPotionButton, 'Heal On Str')
    end
end

function CAUIGumpHeal_processCurePotionsButtonInteractions()
    if CAUIGumpHeal_CAUIGH.Config.curePotionsButton:WasClicked() then
        CAUIGumpHealConfig.CurePots = CAUIGumpLogicBase_onBooleanButtonPressed(CAUIGumpHealConfig.CurePots, CAUIGumpHeal_CAUIGH.Config.curePotionsButton, 'Use Cure')
    end
end

function CAUIGumpHeal_processUIInteractions()
    CAUIGumpHeal_processHealButtonInteractions()
    CAUIGumpHeal_processHealConfigButtonInteractions()
    CAUIGumpHeal_processBandageSelfButtonInteractions()
    CAUIGumpHeal_processBandageOtherButtonInteractions()
    CAUIGumpHeal_processHealPotionsModeButtonInteractions()
    CAUIGumpHeal_processHealPotionAfterStrengthPotionButtonInteractions()
    CAUIGumpHeal_processCurePotionsButtonInteractions()
end

function CAUIGumpHeal_updateCAConfigToCurrentUIConfig(CAConfig)
    local bandagesConfig = CAConfig.modules.Bandages
    local healingPotionsConfig = CAConfig.modules.HealingPotions
    local strengthPotionsConfig = CAConfig.modules.Buffs.Strength
    local curePotionsConfig = CAConfig.modules.CurePotions
    if CAUIGumpHealConfig.HealEnabled then
        bandagesConfig.Enable = CAUIGumpHealConfig.BandageSelf
        bandagesConfig.BandageAllies = CAUIGumpHealConfig.BandageOther
        healingPotionsConfig.Enable = CAUIGumpHealConfig.HealPotsMode ~= CAUIGumpHeal_HealPotsModeValues.None
        healingPotionsConfig.HPDrinkThreshould = CAUIGumpHeal_HealPotsPercentageThreshoulds[CAUIGumpHealConfig.HealPotsMode]
        strengthPotionsConfig.DrinkHeal = CAUIGumpHealConfig.HealPotsAfterStrPot
        curePotionsConfig.Enable = CAUIGumpHealConfig.CurePots
    else
        bandagesConfig.Enable = false
        bandagesConfig.BandageAllies = false
        healingPotionsConfig.Enable = false
        healingPotionsConfig.HPDrinkThreshould = 0
        strengthPotionsConfig.DrinkHeal = false
        curePotionsConfig.Enable = false
    end
end

function CAUIGumpHeal_initUI(mainWindow, row)
    CALog_debug('Creating Healing UI...')
    CAUIGumpHeal_CAUIGH.enableButton = CAUIGumpLayoutBase_createModuleEnableButtonAtRow(mainWindow, row, 'Heal')
    CAUIGumpHeal_CAUIGH.enableLabel = CAUIGumpLayoutBase_createModuleEnableLabelAtRow(mainWindow, row, 'Enabled')
    CAUIGumpHeal_CAUIGH.configButton = CAUIGumpLayoutBase_createModuleConfigButtonAtRow(mainWindow, row)
    CAUIGumpHeal_CAUIGH.Config.window = CAUIGumpLayoutBase_createModuleConfigWindow('healConfigWindow', 'Heal Config', 5, row)
    CAUIGumpLogicBase_registerSharedVisibilityConfigWindowsCloseFunction(CAUIGumpHeal_closeHealConfigWindow)
    CAUIGumpHeal_CAUIGH.Config.bandageSelfButton = CAUIGumpLayoutBase_createModuleConfigWindowButtonAtRow(CAUIGumpHeal_CAUIGH.Config.window, 1, CAUIGumpLogicBase_getBoonleanButtonStateDisplayStr(CAUIGumpHealConfig.BandageSelf, 'Bandage Self'), 140, CAUIGumpLayoutBase_getLayoutConstants().ModuleConfigWindowFeatureEnableButtonSizeY)
    CAUIGumpHeal_CAUIGH.Config.bandageOtherButton = CAUIGumpLayoutBase_createModuleConfigWindowButtonAtRow(CAUIGumpHeal_CAUIGH.Config.window, 2, CAUIGumpLogicBase_getBoonleanButtonStateDisplayStr(CAUIGumpHealConfig.BandageOther, 'Bandage Others'), 140, CAUIGumpLayoutBase_getLayoutConstants().ModuleConfigWindowFeatureEnableButtonSizeY)
    CAUIGumpHeal_CAUIGH.Config.healPotionsModeButton = CAUIGumpLayoutBase_createModuleConfigWindowButtonAtRow(CAUIGumpHeal_CAUIGH.Config.window, 3, CAUIGumpHeal_HealPotsModeStrings[CAUIGumpHealConfig.HealPotsMode], 180, CAUIGumpLayoutBase_getLayoutConstants().ModuleConfigWindowFeatureEnableButtonSizeY)
    CAUIGumpHeal_CAUIGH.Config.healPotionAfterStrengthPotionButton = CAUIGumpLayoutBase_createModuleConfigWindowButtonAtRow(CAUIGumpHeal_CAUIGH.Config.window, 4, CAUIGumpLogicBase_getBoonleanButtonStateDisplayStr(CAUIGumpHealConfig.HealPotsAfterStrPot, 'Heal On Str'), 140, CAUIGumpLayoutBase_getLayoutConstants().ModuleConfigWindowFeatureEnableButtonSizeY)
    CAUIGumpHeal_CAUIGH.Config.curePotionsButton = CAUIGumpLayoutBase_createModuleConfigWindowButtonAtRow(CAUIGumpHeal_CAUIGH.Config.window, 5, CAUIGumpLogicBase_getBoonleanButtonStateDisplayStr(CAUIGumpHealConfig.CurePots, 'Use Cure'), 140, CAUIGumpLayoutBase_getLayoutConstants().ModuleConfigWindowFeatureEnableButtonSizeY)
end

CAUIGumpBuffs_CAUIGB = {
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
}

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
    BuffsEnabled = false,
    ConfigWindowClosed = true,
    EnableNightsight = true,
    EnableStrength = true,
    EnableAgility = true,
    HealPotsAfterStrPot = true,
    StaminaPotsMode = CAUIGumpBuffs_StaminaPotsModeValues.SixtyPercent
}

function CAUIGumpBuffs_processBuffsButtonInteractions()
    if CAUIGumpBuffs_CAUIGB.enableButton:WasClicked() then
        CAUIGumpBuffsState.BuffsEnabled = CAUIGumpLogicBase_onEnabledDisabledButtonPressed(CAUIGumpBuffsState.BuffsEnabled, CAUIGumpBuffs_CAUIGB.enableLabel, 'Buffs')
    end
end

function CAUIGumpBuffs_updateBuffsConfigWindow(targetValue, closeOtherCWs)
    CAUIGumpBuffsState.ConfigWindowClosed = CAUIGumpLogicBase_onConfigMenuButtonPressed(not targetValue, CAUIGumpBuffs_CAUIGB.configButton, CAUIGumpBuffs_CAUIGB.Config.window, 'Buffs Config', closeOtherCWs)
end

function CAUIGumpBuffs_closeBuffsConfigWindow()
    CAUIGumpBuffs_updateBuffsConfigWindow(true, false)
end

function CAUIGumpBuffs_processBuffsConfigButtonInteractions()
    if CAUIGumpBuffs_CAUIGB.configButton:WasClicked() then
        CAUIGumpBuffs_updateBuffsConfigWindow(not CAUIGumpBuffsState.ConfigWindowClosed, true)
    end
end

function CAUIGumpBuffs_processNightsightButtonInteractions(force)
    if force or CAUIGumpBuffs_CAUIGB.Config.enableNightsight:WasClicked() then
        CAUIGumpBuffsState.EnableNightsight = CAUIGumpLogicBase_onBooleanButtonPressed(CAUIGumpBuffsState.EnableNightsight, CAUIGumpBuffs_CAUIGB.Config.enableNightsight, 'Nightsight')
    end
end

function CAUIGumpBuffs_processStrengthButtonInteractions()
    if CAUIGumpBuffs_CAUIGB.Config.enableStrength:WasClicked() then
        CAUIGumpBuffsState.EnableStrength = CAUIGumpLogicBase_onBooleanButtonPressed(CAUIGumpBuffsState.EnableStrength, CAUIGumpBuffs_CAUIGB.Config.enableStrength, 'Strength')
    end
end

function CAUIGumpBuffs_processAgilityButtonInteractions()
    if CAUIGumpBuffs_CAUIGB.Config.enableAgility:WasClicked() then
        CAUIGumpBuffsState.EnableAgility = CAUIGumpLogicBase_onBooleanButtonPressed(CAUIGumpBuffsState.EnableAgility, CAUIGumpBuffs_CAUIGB.Config.enableAgility, 'Agility')
    end
end

function CAUIGumpBuffs_processRefreshOnAgilityButtonInteractions()
    if CAUIGumpBuffs_CAUIGB.Config.refreshAfterAgility:WasClicked() then
        CAUIGumpBuffsState.HealPotsAfterStrPot = CAUIGumpLogicBase_onBooleanButtonPressed(CAUIGumpBuffsState.HealPotsAfterStrPot, CAUIGumpBuffs_CAUIGB.Config.refreshAfterAgility, 'Refresh On Agi')
    end
end

function CAUIGumpBuffs_processStaminaPotionsModeButtonInteractions()
    if CAUIGumpBuffs_CAUIGB.Config.staminaPotionsModeButton:WasClicked() then
        CAUIGumpBuffsState.StaminaPotsMode = CAUIGumpLogicBase_onEnumStateButtonPressed(CAUIGumpBuffsState.StaminaPotsMode, CAUIGumpBuffs_StaminaPotsModeValues.EightyPercent, CAUIGumpBuffs_StaminaPotsModeStrings, CAUIGumpBuffs_CAUIGB.Config.staminaPotionsModeButton, 'Stamina Potions Mode')
    end
end

function CAUIGumpBuffs_processUIInteractions()
    CAUIGumpBuffs_processBuffsButtonInteractions()
    CAUIGumpBuffs_processBuffsConfigButtonInteractions()
    CAUIGumpBuffs_processNightsightButtonInteractions()
    CAUIGumpBuffs_processStrengthButtonInteractions()
    CAUIGumpBuffs_processAgilityButtonInteractions()
    CAUIGumpBuffs_processRefreshOnAgilityButtonInteractions()
    CAUIGumpBuffs_processStaminaPotionsModeButtonInteractions()
end

function CAUIGumpBuffs_updateCAConfigToCurrentUIConfig(CAConfig)
    local buffsConfig = CAConfig.modules.Buffs
    buffsConfig.Enable = CAUIGumpBuffsState.BuffsEnabled
    buffsConfig.Nightsight.Enable = CAUIGumpBuffsState.EnableNightsight
    buffsConfig.Strength.Enable = CAUIGumpBuffsState.EnableStrength
    buffsConfig.Agility.Enable = CAUIGumpBuffsState.EnableAgility
    buffsConfig.Stamina.Enable = CAUIGumpBuffsState.StaminaPotsMode ~= CAUIGumpBuffs_StaminaPotsModeValues.None
    buffsConfig.Stamina.DrinkThreshould = CAUIGumpBuffs_StaminaPotsModeThreshoulds[CAUIGumpBuffsState.StaminaPotsMode]
end

function CAUIGumpBuffs_initUI(mainWindow, row)
    CALog_debug('Creating Buffs UI...')
    CAUIGumpBuffs_CAUIGB.enableButton = CAUIGumpLayoutBase_createModuleEnableButtonAtRow(mainWindow, row, 'Buffs')
    CAUIGumpBuffs_CAUIGB.enableLabel = CAUIGumpLayoutBase_createModuleEnableLabelAtRow(mainWindow, row, 'Disabled')
    CAUIGumpBuffs_CAUIGB.enableLabel:SetColor(1, 0, 0, 1)
    CAUIGumpBuffs_CAUIGB.configButton = CAUIGumpLayoutBase_createModuleConfigButtonAtRow(mainWindow, row)
    CAUIGumpBuffs_CAUIGB.Config.window = CAUIGumpLayoutBase_createModuleConfigWindow('buffsConfigWindow', 'Buffs Config', 5, row)
    CAUIGumpLogicBase_registerSharedVisibilityConfigWindowsCloseFunction(CAUIGumpBuffs_closeBuffsConfigWindow)
    CAUIGumpBuffs_CAUIGB.Config.enableNightsight = CAUIGumpLayoutBase_createModuleConfigWindowButtonAtRow(CAUIGumpBuffs_CAUIGB.Config.window, 1, CAUIGumpLogicBase_getBoonleanButtonStateDisplayStr(CAUIGumpBuffsState.EnableNightsight, 'Nightsight'))
    CAUIGumpBuffs_CAUIGB.Config.enableStrength = CAUIGumpLayoutBase_createModuleConfigWindowButtonAtRow(CAUIGumpBuffs_CAUIGB.Config.window, 2, CAUIGumpLogicBase_getBoonleanButtonStateDisplayStr(CAUIGumpBuffsState.EnableStrength, 'Strength'))
    CAUIGumpBuffs_CAUIGB.Config.enableAgility = CAUIGumpLayoutBase_createModuleConfigWindowButtonAtRow(CAUIGumpBuffs_CAUIGB.Config.window, 3, CAUIGumpLogicBase_getBoonleanButtonStateDisplayStr(CAUIGumpBuffsState.EnableAgility, 'Agility'))
    CAUIGumpBuffs_CAUIGB.Config.refreshAfterAgility = CAUIGumpLayoutBase_createModuleConfigWindowButtonAtRow(CAUIGumpBuffs_CAUIGB.Config.window, 4, CAUIGumpLogicBase_getBoonleanButtonStateDisplayStr(CAUIGumpBuffsState.HealPotsAfterStrPot, 'Refresh On Agi'), 140, CAUIGumpLayoutBase_getLayoutConstants().ModuleConfigWindowFeatureEnableButtonSizeY)
    CAUIGumpBuffs_CAUIGB.Config.staminaPotionsModeButton = CAUIGumpLayoutBase_createModuleConfigWindowButtonAtRow(CAUIGumpBuffs_CAUIGB.Config.window, 5, CAUIGumpBuffs_StaminaPotsModeStrings[CAUIGumpBuffsState.StaminaPotsMode], 180, CAUIGumpLayoutBase_getLayoutConstants().ModuleConfigWindowFeatureEnableButtonSizeY)
end

function CAUIGumpBuffs_getEnableNightsight()
    return CAUIGumpBuffsState.EnableNightsight
end

function CAUIGumpBuffs_setEnableNightsight(isChecked)
    CAUIGumpBuffsState.EnableNightsight = not isChecked
    CAUIGumpBuffs_processNightsightButtonInteractions(true)
end

CAUIGumpCommands_CAUIGC = {
    enableButton = nil,
    enableLabel = nil
}

CAUIGumpCommandsConfig = {
    CommandsEnabled = true
}

function CAUIGumpCommands_processCommandsButtonInteractions()
    if CAUIGumpCommands_CAUIGC.enableButton:WasClicked() then
        CAUIGumpCommandsConfig.CommandsEnabled = CAUIGumpLogicBase_onEnabledDisabledButtonPressed(CAUIGumpCommandsConfig.CommandsEnabled, CAUIGumpCommands_CAUIGC.enableLabel, 'Commands')
    end
end

function CAUIGumpCommands_processUIInteractions()
    CAUIGumpCommands_processCommandsButtonInteractions()
end

function CAUIGumpCommands_updateCAConfigToCurrentUIConfig(CAConfig)
    local commandsConfig = CAConfig.userCommands
    commandsConfig.Enable = CAUIGumpCommandsConfig.CommandsEnabled
end

function CAUIGumpCommands_initUI(mainWindow, row)
    CALog_debug('Creating Commands UI...')
    CAUIGumpCommands_CAUIGC.enableButton = CAUIGumpLayoutBase_createModuleEnableButtonAtRow(mainWindow, row, 'Commands')
    CAUIGumpCommands_CAUIGC.enableLabel = CAUIGumpLayoutBase_createModuleEnableLabelAtRow(mainWindow, row, 'Enabled')
end

CAUIGumpAttack_CAUIGA = {
    enableButton = nil,
    enableLabel = nil,
    configButton = nil,
    Config = {
        window = nil,
        rangeMaxButton = nil,
        exceptionModeButton = nil
    }
}

CAUIGumpAttack_AttackRangeValues = {
    One = 1,
    Three = 2,
    Five = 3,
    Seven = 4,
    Nine = 5,
    Eleven = 6
}

CAUIGumpAttack_AttackRangeStrings = {
    'Range (1)',
    'Range (3)',
    'Range (5)',
    'Range (7)',
    'Range (9)',
    'Range (11)',
}

CAUIGumpAttack_AttackRangeConfigValues = {
    1,
    3,
    5,
    7,
    9,
    11
}

CAUIGumpAttack_AttackExceptionModeValues = {
    None = 1,
    IDAndNames = 2
}

CAUIGumpAttack_AttackExceptionModeStrings = {
    'Exceptions (None)',
    'Exceptions (ID + Names)'
}

CAUIGumpAttackConfig = {
    AttackEnabled = false,
    ConfigWindowClosed = true,
    AttackRangeMax = CAUIGumpAttack_AttackRangeValues.Five,
    AttackExceptionsMode = CAUIGumpAttack_AttackExceptionModeValues.IDAndNames
}

function CAUIGumpAttack_processAttackButtonInteractions()
    if CAUIGumpAttack_CAUIGA.enableButton:WasClicked() then
        CAUIGumpAttackConfig.AttackEnabled = CAUIGumpLogicBase_onEnabledDisabledButtonPressed(CAUIGumpAttackConfig.AttackEnabled, CAUIGumpAttack_CAUIGA.enableLabel, 'Attack')
    end
end

function CAUIGumpAttack_updateAttackConfigWindow(targetValue, closeOtherCWs)
    CAUIGumpAttackConfig.ConfigWindowClosed = CAUIGumpLogicBase_onConfigMenuButtonPressed(not targetValue, CAUIGumpAttack_CAUIGA.configButton, CAUIGumpAttack_CAUIGA.Config.window, 'Attack Config', closeOtherCWs)
end

function CAUIGumpAttack_closeAttackConfigWindow()
    CAUIGumpAttack_updateAttackConfigWindow(true, false)
end

function CAUIGumpAttack_processAttackConfigButtonInteractions()
    if CAUIGumpAttack_CAUIGA.configButton:WasClicked() then
        CAUIGumpAttack_updateAttackConfigWindow(not CAUIGumpAttackConfig.ConfigWindowClosed, true)
    end
end

function CAUIGumpAttack_processAttackRangeMaxButtonInteractions()
    if CAUIGumpAttack_CAUIGA.Config.rangeMaxButton:WasClicked() then
        CAUIGumpAttackConfig.AttackRangeMax = CAUIGumpLogicBase_onEnumStateButtonPressed(CAUIGumpAttackConfig.AttackRangeMax, CAUIGumpAttack_AttackRangeValues.Eleven, CAUIGumpAttack_AttackRangeStrings, CAUIGumpAttack_CAUIGA.Config.rangeMaxButton, 'Attack Range')
    end
end

function CAUIGumpAttack_processAttackExceptionsModeButtonInteractions()
    if CAUIGumpAttack_CAUIGA.Config.exceptionModeButton:WasClicked() then
        CAUIGumpAttackConfig.AttackExceptionsMode = CAUIGumpLogicBase_onEnumStateButtonPressed(CAUIGumpAttackConfig.AttackExceptionsMode, CAUIGumpAttack_AttackExceptionModeValues.IDAndNames, CAUIGumpAttack_AttackExceptionModeStrings, CAUIGumpAttack_CAUIGA.Config.exceptionModeButton, 'Attack Exceptions Mode')
    end
end

function CAUIGumpAttack_processUIInteractions()
    CAUIGumpAttack_processAttackButtonInteractions()
    CAUIGumpAttack_processAttackConfigButtonInteractions()
    CAUIGumpAttack_processAttackRangeMaxButtonInteractions()
    CAUIGumpAttack_processAttackExceptionsModeButtonInteractions()
end

function CAUIGumpAttack_updateCAConfigToCurrentUIConfig(CAConfig)
    local attackConfig = CAConfig.modules.Attack
    attackConfig.Enable = CAUIGumpAttackConfig.AttackEnabled
    attackConfig.Rangemax = CAUIGumpAttack_AttackRangeConfigValues[CAUIGumpAttackConfig.AttackRangeMax]
    attackConfig.AllowMobilesExceptionsGraphicIDs = CAUIGumpAttackConfig.AttackExceptionsMode == CAUIGumpAttack_AttackExceptionModeValues.IDAndNames
    attackConfig.AllowMobilesExceptionsNames = CAUIGumpAttackConfig.AttackExceptionsMode == CAUIGumpAttack_AttackExceptionModeValues.IDAndNames
end

function CAUIGumpAttack_initUI(mainWindow, row)
    CALog_debug('Creating Attack UI...')
    CAUIGumpAttack_CAUIGA.enableButton = CAUIGumpLayoutBase_createModuleEnableButtonAtRow(mainWindow, row, 'Attack')
    CAUIGumpAttack_CAUIGA.enableLabel = CAUIGumpLayoutBase_createModuleEnableLabelAtRow(mainWindow, row, 'Disabled')
    CAUIGumpAttack_CAUIGA.enableLabel:SetColor(1, 0, 0, 1)
    CAUIGumpAttack_CAUIGA.configButton = CAUIGumpLayoutBase_createModuleConfigButtonAtRow(mainWindow, row)
    CAUIGumpAttack_CAUIGA.Config.window = CAUIGumpLayoutBase_createModuleConfigWindow('attackConfigWindow', 'Attack Config', 2, row)
    CAUIGumpLogicBase_registerSharedVisibilityConfigWindowsCloseFunction(CAUIGumpAttack_closeAttackConfigWindow)
    CAUIGumpAttack_CAUIGA.Config.rangeMaxButton = CAUIGumpLayoutBase_createModuleConfigWindowButtonAtRow(CAUIGumpAttack_CAUIGA.Config.window, 1, CAUIGumpAttack_AttackRangeStrings[CAUIGumpAttackConfig.AttackRangeMax])
    CAUIGumpAttack_CAUIGA.Config.exceptionModeButton = CAUIGumpLayoutBase_createModuleConfigWindowButtonAtRow(CAUIGumpAttack_CAUIGA.Config.window, 2, 'Exceptions (ID + Names)', 180, CAUIGumpLayoutBase_getLayoutConstants().ModuleConfigWindowFeatureEnableButtonSizeY)
end

CAUIGumpScavenge_CAUIGS = {
    enableButton = nil,
    enableLabel = nil,
    configButton = nil,
    Config = {
        window = nil,
        activateGoldButton = nil,
        activateBandagesButton = nil,
        activateBonesButton = nil,
        activateGrimoiresButton = nil,
        activateRibsButton = nil
    }
}

CAUIGumpScavengeConfig = {
    ScavengerEnabled = false,
    ConfigWindowOpen = true,
    ScavengeGold = true,
    ScavengeCleanBandages = true,
    ScavengeBones = true,
    ScavengeGrimoires = true,
    ScavengeRibs = true
}

function CAUIGumpScavenge_processScavengerButtonInteractions()
    if CAUIGumpScavenge_CAUIGS.enableButton:WasClicked() then
        CAUIGumpScavengeConfig.ScavengerEnabled = CAUIGumpLogicBase_onEnabledDisabledButtonPressed(CAUIGumpScavengeConfig.ScavengerEnabled, CAUIGumpScavenge_CAUIGS.enableLabel, 'Scavenger')
    end
end

function CAUIGumpScavenge_updateScavengerConfigWindow(targetValue, closeOtherCWs)
    CAUIGumpScavengeConfig.ConfigWindowOpen = CAUIGumpLogicBase_onConfigMenuButtonPressed(not targetValue, CAUIGumpScavenge_CAUIGS.configButton, CAUIGumpScavenge_CAUIGS.Config.window, 'Scavenger Config', closeOtherCWs)
end

function CAUIGumpScavenge_closeScavengerConfigWindow()
    CAUIGumpScavenge_updateScavengerConfigWindow(true, false)
end

function CAUIGumpScavenge_processScavengerConfigButtonInteractions()
    if CAUIGumpScavenge_CAUIGS.configButton:WasClicked() then
        CAUIGumpScavenge_updateScavengerConfigWindow(not CAUIGumpScavengeConfig.ConfigWindowOpen, true)
    end
end

function CAUIGumpScavenge_processScavengeGoldButtonInteractions()
    if CAUIGumpScavenge_CAUIGS.Config.activateGoldButton:WasClicked() then
        CAUIGumpScavengeConfig.ScavengeGold = CAUIGumpLogicBase_onBooleanButtonPressed(CAUIGumpScavengeConfig.ScavengeGold, CAUIGumpScavenge_CAUIGS.Config.activateGoldButton, 'Gold')
    end
end

function CAUIGumpScavenge_processScavengeBandagesButtonInteractions()
    if CAUIGumpScavenge_CAUIGS.Config.activateBandagesButton:WasClicked() then
        CAUIGumpScavengeConfig.ScavengeCleanBandages = CAUIGumpLogicBase_onBooleanButtonPressed(CAUIGumpScavengeConfig.ScavengeCleanBandages, CAUIGumpScavenge_CAUIGS.Config.activateBandagesButton, 'Bandages')
    end
end

function CAUIGumpScavenge_processScavengeBonesButtonInteractions()
    if CAUIGumpScavenge_CAUIGS.Config.activateBonesButton:WasClicked() then
        CAUIGumpScavengeConfig.ScavengeBones = CAUIGumpLogicBase_onBooleanButtonPressed(CAUIGumpScavengeConfig.ScavengeBones, CAUIGumpScavenge_CAUIGS.Config.activateBonesButton, 'Bones')
    end
end

function CAUIGumpScavenge_processScavengeGrimoiresButtonInteractions()
    if CAUIGumpScavenge_CAUIGS.Config.activateGrimoiresButton:WasClicked() then
        CAUIGumpScavengeConfig.ScavengeGrimoires = CAUIGumpLogicBase_onBooleanButtonPressed(CAUIGumpScavengeConfig.ScavengeGrimoires, CAUIGumpScavenge_CAUIGS.Config.activateGrimoiresButton, 'Grimoires')
    end
end

function CAUIGumpScavenge_processScavengeRibsButtonInteractions()
    if CAUIGumpScavenge_CAUIGS.Config.activateRibsButton:WasClicked() then
        CAUIGumpScavengeConfig.ScavengeRibs = CAUIGumpLogicBase_onBooleanButtonPressed(CAUIGumpScavengeConfig.ScavengeRibs, CAUIGumpScavenge_CAUIGS.Config.activateRibsButton, 'Ribs')
    end
end

function CAUIGumpScavenge_processUIInteractions()
    CAUIGumpScavenge_processScavengerButtonInteractions()
    CAUIGumpScavenge_processScavengerConfigButtonInteractions()
    CAUIGumpScavenge_processScavengeGoldButtonInteractions()
    CAUIGumpScavenge_processScavengeBandagesButtonInteractions()
    CAUIGumpScavenge_processScavengeBonesButtonInteractions()
    CAUIGumpScavenge_processScavengeGrimoiresButtonInteractions()
    CAUIGumpScavenge_processScavengeRibsButtonInteractions()
end

function CAUIGumpScavenge_updateCAConfigToCurrentUIConfig(CAConfig)
    local scavengeConfig = CAConfig.modules.Scavenging
    scavengeConfig.Enable = CAUIGumpScavengeConfig.ScavengerEnabled
    scavengeConfig.DisallowGold = not CAUIGumpScavengeConfig.ScavengeGold
    scavengeConfig.DisallowCleanBandages = not CAUIGumpScavengeConfig.ScavengeCleanBandages
    scavengeConfig.DisallowBones = not CAUIGumpScavengeConfig.ScavengeBones
    scavengeConfig.DisallowGrimoire = not CAUIGumpScavengeConfig.ScavengeGrimoires
    scavengeConfig.DisallowRibs = not CAUIGumpScavengeConfig.ScavengeRibs
end

function CAUIGumpScavenge_initUI(mainWindow, row)
    CALog_debug('Creating Scavenge UI...')
    CAUIGumpScavenge_CAUIGS.enableButton = CAUIGumpLayoutBase_createModuleEnableButtonAtRow(mainWindow, row, 'Scavenge')
    CAUIGumpScavenge_CAUIGS.enableLabel = CAUIGumpLayoutBase_createModuleEnableLabelAtRow(mainWindow, row, 'Disabled')
    CAUIGumpScavenge_CAUIGS.enableLabel:SetColor(1, 0, 0, 1)
    CAUIGumpScavenge_CAUIGS.configButton = CAUIGumpLayoutBase_createModuleConfigButtonAtRow(mainWindow, row)
    CAUIGumpScavenge_CAUIGS.Config.window = CAUIGumpLayoutBase_createModuleConfigWindow('scavengerConfigWindow', 'Scavenge Config', 5, row)
    CAUIGumpLogicBase_registerSharedVisibilityConfigWindowsCloseFunction(CAUIGumpScavenge_closeScavengerConfigWindow)
    CAUIGumpScavenge_CAUIGS.Config.activateGoldButton = CAUIGumpLayoutBase_createModuleConfigWindowButtonAtRow(CAUIGumpScavenge_CAUIGS.Config.window, 1, CAUIGumpLogicBase_getBoonleanButtonStateDisplayStr(CAUIGumpScavengeConfig.ScavengeGold, 'Gold'))
    CAUIGumpScavenge_CAUIGS.Config.activateBandagesButton = CAUIGumpLayoutBase_createModuleConfigWindowButtonAtRow(CAUIGumpScavenge_CAUIGS.Config.window, 2, CAUIGumpLogicBase_getBoonleanButtonStateDisplayStr(CAUIGumpScavengeConfig.ScavengeCleanBandages, 'Bandages'))
    CAUIGumpScavenge_CAUIGS.Config.activateBonesButton = CAUIGumpLayoutBase_createModuleConfigWindowButtonAtRow(CAUIGumpScavenge_CAUIGS.Config.window, 3, CAUIGumpLogicBase_getBoonleanButtonStateDisplayStr(CAUIGumpScavengeConfig.ScavengeBones, 'Bones'))
    CAUIGumpScavenge_CAUIGS.Config.activateGrimoiresButton = CAUIGumpLayoutBase_createModuleConfigWindowButtonAtRow(CAUIGumpScavenge_CAUIGS.Config.window, 4, CAUIGumpLogicBase_getBoonleanButtonStateDisplayStr(CAUIGumpScavengeConfig.ScavengeGrimoires, 'Grimoires'))
    CAUIGumpScavenge_CAUIGS.Config.activateRibsButton = CAUIGumpLayoutBase_createModuleConfigWindowButtonAtRow(CAUIGumpScavenge_CAUIGS.Config.window, 5, CAUIGumpLogicBase_getBoonleanButtonStateDisplayStr(CAUIGumpScavengeConfig.ScavengeRibs, 'Ribs'))
end

CAUI = {
    mainWindow = nil
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

    local nightsightUIEnabled = CAUIGumpBuffs_getEnableNightsight()

    CAUIGumpMainRow_processUIInteractions()        --- Main Row
    CAUIGumpRun_processUIInteractions()            --- Run
    CAUIGumpCommands_processUIInteractions()       --- Commands
    CAUIGumpAttack_processUIInteractions()         --- Attack
    CAUIGumpHeal_processUIInteractions()           --- Heal
    CAUIGumpBuffs_processUIInteractions()          --- Buffs
    CAUIGumpScavenge_processUIInteractions()       --- Scavenge

    nightsightUIChanged = nightsightUIEnabled ~= CAUIGumpBuffs_getEnableNightsight()
end

function CAUIGump_updateCombatAssistantConfig(CAConfig)

    --- Override UI values to CA Config
    CAUIGumpMainRow_updateCAConfigToCurrentUIConfig(CAConfig)      --- Main Row
    CAUIGumpCommands_updateCAConfigToCurrentUIConfig(CAConfig)     --- Commands
    CAUIGumpAttack_updateCAConfigToCurrentUIConfig(CAConfig)       --- Attack
    CAUIGumpHeal_updateCAConfigToCurrentUIConfig(CAConfig)         --- Heal
    CAUIGumpBuffs_updateCAConfigToCurrentUIConfig(CAConfig)        --- Buffs
    CAUIGumpScavenge_updateCAConfigToCurrentUIConfig(CAConfig)     --- Scavenge

    --- Because of internal error, nightsight may disable itself (don't override that part, unless there is a user interaction)
    if not nightsightUIChanged then
        CAConfig.modules.Buffs.Nightsight.Enable = CAPotionsNightsight_getEnable()
        CAUIGumpBuffs_setEnableNightsight(CAPotionsNightsight_getEnable())
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
    furthestElementX = CAUIGumpLayoutBase_getLayoutConstants().ModuleConfigButtonPosX + CAUIGumpLayoutBase_getLayoutConstants().ModuleConfigButtonSizeX
    furthestElementY = CAUIGumpLayoutBase_getLayoutConstants().ModuleRowPosYStart + CAUIGumpLayoutBase_getLayoutConstants().ModuleRowPosYIncrement * (CAUIMainWindowLayout.NumberOfModules -1) + CAUIGumpLayoutBase_getLayoutConstants().ModuleEnableButtonSizeY
    CAUI.mainWindow:SetPosition(CAUIMainWindowLayout.StartPosX, CAUIMainWindowLayout.StartPosY)
    CAUI.mainWindow:SetSize(furthestElementX + CAUIMainWindowLayout.SizeXOffset, furthestElementY + CAUIMainWindowLayout.SizeYOffset)

    CALog_debug("Window created and ready!")
end

function CAUIGump_initModules()
    CAUIGumpMainRow_initUI(CAUI.mainWindow)        --- Main Row
    CAUIGumpRun_initUI(CAUI.mainWindow, 1)         --- Run
    CAUIGumpCommands_initUI(CAUI.mainWindow, 2)    --- Commands
    CAUIGumpAttack_initUI(CAUI.mainWindow, 3)      --- Attack
    CAUIGumpHeal_initUI(CAUI.mainWindow, 4)        --- Heal
    CAUIGumpBuffs_initUI(CAUI.mainWindow, 5)       --- Buffs
    CAUIGumpScavenge_initUI(CAUI.mainWindow, 6)    --- Scavenge
end

function CAUIGump_initMainGump()
    CAUIGump_initMainWindow()
    CAUIGump_initModules()
end

function CAUIGump_runGump(CAConfig)

    CALog_debug('Starting Combat Assistant Iteration!')
    UI.DestroyAllWindows()                                  --- Cleanup
    CAUIGump_initMainGump()                                         --- Init main gump (create UI, set up event handlers, etc...)
    CAMainLoop_mainLoopInit(CAConfig)                             --- Initialize main loop (configure modules, etc...)
    while true do

        CAUIGump_processUIGumpInteractions()                        --- Check for UI changes
        CAUIGump_updateCombatAssistantConfig(CAConfig)              --- Process Updates to Combat Assistant Config
        if CAUIGumpRun_getIterateCAMainLoop() then             --- Is the Combat Assistant set to run in the UI?
            CAUIGumpRun_startIteration()
            CAMainLoop_mainLoopIterate(CAConfig)                  --- Iterate main loop once (process actions, etc...)
            CAUIGumpRun_endIteration()
        else
            CALog_debug('Combat Assistant Disabled!')
        end

        Pause(50)
    end
end

FriendsSerialList = {     --- FriendsSerialList: add serials of friends to this list so that:
                                ---  1) Attack module does not attack them, even when they are grey
                                ---  2) To cross-heal them if they are damaged
    0x003306A5  --- Dardez Jum Zir (if you want to attack me, remove me from the list)
}

MobilesExceptionsGraphicIDs = {   --- MobilesExceptionsGraphicIDs: add graphic IDs of mobiles you want attack module to ignore
    0x00ED  --- A Hind
}

MobilesExceptionsNames = {    --- MobilesExceptionsNames: add names of mobiles you want attack module to ignore
    "a cow",
    "a horse",
    "a rat",
    "a magpie",
    "a crow",
    "a towhee",
    "a dog",
    "a cat",
    "a bull",
    "a sheep",
    "a gorila",
    "a forest ostard"

}

ScavengerLootTable = {  --- ScavengerLootTable: add here the graphic IDs of items to auto-loot
    --- (highest priority)
    0xFDAD,  --- Eren Coin
    0x0F91,  --- Fragment
    0xFD8C,  --- Soul
    0xFD8F,  --- Mastery Gem
    0x0E73,  --- Skill Cap Ball
    0xFF3A,  --- Skill Scroll
    0x9FF8,  --- Paragon Chest
    0x9FF9,  --- Paragon Chest
    0x14EC,  --- Treasure Map
    0x573B,  --- Pigments
    ---0x0EB2,  --- Lap Harp
    ---0x0EB1,  --- Standing Harp
    ---0x0EB3,  --- Lute
    ---0x0E9D,  --- Tambourine
    ---0x0E9E,  --- Tambourine
    ---0x0E9C,  --- Drum
    0x0F26,  --- Diamond
    0x0F10,  --- Emerald
    0x0F16,  --- Amethyst
    0x0F10,  --- Emerald
    0x0F19,  --- Saphire
    0x0F25,  --- Amber
    0x0F13,  --- Ruby
    0x26B4,  --- Daemon Scales
    0xFCA9,  --- Hardened Resin
    0x318B,  --- Enchanted Bark
    0x0E21,  --- Clean Bandage
    ---0x0F8D,  --- Spider Silk
    ---0x0F86,  --- Mandrake Root
    ---0x0F8C,  --- Ash
    ---0x0F7B,  --- Blood Moss
    ---0x0F88,  --- Night Shade
    ---0x0F84,  --- Garlic
    ---0x0F7A,  --- Black Pearl
    ---0x0F85,  --- Ginseng
    ---0x0F3F,  --- Arrows
    ---0x1BFB,  --- Bolts
    ---0x09F1,  --- Raw Ribs
    ---0x0E86,  --- Pickaxe
    0xFF30,  --- Potato
    0x0F7E,  --- Bones
    0x2D9D,  --- Grimoire
    0x0EED,  --- Gold
    --- (lowest priority)
}

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
            Enable = true,                      --- Bandages player if HP is below BandageSelfHPThreshould or if poisoned and no cure potions
            BandageSelfHPThreshould = 99,       --- in percentage, when to use bandage
            BandageAllies = true,               --- Whether to attempt to bandage allies when player is not in need of bandaging
            BandageAlliesHPThreshould = 90,     --- in percentage, when to use bandage
            AlliesSerials = FriendsSerialList   --- List of allies serials to bandage, if BandageAllies is true
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
            LeatherHuesToKeep = {}
        },
        Scavenging = {
            Enable = false,                             --- Scavenges items from the ground, only arrows, add more if needed
            Frequency = 0,                              --- milliseconds, zero means immediate
            LootItemsSerials = ScavengerLootTable,      --- List of items to scavenge,
            LootItemsNames = {},                        --- Use if serial not available
            DisallowGold = false,                       --- Toggle scavenging gold
            DisallowCleanBandage = false,               --- Toggle scavenging clean bandages
            DisallowBones = false,                      --- Toggle scavenging bones
            DisallowGrimoire = false,                   --- Toggle scavenging grimoires
            DisallowRibs = false                        --- Toggle scavenging ribs
        },
        Attack = {
            Enable = false,                                             --- Attacks nearby enemies automatically
            Rangemax = 10,                                              --- Attack search range
            AllowMobilesExceptionsSerials = true,                       --- Allow Mobiles Serials to ignore
            MobilesExceptionsSerials = FriendsSerialList,               --- Mobiles Serials to ignore (add friends so to not attack should they become grey)
            AllowMobilesExceptionsGraphicIDs = true,                    --- Allow Mobiles Mobiles GraphicIDs to ignore
            MobilesExceptionsGraphicIDs = MobilesExceptionsGraphicIDs,  --- Mobiles GraphicIDs to ignore (don't kill: cows, dogs...)
            AllowMobilesExceptionsNames = true,                         --- Allow Mobiles Mobiles Names to ignore
            MobilesExceptionsNames = MobilesExceptionsNames,            --- Mobiles Names to ignore (use if don't have serial or graphic available)
            CheckFrequency = 500                                        --- in milliseconds, how often to check for new targets, adjust if needed
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

CAConfigDexer_run()
