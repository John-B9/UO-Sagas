local il = Import('IPLib')

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

local limit_durability = 0
local disarm_wait_time = 1000

local function disarmPlayerIfWeaponDurabilityTooLow_()
    return disarmPlayerIfWeaponDurabilityBellowThreshould_(limit_durability, disarm_wait_time)
end

------------
-- Export --
------------

local Obj = {
    disarmPlayerIfWeaponDurabilityBellowThreshould = disarmPlayerIfWeaponDurabilityBellowThreshould_,
    disarmPlayerIfWeaponDurabilityTooLow = disarmPlayerIfWeaponDurabilityTooLow_
}

return Obj