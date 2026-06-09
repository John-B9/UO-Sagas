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
local cauigheal = Import('CAUIGumpHeal')
local cauigbuffs = Import('CAUIGumpBuffs')
local cauigattack = Import('CAUIGumpAttack')
local cauigcommands = Import('CAUIGumpCommands')
local cauigscavenge = Import('CAUIGumpScavenge')

local capn = Import('CAPotionsNightsight')

-----------------
--- Variables ---
-----------------

local RunUIGumpState = {
    IterateCAMainLoop = false,
    OverrideWithNoCommands = false,
    OverrideWithNoAttacks = true,
    OverrideWithNoScavenger = true,
    ScavengerConfigOpen = true,
    ScavengerAllowGold = true,
    ScavengerAllowBones = true,
    ScavengerAllowGrimoire = true
}

--------------------------------------
--- Main Window - Layout Constants ---
--------------------------------------

local mainWindowTopLabelPosX = 10
local mainWindowTopLabelPosY = 40
local mainWindowModuleEnableButtonPosX = 10
local mainWindowModuleEnableButtonSizeX = 100
local mainWindowModuleEnableButtonSizeY = 30
local mainWindowModuleEnableStatusLabelPosX = 140
local mainWindowModuleConfigButtonPosX = 220
local mainWindowModuleConfigButtonSizeX = 30
local mainWindowModuleConfigButtonSizeY = 30
local mainWindowModuleRowPosYStart = 70
local mainWindowModuleRowPosYIncrement = 50
local mainWindowModuleRowPosYLabelAlignIncrement = 8
local mainWindowRunButtonSizeX = 80
local mainWindowRunButtonSizeY = 30

local mainWindowNumberOfModules = 5
local mainWindowSizeX = mainWindowModuleConfigButtonPosX + 50
local mainWindowSizeY = mainWindowModuleRowPosYStart + mainWindowModuleRowPosYIncrement * (mainWindowNumberOfModules -1) + 50
local mainWindowStartPosX = 200
local mainWindowStartPosY = 200

---------------------------------
--- Main Window - UI Elements ---
---------------------------------

local mainWindow = nil
local titleLabel = nil

local runButton = nil
local runStatusLabel = nil

local activateHealButton = nil
local healStatusLabel = nil
local healConfigButton = nil

local activateCommandsButton = nil
local commandsStatusLabel = nil

local activateAttackButton = nil
local attackStatusLabel = nil

local activateScavengerButton = nil
local scavengerStatusLabel = nil
local scavengerConfigButton = nil

-------------------------------------------------------
--- Generic Module Config Window - Layout Constants ---
-------------------------------------------------------

local moduleConfigWindowStartPosX = 200
local moduleConfigWindowStartPosY = 200
local moduleConfigWindowFeatureEnableButtonPosX = 10
local moduleConfigWindowFeatureEnableButtonPosYStart = 40
local moduleConfigWindowFeatureEnableButtonPosYIncrement = 50
local moduleConfigWindowFeatureEnableButtonSizeX = 110
local moduleConfigWindowFeatureEnableButtonSizeY = 30

local moduleConfigWindowSizeX = 90

-------------------------------------
--- UI Elements - ScavengerConfig ---
-------------------------------------

local scavengerConfigWindow = nil
local activateScavengerGoldButton = nil
local activateScavengerBonesButton = nil
local activateScavengerGrimoireButton = nil

local scavengerConfigNumberOfFeatures = 3
local scavengerConfigWindowSizeY = moduleConfigWindowFeatureEnableButtonPosYStart + moduleConfigWindowFeatureEnableButtonPosYIncrement * (scavengerConfigNumberOfFeatures - 1) + 50

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

    if runButton:WasClicked() then                                                          --- Run
        onRunCombatAssistantButtonPressed_(not RunUIGumpState.IterateCAMainLoop)
    end

    ---if activateHealButton:WasClicked() then                                                 --- Heal
    ---    onHealButtonPressed_(RunUIGumpState.OverrideWithNoHeal)
    ---end

    cauigbuffs.processUIInteractions()                                                      --- Buffs

    if activateCommandsButton:WasClicked() then                                             --- Commands
        onOverrideWithNoCommandsButtonPressed_(RunUIGumpState.OverrideWithNoCommands)
    end

    if activateAttackButton:WasClicked() then                                               --- Attack
        onAttackButtonPressed_(RunUIGumpState.OverrideWithNoAttacks)
    end

    if activateScavengerButton:WasClicked() then                                            --- Scavenger
        onScavengerButtonPressed_(RunUIGumpState.OverrideWithNoScavenger)
    end

    if scavengerConfigButton:WasClicked() then                                              --- Scavenger Config Button
        onScavengerConfigButtonPressed_(not RunUIGumpState.ScavengerConfigOpen)
    end

    --- Scavenging Config Window
    if activateScavengerGoldButton:WasClicked() then                                        --- Scavenger Config Gold
        onScavengerGoldButtonPressed_(not RunUIGumpState.ScavengerAllowGold)
    end

    if activateScavengerBonesButton:WasClicked() then                                       --- Scavenger Config Bones
        onScavengerBonesButtonPressed_(not RunUIGumpState.ScavengerAllowBones)
    end

    if activateScavengerGrimoireButton:WasClicked() then                                    --- Scavenger Config Grimmoire
        onScavengerGrimoireButtonPressed_(not RunUIGumpState.ScavengerAllowGrimoire)
    end
