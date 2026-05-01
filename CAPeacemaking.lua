----------------------------------------------------------------------
--- Combat Assistant (CA) Peacemaking
--- Author: JohnB9
---
--- Mentions: Halesluker  - Base script
---
--- Version: 1.0.0  - Module separation of Base script
---
--- Description: Peacemaking functions
----------------------------------------------------------------------

local cal = Import('CALog')
local cat = Import('CATime')

-----------------
--- Variables ---
-----------------

PeacemakingConfig = {
    Enable = false
}

local PeacemakingState = {
    isActive = false,
    startTime = nil,
    endTime = nil
}

---------------
--- Setters ---
---------------

local function setEnable_(val)
    PeacemakingConfig.Enable = val
end

local function setConfig_(config)
    setEnable_(config.Enable)
end

-----------------
--- Functions ---
-----------------

local function peacemaking_()
    
    if not PeacemakingConfig.Enable then
        return
    end

    local skill = Skills.GetValue("Peacemaking")
    if not skill or not (skill > 0) then
        cal.debug("No skill in peacemaking...")
        return
    end

    if recentCast() then
        cal.debug("Resent cast, waiting to retry peacemaking.")
        PeacemakingState.isActive = true
        PeacemakingState.startTime = cat.getCurrentTickTime()
        local recastWaitTime = 8
        PeacemakingState.endTime = PeacemakingState.startTime + recastWaitTime
        return
    end

    -- Whom do you wish to calm?
    if not Journal.Contains("You begin to play a soothing melody") or not Journal.Contains("That creature is already being calmed.") then
        cal.debug("No Peacemaking song in progress, starting...")
        Spells.Cast("Peacemaking")
    end

end

--------------
--- Export ---
--------------

local Obj = {
    setEnable = setEnable_,
    setConfig = setConfig_,
    peacemaking = peacemaking_
}

return Obj