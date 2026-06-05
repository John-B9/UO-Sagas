----------------------------------------------------------------------
--- Combat Assistant (CA) Attack
--- Author: JohnB9
---
--- Mentions: omgarturo  - workarounds for API limitations + extras
--- 
--- Version: 1.0.0  - Base Implementation
---
--- Description: Attack functions
----------------------------------------------------------------------

local bl = Import('BaseLib')
local cal = Import('CALog')
local cat = Import('CATime')

-----------------
--- Variables ---
-----------------

AttackConfig = {
    Enable = false,
    Rangemax = 10,
    MobilesExceptionsSerials = nil,
    MobilesExceptionsGraphicIDs = nil,
    MobilesExceptionsNames = nil,
    CheckFrequency = 3000
}

local AttackState = {
    lastCheckTickTime = nil
}

-----------------
--- Accessors ---
-----------------

local function setEnable_(val)
    AttackConfig.Enable = val
end

local function setRangemax_(val)
    AttackConfig.Rangemax = val
end

local function setMobilesExceptionSerialsList_(val)
    AttackConfig.MobilesExceptionsSerials = val
end

local function setMobilesExceptionGraphicIDsList_(val)
    AttackConfig.MobilesExceptionsGraphicIDs = val
end

local function setMobilesExceptionNamesList_(val)
    AttackConfig.MobilesExceptionsNames = val
end

local function setCheckFrequency_(val)
    AttackConfig.CheckFrequency = val
end

local function setConfig_(config)
    setEnable_(config.Enable)
    setRangemax_(config.Rangemax)
    setMobilesExceptionSerialsList_(config.MobilesExceptionsSerials)
    setMobilesExceptionGraphicIDsList_(config.MobilesExceptionsGraphicIDs)
    setMobilesExceptionNamesList_(config.MobilesExceptionsNames)
    setCheckFrequency_(config.CheckFrequency)
end

-----------------
--- Functions ---
-----------------

local function nearestMosttHitMobileFirstComparePredicate_(mobile_l, mobile_r)
    if mobile_l.Distance == mobile_r.Distance then
        if mobile_l.DiffHits == mobile_r.DiffHits then
            return (mobile_l.Name or "") < (mobile_r.Name or "")
        end
        return mobile_l.DiffHits > mobile_r.DiffHits
    end
    return mobile_l.Distance < mobile_r.Distance
end

local function targetAcceptPredicate_(mobile)

    if mobile.IsDead then
        return false
    end
    
    if mobile.NotorietyFlag == "Innocent" or mobile.NotorietyFlag == "Ally" or mobile.NotorietyFlag == "Invulnerable" then
        return false
    end

    if mobile.Graphic == 0x0009 and mobile.Hue == 0x0000 then       --- Don't atack deamon summons
        return false
    end

    if bl.equalsAnyInTable(mobile.Serial, AttackConfig.MobilesExceptionsSerials) then
        return false
    end

    if bl.equalsAnyInTable(mobile.Graphic, AttackConfig.MobilesExceptionsGraphicIDs) then
        return false
    end

    if bl.equalsAnyInTable(mobile.Name, AttackConfig.MobilesExceptionsNames) then
        return false
    end

    return true
end

local function attackNearestEnemy_()

    if AttackConfig.Enable == false then
        return false
    end

    local currentTickTime = cat.getCurrentTickTime()
    if AttackState.lastCheckTickTime and not cat.exceedsDuration(AttackState.lastCheckTickTime, currentTickTime, AttackConfig.CheckFrequency) then
        cal.debug("Attack on cooldown: last atack check tick ("..AttackState.lastCheckTickTime..
            "), current ("..currentTickTime..
            "), elapsed ("..(currentTickTime-AttackState.lastCheckTickTime)..
            "), target ("..AttackConfig.CheckFrequency..")")
        return false
    end
    AttackState.lastCheckTickTime = currentTickTime

    cal.debug('Searching for attack targets')
    local filter = { rangemax = AttackConfig.Rangemax, notorieties = { 0, 3, 4, 5, 6} }
    local list = Mobiles.FindByFilter(filter)
    for index, mobile in ipairs(list) do
        cal.debug('Found mobile ('..mobile.Name..') at location x:'..mobile.X..' y:'..mobile.Y)
    end
        
    cal.debug('Removing unwanted targets')
    for i = #list, 1, -1 do
        if not targetAcceptPredicate_(list[i]) then
            table.remove(list, i)
        end
    end

    local mobileTarget = nil
    if #list > 0 then

        cal.debug('Sorting attack targets')
        table.sort(list, nearestMosttHitMobileFirstComparePredicate_)
        for index, mobile in ipairs(list) do
            cal.debug('Found mobile ('..mobile.Name..') at location x:'..mobile.X..' y:'..mobile.Y)
        end

        cal.debug('Choosing attack target')
        for index, mobile in ipairs(list) do
            if mobile.Serial ~= Player.Serial then
                mobileTarget = mobile
                break
            end
        end
    end

    if mobileTarget then
        cal.debug('Attacking ('..mobileTarget.Name..') at location x:'..mobileTarget.X..' y:'..mobileTarget.Y)
        Player.Attack(mobileTarget.Serial)
    else
        cal.debug('Found no target to attack')
    end

    return true
end

local function attack_()
    return attackNearestEnemy_()
end

--------------
--- Export ---
--------------

local Obj = {
    setEnable = setEnable_,
    setConfig = setConfig_,
    attack = attack_
}

return Obj