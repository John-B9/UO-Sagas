----------------------------------------------------------------------
--- Combat Assistant (CA) Gathering Lumberjacking
--- Author: JohnB9
---
--- Version: 1.0.0  - Base implementation of lumberjacking
---                   functionality
---
--- Description: lumberjacking functions
----------------------------------------------------------------------

local bl = Import('BaseLib')
local cal = Import('CALog')
local cat = Import('CATime')
local ipmp = Import('IPMaterialPredicates')
local iuls = Import('IULumberjackSwap')

-----------------
--- Constants ---
-----------------

local LumberjackingFSMStates = {
    EquipHatchet = 1,
    Chop = 2,
    WaitingForChop = 3
}

local LumberjackingFSMStatesStrings = {
    "EquipHatchet",
    "Chop",
    "WaitingForChop"
}

local GatheringLumberjackingStaticConfig = {
    HatchetGraphicID = 3907,
    LogsGraphicID = 7133,
    WeightLogCutThreshold = 10
}

-----------------
--- Variables ---
-----------------

GatheringLumberjackingState = {
    FSMState = LumberjackingFSMStates.EquipHatchet,
    HatchetInUse = nil
}

-----------------
--- Functions ---
-----------------

local function resetLumberjackFSM_()
    cal.debug("Clearing lumberjacking FSM state")
    GatheringLumberjackingState.FSMState = LumberjackingFSMStates.EquipHatchet
    GatheringLumberjackingState.HatchetInUse = nil
end

local function equipHatchet_()
    local hatchet = Items.FindByLayer(2)
    if hatchet == nil or hatchet.Graphic ~= GatheringLumberjackingStaticConfig.HatchetGraphicID then
        iuls.lumberjackSwap(ipmp.itemIsOfIron, nil)
        hatchet = Items.FindByLayer(2)
        Pause(cat.getActionWaitTime())
    end
    if hatchet == nil then
        cal.mainInfo("Missing Hatchet")
    end
    GatheringLumberjackingState.HatchetInUse = hatchet
end

local brokeAxeJournalLog = "You broke your axe."
local noTreesNearbyJournalLog = "There is nothing you can harvest nearby."
local nearbyTreesDepletedJournalLog = "There's not enough wood here to harvest."
local waitActionJournalLog = "You must wait to perform another action."
local windowOutOfFocus = "Your game window does not have focus"
local normalLogsCollectedJournalLog = "logs and put them into your backpack."
local questProgressJournalLog = "Quest progress: Gather"

local failedToGatherJournalLog = "You hack at the tree for a while"

local veriteLogsCollectedJournalLog = "You chop some verite logs and put them into your backpack."
local valoriteLogsCollectedJournalLog = "You chop some valorite logs and put them into your backpack."

local function checkJournal()

    if Journal.Contains(brokeAxeJournalLog) then
        cal.mainInfo("Axe broke. Re-equipping...")
        return LumberjackingFSMStates.EquipHatchet
    end

    if Journal.Contains(noTreesNearbyJournalLog) then
        cal.mainInfo("No trees nearby...")
        return LumberjackingFSMStates.Chop
    end

    if Journal.Contains(nearbyTreesDepletedJournalLog) then
        cal.mainInfo("Trees already depleted...")
        return LumberjackingFSMStates.Chop
    end

    if Journal.Contains(waitActionJournalLog) or Journal.Contains(windowOutOfFocus) then
        ---cal.mainInfo("Trees already depleted...")
        return LumberjackingFSMStates.Chop
    end

    if Journal.Contains(normalLogsCollectedJournalLog) or Journal.Contains(questProgressJournalLog) then
        cal.mainInfo("Got some Logs...")
        return LumberjackingFSMStates.Chop
    end

    return LumberjackingFSMStates.WaitingForChop
end

local function weightThreshouldReached_()
    return Player.Weight > Player.MaxWeight - GatheringLumberjackingStaticConfig.WeightLogCutThreshold
end

local function checkWeightAndCutLogs_()
    if weightThreshouldReached_() then
        --- Check and cut logs
        local logs = bl.findInInventory(GatheringLumberjackingStaticConfig.LogsGraphicID)
        if GatheringLumberjackingState.HatchetInUse ~= nil and logs ~= nil then
            cal.mainInfo("Chopping Logs...")
            for i, item in ipairs(logs) do
                Player.UseObject(GatheringLumberjackingState.HatchetInUse.Serial)
                if Target.WaitForTarget(1000) then
                    Target.TargetSerial(item.Serial)
                end
                Pause(cat.getActionWaitTime())
            end
        else
            cal.mainInfo("I need to find a bank")
        end
    end
end

local function transitionLumberjackFSM_()

    local currentState = GatheringLumberjackingState.FSMState
    local currentStateString = LumberjackingFSMStatesStrings[currentState]
    cal.debug("Transitioning lumberjacking FSM (Current state: " .. currentStateString .. ")")

    if currentState == LumberjackingFSMStates.EquipHatchet then

        equipHatchet_()
        if GatheringLumberjackingState.HatchetInUse ~= nil then
            GatheringLumberjackingState.FSMState = LumberjackingFSMStates.Chop
        end

    elseif currentState == LumberjackingFSMStates.Chop then
        
        Player.UseObject(GatheringLumberjackingState.HatchetInUse.Serial)
        if Target.WaitForTarget(1000) then
            Target.Self()
        end
        Pause(cat.getActionWaitTime())
        GatheringLumberjackingState.FSMState = checkJournal()

    elseif currentState == LumberjackingFSMStates.WaitingForChop then

        GatheringLumberjackingState.FSMState = checkJournal()

    end
    
    checkWeightAndCutLogs_()

    cal.debug("Transitioning lumberjacking FSM (End state: " .. LumberjackingFSMStatesStrings[GatheringLumberjackingState.FSMState] .. ")")

end

--------------
--- Export ---
--------------

local Obj = {
    resetLumberjackFSM = resetLumberjackFSM_,
    transitionLumberjackFSM = transitionLumberjackFSM_
}

return Obj