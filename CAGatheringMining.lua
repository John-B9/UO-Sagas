----------------------------------------------------------------------
--- Combat Assistant (CA) Gathering Mining
--- Author: JohnB9
---
--- Version: 1.0.0  - Base implementation of mining functionality
---
--- Description: mining functions
----------------------------------------------------------------------

local bl = Import('BaseLib')
local cal = Import('CALog')
local cat = Import('CATime')
local ipmp = Import('IPMaterialPredicates')
local iums = Import('IUMinerSwap')
local cagfsm = Import('CAGatheringFSM')

-----------------
--- Constants ---
-----------------

local GatheringMiningStaticConfig = {
    PickaxeGraphicID = 3718,
    OresGraphicID = 6585
}

GatheringMiningConfig = {
    PickaxeMaterialType = nil,
    OreHuesToKeep = {
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

local function setPickaxeMaterialType_(materialType)
    GatheringMiningConfig.PickaxeMaterialType = materialType
end

local function setOreHuesToKeep_(hues)
    GatheringMiningConfig.OreHuesToKeep = hues
end

-----------------
--- Functions ---
-----------------

local function resetMiningFSM_()
    cagfsm.resetGatheringFSM()
end

local function equipPickaxe_()
    local pickaxe = Items.FindByLayer(1)
    if pickaxe == nil or pickaxe.Graphic ~= GatheringMiningStaticConfig.PickaxeGraphicID then
        iums.minerSwap(GatheringMiningConfig.PickaxeMaterialType)
        pickaxe = Items.FindByLayer(1)
        Pause(cat.getActionWaitTime())
    end
    if pickaxe == nil then
        cal.mainInfo("Missing Pickaxe")
    end
    cagfsm.setToolInUse(pickaxe)
end

local brokePickaxeJournalLog = "You have worn out your tool!"
local noOresNearbyJournalLog = "There is nothing you can harvest nearby."
local nearbyOresDepletedJournalLog = "There is no metal here to mine."
local waitActionJournalLog = "You must wait to perform another action."
local windowOutOfFocus = "Your game window does not have focus"
local normalOresCollectedJournalLog = "ore and put it in your backpack."
local questProgressJournalLog = "Quest progress: Gather"


local tooFarToGatherJournalLog = "You have moved too far away to continue mining."

local failedToGatherJournalLog = "You loosen some rocks but fail to find any usable ore."

local veriteOresCollectedJournalLog = "You mine some verite ore and put them into your backpack."
local valoriteOresCollectedJournalLog = "You mine some valorite ore and put them into your backpack."

local function checkJournal_()

    if Journal.Contains(brokePickaxeJournalLog) then
        cal.mainInfo("Pickaxe broke. Re-equipping...")
        return cagfsm.getGatheringFSMStates().EquipTool
    end

    if Journal.Contains(noOresNearbyJournalLog) then
        cal.mainInfo("No ores nearby...")
        return cagfsm.getGatheringFSMStates().Gather
    end

    if Journal.Contains(nearbyOresDepletedJournalLog) then
        cal.mainInfo("Ores already depleted...")
        return cagfsm.getGatheringFSMStates().Gather
    end

    if Journal.Contains(waitActionJournalLog) or Journal.Contains(windowOutOfFocus) then
        return cagfsm.getGatheringFSMStates().Gather
    end

    if Journal.Contains(normalOresCollectedJournalLog) or Journal.Contains(questProgressJournalLog) then
        cal.mainInfo("Got some Ores...")
        return cagfsm.getGatheringFSMStates().Gather
    end

    return cagfsm.getGatheringFSMStates().WaitingResult
end

local function transitionMiningFSM_()
    local FSMConfigMining = {
        SkillName = "Mining",
        equipTool = equipPickaxe_,
        checkJournal = checkJournal_,
        postTransitionWork = nil,
        materialGraphicID = GatheringMiningStaticConfig.OresGraphicID,
        materialHuesToKeep = GatheringMiningConfig.OreHuesToKeep
    }
    cagfsm.transitionGatheringFSM(FSMConfigMining)
end

--------------
--- Export ---
--------------

local Obj = {
    setPickaxeMaterialType = setPickaxeMaterialType_,
    setOreHuesToKeep = setOreHuesToKeep_,
    resetMiningFSM = resetMiningFSM_,
    transitionMiningFSM = transitionMiningFSM_
}

return Obj