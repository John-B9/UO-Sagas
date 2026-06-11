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
local cauiglayout = Import('CAUIGumpLayout')
local cauigmainrow = Import('CAUIGumpMainRow')
local cauigrun = Import('CAUIGumpRun')
---local cauigheal = Import('CAUIGumpHeal')
local cauigbuffs = Import('CAUIGumpBuffs')
local cauigcommands = Import('CAUIGumpCommands')
local cauigattack = Import('CAUIGumpAttack')
local cauigscavenge = Import('CAUIGumpScavenge')
local capn = Import('CAPotionsNightsight')

---------------------------------
--- Main Window - UI Elements ---
---------------------------------

local CAUI = {
    mainWindow = nil,
    titleLabel = nil,
    configButton = nil,
    Config = {
        window = nil,
        rearmButton = nil,
        skinnButton = nil
    },
    Run = {
        enableButton = nil,
        enableLabel = nil
    },
    ---Heal = {
    ---    enableButton = nil,
    ---    enableLabel = nil
    ---},
    Buffs = {
        enableButton = nil,
        enableLabel = nil
    },
    Commands = {
        enableButton = nil,
        enableLabel = nil
    },
    Attack = {
        enableButton = nil,
        enableLabel = nil
    },
    Scavenge = {
        enableButton = nil,
        enableLabel = nil,
        configButton = nil,
        Config = {
            window = nil,
            activateGoldButton = nil,
            activateBonesButton = nil,
            activateGrimoireButton = nil,
            activateRibsButton = nil
        }
    }
}

local CAUIMainWindowLayout = {
    StartPosX = 200,
    StartPosY = 200,
    SizeXOffset = 20,
    SizeYOffset = 20,
    NumberOfModules = 5     --- Must match the current #modules
}

-----------------
--- Functions ---
-----------------

local function processUIGumpInteractions_()
    cauigmainrow.processUIInteractions(CAUI.configButton, CAUI.Config.window, CAUI.Config.rearmButton, CAUI.Config.skinnButton)
    cauigrun.processUIInteractions(CAUI.Run.enableButton, CAUI.Run.enableLabel)                     --- Run
    ---cauigheal.processUIInteractions(CAUI.Run.enableButton, CAUI.Run.enableLabel)                    --- Heal
    cauigbuffs.processUIInteractions(CAUI.Buffs.enableButton, CAUI.Buffs.enableLabel)               --- Buffs
    cauigcommands.processUIInteractions(CAUI.Commands.enableButton, CAUI.Commands.enableLabel)      --- Commands
    cauigattack.processUIInteractions(CAUI.Attack.enableButton, CAUI.Attack.enableLabel)            --- Attack
    cauigscavenge.processUIInteractions(CAUI.Scavenge.enableButton, CAUI.Scavenge.enableLabel, CAUI.Scavenge.configButton, CAUI.Scavenge.Config.window, CAUI.Scavenge.Config.activateGoldButton, CAUI.Scavenge.Config.activateBonesButton, CAUI.Scavenge.Config.activateGrimoireButton, CAUI.Scavenge.Config.activateRibsButton)              --- Scavenge
end

local function updateCombatAssistantConfig_(CAConfig)

    --- Override UI values to CA Config
    cauigmainrow.updateCAConfigToCurrentUIConfig(CAConfig.modules.ArmDisarm, CAConfig.modules.Skinning)     --- Main
    ---cauigheal.updateCAConfigToCurrentUIConfig(CAConfig.modules.Buffs)                                    --- Heal
    cauigbuffs.updateCAConfigToCurrentUIConfig(CAConfig.modules.Buffs)                                      --- Buffs
    cauigcommands.updateCAConfigToCurrentUIConfig(CAConfig.userCommands)                                    --- Commands
    cauigattack.updateCAConfigToCurrentUIConfig(CAConfig.modules.Attack)                                    --- Attack
    cauigscavenge.updateCAConfigToCurrentUIConfig(CAConfig.modules.Scavenging)                              --- Scavenge

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

local function initMainWindow_()

    cal.debug('Initializing main gump...')
    CAUI.mainWindow = UI.CreateWindow('CAUI.mainWindow', 'SAGAS Combat Assistant')
    if not CAUI.mainWindow then
        cal.debug('Failed to create main gump!')
        return
    end

    cal.debug('Initializing Main Window...')
    local furthestElementX = cauiglayout.getLayoutConstants().ModuleConfigButtonPosX + cauiglayout.getLayoutConstants().ModuleConfigButtonSizeX
    local furthestElementY = cauiglayout.getLayoutConstants().ModuleRowPosYStart + cauiglayout.getLayoutConstants().ModuleRowPosYIncrement * (CAUIMainWindowLayout.NumberOfModules -1) + cauiglayout.getLayoutConstants().ModuleEnableButtonSizeY
    CAUI.mainWindow:SetPosition(CAUIMainWindowLayout.StartPosX, CAUIMainWindowLayout.StartPosY)
    CAUI.mainWindow:SetSize(furthestElementX + CAUIMainWindowLayout.SizeXOffset, furthestElementY + CAUIMainWindowLayout.SizeYOffset)

    cal.debug("Window created and ready!")
end

local function initModules_()
    CAUI.titleLabel, CAUI.configButton, CAUI.Config.window, CAUI.Config.rearmButton, CAUI.Config.skinnButton = cauigmainrow.initUI(CAUI.mainWindow)
    CAUI.Run.enableButton , CAUI.Run.enableLabel = cauigrun.initUI(CAUI.mainWindow, 1)                      --- Run
    ---CAUI.Run.enableButton , CAUI.Run.enableLabel = cauigheal.initUI(CAUI.mainWindow, 1)                  --- Heal
    CAUI.Buffs.enableButton , CAUI.Buffs.enableLabel = cauigbuffs.initUI(CAUI.mainWindow, 2)                --- Buffs
    CAUI.Commands.enableButton , CAUI.Commands.enableLabel = cauigcommands.initUI(CAUI.mainWindow, 3)       --- Commands
    CAUI.Attack.enableButton , CAUI.Attack.enableLabel = cauigattack.initUI(CAUI.mainWindow, 4)             --- Attack
    CAUI.Scavenge.enableButton, CAUI.Scavenge.enableLabel, CAUI.Scavenge.configButton, CAUI.Scavenge.Config.window, CAUI.Scavenge.Config.activateGoldButton, CAUI.Scavenge.Config.activateBonesButton, CAUI.Scavenge.Config.activateGrimoireButton, CAUI.Scavenge.Config.activateRibsButton = cauigscavenge.initUI(CAUI.mainWindow, 5)        --- Scavenge
end

local function initMainGump_()
    initMainWindow_()
    initModules_()
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
            CAUI.Run.enableLabel:SetText('Running...')                --- Starting Iteration
            CAUI.Run.enableLabel:SetColor(1, 0.5, 0, 1)               --- Orange

            caml.mainLoopIterate(CAConfig)                      --- Iterate main loop once (process actions, etc)

            cal.debug('Combat Assistant Iteration Done!')
            CAUI.Run.enableLabel:SetText('Running...')                --- Iteration Done
            CAUI.Run.enableLabel:SetColor(0, 1, 0, 1)                 --- Green

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