----------------------------------------------------------------------
--- Combat Assistant (CA) Gathering Mining
--- Author: JohnB9
---
--- Version: 1.0.0  - Base implementation of mining functionality
---
--- Description: mining functions
----------------------------------------------------------------------

local cal = Import('CALog')

-----------------
--- Variables ---
-----------------

GatheringMiningConfig = {
}

local GatheringMiningStaticConfig = {
}

local GatheringMiningState = {
}

-----------------
--- Functions ---
-----------------

local function resetMiningFSM_()
    cal.debug("Clearing mining FSM state")
end

local function transitionMiningFSM_()
    cal.debug("Stepping mining FSM")
end

--------------
--- Export ---
--------------

local Obj = {
    resetMiningFSM = resetMiningFSM_,
    transitionMiningFSM = transitionMiningFSM_
}

return Obj