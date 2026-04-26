local bl = Import('BaseLib')
local ipl = Import('IPLib')
local cbl = Import('combatBotLib')
local iusiih = Import('IUSwapItemInHand')

local pickaxe_type_id = 3718
local war_axe_type_id = 5040
local war_hammer_type_id = 5177

local function pickaxeAcceptPredicate(item)
    local itemMaterial = ipl.getMaterial(item)
    bl.printIfDebug(true, itemMaterial)
    if itemMaterial == "Iron" then
        return true
    end
    return false
end

local function equipPickaxe()
    local pickaxe = Items.FindByType(pickaxe_type_id)
    ipl.equipItemWithLessUsesRemaining(pickaxe_type_id, pickaxe.Name, pickaxeAcceptPredicate)
end

local function equipWarAxeAndFight()
    local war_axe = Items.FindByType(war_axe_type_id)
    ipl.equipItemWithLessDurability(war_axe_type_id, war_axe.Name)
    Pause(500)
    --cbl.mainLoop()
end

local function equipWarHammerAndFight()
    local war_axe = Items.FindByType(war_hammer_type_id)
    ipl.equipItemWithLessDurability(war_hammer_type_id, war_axe.Name)
    Pause(500)
    cbl.mainLoop()
end

local config = {
    first = { serial = pickaxe_type_id, equip = equipPickaxe },
    second = { serial = war_axe_type_id, equip = equipWarAxeAndFight }
    --second = { serial = war_hammer_type_id, equip = equipWarHammerAndFight }
}

iusiih.swapItemInHand(config)