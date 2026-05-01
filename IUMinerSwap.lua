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
local war_hammer_type_id = 5177
local pickaxeAcceptPredicate = nil
local postSwapCallback = nil

-----------------
--- Functions ---
-----------------

local function equipPickaxe_()
    local pickaxe = Items.FindByType(pickaxe_type_id)
    ipl.equipItemWithLessUsesRemaining(pickaxe_type_id, pickaxe.Name, pickaxeAcceptPredicate)
end

local function equipWarAxeAndFight_()
    local war_axe = Items.FindByType(war_axe_type_id)
    ipl.equipItemWithLessDurability(war_axe_type_id, war_axe.Name)
    if postSwapCallback then
        Pause(500)
        postSwapCallback()
    end
end

local function equipWarHammerAndFight_()
    local war_axe = Items.FindByType(war_hammer_type_id)
    ipl.equipItemWithLessDurability(war_hammer_type_id, war_axe.Name)
    Pause(500)
    if postSwapCallback then
        postSwapCallback()
    end
end

local config = {
    first = { serial = pickaxe_type_id, equip = equipPickaxe_ , acceptPredicate = nil},
    second = { serial = war_axe_type_id, equip = equipWarAxeAndFight_ , acceptPredicate = nil }
    --second = { serial = war_hammer_type_id, equip = equipWarHammerAndFight, acceptPredicate = nil  }
}

local function minerSwap_(pickaxeAcceptPredicate_, callback)
    config.first.acceptPredicate = pickaxeAcceptPredicate_
    pickaxeAcceptPredicate = pickaxeAcceptPredicate_
    postSwapCallback = callback
    iusiih.swapItemInHand(config, callback)
end

--------------
--- Export ---
--------------

local Obj = {
    minerSwap = minerSwap_
}

return Obj