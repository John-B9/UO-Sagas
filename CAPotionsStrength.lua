----------------------------------------------------------------------
--- Combat Assistant (CA) Potions Strength
--- Author: JohnB9
---
--- Version: 1.0.0  - Module separation of Base script
---
--- Description: Strength Potions functions
----------------------------------------------------------------------

local cal = Import('CALog')
local cat = Import('CATime')
local capt = Import('CAPotionsTime')
local caph = Import('CAPotionsHealing')
local capd = Import('CAPotionsDrink')

-----------------
--- Variables ---
-----------------

StrengthPotionsConfig = {
    Enable = false,
    BaseStr = 100,
    DrinkHeal = false
}

local StrengthPotionsStaticConfig = {
    Potion = 0x0f09,
    Name = "Greater Strength"
}

local StrengthPotionsState = {
    lastDrinkTime = nil
}

---------------
--- Setters ---
---------------

local function setEnable_(val)
    StrengthPotionsConfig.Enable = val
end

local function setBaseStrength_(val)
    StrengthPotionsConfig.BaseStrength = val
end

local function setDrinkHeal_(val)
    StrengthPotionsConfig.DrinkHeal = val
end

local function setConfig_(config)
    setEnable_(config.Enable)
    setBaseStrength_(config.BaseStrength)
    setDrinkHeal_(config.DrinkHeal)
end

-----------------
--- Functions ---
-----------------

local function shouldAtemptDrink_(forced)
    --if capt.shouldAtemptToDrinkStrength(StrengthPotionsState.lastDrinkTime) == false then
    --    return false
    --end
    cal.debug("Checking if strength is debuffed or dropped")
    if Player.Str > StrengthPotionsConfig.BaseStrength then
        cal.debug("Player strength is above base strength, skipping strength buff.")
        return false
    end
    return true
end

local function drinkSuccessfullPredicate_()
    return cat.pauseUntil(function() return Player.Str > StrengthPotionsConfig.BaseStrength end, 50, cat.getActionWaitTime())
end

local function strength_(forced)
    if not StrengthPotionsConfig.Enable then
        return false
    end
    local drinkReturnVal, lastDrinkTime = capd.drink(StrengthPotionsStaticConfig.Potion, StrengthPotionsStaticConfig.Name, shouldAtemptDrink_, drinkSuccessfullPredicate_, forced)
    local drankPotion = (drinkReturnVal == DrinkAtemptResult.DRANK_POTION)
    if lastDrinkTime then
        StrengthPotionsState.lastDrinkTime = lastDrinkTime
    end
    if drankPotion and StrengthPotionsConfig.DrinkHeal then
        cal.debug("Strength buffed, drinking health potion to recover right away.")
        caph.health(true)
    end
    return drankPotion
end

--------------
--- Export ---
--------------

local Obj = {
    setEnable = setEnable_,
    setBaseStr = setBaseStrength_,
    setConfig = setConfig_,
    strength = strength_
}

return Obj