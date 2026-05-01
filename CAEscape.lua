----------------------------------------------------------------------
--- Combat Assistant (CA) Escape
--- Author: JohnB9
---
--- Mentions: Halesluker  - Base script
---
--- Version: 1.0.0  - Module separation of Base script
---
--- Description: Escape functions
----------------------------------------------------------------------

local cal = Import('CALog')
local cat = Import('CATime')

-----------------
--- Variables ---
-----------------

EscapeConfig = {
    EnablePopPouch = true,
    EnableComand = false,
    EnableMoongate = true,
    MoongateGumpId = 585180759
}

local EscapeState = {
    flaggedForPvp = false,
    moongate = {
        lastTickTime = nil,
        serial = nil,
        previousDistance = nil,
        messageShown = false
    },
}

local EscapeCommandStaticConfig = {
    Command = "I shall return!", -- The command to say, make it unique to you
    Callback = function() -- Use the assistant and record your way of escaping and paste it below
        Player.UseObject('1110433901')
        Gumps.WaitForGump(1498407526, 1000)
        Gumps.PressButton(1498407526, 26)
        return true
    end
}

---------------
--- Setters ---
---------------

local function setEnablePopPouch_(val)
    EscapeConfig.EnablePopPouch = val
end

local function setEnableComand_(val)
    EscapeConfig.EnableComand = val
end

local function setEnableMoongate_(val)
    EscapeConfig.EnableMoongate = val
end

local function setConfig_(config)
    setEnablePopPouch_(EscapeConfig.EnablePopPouch)
    setEnableComand_(EscapeConfig.EnableComand)
    setEnableMoongate_(EscapeConfig.EnableMoongate)
end

-----------------
--- Functions ---
-----------------

local function popPouch_()

    if not EscapeConfig.EnablePopPouch then
        return
    end

    if Journal.Contains("You are now PvP-Combat flagged!") then
        EscapeState.flaggedForPvp = true
    end

    if Journal.Contains("You are no longer PvP-Combat flagged!") then
        EscapeState.flaggedForPvp = false
    end

    cal.debug("Checking pop-pouch...")
    if EscapeState.flaggedForPvp and Player.IsParalyzed and Journal.Contains("You cannot move!") then
        cal.debug("Player is paralyzed, popping pouch.")
        cal.info("Popping pouch")
        Player.PopPouch()
    end

end

local function escape_()

    if not EscapeConfig.EnableComand then
        return
    end

    if Player.IsDead then
        cal.debug("Player is dead, skipping escape.")
        return
    end

    if Player.IsHidden then
        cal.debug("Player is hiding, skipping escape.")
        return
    end

    local command = EscapeCommandStaticConfig.Command
    if not Journal.Contains(command) then
        return
    end

    local callback = EscapeCommandStaticConfig.Callback

    cal.debug("Checking escape command...")
    if callback and type(callback) == "function" then
        cal.debug("Running escape callback function")
        cat.pauseUntil(callback, 50, cat.getActionWaitTime())
    end

end

-- Based on Jase's moongate script: https://uoaddicts.com/script/escape-moongate-m-cm6micvh
local function moongate_()

    if not EscapeConfig.EnableMoongate then
        return
    end

    local currentTickTime = cat.getCurrentTickTime()

    if not cat.exceedsDuration(EscapeState.moongate.lastTickTime, currentTickTime, 1000) then
        cal.debug("Moongate check is not ready yet, skipping")
        return
    end

    cal.debug("Checking escape command...")
    EscapeState.moongate.lastTickTime = currentTickTime

    local gate = Items.FindByName('Moongate')

    if not gate then
        EscapeState.moongate.serial = nil
        EscapeState.moongate.previousDistance = nil
        EscapeState.moongate.messageShown = false
        return
    end

    if EscapeState.moongate.serial ~= gate.Serial then
        EscapeState.moongate.serial = gate.Serial
        EscapeState.moongate.previousDistance = gate.Distance
        EscapeState.moongate.messageShown = false
        return
    end

    if EscapeState.moongate.previousDistance == nil then
        EscapeState.moongate.previousDistance = gate.Distance
    end

    local movingTowardGate = gate.Distance < EscapeState.moongate.previousDistance
    local isNearGate = gate.Distance <= 10
    local movedAway = gate.Distance > 10

    if movedAway and EscapeState.moongate.messageShown then
        EscapeState.moongate.messageShown = false
        cal.debug("Moved away from moongate, resetting message flag")
    end

    if (movingTowardGate or isNearGate) and not EscapeState.moongate.messageShown then
        cal.info("Found moongate")
        EscapeState.moongate.messageShown = true
    end

    EscapeState.moongate.previousDistance = gate.Distance

    if gate.Distance > 2 then
        cal.debug("Moongate is too far away, skipping")
        return
    end

    if Gumps.IsActive(EscapeConfig.MoongateGumpId) then
        cal.info("Click destination")
    else
        Player.UseObject(gate.Serial)
    end

    if Gumps.WaitForGump(EscapeConfig.MoongateGumpId, cat.getActionWaitTime()) then
        cal.info("Trying to travel")
        Gumps.PressButton(EscapeConfig.MoongateGumpId, 1)
    end

end

--------------
--- Export ---
--------------

local Obj = {
    setEnablePopPouch = setEnablePopPouch_,
    setEnableEscape = setEnableEscape_,
    setEnableMoongate = setEnableMoongate_,
    setConfig = setConfig_,
    popPouch = popPouch_,
    escape = escape_,
    moongate = moongate_
}

return Obj