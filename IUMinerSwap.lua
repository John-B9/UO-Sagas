----------------------------------------------------------------------
--- IU (Item Usage) Miner Swap
--- Author: JohnB9
---
--- Description: Import this if you want to call 'minerSwap' from
---              another script
--- 
---              Swaps between a pickaxe and a warhammer
--- 
---              Accepts:
---               - an accept predicate for the pickaxe item
---               - a callback function, to be run after swap is done
----------------------------------------------------------------------

local ipl = Import('IPLib')
local iusiih = Import('IUSwapItemInHand')

-----------------
--- Variables ---
-----------------

local pickaxe_type_id = 3718
local war_axe_type_id = 5040
local pickaxeAcceptPredicate = nil
local postSwapCallback = nil

-----------------
--- Functions ---
-----------------

local function equipPickaxe_()
    local pickaxe = Items.FindByType(pickaxe_type_id)
    ipl.equipItemWithLessUsesRemaining(pickaxe_type_id, pickaxe.Name, pickaxeAcceptPredicate)
end

MinerWeaponToEquipGraphicID = war_axe_type_id

local function setWeaponToEquipGraphicID_(weaponGraphicID)
    MinerWeaponToEquipGraphicID = weaponGraphicID
end

local function equipWeapon_()
    local weapon = Items.FindByType(MinerWeaponToEquipGraphicID)
    ipl.equipItemWithLessDurability(MinerWeaponToEquipGraphicID, weapon.Name)
    if postSwapCallback then
        Pause(500)
        postSwapCallback()
    end
end

local config = {
    first = { serial = pickaxe_type_id, equip = equipPickaxe_ , acceptPredicate = nil},
    second = { serial = war_axe_type_id, equip = equipWeapon_ , acceptPredicate = nil }
}

local function minerSwap_(pickaxeAcceptPredicate_, callback)
    config.second.serial = MinerWeaponToEquipGraphicID
    config.first.acceptPredicate = pickaxeAcceptPredicate_
    pickaxeAcceptPredicate = pickaxeAcceptPredicate_
    postSwapCallback = callback
    iusiih.swapItemInHand(config, callback)
end

--------------
--- Export ---
--------------

local Obj = {
    setWeaponToEquipGraphicID = setWeaponToEquipGraphicID_,
    minerSwap = minerSwap_
}

return Obj