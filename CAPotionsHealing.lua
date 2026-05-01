----------------------------------------------------------------------
--- Combat Assistant (CA) Potions Healing
--- Author: JohnB9
---
--- Version: 1.0.0  - Module separation of Base script
---
--- Description: Healing Potions functions
----------------------------------------------------------------------

local bl = Import('BaseLib')
local cal = Import('CALog')
local cat = Import('CATime')
local capt = Import('CAPotionsTime')
local capd = Import('CAPotionsDrink')

-----------------
--- Variables ---
-----------------

HealingPotionsConfig = {
    Enable = false, -- Drinks healing potions when bellow threshould
    HPDrinkThreshould = 20 -- in percentage, when to use heal potion
}

local HealingPotionsStaticConfig = {
    Potion = 0x0f0c,
    Name = "Greater Heal"
}

local HealingPotionsState = {
    lastDrinkTime = 0
}

---------------
--- Setters ---
---------------

local function setEnable_(val)
    HealingPotionsConfig.Enable = val
end

local function setHPDrinkThreshould_(val)
    HealingPotionsConfig.HPDrinkThreshould = val
end

local function setConfig_(config)
    setEnable_(config.Enable)
    setHPDrinkThreshould_(config.HPDrinkThreshould)
end

-----------------
--- Functions ---
-----------------

local function shouldAtemptDrink_(forced)
    if Player.IsHidden then
        cal.debug("Player is hiding, skipping health potion.")
        return false
    end
    local playerHpPercentage = bl.getHpPercentage()
    if not forced and (playerHpPercentage > HealingPotionsConfig.HPDrinkThreshould) then
        cal.debug("Player HP is above health potion threshold, skipping health potion.")
        return false
    end
    cal.debug("Player HP is below health potion threshold, drinking health potion.")
    if Player.IsPoisoned then
        cal.debug("Player is poisoned, skipping health potion.")
        return false
    end
    if not forced and not capt.shouldAtemptToDrinkHeal(HealingPotionsState.lastDrinkTime) then
        cal.debug("Health potion recently drunk, skipping.")
        return false
    end
    return true
end

local function drinkSuccessfullPredicate_()
    return cat.pauseUntil(function () return Journal.Contains("You feel better") end, 50, cat.getActionWaitTime())
end

local function health_(forced)
    if not HealingPotionsConfig.Enable then
        return
    end
    local potionDrinkState, lastDrinkTime = capd.drink(HealingPotionsStaticConfig.Potion, HealingPotionsStaticConfig.Name, shouldAtemptDrink_, drinkSuccessfullPredicate_, forced)
    if lastDrinkTime then
        HealingPotionsState.lastDrinkTime = lastDrinkTime
    end
    return potionDrinkState == DrinkAtemptResult.DRANK_POTION
end

--------------
--- Export ---
--------------

local Obj = {
    setEnable = setEnable_,
    setHPDrinkThreshould = setHPDrinkThreshould_,
    setConfig = setConfig_,
    health = health_
}

return Obj