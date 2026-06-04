----------------------------------------------------------------------
--- Combat Assistant (CA) Run Dexer
--- Author: JohnB9
---
--- Version: 1.0.0  - Run Combat Bot with Dexer Config
---
--- Description: Running this script will run Combat Bot with a Dexer
---              main loop configuration
----------------------------------------------------------------------

-----------
--- Run ---
-----------

-- ========================================
-- Imported: CAConfigDexer
-- ========================================

LogConfig = {
    EnableDebugLog = false,
    DebugLogTick = 60,
    EnableDebugTick = false, -- Overrides MainLoopTick in debug mode (script will run much slower)
    DebugTick = 500,
    EnableOverheadMessages = false -- Enables overhead messages, if false then messages will be printed in journal
}

LogStaticConfig = {
    DatePattern = "%H:%M:%S",
    InfoTextColor    = 88,
    WarningTextColor = 34,
    ErrorTextColor   = 53,
    DebugTextColor   = 1153,
}

TimeConfig = {
    ActionWaitTime = 1000 -- in milliseconds, how long to wait for actions like using items, targeting etc.
}

TimeState = {
    currentTickTime = math.floor(os.time() * 1000)
}

function BaseLib_deepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[BaseLib_deepCopy(orig_key)] = BaseLib_deepCopy(orig_value)
        end
        setmetatable(copy, BaseLib_deepCopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

debugEnabled = false

uses_remaining_regex_str = "Uses Remaining: (%d+)"

identification_charges_regex_str = "Identification Charges: (%d+)"

material_regex_str = "Material: (%w+)"

contents_regex_str = "Contents: (%d+)/(%d+) Items"

durability_regex_str = "Durability: (%d+)/(%d+)"

ArmDisarmConfig = {
    Enable  = false, -- Rearms your weapon if you are disarmed
    AlwaysRearm = false -- rearm without moving, warning will spam messages if you drag from hands
}

ArmDisarmStaticConfig = {
    durabilityDisarmThreshould = 0, -- will disarm player and avoid re-arm, if durability <= threshould
    layerOneHanded = 1,
    layerTwoHanded = 2,
    rearmBusrtRequestDelta = 500
}

ArmDisarmState = {
    disarmed = nil,
    disarm = { x = 0, y = 0 },
    lastRightHand = nil,
    lastLeftHand = nil,
    lastRightHandEquipAtemptTime = 0,
    lastLeftHandEquipAtemptTime = 0
}

EscapeConfig = {
    EnablePopPouch = true,
    EnableComand = false,
    EnableMoongate = true,
    MoongateGumpId = 585180759
}

    flaggedForPvp = false,
    moongate = {
        lastTickTime = nil,
        serial = nil,
        previousDistance = nil,
        messageShown = false
    },
}

    Command = "I shall return!", -- The command to say, make it unique to you
    Callback = function() -- Use the assistant and record your way of escaping and paste it below
        Player.UseObject('1110433901')
        Gumps.WaitForGump(1498407526, 1000)
        Gumps.PressButton(1498407526, 26)
        return true
    end
}
