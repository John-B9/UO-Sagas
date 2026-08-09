----------------------------------------------------------------------
--- Combat Assistant (CA) Gathering
--- Author: JohnB9
---
--- Version: 1.0.0  - Base implementation of gathering functionality
---
--- Description: Gathering functions
----------------------------------------------------------------------

local cal = Import('CALog')
local cagl = Import('CAGatheringLumberjacking')
local cagm = Import('CAGatheringMining')

-----------------
--- Variables ---
-----------------

GatheringConfig = {
    MiningModeActive = false,
    LumberjackingModeActive = false,
    ConfigChangedListenersCallbacks = {}
}

---------------
--- Setters ---
---------------

local function setConfig_(config)
    cagl.setConfig(config)
    cagm.setConfig(config)
end

-----------------
--- Functions ---
-----------------

local function registerConfigChangedListenersCallback_(callback)
    table.insert(GatheringConfig.ConfigChangedListenersCallbacks, callback)
end

local function runConfigChangedListenersCallbacks_()
    for _, callback in ipairs(GatheringConfig.ConfigChangedListenersCallbacks) do
        callback(GatheringConfig.LumberjackingModeActive, GatheringConfig.MiningModeActive)
    end
end

local function resetGatheringFSM_()
    cal.debug("Clearing gathering FSM state")
    cagl.resetLumberjackFSM()
    cagm.resetMiningFSM()
end

local function disableGatheringModes_()
    cal.debug("Disabling all gathering modes")
    GatheringConfig.MiningModeActive = false
    GatheringConfig.LumberjackingModeActive = false
    resetGatheringFSM_()
end

local function toggleMiningMode_()
    local newState = not GatheringConfig.MiningModeActive
    disableGatheringModes_()
    cal.mainInfo("Toggling Mining Mode to: " .. tostring(newState))
    GatheringConfig.MiningModeActive = newState
    runConfigChangedListenersCallbacks_()
end

local function toggleLumberjackingMode_()
    local newState = not GatheringConfig.LumberjackingModeActive
    disableGatheringModes_()
    cal.mainInfo("Toggling Lumberjacking Mode to: " .. tostring(newState))
    GatheringConfig.LumberjackingModeActive = newState
    runConfigChangedListenersCallbacks_()
end

local function gather_()
    if not GatheringConfig.MiningModeActive and not GatheringConfig.LumberjackingModeActive then
        cal.debug("No gathering mode is active...")
        return
    end
    cal.debug("Gathering resources")
    if GatheringConfig.MiningModeActive then
        cagm.transitionMiningFSM()
    elseif GatheringConfig.LumberjackingModeActive then
        cagl.transitionLumberjackFSM()
    end
end

--------------
--- Export ---
--------------

local Obj = {
    setConfig = setConfig_,
    registerConfigChangedListenersCallback = registerConfigChangedListenersCallback_,
    toggleMiningMode = toggleMiningMode_,
    toggleLumberjackingMode = toggleLumberjackingMode_,
    gather = gather_
}

return Obj