----------------------------------------------------------------------
--- Combat Assistant (CA) GatheringFSM
--- Author: JohnB9
---
--- Version: 1.0.0  - Base implementation
---
--- Description: Gathering generic Finite State Machine
----------------------------------------------------------------------

local bl = Import('BaseLib')
local cal = Import('CALog')
local cat = Import('CATime')

-----------------
--- Constants ---
-----------------

local GatheringFSMStates = {
    EquipTool = 1,
    Gather = 2,
    WaitingResult = 3
}

local GatheringFSMStatesStrings = {
    "EquipTool",
    "Gather",
    "WaitingResult"
}

-----------------
--- Variables ---
-----------------

local GatheringFSMConfigStatic = {
    NoisyMode = true,
    WeightTolerance = 10,
    GatheringWaitTimeout = 4000
}

GatheringFSMState = {
    FSMState = GatheringFSMStates.EquipTool,
    ToolInUse = nil,
    LastWaitingGatheringStartTime = nil
}

-----------------
--- Accessors ---
-----------------

local function getGatheringFSMStates_()
    return GatheringFSMStates
end

local function getToolInUse_()
    return GatheringFSMState.ToolInUse
end

local function setToolInUse_(tool)
    GatheringFSMState.ToolInUse = tool
end

-----------------
--- Functions ---
-----------------

local function resetGatheringFSM_()
    cal.debug("Clearing gathering FSM state")
    GatheringFSMState.FSMState = GatheringFSMStates.EquipTool
    GatheringFSMState.ToolInUse = nil
    GatheringFSMState.LastWaitingGatheringStartTime = nil
end

local function weightThreshouldReached_()
    return Player.Weight > Player.MaxWeight - GatheringFSMConfigStatic.WeightTolerance
end

local function announceFoundMaterial_(material, keep)
    local msgPrefix = keep and "+ " or "- "
    local msgSufix = keep and " +" or " -"
    if GatheringFSMConfigStatic.NoisyMode then
        Player.Say(msgPrefix .. material.Name .. msgSufix, 48)
    else
        cal.mainInfo(msgPrefix .. material.Name .. " " .. msgSufix)
    end
end

local function dropUnwantedMaterials_(materialGraphicID, materialHuesToKeep)
    local materials = bl.findInInventory(materialGraphicID)
    for _, material in ipairs(materials) do
        local keepMaterial = bl.tableContains(materialHuesToKeep, material.Hue)
        if not keepMaterial then
            Player.PickUp(material.Serial, material.Amount)
            Player.DropOnGround()
            Pause(0.5 * cat.getActionWaitTime())
        end
        announceFoundMaterial_(material, keepMaterial)
    end
end

local function transitionGatheringFSM_(FSMConfig)
    
    local currentState = GatheringFSMState.FSMState
    local currentStateString = GatheringFSMStatesStrings[currentState]
    cal.debug("Transitioning Gathering FSM (".. FSMConfig.SkillName ..") -> (Current state: " .. currentStateString .. ")")

    if currentState == GatheringFSMStates.EquipTool then

        FSMConfig.equipTool()
        if GatheringFSMState.ToolInUse ~= nil then
            GatheringFSMState.FSMState = GatheringFSMStates.Gather
        end

    elseif currentState == GatheringFSMStates.Gather then
        
        Player.UseObject(GatheringFSMState.ToolInUse.Serial)
        if Target.WaitForTarget(1000) then
            Target.Self()
        end
        Pause(cat.getActionWaitTime())
        GatheringFSMState.FSMState = FSMConfig.checkJournal()

    elseif currentState == GatheringFSMStates.WaitingResult then

        if GatheringFSMState.LastWaitingGatheringStartTime == nil then
            GatheringFSMState.LastWaitingGatheringStartTime = cat.getCurrentTickTime()
        end

        GatheringFSMState.FSMState = FSMConfig.checkJournal()

        if GatheringFSMState.FSMState ~= GatheringFSMStates.WaitingResult then
            GatheringFSMState.LastWaitingGatheringStartTime = nil
        else
            local currentTickTime = cat.getCurrentTickTime()
            local exceedsDuration = cat.exceedsDuration(GatheringFSMState.LastWaitingGatheringStartTime, currentTickTime, GatheringFSMConfigStatic.GatheringWaitTimeout)
            if exceedsDuration then
                cal.debug("Gathering timeout reached...")
                GatheringFSMState.FSMState = GatheringFSMStates.Gather      --- We are probably stuck waiting for a journal entry that will never come, so let's try to gather again
                GatheringFSMState.LastWaitingGatheringStartTime = nil
            end
        end

    end
    
    if weightThreshouldReached_() then
        dropUnwantedMaterials_(FSMConfig.materialGraphicID, FSMConfig.materialHuesToKeep)
        if FSMConfig.weightThreshouldReachedCallback ~= nil then
            FSMConfig.weightThreshouldReachedCallback()
        end
    end
    
    if weightThreshouldReached_() then
        cal.mainInfo("I need to find a bank")
    end

    cal.debug("Transitioning gathering FSM (".. FSMConfig.SkillName ..") -> (End state: " .. GatheringFSMStatesStrings[GatheringFSMState.FSMState] .. ")")

end

--------------
--- Export ---
--------------

local Obj = {
    getGatheringFSMStates = getGatheringFSMStates_,
    getToolInUse = getToolInUse_,
    setToolInUse = setToolInUse_,
    resetGatheringFSM = resetGatheringFSM_,
    transitionGatheringFSM = transitionGatheringFSM_
}

return Obj