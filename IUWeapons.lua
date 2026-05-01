----------------------------------------------------------------------
--- IU (Item Usage) Weapons
--- Author: JohnB9
---
--- Description: Import this if you want to call its functions from
---              another script
--- 
---              Utility methods for weapons:
---               - Disarm player if weapon in hand durability is low
----------------------------------------------------------------------

local il = Import('IPLib')

-----------------
--- Variables ---
-----------------

local limit_durability = 0
local disarm_wait_time = 1000

---------------
-- Functions --
---------------

local function disarmPlayerIfWeaponDurabilityBellowThreshould_(durabilityThreshould, disarmWaitTime)
    local disarmedPlayer = false
    local handToUnequip = "left"
    local weapon = Items.FindByLayer(1)
    if not weapon then
        handToUnequip = "right"
        weapon = Items.FindByLayer(2)
    end

    if weapon then
        local durability = il.getDurability(weapon)[1]
        if il.getDurability(weapon)[1] <= durabilityThreshould then
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
    disarmPlayerIfWeaponDurabilityBellowThreshould = disarmPlayerIfWeaponDurabilityBellowThreshould_,
    disarmPlayerIfWeaponDurabilityTooLow = disarmPlayerIfWeaponDurabilityTooLow_
}

return Obj