----------------------------------------------------------------------
--- Combat Assistant (CA) Potions Cure
--- Author: JohnB9
---
--- Version: 1.0.0  - Module separation of Base script
---
--- Description: Cure Potion functions
----------------------------------------------------------------------

local cal = Import('CALog')
local cat = Import('CATime')
local capt = Import('CAPotionsTime')
local capd = Import('CAPotionsDrink')

-----------------
--- Variables ---
-----------------

PotionsCureConfig = {
    Enable = false,
    ColldownTime = 1000 --- in milliseconds, overridable
}

local PotionsCureStaticConfig = {
    Potion = 0x0f07,
    Name = "Greater Cure"
}

local PotionsCureState = {
    lastDrinkTime = 0,
    isPoisoned = false
}

---------------
--- Setters ---
---------------

local function setEnable_(val)
    PotionsCureConfig.Enable = val
end

local function setColldownTime_(val)
    PotionsCureConfig.ColldownTime = val
end

local function setConfig_(config)
    setEnable_(config.Enable)
    setColldownTime_(config.ColldownTime)
end

-----------------
--- Functions ---
-----------------

local function shouldAtemptDrink_(forced)
    if Player.IsHidden then
        cal.debug("Player is hiding, skipping cure.")
        return false
    end
    cal.debug("Player is poisoned: " .. tostring(Player.IsPoisoned))
    if not Player.IsPoisoned then
        if PotionsCureState.isPoisoned then
            cal.info("Cured")
        end
        PotionsCureState.isPoisoned = false
        cal.debug("Player is not poisoned")
        return false
    end
    PotionsCureState.isPoisoned = true
    if not capt.shouldAtemptToDrinkCure(PotionsCureState.lastDrinkTime, PotionsCureConfig.ColldownTime) then
        cal.debug("Cure potion recently drunk, skipping.")
        return false
    end
    return true
end

local function drinkSuccessfullPredicate_()
    return cat.pauseUntil(function() return Journal.Contains("You feel cured of poison") end, 50, cat.getActionWaitTime())
end

local function cure_(forced)
    if not PotionsCureConfig.Enable then
        return false
    end
    local potionDrinkState, lastDrinkTime = capd.drink(PotionsCureStaticConfig.Potion, PotionsCureStaticConfig.Name, shouldAtemptDrink_, drinkSuccessfullPredicate_, forced)
    if lastDrinkTime then
        cal.debug("Cure potion drank, saving last drink time.")
        PotionsCureState.lastDrinkTime = lastDrinkTime
    end
    return potionDrinkState == DrinkAtemptResult.DRANK_POTION
end

--------------
--- Export ---
--------------

local Obj = {
    setEnable = setEnable_,
    setColldownTime = setColldownTime_,
    setConfig = setConfig_,
    cure = cure_
}

return Obj
