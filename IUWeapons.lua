----------------------------------------------------------------------
--- IU (Item Usage) Weapons
--- Author: JohnB9
---
--- Description: Import this if you want to call its functions from
---              another script
--- 
---              Utility methods for weapons:
---               - Wrapers for getting equiped weapon properties
---               - Disarm player if weapon in hand durability is low
----------------------------------------------------------------------

local ipl = Import('IPLib')

-----------------
--- Variables ---
-----------------

local limit_durability = 0
local disarm_wait_time = 1000

---------------
-- Functions --
---------------

local function getEquipedShield_()
    local shield = Items.FindByLayer(2)
    if shield and shield.Name and string.find(shield.Name, "Shield") then
        return shield
    end
    return nil
end

local function getEquipedShieldDurabilityPercentage_()
    local shield = getEquipedShield_()
    if not shield then
        return nil
    end
    return ipl.getDurabilityPercentage(shield)
end

local function getEquipedWeapon_()
    local weapon = Items.FindByLayer(1)
    if not weapon then
        local secondHandItem = Items.FindByLayer(2)
        if secondHandItem and secondHandItem.Name and not string.find(secondHandItem.Name, "Shield") then
            weapon = Items.FindByLayer(2)
        end
    end
    return weapon
end

local function getEquipedWeaponDurabilityPercentage_()
    local weapon = getEquipedWeapon_()
    if not weapon then
        return nil
    end
    return ipl.getDurabilityPercentage(weapon)
end

local function getFirstOrSecondHandEquipedItem_()
    local weapon = Items.FindByLayer(1)
    if not weapon then
        weapon = Items.FindByLayer(2)
    end
    return weapon
end

local function disarmPlayerIfWeaponDurabilityBellowThreshould_(durabilityThreshould, disarmWaitTime)
    local disarmedPlayer = false
    local handToUnequip = "left"
    local weapon = getFirstOrSecondHandEquipedItem_()
    if weapon then
        local durability = ipl.getDurability(weapon)[1]
        if ipl.getDurability(weapon)[1] <= durabilityThreshould then
            Player.ClearHands(handToUnequip)
            -- Wait for hands to be cleared
            Pause(disarmWaitTime)
            disarmedPlayer = true
        end
    end
    return disarmedPlayer
end

local function disarmPlayerIfWeaponDurabilityTooLow_()
    return disarmPlayerIfWeaponDurabilityBellowThreshould_(limit_durability, disarm_wait_time)
end

--------------
--- Export ---
--------------

local Obj = {
    getEquipedShield = getEquipedShield_,
    getEquipedShieldDurabilityPercentage = getEquipedShieldDurabilityPercentage_,
    getEquipedWeapon = getEquipedWeapon_,
    getEquipedWeaponDurabilityPercentage = getEquipedWeaponDurabilityPercentage_,
    disarmPlayerIfWeaponDurabilityBellowThreshould = disarmPlayerIfWeaponDurabilityBellowThreshould_,
    disarmPlayerIfWeaponDurabilityTooLow = disarmPlayerIfWeaponDurabilityTooLow_
}

return Obj