----------------------------------------------------------------------
--- Combat Assistant (CA) Time
--- Author: JohnB9
---
--- Mentions: Halesluker  - Base script
---
--- Version: 1.0.0  - Module separation of Base script
---
--- Description: Time functions
----------------------------------------------------------------------

-----------------
--- Variables ---
-----------------

TimeConfig = {
    ActionWaitTime = 1000, -- in milliseconds, how long to wait for actions like using items, targeting etc.
}

TimeState = {
    currentTickTime = math.floor(os.time() * 1000),
}

--------------
-- Acessors --
--------------

local function getActionWaitTime_()
    return TimeConfig.ActionWaitTime
end

local function setActionWaitTime_(val)
    TimeConfig.ActionWaitTime = val
end

local function getCurrentTickTime_()
    return TimeState.currentTickTime
end

-----------------
--- Functions ---
-----------------

local function getCurrentTime_()
    return math.floor(os.time() * 1000)
end

local function updateCurrentTickTime_()
    TimeState.currentTickTime = getCurrentTime_()
    return TimeState.currentTickTime
end

--- Description:
---  Continuously evaluates 'callback' at every 'interval' ms
---  (pausing between intervals) utill it evaluates to true
--- Returns:
---  true - when 'callback' evaluates to true
---  true - when 'timeout' is reached
--- 
local function pauseUntil_(callback, interval, timeout)
    local startTime = getCurrentTime_()
    while (getCurrentTime_() - startTime) < timeout do
        if callback() then
            return true
        end
        Pause(interval)
    end
    return false
end

local function exceedsDuration_(startTime, endTime, duration)
    if startTime == nil then
        return true
    end

    if endTime == nil then
        endTime = getCurrentTime_()
    end

    if duration == nil then
        duration = 1000
    end

    return (endTime - startTime) >= duration
end

--------------
--- Export ---
--------------

local Obj = {
    getActionWaitTime = getActionWaitTime_,
    setActionWaitTime = setActionWaitTime_,
    getCurrentTickTime = getCurrentTickTime_,
    updateCurrentTickTime = updateCurrentTickTime_,
    pauseUntil = pauseUntil_,
    exceedsDuration = exceedsDuration_
}

return Obj