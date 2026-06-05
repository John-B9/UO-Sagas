----------------------------------------------------------------------
--- Combat Assistant (CA) Bandage
--- Author: JohnB9
---
--- Mentions: Halesluker  - Base script
---           OmgArturo   - Cross heal
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
    Enable = false,                 --- Bandages player if HP is below BandageSelfHPThreshould or if poisoned and no cure potions
    BandageSelfHPThreshould = 99,   --- in percentage, when to use bandage
    BandageAllies = false,          --- Whether to attempt to bandage allies when player is not in need of bandaging
    BandageAlliesHPThreshould = 90, --- in percentage, when to use bandage
    AlliesSerials = {}              --- List of allies serials to bandage, if BandageAllies is true
}

local BandageStaticConfig = {
    Bandages = { 0x00e21 },
    OverheadPauseTime = 0,          --- in ms, zero means only when beginning bandage
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
    BandageConfig.BandageSelfHPThreshould = val
end

local function setConfig_(config)
    setEnable_(config.Enable)
    setBandageHP_(config.BandageSelfHPThreshould)
    BandageConfig.BandageAllies = config.BandageAllies
    BandageConfig.BandageAlliesHPThreshould = config.BandageAlliesHPThreshould
    BandageConfig.AlliesSerials = config.AlliesSerials
end

-----------------
--- Functions ---
-----------------

local function bandageSelfEndTime_(start)
    local delayMs = math.ceil((9.0 + 0.85 * ((130 - Player.Dex) / 20)) * 1000)
    local baseTime = start or cat.getCurrentTickTime() or math.floor(os.time() * 1000)
    return baseTime + delayMs
end

local function bandageOtherEndTime_(start)
    --local delayMs = math.ceil((9.0 + 0.85 * ((130 - Player.Dex) / 20)) * 1000)
    local delayMs = 5000
    local baseTime = start or cat.getCurrentTickTime() or math.floor(os.time() * 1000)
    return baseTime + delayMs
end

local function getBandages_()
    cal.debug("Looking for bandages...")
    local bandages = bl.findInInventory(BandageStaticConfig.Bandages)
    if not bandages or #bandages == 0 then
        if cat.exceedsDuration(BandageState.lastOverheadTime, currentTickTime, BandageStaticConfig.WarningPauseTime) then
            cal.warning("No bandages found")
            BandageState.lastOverheadTime = currentTickTime
        end
        return nil
    end

    --- Print size of bandages or 1 if only one item
    local bandageCount = #bandages > 1 and #bandages or 1
    cal.debug("Have " .. bandageCount .. " bandage(s)...")
    return bandages
end

local function appyBandages_(target)

    local bandages = getBandages_()
    if not bandages then
        return false
    end
    
    --- Loop in case you got item from bank or other "player" container
    cal.debug("Attempting to bandage...")
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

        if target == nil then
            if Target.Self() then
                isBandagingSuccessful = true
                break
            end
        elseif Target.TargetSerial(target.Serial) then
            isBandagingSuccessful = true
            break
        end

        :: continue ::
    end
    
    if not isBandagingSuccessful then
        cal.debug("Failed to bandage, the bandages found are probably in bank?")
        return false
    end

    isBandagingSuccessful = cat.pauseUntil(function()
        return Journal.Contains("You begin applying the bandages.")
    end, 50, 500)

    if not isBandagingSuccessful then
        BandageState.isBandaging = false
        BandageState.lastBandageStart = nil
        return false
    end

    return true
end

local function bandageOther_(currentTickTime)

    if not BandageConfig.BandageAllies then
        return
    end

    cal.debug("Atempting to bandage allies...")
    for _, serial in ipairs(BandageConfig.AlliesSerials) do
        if serial == Player.Serial then
            goto continue
        end

        local ally = Mobiles.FindBySerial(serial)

        -- Check if ally exists, is alive, in range (1 tile), and needs help
        if ally and ally.Hits > 0 and ally.Distance <= 1 then
            if bl.getHpPercentage(ally) <= BandageConfig.BandageAlliesHPThreshould or ally.IsPoisoned then

                cal.debug("Ally " .. ally.Name .. " needs bandage, attempting to bandage...")

                local bandages = getBandages_()
                if not bandages then
                    return
                end

                local isBandagingSuccessful = appyBandages_(ally)
                if not isBandagingSuccessful then
                    return
                end
                
                cal.debug("Bandaging " .. ally.Name)
                
                if BandageStaticConfig.OverheadPauseTime == 0 then
                    cal.info("Bandaging... " .. ally.Name)
                    BandageState.lastOverHeadTime = currentTickTime
                end

                BandageState.isBandaging = isBandagingSuccessful
                BandageState.lastBandageStart = currentTickTime
                BandageState.bandageTimeEnd = bandageOtherEndTime_(BandageState.lastBandageStart)
            end
        end
        ::continue::
    end
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
        BandageState.bandageTimeEnd = bandageSelfEndTime_(currentTickTime)
        BandageState.isBandaging = true
        return
    end

    local playerHpPercentage = bl.getHpPercentage(Player)
    if not Player.IsPoisoned and (playerHpPercentage >= BandageConfig.BandageSelfHPThreshould) then
        cal.debug("Player not poisoned or HP is above threshold, no bandage needed.")
        bandageOther_(currentTickTime)
        return
    end

    if Player.IsPoisoned then
        cal.debug("Using bandages due to previous poison.")
        cal.info("Curing with bandage")
    end

    local isBandagingSuccessful = appyBandages_(nil)
    if not isBandagingSuccessful then
        return
    end

    cal.info("Bandaging self")

    if BandageStaticConfig.OverheadPauseTime == 0 then
        cal.debug("Bandaging...")
        BandageState.lastOverHeadTime = currentTickTime
    end

    BandageState.isBandaging = isBandagingSuccessful
    BandageState.lastBandageStart = currentTickTime
    BandageState.bandageTimeEnd = bandageSelfEndTime_(BandageState.lastBandageStart)
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