end

local function updateCombatAssistantConfig_(CAConfig)

    --- Override UI values to CA Config
    cauigbuffs.updateCAConfigToCurrentUIConfig_(CAConfig.modules.Buffs)                             --- Buffs
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

local function initMainGumpRun_(mainWindow)
    cal.debug('Initializing Run Checkbox...')
    local runCheckboxPosY = mainWindowModuleRowPosYStart
    runButton = mainWindow:AddButton(mainWindowModuleEnableButtonPosX, runCheckboxPosY, 'Run', mainWindowRunButtonSizeX, mainWindowRunButtonSizeY)
    runStatusLabel = mainWindow:AddLabel(mainWindowModuleEnableStatusLabelPosX, runCheckboxPosY + mainWindowModuleRowPosYLabelAlignIncrement, 'Stopped')
    runStatusLabel:SetColor(1, 0, 0, 1)
end

local function initMainGumpHeal_(mainWindow)
    cal.debug('Initializing Heal Checkbox...')
    local scavengerCheckboxPosY = mainWindowModuleRowPosYStart + mainWindowModuleRowPosYIncrement * 4
    activateScavengerButton = mainWindow:AddButton(mainWindowModuleEnableButtonPosX, scavengerCheckboxPosY, 'Scavenge', mainWindowModuleEnableButtonSizeX, mainWindowModuleEnableButtonSizeY)
    scavengerStatusLabel = mainWindow:AddLabel(mainWindowModuleEnableStatusLabelPosX, scavengerCheckboxPosY + mainWindowModuleRowPosYLabelAlignIncrement, 'Disabled')
    scavengerStatusLabel:SetColor(1, 0, 0, 1)

    cal.debug('Initializing Scavenger Config Button...')
    scavengerConfigButton = mainWindow:AddButton(mainWindowModuleConfigButtonPosX, scavengerCheckboxPosY, '+', mainWindowModuleConfigButtonSizeX, mainWindowModuleConfigButtonSizeY)

    cal.debug('Initializing Scavenger Config window...')
    scavengerConfigWindow = UI.CreateWindow('scavengerConfigWindow', 'Scavenger')
    if not scavengerConfigWindow then
        cal.debug('Failed to create scavenger config window!')
        return
    end
    cal.debug('Initializing Scavenger Config Window...')
    scavengerConfigWindow:SetPosition(moduleConfigWindowStartPosX, moduleConfigWindowStartPosY)
    scavengerConfigWindow:SetSize(moduleConfigWindowSizeX, scavengerConfigWindowSizeY)
    scavengerConfigWindow:Hide()

    cal.debug('Initializing Scavenger Config Window buttons...')
    local activateScavengerGoldButtonPosY = moduleConfigWindowFeatureEnableButtonPosYStart
    activateScavengerGoldButton = scavengerConfigWindow:AddButton(moduleConfigWindowFeatureEnableButtonPosX, activateScavengerGoldButtonPosY, 'Gold (Y)', moduleConfigWindowFeatureEnableButtonSizeX, moduleConfigWindowFeatureEnableButtonSizeY)
    local activateScavengerBonesButtonPosY = moduleConfigWindowFeatureEnableButtonPosYStart + moduleConfigWindowFeatureEnableButtonPosYIncrement
    activateScavengerBonesButton = scavengerConfigWindow:AddButton(moduleConfigWindowFeatureEnableButtonPosX, activateScavengerBonesButtonPosY, 'Bones (Y)', moduleConfigWindowFeatureEnableButtonSizeX, moduleConfigWindowFeatureEnableButtonSizeY)
    local activateScavengerGrimoireButtonPosY = moduleConfigWindowFeatureEnableButtonPosYStart + moduleConfigWindowFeatureEnableButtonPosYIncrement * 2
    activateScavengerGrimoireButton = scavengerConfigWindow:AddButton(moduleConfigWindowFeatureEnableButtonPosX, activateScavengerGrimoireButtonPosY, 'Grimoires (Y)', moduleConfigWindowFeatureEnableButtonSizeX, moduleConfigWindowFeatureEnableButtonSizeY)

end

local function initMainGumpCommands_(mainWindow)
    cal.debug('Initializing Commands Checkbox...')
    local commandsCheckboxPosY = mainWindowModuleRowPosYStart + mainWindowModuleRowPosYIncrement * 2
    activateCommandsButton = mainWindow:AddButton(mainWindowModuleEnableButtonPosX, commandsCheckboxPosY, 'Commands', mainWindowModuleEnableButtonSizeX, mainWindowModuleEnableButtonSizeY)
    commandsStatusLabel = mainWindow:AddLabel(mainWindowModuleEnableStatusLabelPosX, commandsCheckboxPosY + mainWindowModuleRowPosYLabelAlignIncrement, 'Enabled')
    commandsStatusLabel:SetColor(0, 1, 0, 1)
