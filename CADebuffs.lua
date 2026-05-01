----------------------------------------------------------------------
--- Combat Assistant (CA) Debuffs
--- Author: JohnB9
---
--- Mentions: Halesluker  - Base script
---
--- Version: 1.0.0  - Module separation of Base script
---
--- Description: Debuffs functions
----------------------------------------------------------------------

local cal = Import('CALog')
local cap = Import('CAPeacemaking')

-----------------
--- Variables ---
-----------------

DebuffsConfig = {
    Enable = false -- 
}

---------------
--- Setters ---
---------------

local function setEnable_(val)
    DebuffsConfig.Enable = val
end

local function setConfig_(config)
    setEnable_(config.Enable)
    cap.setConfig(config.Peacemaking)
end

-----------------
--- Functions ---
-----------------

local function debuffs_()

    if not DebuffsConfig.Enable then
        return
    end

    cal.debug("Buffs running")

    if Player.IsHidden then
        cal.debug("Player is hiding, skipping buffs.")
        return
    end

    cap.peacemaking()
    
end

--------------
--- Export ---
--------------

local Obj = {
    setEnable = setEnable_,
    setConfig = setConfig_,
    debuffs = debuffs_
}

return Obj