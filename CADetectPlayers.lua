----------------------------------------------------------------------
--- Combat Assistant (CA) Detect Players
--- Author: JohnB9
---
--- Mentions: Halesluker  - Base script
---
--- Version: 1.0.0  - Module separation of Base script
---
--- Description: Detect Players functions
----------------------------------------------------------------------

local cal = Import('CALog')
local cat = Import('CATime')

-----------------
--- Variables ---
-----------------

DetectPlayersConfig = {
    Enable = false
}

local DetectPlayersStaticConfig = {
    Players = { "oFrizz", "FloodgateUO", "Lespunk Strange", "Vector", "BTK", "RDY", "BRG", "URK" },
    AlertPauseTime = 10 * 1000 -- alert once per 10 seconds
}

local DetectPlayersState = {
    lastTickTime = 0,
    lastOverheadTime = 0
}

---------------
--- Setters ---
---------------

local function setEnable_(val)
    DetectPlayersConfig.Enable = val
end

local function setConfig_(config)
    setEnable_(config.Enable)
end

-----------------
--- Functions ---
-----------------

local function detectPlayers_()

    if not DetectPlayersConfig.Enable then
        return
    end

    local currentTickTime = cat.getCurrentTickTime()

    cal.debug("Hunting for players...")

    DetectPlayersState.lastTickTime = currentTickTime

    local isWarningTimeExceeded = cat.exceedsDuration(DetectPlayersState.lastOverheadTime, currentTickTime, DetectPlayersStaticConfig.AlertPauseTime)
    if not isWarningTimeExceeded then
        cal.debug("Last player detection notification was too recent, skipping")
        return
    end

    for index, playerName in ipairs(DetectPlayersStaticConfig.Players) do
        cal.debug("Looking for player " .. index .. "... ")
        if Journal.Contains(playerName) then
            cal.info("Hunted player " .. playerName)
            DetectPlayersState.lastOverheadTime = currentTickTime
        end
    end

end

--------------
--- Export ---
--------------

local Obj = {
    setEnable = setEnable_,
    setConfig = setConfig_,
    detectPlayers = detectPlayers_
}

return Obj