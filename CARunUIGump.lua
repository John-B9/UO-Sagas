----------------------------------------------------------------------
--- Combat Assistant (CA) Run UI Gump
--- Author: JohnB9
---
--- Version: 1.1.0  - Base UI implementation and main loop integration
---
--- Description: Methods for launching the Combat Assistant UI Gump
---              Will need to be given a main loop configuration
----------------------------------------------------------------------

local cal = Import('CALog')
local caml = Import('CAMainLoop')
local capn = Import('CAPotionsNightsight')

-----------------
--- Variables ---
-----------------

local RunUIGumpState = {
    IterateCAMainLoop = false,
    OverrideWithNoBuffs = false,
    OverrideWithNoCommands = false,
    OverrideWithNoAttacks = true,
    OverrideWithNoScavenger = true,
    ScavengerConfigOpen = true,
    ScavengerAllowGold = true,
    ScavengerAllowBones = true,
    ScavengerAllowGrimoire = true
}

local mainWindow = nil
local titleLabel = nil
local runButton = nil
local runStatusLabel = nil
local activateBuffsButton = nil
local buffsStatusLabel = nil
local activateCommandsButton = nil
local commandsStatusLabel = nil
local activateAttacksButton = nil
local attackStatusLabel = nil
local activateScavengerButton = nil
local scavengerStatusLabel = nil
local scavengerConfigButton = nil

local scavengerConfigWindow = nil
local activateScavengerGoldButton = nil
local activateScavengerBonesButton = nil
local activateScavengerGrimoireButton = nil

-----------------
--- Functions ---
-----------------

function onRunCombatAssistantButtonPressed_(isChecked)
    cal.debug('Run checkbox changed: '..tostring(isChecked))
    RunUIGumpState.IterateCAMainLoop = isChecked
    if isChecked then
        runStatusLabel:SetText('Running')
        runStatusLabel:SetColor(0, 1, 0, 1)
    else
        runStatusLabel:SetText('Stopped')
        runStatusLabel:SetColor(1, 0, 0, 1)
    end
end

function onOverrideWithNoBuffsButtonPressed_(isChecked)
    cal.debug('Buffs disabled checkbox changed: '..tostring(isChecked))
    RunUIGumpState.OverrideWithNoBuffs = not isChecked
    if isChecked then
        buffsStatusLabel:SetText('Enabled')
        buffsStatusLabel:SetColor(0, 1, 0, 1)
    else
        buffsStatusLabel:SetText('Disabled')
        buffsStatusLabel:SetColor(1, 0, 0, 1)
    end
end

function onOverrideWithNoCommandsButtonPressed_(isChecked)
    cal.debug('Commands disabled checkbox changed: '..tostring(isChecked))
    RunUIGumpState.OverrideWithNoCommands = not isChecked
    if isChecked then
        commandsStatusLabel:SetText('Enabled')
        commandsStatusLabel:SetColor(0, 1, 0, 1)
    else
        commandsStatusLabel:SetText('Disabled')
        commandsStatusLabel:SetColor(1, 0, 0, 1)
    end
end

function onAttackButtonPressed_(isChecked)
    cal.debug('Attack disabled checkbox changed: '..tostring(isChecked))
    RunUIGumpState.OverrideWithNoAttacks = not isChecked
    if isChecked then
        attackStatusLabel:SetText('Enabled')
        attackStatusLabel:SetColor(0, 1, 0, 1)
    else
        attackStatusLabel:SetText('Disabled')
        attackStatusLabel:SetColor(1, 0, 0, 1)
    end
end

function onScavengerButtonPressed_(isChecked)
    cal.debug('Scavenger disabled checkbox changed: '..tostring(isChecked))
    RunUIGumpState.OverrideWithNoScavenger = not isChecked
    if isChecked then
        scavengerStatusLabel:SetText('Enabled')
        scavengerStatusLabel:SetColor(0, 1, 0, 1)
    else
        scavengerStatusLabel:SetText('Disabled')
        scavengerStatusLabel:SetColor(1, 0, 0, 1)
    end
end

function onScavengerConfigButtonPressed_(isChecked)
    cal.debug('Scavenger config checkbox changed: '..tostring(isChecked))
    RunUIGumpState.ScavengerConfigOpen = isChecked
    if isChecked then
        scavengerConfigButton:SetText('+')
        scavengerConfigWindow:Hide()
    else
        scavengerConfigButton:SetText('-')
        scavengerConfigWindow:Show()
    end
