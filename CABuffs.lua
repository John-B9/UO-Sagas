----------------------------------------------------------------------
--- Combat Assistant (CA) Buffs
--- Author: JohnB9
---
--- Mentions: Halesluker  - Base script
---
--- Version: 1.0.0  - Module separation of Base script
---
--- Description: Buffs functions
----------------------------------------------------------------------

local cal = Import('CALog')
local casoh = Import('CASongOfHealing')
local capn = Import('CAPotionsNightsight')
local capsta = Import('CAPotionsStamina')
local capstr = Import('CAPotionsStrength')
local capagi = Import('CAPotionsAgility')
local caef = Import('CAEatFood')

-----------------
--- Variables ---
-----------------

BuffsConfig = {
    Enable = false --- To enable/disable auto-buffs altogether
}

---------------
--- Setters ---
---------------

local function setEnable_(val)
    BuffsConfig.Enable = val
end

local function setConfig_(config)
    setEnable_(config.Enable)
    casoh.setConfig(config.SongOfHealing)
    capn.setConfig(config.Nightsight)
    capsta.setConfig(config.Stamina)
    capstr.setConfig(config.Strength)
    capagi.setConfig(config.Agility)
    caef.setConfig(config.EatFood)
end

-----------------
--- Functions ---
-----------------

local function buffs_()

    if not BuffsConfig.Enable then
        return
    end

    if Player.IsDead then
        cal.debug("Player is dead, skipping buffs.")
        return
    end

    if Player.IsHidden then
        cal.debug("Player is hiding, skipping buffs.")
        return
    end

    cal.debug("Applying buffs.")
    casoh.songOfHealing()
    capn.nightsight(false)
    capsta.stamina(false)
    capstr.strength(false)
    capagi.agility(false)
    caef.eatFood()

end

--------------
--- Export ---
--------------

local Obj = {
    setEnable = setEnable_,
    setConfig = setConfig_,
    buffs = buffs_
}

return Obj