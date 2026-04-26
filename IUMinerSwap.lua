local bl = Import('BaseLib')
local ipl = Import('IPLib')
local cbl = Import('combatBotLib')
local iusiih = Import('IUSwapItemInHand')

local pickaxe_type_id = 3718
local war_axe_type_id = 5040
local war_hammer_type_id = 5177

local pickaxeAcceptPredicate = nil
local function equipPickaxe_()
    local pickaxe = Items.FindByType(pickaxe_type_id)
    ipl.equipItemWithLessUsesRemaining(pickaxe_type_id, pickaxe.Name, pickaxeAcceptPredicate)
end

local function equipWarAxeAndFight_()
    local war_axe = Items.FindByType(war_axe_type_id)
    ipl.equipItemWithLessDurability(war_axe_type_id, war_axe.Name)
    Pause(500)
    cbl.mainLoop()
end

local function equipWarHammerAndFight_()
    local war_axe = Items.FindByType(war_hammer_type_id)
    ipl.equipItemWithLessDurability(war_hammer_type_id, war_axe.Name)
    Pause(500)
    cbl.mainLoop()
end

local config = {
    first = { serial = pickaxe_type_id, equip = equipPickaxe_ },
    second = { serial = war_axe_type_id, equip = equipWarAxeAndFight_ }
    --second = { serial = war_hammer_type_id, equip = equipWarHammerAndFight }
}

local function minerSwap_(pickaxeAcceptPredicate_)
    pickaxeAcceptPredicate = pickaxeAcceptPredicate_
    iusiih.swapItemInHand(config)
end

------------
-- Export --
------------

local Obj = {
    minerSwap = minerSwap_
}

return Obj