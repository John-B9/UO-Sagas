----------------------------------------------------------------------
--- Combat Assistant (CA) Song Of Healing
--- Author: JohnB9
---
--- Mentions: Halesluker  - Base script
---
--- Version: 1.0.0  - Module separation of Base script
---
--- Description: Song Of Healing functions
----------------------------------------------------------------------

local cal = Import('CALog')
local cat = Import('CATime')

-----------------
--- Variables ---
-----------------

SongOfHealingConfig = {
    Enable = false,
    FailWait = 30 * 1000, -- in ms, how long to retry if already under effects by manual cast
    Instruments = {"Drum", "Lute", "Tambourine", "Lap Harp" }
}

local SongOfHealingState = {
    isActive = false,
    startTime = nil,
    endTime = nil,
    duration = 163 * 1000, -- Need to calculate based on music skill?
    lastWarningTickTime = nil,
    instrument = nil,
}

---------------
--- Setters ---
---------------

local function setEnable_(val)
    SongOfHealingConfig.Enable = val
end

local function setFailWait_(val)
    SongOfHealingConfig.FailWait = val
end

local function setInstruments_(val)
    SongOfHealingConfig.Instruments = val
end

local function setConfig_(config)
    setEnable_(config.Enable)
    setFailWait_(config.FailWait)
    setInstruments_(config.Instruments)
end

-----------------
--- Functions ---
-----------------

local function startBuff(buffState, duration)
    buffState.isActive = true
    buffState.startTime = cat.getCurrentTickTime()
    buffState.endTime = buffState.startTime + duration
end

local function recentCast()
    return Journal.Contains("You play your hypnotic music, stopping the battle.") or Journal.Contains("You must wait a few seconds before you can play another song.") or Journal.Contains("Your song creates a healing aura around you.")
end


local function songOfHealing_()
    
    if not SongOfHealingConfig.Enable then
        return
    end

    local musicSkill = Skills.GetValue("Musicianship")
    if musicSkill and musicSkill > 0 then
        cal.debug("Musicianship skill is " .. musicSkill .. ", proceeding with Song of Healing.")
    else
        cal.debug("Musicianship skill is 0, skipping Song of Healing.")
        return
    end

    local currentTickTime = cat.getCurrentTickTime()
    if SongOfHealingState.isActive then
        if currentTickTime > SongOfHealingState.endTime then
            SongOfHealingState.isActive = false
            cal.debug("Song of Healing ended.")
            return
        end
        cal.debug("Waiting for Song of Healing to end in: " ..
        ((SongOfHealingState.endTime - currentTickTime) / 1000) .. " seconds.")
        return
    end

    if recentCast() then
        cal.debug("Buff was recently cast, wait to retry")
        SongOfHealingState.isActive = true
        SongOfHealingState.startTime = currentTickTime
        local recastWaitTime = 8
        SongOfHealingState.endTime = SongOfHealingState.startTime + recastWaitTime
        return
    end

    if not SongOfHealingState.instrument then
        local instrument = nil
        for _, instrumentName in ipairs(SongOfHealingConfig.Instruments) do
            cal.debug("Looking for instrument: " .. instrumentName)
            instrument = Items.FindByName(instrumentName)
            if instrument then
                cal.debug("Found instrument: " .. instrument.Name)
                break
            end
        end

        if not instrument then
            cal.debug("No instrument found in inventory")
            return
        end

        SongOfHealingState.instrument = instrument
    end

    cal.debug("Casting Song of Healing...")
    if not Spells.Cast("SongOfHealing") then
        if cat.exceedsDuration(SongOfHealingState.lastWarningTickTime, currentTickTime, SongOfHealingConfig.FailWait) then
            cal.info("Recasting Song of Healing")
            cal.debug("Failed to cast Song of Healing, waiting " .. (SongOfHealingConfig.FailWait / 1000) .. " seconds to retry.")
            SongOfHealingState.lastWarningTickTime = currentTickTime
        end
        startBuff(SongOfHealingState, SongOfHealingConfig.FailWait)
        return
    end

    local castSuccess = cat.pauseUntil(function()
        if Journal.Contains("You are already under the effects") then
            cal.debug("Song was already active.")
            return false
        elseif Journal.Contains("Your song creates a healing aura around you.") then
            return true
        elseif Journal.Contains("What instrument shall you play?") then
            cal.debug("Instrument depleeted, will look for a new one")
            SongOfHealingState.instrument = nil
            return false
        end
        return false
    end, 50, cat.getActionWaitTime())

    if not castSuccess then
        if cat.exceedsDuration(SongOfHealingState.lastWarningTickTime, currentTickTime, SongOfHealingConfig.FailWait) then
            cal.info("Recasting Song of Healing")
            cal.debug("Journal did not contain expectations for Song of Healing, waiting " .. (SongOfHealingConfig.FailWait / 1000)
            .. " seconds to retry.")
            SongOfHealingState.lastWarningTickTime = currentTickTime
        end
        startBuff(SongOfHealingState, SongOfHealingConfig.FailWait)
        return
    end

    startBuff(SongOfHealingState, SongOfHealingState.duration)
    cal.info("Casted Song of Healing")
    cal.debug("Song of Healing started.")
end

--------------
--- Export ---
--------------

local Obj = {
    setEnable = setEnable_,
    setFailWait = setFailWait_,
    setInstruments = setInstruments_,
    setConfig = setConfig_,
    songOfHealing = songOfHealing_
}

return Obj