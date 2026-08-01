----------------------------------------------------------------------
--- IU (Item Usage) Lumberjack Swap
--- Author: JohnB9
---
--- Description: Import this if you want to call 'lumberjackSwap' from
---              another script
--- 
---              Swaps between a hatchet and an axe
--- 
---              Accepts:
---               - an accept predicate for the hatchet item
---               - a callback function, to be run after swap is done
----------------------------------------------------------------------

local ipl = Import('IPLib')
local iusiih = Import('IUSwapItemInHand')

-----------------
--- Variables ---
-----------------

local hatchet_type_id = 3907
local double_axe_type_id = 3915
local hatchetAcceptPredicate = nil
local postSwapCallback = nil

-----------------
--- Functions ---
-----------------

local function equipHatchet_()
    local hatchet = Items.FindByType(hatchet_type_id)
    local success = ipl.equipItemWithLessUsesRemaining(hatchet_type_id, hatchet.Name, hatchetAcceptPredicate)
end

LumberjackWeaponToEquipGraphicID = double_axe_type_id

local function setWeaponToEquipGraphicID_(weaponGraphicID)
    LumberjackWeaponToEquipGraphicID = weaponGraphicID
end

local function equipWeapon_()
    local weapon = Items.FindByType(LumberjackWeaponToEquipGraphicID)
    local success = ipl.equipItemWithLessDurability(LumberjackWeaponToEquipGraphicID, weapon.Name)
    if postSwapCallback then
        Pause(500)
        postSwapCallback()
    end
end

local config = {
    first = { serial = hatchet_type_id, equip = equipHatchet_, acceptPredicate = nil },
    second = { serial = double_axe_type_id, equip = equipWeapon_, acceptPredicate = nil }
}

local function lumberjackSwap_(hatchetAcceptPredicate_, callback)
    config.second.serial = LumberjackWeaponToEquipGraphicID
    config.first.acceptPredicate = hatchetAcceptPredicate_
    hatchetAcceptPredicate = hatchetAcceptPredicate_
    postSwapCallback = callback
    iusiih.swapItemInHandWithRetry(config, callback)
end

--------------
--- Export ---
--------------

local Obj = {
    setWeaponToEquipGraphicID = setWeaponToEquipGraphicID_,
    lumberjackSwap = lumberjackSwap_
}

return Obj