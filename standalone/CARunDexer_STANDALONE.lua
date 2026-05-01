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
    EnableDebugTick = false,
    DebugTick = 500,
    EnableOverheadMessages = false
}

CAConfigDexer_CAMainLoop_CALog_LogStaticConfig = {
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
        color = CAConfigDexer_CAMainLoop_CALog_LogStaticConfig.InfoTextColor
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
    CALog_overhead(text, CAConfigDexer_CAMainLoop_CALog_LogStaticConfig.InfoTextColor, true)
end

function CALog_info(text)
    CALog_overhead(text, CAConfigDexer_CAMainLoop_CALog_LogStaticConfig.InfoTextColor, false)
end

function CALog_warning(text)
    CALog_overhead(text, CAConfigDexer_CAMainLoop_CALog_LogStaticConfig.WarningTextColor, false)
end

function CALog_error(text)
    CALog_overhead(text, CAConfigDexer_CAMainLoop_CALog_LogStaticConfig.ErrorTextColor, false)
end

function CALog_debug(text)

    if not LogConfig.EnableDebugLog then
        return
    end

    local ok, timestamp = pcall(function()
        return os.date(CAConfigDexer_CAMainLoop_CALog_LogStaticConfig.DatePattern, os.time()) .. "." .. string.format("%03d", os.time() * 1000 % 1000)
    end)

    if not ok then
        timestamp = os.time()
    end

    if LogConfig.EnableDebugTick and LogConfig.DebugTick > LogConfig.DebugLogTick then
        Pause(LogConfig.DebugTick - LogConfig.DebugLogTick)
    end

    Console.log("[" .. timestamp .. "] " .. text, CAConfigDexer_CAMainLoop_CALog_LogStaticConfig.DebugTextColor)
end

TimeConfig = {
    ActionWaitTime = 1000,
}

TimeState = {
    currentTickTime = math.floor(os.time() * 1000),
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

function BaseLib_printIfDebug(debug, stringToPrint)
    if debug then
        Console.debug(stringToPrint)

    end
end

function BaseLib_getHpPercentage()
    return (Player.Hits / Player.HitsMax) * 100
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

durability_regex_str = "Durability: (%d+)/(%d+)"
function IPLib_getDurability(item)
    return IPLib_getItemDoubleValueProperty(item, durability_regex_str)
end

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

function IPLib_equipItemWithLessDoublePropertyFirstValue(itemID, fieldStr, itemName)
    local itemToEquip = IPLib_getItemWithLessDoublePropertyFirstValue(itemID, fieldStr)
    if itemToEquip == nil then
        Messages.Print("Missing " .. itemName .. "...", 69, Player.Serial)
        return nil
    end
    Player.Equip(itemToEquip.Serial)
    return itemToEquip
end

function IPLib_equipItemWithLessDurability(itemID, itemName)
    return IPLib_equipItemWithLessDoublePropertyFirstValue(itemID, durability_regex_str, itemName)
end

ArmDisarmConfig = {
    Enable  = false,
    AlwaysRearm = false
}

ArmDisarmStaticConfig = {
    durabilityDisarmThreshould = 0,
    layerOneHanded = 1,
    layerTwoHanded = 2,
    rearmBusrtRequestDelta = 500
}

ArmDisarmState = {
    disarmed = nil,
    disarm = { x = 0, y = 0 },
    lastRightHand = nil,
    lastLeftHand = nil,
    lastRightHandEquipAtemptTime = 0,
    lastLeftHandEquipAtemptTime = 0
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

function CAArmDisarm_disarmPlayerIfWeaponDurabilityIsLow()

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
            ArmDisarmState.lastRightHand = nil
            ArmDisarmState.disarm.x = 0
            ArmDisarmState.disarm.y = 0
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
            ArmDisarmState.lastLeftHand = nil
            ArmDisarmState.disarm.x = 0
            ArmDisarmState.disarm.y = 0
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
        CAArmDisarm_disarmPlayerIfWeaponDurabilityIsLow()
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

    if isDisarmed and (ArmDisarmConfig.AlwaysRearm or playerMoved) then

        alreadyHasRightHand = Items.FindByLayer(ArmDisarmStaticConfig.layerOneHanded)
        if alreadyHasRightHand then
            CALog_debug("Weapon " ..
            ((ArmDisarmState.lastRightHand and ArmDisarmState.lastRightHand.Name) or "No Weapon Name") .. " already equipped in right hand")
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
            CALog_warning("Right hand disarmed, move to equip")
            ArmDisarmState.disarm.x = Player.X
            ArmDisarmState.disarm.y = Player.Y
        elseif ArmDisarmState.lastLeftHand and not Items.FindByLayer(ArmDisarmStaticConfig.layerTwoHanded) then
            CALog_warning("Left hand disarmed, move to equip")
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
    Command = "I shall return!",
    Callback = function()
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
        Duration = (300 + math.ceil(Skills.GetValue("Alchemy")*10)*3 + 1) * 1000,
        CheckFrequency = 5000
    },
    GreaterStrength = {
        Name = "Greater Stength",
        Duration = (120 + math.floor(Skills.GetValue("Alchemy"))*6 + 1) * 1000,
        Buff = 20 + math.floor(Skills.GetValue("Alchemy"))/10,
        CheckFrequency = 5000
    },
    GreaterAgility = {
        Name = "Greater Agility",
        Duration = (120 + math.floor(Skills.GetValue("Alchemy"))*6 + 1) * 1000,
        Buff = 20 + math.floor(Skills.GetValue("Alchemy"))/10,
        CheckFrequency = 5000
    },
    GreaterHeal = {
        Name = "Greater Heal",
        DrinkCooldown = 15 * 1000
    },
    GreaterCure = {
        Name = "Greater Cure"
    }
}

CAPotionsHealing_CAPotionsTime_PotionsTimeState = {
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
    return CAPotionsTime_shouldAtemptToDrink(CAPotionsHealing_CAPotionsTime_PotionsTimeStaticConfig.Nightsight, CAPotionsHealing_CAPotionsTime_PotionsTimeState.Nightsight, lastDrinkTime)
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
    Enable = false,
    HPDrinkThreshould = 20
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
    playerHpPercentage = BaseLib_getHpPercentage()
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
    ColldownTime = 1000
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
    Enable = false,
    BandageHP = 99
}

CABandage_BandageStaticConfig = {
    Bandages = { 0x00e21 },
    OverheadPauseTime = 0,
    WarningPauseTime = 60 * 1000
}

CABandage_BandageState = {
    lastOverheadTime = 0,
    isBandaging = false,
    bandageTimeEnd = nil
}

function CABandage_setEnable(val)
    BandageConfig.Enable = val
end

function CABandage_setBandageHP(val)
    BandageConfig.BandageHP = val
end

function CABandage_setConfig(config)
    CABandage_setEnable(config.Enable)
    CABandage_setBandageHP(config.BandageHP)
end

function CABandage_bandageEndTime(start)
    local delayMs = math.ceil((9.0 + 0.85 * ((130 - Player.Dex) / 20)) * 1000)
    local baseTime = start or CATime_getCurrentTickTime() or math.floor(os.time() * 1000)
    return baseTime + delayMs
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

    if CABandage_BandageState.isBandaging then
        CALog_debug("Already healing, skipping bandage.")
        timeLeft = CABandage_BandageState.bandageTimeEnd - currentTickTime

        if timeLeft > 0 and CABandage_BandageStaticConfig.OverheadPauseTime > 0  then
            if CATime_exceedsDuration(CABandage_BandageState.lastOverHeadTime, currentTickTime, CABandage_BandageStaticConfig.OverheadPauseTime) then
                countdown = math.floor(timeLeft / 1000)
                if countdown >= 1 then
                    CALog_info("Bandaging " .. countdown .. "s")
                end
                CABandage_BandageState.lastOverHeadTime = currentTickTime
            end
        end

        if currentTickTime > CABandage_BandageState.bandageTimeEnd then
            CABandage_BandageState.isBandaging = false
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
        CABandage_BandageState.bandageTimeEnd = CABandage_bandageEndTime(currentTickTime)
        CABandage_BandageState.isBandaging = true
        return
    end

    playerHpPercentage = BaseLib_getHpPercentage()

    if not Player.IsPoisoned and (playerHpPercentage >= BandageConfig.BandageHP) then
        CALog_debug("Player not poisoned or HP is above threshold, no bandage needed.")
        return
    end

    if Player.IsPoisoned and CABandage_BandageState.useBandages then
        CALog_debug("Using bandages due to previous poison.")
        info("Curing with bandage")
        CABandage_BandageState.useBandages = false
    end

    CALog_debug("Looing for bandages...")
    bandages = BaseLib_findInInventory(CABandage_BandageStaticConfig.Bandages)

    if not bandages or #bandages == 0 then
        if CATime_exceedsDuration(CABandage_BandageState.lastOverheadTime, currentTickTime, CABandage_BandageStaticConfig.WarningPauseTime) then
            CALog_warning("No bandages found")
            CABandage_BandageState.lastOverheadTime = currentTickTime
        end
        return
    end

    CALog_debug("Attempting to bandage...")

    bandageCount = #bandages > 1 and #bandages or 1
    CALog_debug("Bandaging with " .. bandageCount .. " bandage(s)...")

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

        if Target.Self() then
            isBandagingSuccessful = true
            break
        end

        :: continue ::
    end

    if not isBandagingSuccessful then
        CALog_debug("Failed to bandage, the bandages found are probably in bank?")
        return
    end

    bandaging = CATime_pauseUntil(function()
        return Journal.Contains("You begin applying the bandages.")
    end, 50, 500)

    if not bandaging then
        CABandage_BandageState.isBandaging = false
        CABandage_BandageState.lastBandageStart = nil
        return
    end

    CALog_debug("Bandaging")

    if CABandage_BandageStaticConfig.OverheadPauseTime == 0 then
        CALog_info("Bandaging...")
        CABandage_BandageState.lastOverHeadTime = currentTickTime
    end

    CABandage_BandageState.isBandaging = bandaging
    CABandage_BandageState.lastBandageStart = currentTickTime
    CABandage_BandageState.bandageTimeEnd = CABandage_bandageEndTime(CABandage_BandageState.lastBandageStart)
end

SongOfHealingConfig = {
    Enable = false,
    FailWait = 30 * 1000,
    Instruments = {"Drum", "Lute", "Tambourine", "Lap Harp" }
}

CABuffs_CASongOfHealing_SongOfHealingState = {
    isActive = false,
    startTime = nil,
    endTime = nil,
    duration = 163 * 1000,
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
    if CABuffs_CASongOfHealing_SongOfHealingState.isActive then
        if currentTickTime > CABuffs_CASongOfHealing_SongOfHealingState.endTime then
            CABuffs_CASongOfHealing_SongOfHealingState.isActive = false
            CALog_debug("Song of Healing ended.")
            return
        end
        CALog_debug("Waiting for Song of Healing to end in: " ..
        ((CABuffs_CASongOfHealing_SongOfHealingState.endTime - currentTickTime) / 1000) .. " seconds.")
        return
    end

    if recentCast() then
        CALog_debug("Buff was recently cast, wait to retry")
        CABuffs_CASongOfHealing_SongOfHealingState.isActive = true
        CABuffs_CASongOfHealing_SongOfHealingState.startTime = currentTickTime
        recastWaitTime = 8
        CABuffs_CASongOfHealing_SongOfHealingState.endTime = CABuffs_CASongOfHealing_SongOfHealingState.startTime + recastWaitTime
        return
    end

    if not CABuffs_CASongOfHealing_SongOfHealingState.instrument then
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

        CABuffs_CASongOfHealing_SongOfHealingState.instrument = instrument
    end

    CALog_debug("Casting Song of Healing...")
    if not Spells.Cast("SongOfHealing") then
        if CATime_exceedsDuration(CABuffs_CASongOfHealing_SongOfHealingState.lastWarningTickTime, currentTickTime, SongOfHealingConfig.FailWait) then
            CALog_info("Recasting Song of Healing")
            CALog_debug("Failed to cast Song of Healing, waiting " .. (SongOfHealingConfig.FailWait / 1000) .. " seconds to retry.")
            CABuffs_CASongOfHealing_SongOfHealingState.lastWarningTickTime = currentTickTime
        end
        startBuff(CABuffs_CASongOfHealing_SongOfHealingState, SongOfHealingConfig.FailWait)
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
            CABuffs_CASongOfHealing_SongOfHealingState.instrument = nil
            return false
        end
        return false
    end, 50, CATime_getActionWaitTime())

    if not castSuccess then
        if CATime_exceedsDuration(CABuffs_CASongOfHealing_SongOfHealingState.lastWarningTickTime, currentTickTime, SongOfHealingConfig.FailWait) then
            CALog_info("Recasting Song of Healing")
            CALog_debug("Journal did not contain expectations for Song of Healing, waiting " .. (SongOfHealingConfig.FailWait / 1000)
            .. " seconds to retry.")
            CABuffs_CASongOfHealing_SongOfHealingState.lastWarningTickTime = currentTickTime
        end
        startBuff(CABuffs_CASongOfHealing_SongOfHealingState, SongOfHealingConfig.FailWait)
        return
    end

    startBuff(CABuffs_CASongOfHealing_SongOfHealingState, CABuffs_CASongOfHealing_SongOfHealingState.duration)
    CALog_info("Casted Song of Healing")
    CALog_debug("Song of Healing started.")
end

NightsightPotionsConfig = {
    Enable = false
}

CAPotionsNightsight_NightsightPotionsStaticConfig = {
    Potion = 0x0f06,
    Name = "Nightsight"
}

CAPotionsNightsight_NightsightPotionsState = {
    lastDrinkTime = nil
}

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
        CALog_error("We'll disable the auto nightsight buff... Just relaunch the combat bot once the current night sight expires")
        CALog_debug("Already under nightsight effect, disabling auto-buff")
        CAPotionsNightsight_setEnable(false)
    end
    return potionDrinkState == DrinkAtemptResult.DRANK_POTION
end

StaminaPotionsConfig = {
    Enable = false,
    DrinkThreshould = 30
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
    EatCooldown = 15 * 60 * 1000,
    BuffFoods = {
        65340,
        65342
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
    Enable = false
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
    Enable = false
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
    AlertPauseTime = 10 * 1000
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
    Frequency = 0,
    Items = {
        0x0F3F,
        0x1BFB
    }
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

function CAScavenge_setItems(val)
    ScavengeConfig.Items = val
end

function CAScavenge_setConfig(config)
    CAScavenge_setEnable(config.Enable)
    CAScavenge_setFrequency(config.Frequency)
    CAScavenge_setItems(config.Items)
end

function CAScavenge_scavenge()

    if not ScavengeConfig.Enable then
        return
    end

    currentTickTime = CATime_getCurrentTickTime()

    if not CATime_exceedsDuration(CAScavenge_ScavengeState.lastTickTime, currentTickTime, ScavengeConfig.Tick) then
        CALog_debug("Scavenging is not ready yet, skipping this tick.")
        return
    end

    CALog_debug("Trying to scavenge...")

    CAScavenge_ScavengeState.lastTickTime = currentTickTime

    filter = { onground = true, rangemax = 2, graphics = ScavengeConfig.items }
    list = Items.FindByFilter(filter)

    for _, item in ipairs(list) do
        if not Player.PickUp(item.Serial, 1000) then
            CALog_debug("Scavenging failed to pick up item: " .. (item.Name or "No Item Name"))
            goto continue
        end

        Pause(250)

        if not Player.DropInBackpack() then
            CALog_debug("Scavenging failed to drop item in backpack: " .. (item.Name or "No Item Name"))
            goto continue
        end

        CALog_debug("Scavenged item: " .. (item.Name or "No Item Name"))
        Pause(250)

        ::continue::
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

function IPMaterialPredicates_itemIsOfCopper(item)
    local itemMaterial = IPLib_getMaterial(item)
    BaseLib_printIfDebug(true, itemMaterial)
    if itemMaterial == "Copper" then
        return true
    end
    return false
end

IUMinerSwap_IUSwapItemInHand_debugEnabled = true

function IUSwapItemInHand_swapItemInHand(config, callback)

    local first_item = Items.FindByType(config.first.serial)
    local second_item = Items.FindByType(config.second.serial)

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

config = {
    first = { serial = pickaxe_type_id, equip = IUMinerSwap_equipPickaxe , acceptPredicate = nil},
    second = { serial = war_axe_type_id, equip = IUMinerSwap_equipWarAxeAndFight , acceptPredicate = nil }

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

IUSkinn_messageHue = 42
IUSkinn_skinning_knife_type_id = 65193

function IUSkinn_useSkinningKnife(callback)

    local skinning_knife = Items.FindByType(IUSkinn_skinning_knife_type_id)
    if skinning_knife == nil then
        Messages.Overhead("Missing Skinning Knife", IUSkinn_messageHue, Player.Serial)
    else
        local best_skinning_knife = IPLib_getItemWithLessUsesRemaining(IUSkinn_skinning_knife_type_id, nil)
        Player.UseObject(best_skinning_knife.Serial)
    end

    Pause(1000)
    if callback then
        callback()
    end

end

function IUScissors_useScissors(callback)
    local scissors = Items.FindByName('Scissors')
    Player.UseObject(scissors.Serial)
    Pause(1000)
    if callback then
        callback()
    end
end

function IUIDWand_useIdWand(callback)

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
    CommandStringPrefix = ""

}

UserTriggeredCommandsStaticConfig = {

}

UserTriggeredCommandsState = {
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
    IUSkinn_useSkinningKnife(nil)
end

function CAUserTriggeredCommands_useScissors()
    IUScissors_useScissors(nil)
end

function CAUserTriggeredCommands_useIdWand()
    IUIDWand_useIdWand(nil)
end

Commands = {
    { Keyword = "Miner Swap Iron", Callback = CAUserTriggeredCommands_minerSwapIron },
    { Keyword = "Miner Swap Copper", Callback = CAUserTriggeredCommands_minerSwapCopper },
    { Keyword = "Lumberjack Swap Iron", Callback = CAUserTriggeredCommands_lumberjackSwapIron },
    { Keyword = "Lumberjack Swap Copper", Callback = CAUserTriggeredCommands_lumberjackSwapCopper },
    { Keyword = "Skinn", Callback = CAUserTriggeredCommands_useSkinningKnife },
    { Keyword = "Scissors", Callback = CAUserTriggeredCommands_useScissors },
    { Keyword = "ID Wand", Callback = CAUserTriggeredCommands_useIdWand }
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

MainLoopConfig = {
    EnableCancel = false
}

MainLoopState = {
    lastJournalTickTime = 0
}

CancelConfig = {
    Command = "I Yeld!",
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
    CAScavenge_setConfig(config.modules.Scavenging)
end

function CAMainLoop_configure(config)
    MainLoopConfig.EnableCancel = config.EnableCancel
    CATime_setActionWaitTime(config.time.ActionWaitTime)
    CALog_setConfig(config.debug)
    CAMainLoop_configureModules(config)
    CAUserTriggeredCommands_setConfig(config.userCommands)
end

function CAMainLoop_journalDependantActions()
    CAArmDisarm_disarmPlayerIfWeaponDurabilityIsLow()
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
    CAScavenge_scavenge()
    CAEscape_moongate()
end

function CAMainLoop_mainLoop(config)

    CAMainLoop_configure(config)
    CALog_mainInfo("Sagas Combat Assistant")
    CALog_debug("Sagas Combat Assistant - Started")

    Journal.Clear()

    while true do

        local newTickTime = CATime_updateCurrentTickTime()
        CALog_debug("Main tick loop start")

        if Player.IsDead then
            CALog_debug("Player is dead, skipping main loop.")
            goto mainloopend
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
        :: mainloopend ::
        Journal.Clear()
        Pause(config.time.MainLoopTick)
    end
end

DexerMainLoopConfig = {
    EnableCancel = false,
    time = {
        ActionWaitTime = 1000,

        MainLoopTick = 60,
        JournalTick = 0,
    },
    debug = {
        EnableDebugLog = true,
        DebugLogTick = 60,
        EnableDebugTick = false,
        DebugTick = 500,
        EnableOverheadMessages = false
    },
    modules = {
        ArmDisarm = {
            Enable = true,
            AlwaysRearm = false
        },
        Escape = {
            EnablePopPouch = true,
            EnableComand = false,
            EnableMoongate = true
        },
        CurePotions = {
            Enable = true,
            ColldownTime = 1000
        },
        HealingPotions = {
            Enable = true,
            HPDrinkThreshould = 20
        },
        Bandages = {
            Enable = true,
            BandageHP = 99
        },
        Buffs = {
            Enable = true,
            SongOfHealing = {
                Enable = false,
                FailWait = 30 * 1000,
                Instruments = {"Drum", "Lute", "Tambourine", "Lap Harp" }
            },
            Nightsight = {
                Enable = true
            },
            Stamina = {
                Enable = true,
                DrinkThreshould = 30
            },
            Strength = {
                Enable = true,
                BaseStrength = 100,
                DrinkHeal = true
            },
            Agility = {
                Enable = true,
                BaseAgility = 81,
                DrinkRefresh = true
            },
            EatFood = {
                Enable = true
            }
        },
        Debuffs = {
            Enable = false,
            Peacemaking = {
                Enable = false
            }
        },
        DetectPlayers = {
            Enable = false
        },
        Scavenging = {
            Enable = false,
            Frequency = 0,
            Items = {
                0x0F3F,
                0x1BFB
            }
        }
    },
    userCommands = {
        Enable = true,
        CommandStringPrefix = "(DEXER)"
    }
}

function CAConfigDexer_run()
    CAMainLoop_mainLoop(DexerMainLoopConfig)
end

-- End of: CAConfigDexer
-- ========================================

CAConfigDexer_run()
