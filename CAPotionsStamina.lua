----------------------------------------------------------------------
--- Combat Assistant (CA) Potions Stamina
--- Author: JohnB9
---
--- Version: 1.0.0  - Module separation of Base script
---
--- Description: Stamina Potions functions
----------------------------------------------------------------------

local cal = Import('CALog')
local cat = Import('CATime')
local capd = Import('CAPotionsDrink')

-----------------
--- Variables ---
-----------------

StaminaPotionsConfig = {
    Enable = false,
    DrinkThreshould = 30 -- in percentage, when to drink stamina potion
}

local StaminaPotionsStaticConfig = {
    Potion = 0x0f0b,
    Name = "Total Refresh"
}

local StaminaPotionsState = {
    lastDrinkTime = nil
}

---------------
--- Setters ---
---------------

local function setEnable_(val)
    StaminaPotionsConfig.Enable = val
end

local function setDrinkThreshould_(val)
    StaminaPotionsConfig.DrinkThreshould = val
end

local function setConfig_(config)
    setEnable_(config.Enable)
    setDrinkThreshould_(config.DrinkThreshould)
end

---------------
-- Functions --
---------------

local function shouldAtemptDrink_(forced)
    cal.debug("Player stamina: " .. Player.Stam .. ", Max Stamina: " .. Player.MaxStam)
    if Player.Stam >= Player.MaxStam then
        cal.debug("Player stamina is full, skipping stamina buff.")
        return false
    end
    local staminaPercentage = (Player.Stam / Player.MaxStam) * 100
    if not forced and staminaPercentage > StaminaPotionsConfig.DrinkThreshould then
        cal.debug("Player stamina is above " .. staminaPercentage .. "%, skipping stamina buff.")
        return false
    end
    return true
end

local function drinkSuccessfullPredicate_()
    return cat.pauseUntil(function() return Journal.Contains("You feel invigorated") end, 50, cat.getActionWaitTime())
end

local function stamina_(forced)
    if not StaminaPotionsConfig.Enable then
        return
    end
    local potionDrinkState, lastDrinkTime = capd.drink(StaminaPotionsStaticConfig.Potion, StaminaPotionsStaticConfig.Name, shouldAtemptDrink_, drinkSuccessfullPredicate_, forced)
    if lastDrinkTime then
        StaminaPotionsState.lastDrinkTime = lastDrinkTime
    end
    return potionDrinkState == DrinkAtemptResult.DRANK_POTION
end

--------------
--- Export ---
--------------

local Obj = {
    setEnable = setEnable_,
    setDrinkThreshould = setDrinkThreshould_,
    setConfig = setConfig_,
    stamina = stamina_
}

return Obj