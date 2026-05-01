----------------------------------------------------------------------
--- Combat Assistant (CA) Potions Agility
--- Author: JohnB9
---
--- Version: 1.0.0  - Module separation of Base script
---
--- Description: Agility Potions functions
----------------------------------------------------------------------

local cal = Import('CALog')
local cat = Import('CATime')
local capt = Import('CAPotionsTime')
local capd = Import('CAPotionsDrink')
local caps = Import('CAPotionsStamina')

-----------------
--- Variables ---
-----------------

AgilityPotionsConfig = {
    Enable = false,
    BaseAgility = 100,
    DrinkRefresh = false
}

local AgilityPotionsStaticConfig = {
    Potion = 0x0f08,
    Name = "Greater Agility"
}

local AgilityPotionsState = {
    lastDrinkTime = nil
}

---------------
--- Setters ---
---------------

local function setEnable_(val)
    AgilityPotionsConfig.Enable = val
end

local function setBaseAgility_(val)
    AgilityPotionsConfig.BaseAgility = val
end

local function setDrinkRefresh_(val)
    AgilityPotionsConfig.DrinkRefresh = val
end

local function setConfig_(config)
    setEnable_(config.Enable)
    setBaseAgility_(config.BaseAgility)
    setDrinkRefresh_(config.DrinkRefresh)
end

-----------------
--- Functions ---
-----------------

local function shouldAtemptDrink_(forced)
    --if capt.shouldAtemptToDrinkAgility(AgilityPotionsState.lastDrinkTime) == false then
    --    return false
    --end
    cal.debug("Checking if dexterity is debuffed or dropped")
    if Player.Dex > AgilityPotionsConfig.BaseAgility then
        cal.debug("Player dexterity is above base value, skipping agility buff.")
        return false
    end
    return true
end

local function drinkSuccessfullPredicate_()
    return cat.pauseUntil(function() return Player.Dex > AgilityPotionsConfig.BaseAgility end, 50, cat.getActionWaitTime())
end

local function agility_(forced)
    if not AgilityPotionsConfig.Enable then
        return false
    end
    local drinkReturnVal, lastDrinkTime = capd.drink(AgilityPotionsStaticConfig.Potion, AgilityPotionsStaticConfig.Name, shouldAtemptDrink_, drinkSuccessfullPredicate_, forced)
    local drankPotion = (drinkReturnVal == DrinkAtemptResult.DRANK_POTION)
    if lastDrinkTime then
        AgilityPotionsState.lastDrinkTime = lastDrinkTime
    end
    if drankPotion and AgilityPotionsConfig.DrinkRefresh then
        cal.debug("Agility buffed, drinking refresh potion to recover right away.")
        caps.stamina(true)
    end
    return drankPotion
end

--------------
--- Export ---
--------------

local Obj = {
    setEnable = setEnable_,
    setBaseAgility = setBaseAgility_,
    setConfig = setConfig_,
    agility = agility_
}

return Obj