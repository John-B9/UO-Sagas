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
local cauigrun = Import('CAUIGumpRun')
---local cauigheal = Import('CAUIGumpHeal')
local cauigbuffs = Import('CAUIGumpBuffs')
local cauigcommands = Import('CAUIGumpCommands')
local cauigattack = Import('CAUIGumpAttack')
local cauigscavenge = Import('CAUIGumpScavenge')
local capn = Import('CAPotionsNightsight')

--------------------------------------
--- Main Window - Layout Constants ---
--------------------------------------

local mainWindowTopLabelPosX = 10
local mainWindowTopLabelPosY = 40
local mainWindowModuleConfigButtonPosX = 220
local mainWindowModuleRowPosYStart = 70
local mainWindowModuleRowPosYIncrement = 50

local mainWindowNumberOfModules = 5
local mainWindowSizeX = mainWindowModuleConfigButtonPosX + 50
local mainWindowSizeY = mainWindowModuleRowPosYStart + mainWindowModuleRowPosYIncrement * (mainWindowNumberOfModules -1) + 50
local mainWindowStartPosX = 200
local mainWindowStartPosY = 200

---------------------------------
--- Main Window - UI Elements ---
---------------------------------

local mainWindow = nil                          --- Main Gump
local titleLabel = nil

local runButton = nil                           --- Run
local runStatusLabel = nil

local activateHealButton = nil                  --- Heal
local healStatusLabel = nil
local healConfigButton = nil

local activateBuffsButton = nil                 --- Buffs
local buffsStatusLabel = nil

local activateCommandsButton = nil              --- Commands
local commandsStatusLabel = nil

local activateAttackButton = nil                --- Attack
local attackStatusLabel = nil

local activateScavengerButton = nil             --- Scavenge
local scavengerStatusLabel = nil
local scavengerConfigButton = nil

local scavengerConfigWindow = nil               --- Scavenge Config Window
local activateScavengerGoldButton = nil
local activateScavengerBonesButton = nil
local activateScavengerGrimoireButton = nil

-----------------
--- Functions ---
-----------------

local function processUIGumpInteractions_()
    cauigrun.processUIInteractions(runButton, runStatusLabel)                               --- Run
    ---cauigheal.processUIInteractions(runButton, runStatusLabel)                              --- Heal
    cauigbuffs.processUIInteractions(activateBuffsButton, buffsStatusLabel)                 --- Buffs
    cauigcommands.processUIInteractions(activateCommandsButton, commandsStatusLabel)        --- Commands
    cauigattack.processUIInteractions(activateAttackButton, attackStatusLabel)              --- Attack
    cauigscavenge.processUIInteractions(activateScavengerButton, scavengerStatusLabel, scavengerConfigButton, scavengerConfigWindow, activateScavengerGoldButton, activateScavengerBonesButton, activateScavengerGrimoireButton)              --- Attack
end

local function updateCombatAssistantConfig_(CAConfig)

    --- Override UI values to CA Config
    ---cauigheal.updateCAConfigToCurrentUIConfig(CAConfig.modules.Buffs)          --- Heal
    cauigbuffs.updateCAConfigToCurrentUIConfig(CAConfig.modules.Buffs)          --- Buffs
    cauigcommands.updateCAConfigToCurrentUIConfig(CAConfig.userCommands)        --- Commands
    cauigattack.updateCAConfigToCurrentUIConfig(CAConfig.modules.Attack)        --- Attack
    cauigscavenge.updateCAConfigToCurrentUIConfig(CAConfig.modules.Scavenging)  --- Scavenge

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

local function initMainGumpWindow_()
    
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

    cal.debug("Window created and ready!")
end

local function initMainGumpModules_()
    runButton , runStatusLabel = cauigrun.initUI(mainWindow, 1)                         --- Run
    ---runButton , runStatusLabel = cauigheal.initUI(mainWindow, 1)                         --- Heal
    activateBuffsButton , buffsStatusLabel = cauigbuffs.initUI(mainWindow, 2)           --- Buffs
    activateCommandsButton , commandsStatusLabel = cauigcommands.initUI(mainWindow, 3)  --- Commands
    activateAttackButton , attackStatusLabel = cauigattack.initUI(mainWindow, 4)        --- Attack
    activateScavengerButton, scavengerStatusLabel, scavengerConfigButton, scavengerConfigWindow, activateScavengerGoldButton, activateScavengerBonesButton, activateScavengerGrimoireButton = cauigscavenge.initUI(mainWindow, 5)        --- Scavenge
end

local function initMainGump_()
    initMainGumpWindow_()
    initMainGumpModules_()
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
        if cauigrun.getIterateCAMainLoop() then

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