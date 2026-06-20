----------------------------------------------------------------------
--- Combat Assistant (CA) Bandage
--- Author: JohnB9
---
--- Mentions: Halesluker  - Base script
---
--- Version: 1.0.0  - Module separation of Base script
---                 - Handling of low durability:
---                     (Don't destroy your katana!)
---                     Unequips and avoids to re-equip weapon when bellow
---                     threshould to avoid further damage to your weapon
---                 - Handling of inconssistant state
---
--- Description: Disarm detection, disarming and re-arming functions
----------------------------------------------------------------------

local ipl = Import('IPLib')
local cal = Import('CALog')
local cat = Import('CATime')

-----------------
--- Variables ---
-----------------

ArmDisarmConfig = {
    Enable  = false, -- Rearms your weapon if you are disarmed
    AlwaysRearm = false, -- rearm without moving, warning will spam messages if you drag from hands
    AutoRearmOnMove = false,
    AutoRearmWithDelay = false
}

local ArmDisarmStaticConfig = {
    durabilityDisarmThreshould = 0, -- will disarm player and avoid re-arm, if durability <= threshould
    layerOneHanded = 1,
    layerTwoHanded = 2,
    rearmBusrtRequestDelta = 500,
    rearmAtemptDelay = 5000
}

local ArmDisarmState = {
    disarmed = nil,
    disarm = { x = 0, y = 0 },
    lastRightHand = nil,
    lastLeftHand = nil,
    lastRightHandEquipAtemptTime = 0,
    lastLeftHandEquipAtemptTime = 0,
    lastDisarmedTime = 0
}

---------------
--- Setters ---
---------------

local function setEnable_(val)
    ArmDisarmConfig.Enable = val
end

local function setAlwaysRearm_(val)
    ArmDisarmConfig.AlwaysRearm = val
end

local function setConfig_(config)
    setEnable_(config.Enable)
    setAlwaysRearm_(config.AlwaysRearm)
    ArmDisarmConfig.AutoRearmOnMove = config.AutoRearmOnMove
    ArmDisarmConfig.AutoRearmWithDelay = config.AutoRearmWithDelay
end

-----------------
--- Functions ---
-----------------

local function disarmPlayer_()

    if not ArmDisarmConfig.Enable then
        return
    end

    cal.debug("Disarming player...")
    if ArmDisarmState.disarmed then
        cal.debug("Player is already disarmed, skipping disarm.")
        return ArmDisarmState.disarmed
    end

    local disarmState = { weapon = nil, hand = nil }
    local weapon = Items.FindByLayer(2)
    if weapon then
        cal.debug("Clearing right hand...")
        Player.ClearHands("right")
        Pause(cat.getActionWaitTime()) --- Wait for hands to be cleared
    end
    disarmState = { weapon = weapon, hand = function() return Items.FindByLayer(2) end }

    ArmDisarmState.disarmed = disarmState

    return disarmState
end

local function equipWeaponIfDurabilityIsOk_(weapon)

    if not weapon then
        cal.error("No weapon to check...")
        return false
    end

    if not weapon.Properties then
        cal.error("Have weapon, but no weapon properties...")
        return false
    end

    local durability = ipl.getDurability(weapon)
    if durability and durability[1] <= ArmDisarmStaticConfig.durabilityDisarmThreshould then
        cal.warning("Weapon Durability Low")
        return false
    end

    return Player.Equip(weapon.Serial)
end

local function disarmPlayerIfWeaponDurabilityIsLow_(replaceImmediately)

    if not ArmDisarmConfig.Enable then
        return
    end

    cal.debug("Checking right-hand weapon durability...")
    local rightWeapon = Items.FindByLayer(ArmDisarmStaticConfig.layerOneHanded)
    if rightWeapon and rightWeapon.Properties then
        cal.debug("Have valid right-hand weapon: "..rightWeapon.Name)
        local durability = ipl.getDurability(rightWeapon)
        if durability and durability[1] <= ArmDisarmStaticConfig.durabilityDisarmThreshould then
            cal.debug("Right-hand weapon durability low, disarming...")
            Player.ClearHands("left")
            local clearState = true
            if replaceImmediately then
                local replaceWeapon = ipl.getItemWithMostDurability(rightWeapon.Graphic)
                local replaceWeaponDurability = replaceWeapon~=nil and ipl.getDurability(replaceWeapon)
                cal.debug("Replace weapon: "..((replaceWeapon~=nil and ("found ("..replaceWeapon.Name..")")) or " not found..."))
                cal.debug("Replace weapon durability: "..((replaceWeapon~=nil and replaceWeaponDurability~=nil and replaceWeaponDurability[1]) or " not found..."))
                if replaceWeapon and replaceWeaponDurability and replaceWeaponDurability[1] > ArmDisarmStaticConfig.durabilityDisarmThreshould then
                    Pause(2*cat.getActionWaitTime())
                    equipWeaponIfDurabilityIsOk_(replaceWeapon)
                    ArmDisarmState.lastRightHand = replaceWeapon
                    clearState = false
                end
            end
            if clearState then
                ArmDisarmState.lastRightHand = nil
                ArmDisarmState.disarm.x = 0
                ArmDisarmState.disarm.y = 0
            end
            Pause(cat.getActionWaitTime())
        end
    else
        if rightWeapon then
            cal.debug("Have valid Properties in item")
        else
            cal.debug("No valid right-hand weapon found")
        end
    end

    cal.debug("Checking left-hand weapon durability...")
    local leftWeapon = Items.FindByLayer(ArmDisarmStaticConfig.layerTwoHanded)
    --- local two_different_weapons = not rightWeapon or (rightWeapon.Serial ~= leftWeapon.Serial)
    if leftWeapon and leftWeapon.Properties then
        cal.debug("Have valid left-hand weapon: "..leftWeapon.Name)
        local durability = ipl.getDurability(leftWeapon)
        if durability and durability[1] <= ArmDisarmStaticConfig.durabilityDisarmThreshould then
            cal.debug("Left-hand weapon durability low, disarming...")
            Player.ClearHands("right")
            local clearState = true
            if replaceImmediately then
                local replaceWeapon = ipl.getItemWithMostDurability(leftWeapon.Graphic)
                local replaceWeaponDurability = replaceWeapon~=nil and ipl.getDurability(replaceWeapon)
                cal.debug("Replace weapon: "..((replaceWeapon~=nil and ("found ("..replaceWeapon.Name..")")) or " not found..."))
                cal.debug("Replace weapon durability: "..((replaceWeapon~=nil and replaceWeaponDurability~=nil and replaceWeaponDurability[1]) or " not found..."))
                if replaceWeapon and replaceWeaponDurability and replaceWeaponDurability[1] > ArmDisarmStaticConfig.durabilityDisarmThreshould then
                    Pause(2*cat.getActionWaitTime())
                    equipWeaponIfDurabilityIsOk_(replaceWeapon)
                    ArmDisarmState.lastLeftHand = replaceWeapon
                    clearState = false
                end
            end
            if clearState then
                ArmDisarmState.lastRightHand = nil
                ArmDisarmState.disarm.x = 0
                ArmDisarmState.disarm.y = 0
            end
            Pause(cat.getActionWaitTime())
        end
    else
        if leftWeapon then
            cal.debug("Have valid Properties in item")
        else
            cal.debug("No valid left-hand weapon found")
        end
    end
end

local function rearmPlayer_()

    if not ArmDisarmConfig.Enable then
        return
    end

    if not ArmDisarmState.disarmed or not ArmDisarmState.disarmed.weapon then
        cal.debug("Player is not disarmed, skipping rearm.")
        return
    end

    cal.debug("Rearming player...")
    while ArmDisarmState.disarmed.hand() == nil do
        if equipWeaponIfDurabilityIsOk_(ArmDisarmState.disarmed.weapon) then
            Pause(cat.getActionWaitTime()) -- Wait for weapon to be equipped
        end
        --Player.Equip(ArmDisarmState.disarmed.weapon.Serial)
        --Pause(cat.getActionWaitTime()) -- Wait for weapon to be equipped
    end

    ArmDisarmState.disarmed = nil
end

local function checkAndFixItemsErrorState_()

    --- Check only when not Player.IsHidden
    if Player.IsHidden then
        return
    end

    --- In some situaions, Items.FindByLayer returns an Items
    --- but it will have no "Properties", which leaves us in and
    --- error state, where we can't re-equip
    ---
    --- This hapens when
    ---  - player is hiden and becomes revealed
    ---
    --- To handle this, we'll unequip and re-equip both hands
    ---
    local rightHand = Items.FindByLayer(ArmDisarmStaticConfig.layerOneHanded)
    local leftHand = Items.FindByLayer(ArmDisarmStaticConfig.layerTwoHanded)
    local clientStartErrorState = (rightHand and not rightHand.Properties) or (leftHand and not leftHand.Properties)
    if clientStartErrorState and (rightHand or leftHand) then

        cal.warning("Found inconssistant state, re-equiping both hand to recover state...")

        --- clear both hands
        Player.ClearHands("both")
        Pause(cat.getActionWaitTime()) --- Wait for hands to be cleared

        --- re-equip righ
        if rightHand then
            ---if not equipWeaponIfDurabilityIsOk_(rightHand) then
            ---    ArmDisarmState.lastRightHand = nil
            ---end
            Player.Equip(rightHand.Serial)
            Pause(cat.getActionWaitTime()) --- Wait for hands to be cleared
        end

        --- re-equip left is not same weapon (twohanded case)
        if leftHand and ((not rightHand) or (leftHand.Serial ~= rightHand.Serial)) then
            ---if not equipWeaponIfDurabilityIsOk_(leftHand) then
            ---    ArmDisarmState.lastLeftHand = nil
            ---end
            Player.Equip(leftHand.Serial)
            Pause(cat.getActionWaitTime()) --- Wait for hands to be cleared
        end

        cal.warning("Found inconssistant re-arm state: correction complete.")
        disarmPlayerIfWeaponDurabilityIsLow_(true)
    end
end

local function disarmed_()

    if not ArmDisarmConfig.Enable then
        return
    end

    cal.debug("Disarm detection running")
    checkAndFixItemsErrorState_()

    if ArmDisarmState.lastRightHand == nil then
        local rightHand = Items.FindByLayer(ArmDisarmStaticConfig.layerOneHanded)
        if not rightHand then
            cal.debug("No weapon in right hand")
        else
            ArmDisarmState.lastRightHand = rightHand
            cal.debug("Weapon " .. (rightHand.Name or "No Weapon Name") .. " used as right hand")
        end
    else
        local rightHand = Items.FindByLayer(ArmDisarmStaticConfig.layerOneHanded)
        if rightHand and rightHand.Serial ~= ArmDisarmState.lastRightHand.Serial then
            cal.debug("Right hand weapon changed from: " .. (ArmDisarmState.lastRightHand.Name or "No Weapon Name") .. " to: "
            .. (rightHand.Name or "No Weapon Name"))
            -- Since user changed weapon we are not disarmed and need to reset both hands in case of two hander
            ArmDisarmState.lastRightHand = nil
            ArmDisarmState.lastLeftHand = nil
            ArmDisarmState.disarm.x = 0
            ArmDisarmState.disarm.y = 0
        end
    end

    if ArmDisarmState.lastLeftHand == nil then
        local leftHand = Items.FindByLayer(ArmDisarmStaticConfig.layerTwoHanded)
        if not leftHand then
            cal.debug("No weapon in left hand")
        else
            ArmDisarmState.lastLeftHand = leftHand
            cal.debug("Weapon " .. (leftHand.Name or "No Weapon Name") .. " used as left hand")
        end
    else
        local leftHand = Items.FindByLayer(ArmDisarmStaticConfig.layerTwoHanded)
        if leftHand and leftHand.Serial ~= ArmDisarmState.lastLeftHand.Serial then
            cal.debug("Left hand weapon changed from: " .. (ArmDisarmState.lastLeftHand.Name or "No Weapon Name") .. " to: "
            .. (leftHand.Name or "No Weapon Name"))
            -- Since user changed weapon we are not disarmed and need to reset both hands in case of two hander
            ArmDisarmState.lastLeftHand = nil
            ArmDisarmState.lastRightHand = nil
            ArmDisarmState.disarm.x = 0
            ArmDisarmState.disarm.y = 0
        end
    end

    local isDisarmed = ArmDisarmState.disarm.x > 0 or ArmDisarmState.disarm.y > 0
    local playerMoved = (Player.X ~= ArmDisarmState.disarm.x or Player.Y ~= ArmDisarmState.disarm.y)
    cal.debug("isDisarmed = "..tostring(isDisarmed)..", playerMoved = "..tostring(playerMoved)..", Player.X = "..Player.X..
    ", Player.y = "..Player.X..", disarm.x = "..ArmDisarmState.disarm.x..", disarm.y = "..ArmDisarmState.disarm.y)

    local autoRearmTimerExpired = false
    if isDisarmed and ArmDisarmConfig.AutoRearmWithDelay then
        local currentTickTime = cat.getCurrentTickTime()
        ---cal.mainInfo("Equipping right hand")
        if ArmDisarmState.lastDisarmedTime == 0 then
            cal.warning("Rearming in "..(ArmDisarmStaticConfig.rearmAtemptDelay / 1000).."s")
            ArmDisarmState.lastDisarmedTime = currentTickTime
        end
    end

    if ArmDisarmState.lastDisarmedTime ~= 0 and cat.exceedsDuration(ArmDisarmState.lastDisarmedTime, currentTickTime, ArmDisarmStaticConfig.rearmAtemptDelay) then
        ArmDisarmState.lastDisarmedTime = 0
        if isDisarmed then
            cal.info("Rearming now...")
            autoRearmTimerExpired = true
        else
            cal.info("Weapon already equiped...")
        end
    end

    local atemptRearmPlayer = isDisarmed and (ArmDisarmConfig.AlwaysRearm or (ArmDisarmConfig.AutoRearmOnMove and playerMoved) or autoRearmTimerExpired)
    if atemptRearmPlayer then
    ---if isDisarmed and (ArmDisarmConfig.AlwaysRearm or playerMoved) then

        --- Right hand
        local alreadyHasRightHand = Items.FindByLayer(ArmDisarmStaticConfig.layerOneHanded)
        if alreadyHasRightHand then
            cal.debug("Weapon " .. ((ArmDisarmState.lastRightHand and ArmDisarmState.lastRightHand.Name) or "No Weapon Name") .. " already equipped in right hand")
        end

        local canEquipRightHand = not alreadyHasRightHand and ArmDisarmState.lastRightHand and ArmDisarmState.lastRightHand.Serial
        if canEquipRightHand then
            cal.debug("Trying to re-equip right hand weapon: " ..
            ((ArmDisarmState.lastRightHand and ArmDisarmState.lastRightHand.Name) or "No Weapon Name"))
            ---@diagnostic disable-next-line: need-check-nil
            if equipWeaponIfDurabilityIsOk_(ArmDisarmState.lastRightHand) then
                --if Player.Equip(ArmDisarmState.lastRightHand.Serial) then
                cal.info("Equipping right hand")
                ArmDisarmState.disarm.x = 0
                ArmDisarmState.disarm.y = 0
                ---lastDisarmRightHand = nil -- To refresh serial
                Pause(cat.getActionWaitTime()) -- Wait to allow the weapon to equip
            else
                cal.warning("Equipping right hand failed")
                local currentTickTime = cat.getCurrentTickTime()
                if ArmDisarmState.lastRightHandEquipAtemptTime ~= 0 and not cat.exceedsDuration(ArmDisarmState.lastRightHandEquipAtemptTime, currentTickTime, ArmDisarmStaticConfig.rearmBusrtRequestDelta) then
                    cal.warning("Found inconssistant state, canceling...")
                    ArmDisarmState.lastRightHand = nil
                    ArmDisarmState.disarm.x = 0
                    ArmDisarmState.disarm.y = 0
                end
                ArmDisarmState.lastRightHandEquipAtemptTime = currentTickTime
            end
        end

        --- Left hand
        local alreadyHasLeftHand = Items.FindByLayer(ArmDisarmStaticConfig.layerTwoHanded)
        if alreadyHasLeftHand then
            cal.debug("Weapon " ..
            ((ArmDisarmState.lastLeftHand and ArmDisarmState.lastLeftHand.Name) or "No Weapon Name") .. " already equipped in left hand")
        end

        local canEquipLeftHand = not alreadyHasLeftHand and ArmDisarmState.lastLeftHand and ArmDisarmState.lastLeftHand.Serial
        if canEquipLeftHand then
            cal.debug("Trying to re-equip left hand weapon: " .. ((ArmDisarmState.lastLeftHand and ArmDisarmState.lastLeftHand.Name) or "No Weapon Name"))
            ---@diagnostic disable-next-line: need-check-nil
            ---if Player.Equip(ArmDisarmState.lastLeftHand.Serial) then
            if equipWeaponIfDurabilityIsOk_(ArmDisarmState.lastLeftHand) then
                cal.info("Equipping left hand")
                ArmDisarmState.disarm.x = 0
                ArmDisarmState.disarm.y = 0
                ---lastDisarmLeftHand = nil --- To refresh serial
                Pause(cat.getActionWaitTime())
            else
                cal.warning("Equipping left hand failed")
                local currentTickTime = cat.getCurrentTickTime()
                if ArmDisarmState.lastLeftHandEquipAtemptTime ~= 0 and not cat.exceedsDuration(ArmDisarmState.lastLeftHandEquipAtemptTime, currentTickTime, ArmDisarmStaticConfig.rearmBusrtRequestDelta) then
                    cal.warning("Found inconssistant state, canceling...")
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
                cal.warning("Right hand disarmed, move to equip")
            end
            ArmDisarmState.disarm.x = Player.X
            ArmDisarmState.disarm.y = Player.Y
        elseif ArmDisarmState.lastLeftHand and not Items.FindByLayer(ArmDisarmStaticConfig.layerTwoHanded) then
            if ArmDisarmConfig.AutoRearmOnMove then
                cal.warning("Left hand disarmed, move to equip")
            end
            ArmDisarmState.disarm.x = Player.X
            ArmDisarmState.disarm.y = Player.Y
        end
    end
end

--------------
--- Export ---
--------------

local Obj = {
    setEnable = setEnable_,
    setAlwaysRearm = setAlwaysRearm_,
    setConfig = setConfig_,
    disarmPlayerIfWeaponDurabilityIsLow = disarmPlayerIfWeaponDurabilityIsLow_,
    disarmPlayer = disarmPlayer_,
    rearmPlayer = rearmPlayer_,
    disarmed = disarmed_
}

return Obj