end

function onScavengerGoldButtonPressed_(isChecked)
    cal.debug('Scavenger allow gold checkbox changed: '..tostring(isChecked))
    RunUIGumpState.ScavengerAllowGold = isChecked
    if isChecked then
        activateScavengerGoldButton:SetText('Gold (Y)')
    else
        activateScavengerGoldButton:SetText('Gold (N)')
    end
end

function onScavengerBonesButtonPressed_(isChecked)
    cal.debug('Scavenger allow bones checkbox changed: '..tostring(isChecked))
    RunUIGumpState.ScavengerAllowBones = isChecked
    if isChecked then
        activateScavengerBonesButton:SetText('Bones (Y)')
    else
        activateScavengerBonesButton:SetText('Bones (N)')
    end
end

function onScavengerGrimoireButtonPressed_(isChecked)
    cal.debug('Scavenger allow grimoire checkbox changed: '..tostring(isChecked))
    RunUIGumpState.ScavengerAllowGrimoire = isChecked
    if isChecked then
        activateScavengerGrimoireButton:SetText('Grimoires (Y)')
    else
        activateScavengerGrimoireButton:SetText('Grimoires (N)')
    end
end

local function processUIGumpInteractions_()

    if runButton:WasClicked() then
        onRunCombatAssistantButtonPressed_(not RunUIGumpState.IterateCAMainLoop)
    end

    if activateBuffsButton:WasClicked() then
        onOverrideWithNoBuffsButtonPressed_(RunUIGumpState.OverrideWithNoBuffs)
    end

    if activateCommandsButton:WasClicked() then
        onOverrideWithNoCommandsButtonPressed_(RunUIGumpState.OverrideWithNoCommands)
    end

    if activateAttacksButton:WasClicked() then
        onAttackButtonPressed_(RunUIGumpState.OverrideWithNoAttacks)
    end

    if activateScavengerButton:WasClicked() then
        onScavengerButtonPressed_(RunUIGumpState.OverrideWithNoScavenger)
    end

    if scavengerConfigButton:WasClicked() then
        onScavengerConfigButtonPressed_(not RunUIGumpState.ScavengerConfigOpen)
    end

    --- Scavenging Config Window
    if activateScavengerGoldButton:WasClicked() then
        onScavengerGoldButtonPressed_(not RunUIGumpState.ScavengerAllowGold)
    end

    if activateScavengerBonesButton:WasClicked() then
        onScavengerBonesButtonPressed_(not RunUIGumpState.ScavengerAllowBones)
    end

    if activateScavengerGrimoireButton:WasClicked() then
        onScavengerGrimoireButtonPressed_(not RunUIGumpState.ScavengerAllowGrimoire)
    end
end

