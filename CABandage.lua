----------------------------------------------------------------------
--- Combat Assistant (CA) Bandage
--- Author: JohnB9
---
--- Mentions: Halesluker  - Base script
---
--- Version: 1.0.0  - Module separation of Base script
---
--- Description: Bandage functions
----------------------------------------------------------------------

local bl = Import('BaseLib')
local cal = Import('CALog')
local cat = Import('CATime')

-----------------
--- Variables ---
-----------------

BandageConfig = {
    Enable = false, --- Bandages player if HP is below BandageHP or if poisoned and no cure potions
    BandageHP = 99 --- in percentage, when to use bandage
}

local BandageStaticConfig = {
    Bandages = { 0x00e21 },
    OverheadPauseTime = 0, --- in ms, zero means only when beginning bandage
    WarningPauseTime = 60 * 1000
}

local BandageState = {
    lastOverheadTime = 0,
    isBandaging = false,
    bandageTimeEnd = nil
}

---------------
--- Setters ---
---------------

local function setEnable_(val)
    BandageConfig.Enable = val
end

local function setBandageHP_(val)
    BandageConfig.BandageHP = val
end

local function setConfig_(config)
    setEnable_(config.Enable)
    setBandageHP_(config.BandageHP)
end

-----------------
--- Functions ---
-----------------

local function bandageEndTime_(start)
    local delayMs = math.ceil((9.0 + 0.85 * ((130 - Player.Dex) / 20)) * 1000)
    local baseTime = start or cat.getCurrentTickTime() or math.floor(os.time() * 1000)
    return baseTime + delayMs
end

local function bandage_()

    if not BandageConfig.Enable then
        return
    end

    local currentTickTime = cat.getCurrentTickTime()

    cal.debug("Bandage running with main tick time")

    if Player.IsHidden then
        cal.debug("Player is hiding, skipping bandage.")
        return
    end

    if BandageState.isBandaging then
        cal.debug("Already healing, skipping bandage.")
        local timeLeft = BandageState.bandageTimeEnd - currentTickTime

        if timeLeft > 0 and BandageStaticConfig.OverheadPauseTime > 0  then
            if cat.exceedsDuration(BandageState.lastOverHeadTime, currentTickTime, BandageStaticConfig.OverheadPauseTime) then
                local countdown = math.floor(timeLeft / 1000)
                if countdown >= 1 then
                    cal.info("Bandaging " .. countdown .. "s")
                end
                BandageState.lastOverHeadTime = currentTickTime
            end
        end

        if currentTickTime > BandageState.bandageTimeEnd then
            BandageState.isBandaging = false
        end

        return
    end

    cal.debug("Checking if bandaging is needed...")
    if Player.IsDead then
        cal.debug("Cannot bandage while dead.")
        return
    end

    if Journal.Contains("You begin applying the bandages") then
        cal.debug("Already manually bandaging, skipping.")
        BandageState.bandageTimeEnd = bandageEndTime_(currentTickTime)
        BandageState.isBandaging = true
        return
    end

    local playerHpPercentage = bl.getHpPercentage()

    if not Player.IsPoisoned and (playerHpPercentage >= BandageConfig.BandageHP) then
        cal.debug("Player not poisoned or HP is above threshold, no bandage needed.")
        return
    end

    if Player.IsPoisoned and BandageState.useBandages then
        cal.debug("Using bandages due to previous poison.")
        info("Curing with bandage")
        BandageState.useBandages = false
    end

    cal.debug("Looing for bandages...")
    local bandages = bl.findInInventory(BandageStaticConfig.Bandages)

    if not bandages or #bandages == 0 then
        if cat.exceedsDuration(BandageState.lastOverheadTime, currentTickTime, BandageStaticConfig.WarningPauseTime) then
            cal.warning("No bandages found")
            BandageState.lastOverheadTime = currentTickTime
        end
        return
    end

    cal.debug("Attempting to bandage...")
    --- Print size of bandages or 1 if only one item
    local bandageCount = #bandages > 1 and #bandages or 1
    cal.debug("Bandaging with " .. bandageCount .. " bandage(s)...")

    --- Loop in case you got item from bank or other "player" container
    local isBandagingSuccessful = false
    for _, item in ipairs(bandages) do
        if not Player.UseObject(item.Serial) then
            cal.debug("Unable to use bandage item.")
            goto continue
        end

        if not Target.WaitForTarget(1000) then
            cal.debug("Targeting failed, unable to bandage.")
            goto continue
        end

        if Target.Self() then
            isBandagingSuccessful = true
            break
        end

        :: continue ::
    end

    if not isBandagingSuccessful then
        cal.debug("Failed to bandage, the bandages found are probably in bank?")
        return
    end

    local bandaging = cat.pauseUntil(function()
        return Journal.Contains("You begin applying the bandages.")
    end, 50, 500)

    if not bandaging then
        BandageState.isBandaging = false
        BandageState.lastBandageStart = nil
        return
    end

    cal.debug("Bandaging")

    if BandageStaticConfig.OverheadPauseTime == 0 then
        cal.info("Bandaging...")
        BandageState.lastOverHeadTime = currentTickTime
    end

    BandageState.isBandaging = bandaging
    BandageState.lastBandageStart = currentTickTime
    BandageState.bandageTimeEnd = bandageEndTime_(BandageState.lastBandageStart)
end

--------------
--- Export ---
--------------

local Obj = {
    setEnable = setEnable_,
    setBandageHP = setBandageHP_,
    setConfig = setConfig_,
    bandage = bandage_
}

return Obj