end

local function initMainGumpAttack_(mainWindow)
    cal.debug('Initializing Attack Checkbox...')
    local attackCheckboxPosY = mainWindowModuleRowPosYStart + mainWindowModuleRowPosYIncrement * 3
    activateAttackButton = mainWindow:AddButton(mainWindowModuleEnableButtonPosX, attackCheckboxPosY, 'Attack', mainWindowModuleEnableButtonSizeX, mainWindowModuleEnableButtonSizeY)
    attackStatusLabel = mainWindow:AddLabel(mainWindowModuleEnableStatusLabelPosX, attackCheckboxPosY + mainWindowModuleRowPosYLabelAlignIncrement, 'Disabled')
    attackStatusLabel:SetColor(1, 0, 0, 1)
end

local function initMainGumpScavenge_(mainWindow)
    cal.debug('Initializing Scavenger Checkbox...')
    local scavengerCheckboxPosY = mainWindowModuleRowPosYStart + mainWindowModuleRowPosYIncrement * 4
    activateScavengerButton = mainWindow:AddButton(mainWindowModuleEnableButtonPosX, scavengerCheckboxPosY, 'Scavenge', mainWindowModuleEnableButtonSizeX, mainWindowModuleEnableButtonSizeY)
    scavengerStatusLabel = mainWindow:AddLabel(mainWindowModuleEnableStatusLabelPosX, scavengerCheckboxPosY + mainWindowModuleRowPosYLabelAlignIncrement, 'Disabled')
    scavengerStatusLabel:SetColor(1, 0, 0, 1)

    cal.debug('Initializing Scavenger Config Button...')
    scavengerConfigButton = mainWindow:AddButton(mainWindowModuleConfigButtonPosX, scavengerCheckboxPosY, '+', mainWindowModuleConfigButtonSizeX, mainWindowModuleConfigButtonSizeY)

    cal.debug('Initializing Scavenger Config window...')
    scavengerConfigWindow = UI.CreateWindow('scavengerConfigWindow', 'Scavenger')
    if not scavengerConfigWindow then
        cal.debug('Failed to create scavenger config window!')
        return
    end
    cal.debug('Initializing Scavenger Config Window...')
    scavengerConfigWindow:SetPosition(moduleConfigWindowStartPosX, moduleConfigWindowStartPosY)
    scavengerConfigWindow:SetSize(moduleConfigWindowSizeX, scavengerConfigWindowSizeY)
    scavengerConfigWindow:Hide()

    cal.debug('Initializing Scavenger Config Window buttons...')
    local activateScavengerGoldButtonPosY = moduleConfigWindowFeatureEnableButtonPosYStart
    activateScavengerGoldButton = scavengerConfigWindow:AddButton(moduleConfigWindowFeatureEnableButtonPosX, activateScavengerGoldButtonPosY, 'Gold (Y)', moduleConfigWindowFeatureEnableButtonSizeX, moduleConfigWindowFeatureEnableButtonSizeY)
    local activateScavengerBonesButtonPosY = moduleConfigWindowFeatureEnableButtonPosYStart + moduleConfigWindowFeatureEnableButtonPosYIncrement
    activateScavengerBonesButton = scavengerConfigWindow:AddButton(moduleConfigWindowFeatureEnableButtonPosX, activateScavengerBonesButtonPosY, 'Bones (Y)', moduleConfigWindowFeatureEnableButtonSizeX, moduleConfigWindowFeatureEnableButtonSizeY)
    local activateScavengerGrimoireButtonPosY = moduleConfigWindowFeatureEnableButtonPosYStart + moduleConfigWindowFeatureEnableButtonPosYIncrement * 2
    activateScavengerGrimoireButton = scavengerConfigWindow:AddButton(moduleConfigWindowFeatureEnableButtonPosX, activateScavengerGrimoireButtonPosY, 'Grimoires (Y)', moduleConfigWindowFeatureEnableButtonSizeX, moduleConfigWindowFeatureEnableButtonSizeY)

end

local function initMainGump_()

    cal.debug('Initializing main gump...')
    mainWindow = UI.CreateWindow('mainWindow', 'SAGAS Combat Assistant')
    if not mainWindow then
        cal.debug('Failed to create main gump!')
        return
    end

    cal.debug('Initializing Main Window...')
    mainWindow:SetPosition(mainWindowStartPosX, mainWindowStartPosY)
    mainWindow:SetSize(mainWindowSizeX, mainWindowSizeY)

    titleLabel = mainWindow:AddLabel(mainWindowTopLabelPosX, mainWindowTopLabelPosY, 'SAGAS Combat Assistant')
    titleLabel:SetColor(0.2, 0.8, 1, 1)

    --- Modules
    initMainGumpRun_(mainWindow)
    initMainGumpHeal_(mainWindow)
    cauigbuffs.initUI(mainWindow, 1) --- Buffs
    initMainGumpCommands_(mainWindow)
    initMainGumpAttack_(mainWindow)
    initMainGumpScavenge_(mainWindow)

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