local function updateCombatAssistantConfig_(CAConfig)

    --- Override values
    CAConfig.modules.Buffs.Enable = not RunUIGumpState.OverrideWithNoBuffs
    CAConfig.userCommands.Enable = not RunUIGumpState.OverrideWithNoCommands
    CAConfig.modules.Attack.Enable = not RunUIGumpState.OverrideWithNoAttacks
    CAConfig.modules.Scavenging.Enable = not RunUIGumpState.OverrideWithNoScavenger
    CAConfig.modules.Scavenging.DisallowGold = not RunUIGumpState.ScavengerAllowGold
    CAConfig.modules.Scavenging.DisallowBones = not RunUIGumpState.ScavengerAllowBones
    CAConfig.modules.Scavenging.DisallowGrimoire = not RunUIGumpState.ScavengerAllowGrimoire

    --- Because of internal error, nightsight may disable itself (don't override that part)
    CAConfig.modules.Buffs.Nightsight.Enable = capn.getEnable()

    --- Configure again to save information
    caml.configure(CAConfig)

    cal.debug(''
    ..'Updating Combat Assistant Config:'
    ..'\n - Buffs Enabled: '..tostring(CAConfig.modules.Buffs.Enable)
    ..'\n - User Commands Enabled: '..tostring(CAConfig.userCommands.Enable)
    ..'\n - Attack Enabled: '..tostring(CAConfig.modules.Attack.Enable)
    ..'\n - Scavenging Enabled: '..tostring(CAConfig.modules.Scavenging.Enable)
    )
end

local function initMainGump_()

    cal.debug('Initializing main gump...')
    mainWindow = UI.CreateWindow('mainWindow', 'SAGAS Combat Assistant')
    if not mainWindow then
        cal.debug('Failed to create main gump!')
        return
    end

    cal.debug('Initializing Main Window...')
    mainWindow:SetPosition(200, 200)
    mainWindow:SetSize(270, 320)

    titleLabel = mainWindow:AddLabel(10, 40, 'SAGAS Combat Assistant')
    titleLabel:SetColor(0.2, 0.8, 1, 1)

    cal.debug('Initializing Run Checkbox...')
    runButton = mainWindow:AddButton(10, 70, 'Run', 80, 30)
    runStatusLabel = mainWindow:AddLabel(140, 78, 'Stopped')
    runStatusLabel:SetColor(1, 0, 0, 1)

    cal.debug('Initializing Buffs Checkbox...')
    activateBuffsButton = mainWindow:AddButton(10, 120, 'Buffs', 100, 30)
    buffsStatusLabel = mainWindow:AddLabel(140, 128, 'Enabled')
    buffsStatusLabel:SetColor(0, 1, 0, 1)

    cal.debug('Initializing Commands Checkbox...')
    activateCommandsButton = mainWindow:AddButton(10, 170, 'Commands', 100, 30)
    commandsStatusLabel = mainWindow:AddLabel(140, 178, 'Enabled')
    commandsStatusLabel:SetColor(0, 1, 0, 1)

    cal.debug('Initializing Attack Checkbox...')
    activateAttacksButton = mainWindow:AddButton(10, 220, 'Attack', 100, 30)
    attackStatusLabel = mainWindow:AddLabel(140, 228, 'Disabled')
    attackStatusLabel:SetColor(1, 0, 0, 1)

    cal.debug('Initializing Scavenger Checkbox...')
    activateScavengerButton = mainWindow:AddButton(10, 270, 'Scavenge', 100, 30)
    scavengerStatusLabel = mainWindow:AddLabel(140, 278, 'Disabled')
    scavengerStatusLabel:SetColor(1, 0, 0, 1)

    cal.debug('Initializing Scavenger Config Button...')
    scavengerConfigButton = mainWindow:AddButton(220, 270, '+', 30, 30)

    cal.debug('Initializing Scavenger Config window...')
    scavengerConfigWindow = UI.CreateWindow('scavengerConfigWindow', 'Scavenger')
    if not scavengerConfigWindow then
        cal.debug('Failed to create scavenger config window!')
        return
    end
    cal.debug('Initializing Scavenger Config Window...')
    scavengerConfigWindow:SetPosition(200, 200)
    scavengerConfigWindow:SetSize(90, 190)
    scavengerConfigWindow:Hide()

    cal.debug('Initializing Scavenger Config Window buttons...')
    activateScavengerGoldButton = scavengerConfigWindow:AddButton(10, 40, 'Gold (Y)', 100, 30)
    activateScavengerBonesButton = scavengerConfigWindow:AddButton(10, 90, 'Bones (Y)', 100, 30)
    activateScavengerGrimoireButton = scavengerConfigWindow:AddButton(10, 140, 'Grimoires (Y)', 110, 30)

    cal.debug("Window created and ready!")
end

local function runGump_(CAConfig)

    cal.debug('Starting Combat Assistant Iteration!')
    UI.DestroyAllWindows()          --- Cleanup
    initMainGump_()                 --- Init main gump (create UI, set up event handlers, etc)
    caml.mainLoopInit(CAConfig)     --- Initialize main loop (configure modules, etc)
    while true do

        processUIGumpInteractions_()                --- Check for UI changes
        updateCombatAssistantConfig_(CAConfig)      --- Process Update

        --- Is the Combat Assistant set to run?
        if RunUIGumpState.IterateCAMainLoop then

            cal.debug('Starting Combat Assistant Iteration!')
            runStatusLabel:SetText('Running...')                --- Starting Iteration
            runStatusLabel:SetColor(1, 0.5, 0, 1)               --- Orange

            caml.mainLoopIterate(CAConfig)                      --- Iterate main loop once (process actions, etc)

            cal.debug('Combat Assistant Iteration Done!')
            runStatusLabel:SetText('Running...')                --- Iteration Done
            runStatusLabel:SetColor(0, 1, 0, 1)                 --- Green

        else
            cal.debug('Combat Assistant Disabled!')
        end

        Pause(50) -- Wait 50ms before next update
    end
end

--------------
--- Export ---
--------------

local Obj = {
    runGump = runGump_
}

return Obj