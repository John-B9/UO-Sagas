----------------------------------------------------------------------
--- Combat Assistant (CA) Potions Nightsight
--- Author: JohnB9
---
--- Version: 1.0.0  - Base script
---
--- Description: Nightsight Potions functions
----------------------------------------------------------------------

local cal = Import('CALog')
local cat = Import('CATime')
local capt = Import('CAPotionsTime')
local capd = Import('CAPotionsDrink')

-----------------
--- Variables ---
-----------------

NightsightPotionsConfig = {
    Enable = false --- continuously drinks nightsight potions when missing that buff
}

local NightsightPotionsStaticConfig = {
    Potion = 0x0f06,
    Name = "Nightsight"
}

local NightsightPotionsState = {
    lastDrinkTime = nil
}

---------------
--- Setters ---
---------------

local function getEnable_()
    return NightsightPotionsConfig.Enable
end

local function setEnable_(val)
    NightsightPotionsConfig.Enable = val
end

local function setConfig_(config)
    setEnable_(config.Enable)
end

-----------------
--- Functions ---
-----------------

local function shouldAtemptDrink_(forced)
    if capt.shouldAtemptToDrinkNightsight(NightsightPotionsState.lastDrinkTime) == false then
        return false
    end
    return true
end

local function drinkSuccessfullPredicate_()
    return not cat.pauseUntil(function() return Journal.Contains("You already have night sight") end, 50, cat.getActionWaitTime())
end

local function nightsight_(forced)
    if not NightsightPotionsConfig.Enable then
        return false
    end
    local potionDrinkState, lastDrinkTime = capd.drink(NightsightPotionsStaticConfig.Potion, NightsightPotionsStaticConfig.Name, shouldAtemptDrink_, drinkSuccessfullPredicate_, forced)
    if lastDrinkTime then
        NightsightPotionsState.lastDrinkTime = lastDrinkTime
    end
    if potionDrinkState == DrinkAtemptResult.DRINK_ATTEMPTED_BUT_FAILED then
        cal.error("Must already have the nightsight buff...")
        cal.error("We have no way to check when to reapply unless by drinking continuously (which makes no sense)")
        cal.error("We'll disable the auto nightsight buff...")
        cal.error("Just relaunch the Combat Assistant (or re-enable the buff via the UI), once the current night sight expires")
        cal.debug("Already under nightsight effect, disabling auto-buff")
        setEnable_(false)
    end
    return potionDrinkState == DrinkAtemptResult.DRANK_POTION
end

--------------
--- Export ---
--------------

local Obj = {
    getEnable = getEnable_,
    setEnable = setEnable_,
    setConfig = setConfig_,
    nightsight = nightsight_
}

return Obj