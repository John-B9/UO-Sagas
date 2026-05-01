----------------------------------------------------------------------
--- Combat Assistant (CA) Eat Food
--- Author: JohnB9
---
--- Mentions: Halesluker  - Base script
---
--- Version: 1.0.0  - Module separation of Base script
---
--- Description: Eat Food functions
----------------------------------------------------------------------

local bl = Import('BaseLib')
local cal = Import('CALog')
local cat = Import('CATime')

-----------------
--- Variables ---
-----------------

EatFoodConfig = {
    Enable = false
}

local EatFoodStaticConfig = {
    EatCooldown = 15 * 60 * 1000, -- in ms, how often to eat food
    BuffFoods = {
        65340, --- Meat Feast
        65342 --- Fish Plate
    }
}

local EatFoodState = {
    lastEatTime = nil
}

---------------
--- Setters ---
---------------

local function setEnable_(val)
    EatFoodConfig.Enable = val
end

local function setConfig_(config)
    setEnable_(config.Enable)
end

-----------------
--- Functions ---
-----------------

local function eatFood_()

    if true then
        --- Bugged: buff foods don't prevent eating if already under the effect
        return
    end

    if not EatFoodConfig.Enable then
        return
    end

    local currentTickTime = cat.getCurrentTickTime()
    if not cat.exceedsDuration(EatFoodState.lastEatTime, currentTickTime, cat.getActionWaitTime()) then
        cal.debug("Food check time is not ready, skipping.")
        return
    end

    if not cat.exceedsDuration(EatFoodState.lastEatTime, currentTickTime, EatFoodStaticConfig.EatCooldown) then
        cal.debug("Eat cooldown not met, skipping.")
        return
    end

    cal.debug("Lookin for food...")
    local foodToEat = nil
    for _, graphic in pairs(EatFoodStaticConfig.BuffFoods) do
        local found = bl.findInInventory({graphic})
        if found and #found > 0 then
            for _, item in ipairs(found) do
                --- take the first match
                foodToEat = item
                goto eatfood
            end
        end
    end

    :: eatfood ::
    if not foodToEat then
        cal.debug("No food items found in inventory.")
        return
    end

    cal.debug("Attempting to eat: " .. (foodToEat.Name or "Unknown"))
    Player.UseObject(foodToEat.Serial)

    cal.info("Finished eating")
    EatFoodState.lastEatTime = currentTickTime

end

--------------
--- Export ---
--------------

local Obj = {
    setEnable = setEnable_,
    setConfig = setConfig_,
    eatFood = eatFood_
}

return Obj