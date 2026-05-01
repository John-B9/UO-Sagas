----------------------------------------------------------------------
--- Combat Assistant (CA) Potions Time
--- Author: JohnB9
---
--- Version: 1.0.0  - Base script
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

DrinkAtemptResult = {
    NO_DRINK_ATTEMPT = 0,
    DRINK_ATTEMPTED_BUT_FAILED = 1,
    DRANK_POTION = 2
}

local PotionsDrinkStaticConfig = {
    WarningPauseTime = 60 * 1000
}

local PotionsDrinkState = {
    lastOverHeadTime = 0
}

---------------
--- Setters ---
---------------

-----------------
--- Functions ---
-----------------

local function drink_(potionGraphicID, potionName, shouldAtemptDrinkPredicate, drinkSuccessfullPredicate, forced)

    if not drinkSuccessfullPredicate then
        cal.error("drink_: Missing drinkSuccessfullPredicate.")
        return DrinkAtemptResult.NO_DRINK_ATTEMPT, nil
    end

    if shouldAtemptDrinkPredicate and not shouldAtemptDrinkPredicate(forced) then
        return DrinkAtemptResult.NO_DRINK_ATTEMPT, nil
    end

    cal.debug("Looking for a " .. potionName .. " potion...")
    local potion = bl.findInInventoryGetFirst(potionGraphicID)
    if not potion then
        local currentTickTime = cat.getCurrentTickTime()
        if cat.exceedsDuration(PotionsDrinkState.lastOverHeadTime, currentTickTime, PotionsDrinkStaticConfig.WarningPauseTime) then
            cal.warning("No " .. potionName .. " potions")
            PotionsDrinkState.lastOverHeadTime = currentTickTime
        end
        return DrinkAtemptResult.NO_DRINK_ATTEMPT, nil
    end

    local alchemySkill = Skills.GetValue("Alchemy")
    if alchemySkill and alchemySkill < 80 then
        cal.debug("Alchemy skill is below 80, disarming weapon to use strength potion.")
        caad.disarmPlayer()
    end

    cal.debug("Using potion: " .. potionName)
    if not Player.UseObject(potion.Serial) then
        cal.debug("Failed to use potion: " .. (potionName.Name or "No Potion Name"))
        return DrinkAtemptResult.DRINK_ATTEMPTED_BUT_FAILED, nil
    end

    if drinkSuccessfullPredicate() then
        cal.debug("Successfully drank a " .. potionName .. " potion.")
        local drinkTime = cat.getCurrentTickTime()
        Pause(cat.getActionWaitTime())
        return DrinkAtemptResult.DRANK_POTION, drinkTime
    end

    return DrinkAtemptResult.DRINK_ATTEMPTED_BUT_FAILED, nil
end

--------------
--- Export ---
--------------

local Obj = {
    drink = drink_
}

return Obj