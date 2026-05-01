----------------------------------------------------------------------
--- Combat Assistant (CA) Potions Time
--- Author: JohnB9
---
--- Description: Potions Time functions
----------------------------------------------------------------------

local bl = Import('BaseLib')
local cal = Import('CALog')
local cat = Import('CATime')
local caad = Import('CAArmDisarm')

-----------------
--- Variables ---
-----------------

local PotionsTimeStaticConfig = {
    Nightsight = {
        Name = "Nightsight",
        Duration = (300 + math.ceil(Skills.GetValue("Alchemy")*10)*3 + 1) * 1000, --- 300s base time + 3s per 0.1 point in alchemy skill + 1s buffer
        CheckFrequency = 5000 --- drink attempt frequency, when not sure if under buff effect
    },
    GreaterStrength = {
        Name = "Greater Stength",
        Duration = (120 + math.floor(Skills.GetValue("Alchemy"))*6 + 1) * 1000, --- 120s base time + 6s per 1 point in alchemy skill + 1s buffer
        Buff = 20 + math.floor(Skills.GetValue("Alchemy"))/10, --- 20 base + 1 per 10 points in alchemy skill
        CheckFrequency = 5000 --- drink attempt frequency, when not sure if under buff effect
    },
    GreaterAgility = {
        Name = "Greater Agility",
        Duration = (120 + math.floor(Skills.GetValue("Alchemy"))*6 + 1) * 1000, --- 120s base time + 6s per 1 point in alchemy skill + 1s buffer
        Buff = 20 + math.floor(Skills.GetValue("Alchemy"))/10, --- 20 base + 1 per 10 points in alchemy skill
        CheckFrequency = 5000 --- drink attempt frequency, when not sure if under buff effect
    },
    GreaterHeal = {
        Name = "Greater Heal",
        DrinkCooldown = 15 * 1000
    },
    GreaterCure = {
        Name = "Greater Cure"
    }
}

local PotionsTimeState = {
    Nightsight = {
        lastCheckTickTime = nil
    },
    GreaterStrength = {
        lastCheckTickTime = nil
    },
    GreaterAgility = {
        lastCheckTickTime = nil
    },
    GreaterHeal = {
    },
    GreaterCure = {
    }
}

---------------
--- Setters ---
---------------

-----------------
--- Functions ---
-----------------

local function shouldAtemptToDrink_(potionStaticConfig, potionState, lastDrinkTime)

    cal.debug("Checking "..potionStaticConfig.Name.." buff")
    local currentTickTime = cat.getCurrentTickTime()
    local exceedsDuration = cat.exceedsDuration(lastDrinkTime, currentTickTime, potionStaticConfig.Duration)
    local durationReallyExpired = lastDrinkTime and exceedsDuration
    if lastDrinkTime and not exceedsDuration then
        cal.debug("Already buffed: last drink tick ("..lastDrinkTime..
            "), current ("..currentTickTime..
            "), elapsed ("..(currentTickTime-lastDrinkTime)..
            "), target ("..potionStaticConfig.Duration..")")
        return false
    end

    local checkOnColldown = potionState.lastCheckTickTime and not cat.exceedsDuration(potionState.lastCheckTickTime, currentTickTime, potionStaticConfig.CheckFrequency)
    if not durationReallyExpired and checkOnColldown then
        cal.debug("Check on cooldown")
        return false
    end
    potionState.lastCheckTickTime = currentTickTime

    return true
end

local function shouldAtemptToDrinkNightsight_(lastDrinkTime)
    return shouldAtemptToDrink_(PotionsTimeStaticConfig.Nightsight, PotionsTimeState.Nightsight, lastDrinkTime)
end

local function shouldAtemptToDrinkStrength_(lastDrinkTime)
    return shouldAtemptToDrink_(PotionsTimeStaticConfig.GreaterStrength, PotionsTimeState.GreaterStrength, lastDrinkTime)
end

local function shouldAtemptToDrinkAgility_(lastDrinkTime)
    return shouldAtemptToDrink_(PotionsTimeStaticConfig.GreaterAgility, PotionsTimeState.GreaterAgility, lastDrinkTime)
end

local function shouldAtemptToDrinkHeal_(lastDrinkTime)
    local currentTickTime = cat.getCurrentTickTime()
    if not cat.exceedsDuration(lastDrinkTime, currentTickTime, PotionsTimeStaticConfig.GreaterHeal.DrinkCooldown) then
        cal.debug("Health potion recently drunk, skipping.")
        return false
    end
    return true
end

local function shouldAtemptToDrinkCure_(lastDrinkTime, drinkCooldown)
    local currentTickTime = cat.getCurrentTickTime()
    if not cat.exceedsDuration(lastDrinkTime, currentTickTime, drinkCooldown) then
        cal.debug("Cure potion recently drunk, skipping.")
        return false
    end
    return true
end

--------------
--- Export ---
--------------

local Obj = {
    shouldAtemptToDrinkNightsight = shouldAtemptToDrinkNightsight_,
    shouldAtemptToDrinkStrength = shouldAtemptToDrinkStrength_,
    shouldAtemptToDrinkAgility = shouldAtemptToDrinkAgility_,
    shouldAtemptToDrinkHeal = shouldAtemptToDrinkHeal_,
    shouldAtemptToDrinkCure = shouldAtemptToDrinkCure_
}

return Obj