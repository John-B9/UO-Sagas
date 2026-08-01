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
local cagfsm = Import('CAGatheringFSM')

-----------------
--- Constants ---
-----------------

local GatheringLumberjackingStaticConfig = {
    HatchetGraphicID = 3907,
    LogsGraphicID = 7133
}

GatheringLumberjackingConfig = {
    HatchetMaterialType = nil,
    LogHuesToKeep = {
        --- 0x0000,         --- Regular
        --- 0x0973,         --- Dull Copper
        0x0966,         --- Shadow Iron
        0x096D,         --- Copper
        0x0972,             --- Bronze
        0x08A5,             --- Gold
        0x0979,             --- Agapite
        0x089F,             --- Verite
        0x08AB              --- Valorite
    }
}

-----------------
--- Accessors ---
-----------------

local function setHatchetMaterialType_(materialType)
    GatheringLumberjackingConfig.HatchetMaterialType = materialType
end

local function setLogHuesToKeep_(hues)
    GatheringLumberjackingConfig.LogHuesToKeep = hues
end

-----------------
--- Functions ---
-----------------

local function resetLumberjackFSM_()
    cagfsm.resetGatheringFSM()
end

local function equipHatchet_()
    local hatchet = Items.FindByLayer(2)
    if hatchet == nil or hatchet.Graphic ~= GatheringLumberjackingStaticConfig.HatchetGraphicID then
        iuls.lumberjackSwap(ipmp.getAcceptPredicateForMaterialType(GatheringLumberjackingConfig.HatchetMaterialType))
        hatchet = Items.FindByLayer(2)
        Pause(cat.getActionWaitTime())
    end
    if hatchet == nil then
        cal.mainInfo("Missing Hatchet")
    end
    cagfsm.setToolInUse(hatchet)
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

local function checkJournal_()

    if Journal.Contains(brokeAxeJournalLog) then
        cal.mainInfo("Axe broke. Re-equipping...")
        return cagfsm.getGatheringFSMStates().EquipTool
    end

    if Journal.Contains(noTreesNearbyJournalLog) then
        cal.mainInfo("No trees nearby...")
        return cagfsm.getGatheringFSMStates().Gather
    end

    if Journal.Contains(nearbyTreesDepletedJournalLog) then
        cal.mainInfo("Trees already depleted...")
        return cagfsm.getGatheringFSMStates().Gather
    end

    if Journal.Contains(waitActionJournalLog) or Journal.Contains(windowOutOfFocus) then
        return cagfsm.getGatheringFSMStates().Gather
    end

    if Journal.Contains(normalLogsCollectedJournalLog) or Journal.Contains(questProgressJournalLog) then
        cal.mainInfo("Got some Logs...")
        return cagfsm.getGatheringFSMStates().Gather
    end

    return cagfsm.getGatheringFSMStates().WaitingResult
end

local function cutLogs_()
    local logs = bl.findInInventory(GatheringLumberjackingStaticConfig.LogsGraphicID)
    if cagfsm.getToolInUse() ~= nil and logs ~= nil then
        cal.mainInfo("Chopping Logs...")
        for i, item in ipairs(logs) do
            Player.UseObject(cagfsm.getToolInUse().Serial)
            if Target.WaitForTarget(1000) then
                Target.TargetSerial(item.Serial)
            end
            Pause(cat.getActionWaitTime())
        end
    end
end

local function transitionLumberjackFSM_()
    local FSMConfigLumberjacking = {
        SkillName = "Lumberjacking",
        equipTool = equipHatchet_,
        checkJournal = checkJournal_,
        weightThreshouldReachedCallback = cutLogs_,
        materialGraphicID = GatheringLumberjackingStaticConfig.LogsGraphicID,
        materialHuesToKeep = GatheringLumberjackingConfig.LogHuesToKeep
    }
    cagfsm.transitionGatheringFSM(FSMConfigLumberjacking)
end

--------------
--- Export ---
--------------

local Obj = {
    setHatchetMaterialType = setHatchetMaterialType_,
    setLogHuesToKeep = setLogHuesToKeep_,
    resetLumberjackFSM = resetLumberjackFSM_,
    transitionLumberjackFSM = transitionLumberjackFSM_
}

return Obj