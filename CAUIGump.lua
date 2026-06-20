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
local cauigheal = Import('CAUIGumpHeal')
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
    Commands = {
        enableButton = nil,
        enableLabel = nil
    },
    Attack = {
        enableButton = nil,
        enableLabel = nil,
        configButton = nil,
        Config = {
            window = nil,
            rangeMaxButton = nil,
            exceptionModeButton = nil
        }
    },
    Heal = {
        enableButton = nil,
        enableLabel = nil,
        configButton = nil,
        Config = {
            window = nil,
            bandageSelfButton = nil,
            bandageOtherButton = nil,
            healPotionsModeButton = nil,
            healPotionAfterStrengthPotionButton = nil,
            curePotionsButton = nil
        }
    },
    Buffs = {
        enableButton = nil,
        enableLabel = nil,
        configButton = nil,
        Config = {
            window = nil,
            enableNightsight = nil,
            enableStrength = nil,
            enableAgility = nil,
            refreshAfterAgility = nil,
            staminaPotionsModeButton = nil
        }
    },
    Scavenge = {
        enableButton = nil,
        enableLabel = nil,
        configButton = nil,
        Config = {
            window = nil,
            activateGoldButton = nil,
            activateBandagesButton = nil,
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
    NumberOfModules = 6     --- Must match the current #modules
}

local CAUIMainWindowState = {
    nightsightUIChanged = false
}

-----------------
--- Functions ---
-----------------

local function processUIGumpInteractions_()
    local nightsightUIEnabled = CAUIGumpBuffsState.EnableNightsight
    cauigmainrow.processUIInteractions(CAUI.configButton, CAUI.Config.window, CAUI.Config.rearmButton, CAUI.Config.skinnButton)
    cauigrun.processUIInteractions(CAUI.Run.enableButton, CAUI.Run.enableLabel)                     --- Run
    cauigcommands.processUIInteractions(CAUI.Commands.enableButton, CAUI.Commands.enableLabel)      --- Commands
    cauigattack.processUIInteractions(CAUI.Attack.enableButton, CAUI.Attack.enableLabel, CAUI.Attack.configButton, CAUI.Attack.Config.window, CAUI.Attack.Config.rangeMaxButton, CAUI.Attack.Config.exceptionModeButton)                                                                                                                            --- Attack
    cauigheal.processUIInteractions(CAUI.Heal.enableButton, CAUI.Heal.enableLabel, CAUI.Heal.configButton, CAUI.Heal.Config.window, CAUI.Heal.Config.bandageSelfButton, CAUI.Heal.Config.bandageOtherButton, CAUI.Heal.Config.healPotionsModeButton, CAUI.Heal.Config.healPotionAfterStrengthPotionButton, CAUI.Heal.Config.curePotionsButton)      --- Heal
    cauigbuffs.processUIInteractions(CAUI.Buffs.enableButton, CAUI.Buffs.enableLabel, CAUI.Buffs.configButton, CAUI.Buffs.Config.window, CAUI.Buffs.Config.enableNightsight, CAUI.Buffs.Config.enableStrength, CAUI.Buffs.Config.enableAgility, CAUI.Buffs.Config.refreshAfterAgility, CAUI.Buffs.Config.staminaPotionsModeButton)                  --- Buffs
    cauigscavenge.processUIInteractions(CAUI.Scavenge.enableButton, CAUI.Scavenge.enableLabel, CAUI.Scavenge.configButton, CAUI.Scavenge.Config.window, CAUI.Scavenge.Config.activateGoldButton, CAUI.Scavenge.Config.activateBandagesButton, CAUI.Scavenge.Config.activateBonesButton, CAUI.Scavenge.Config.activateGrimoireButton, CAUI.Scavenge.Config.activateRibsButton)                    --- Scavenge
    nightsightUIChanged = nightsightUIEnabled ~= CAUIGumpBuffsState.EnableNightsight

end

local function updateCombatAssistantConfig_(CAConfig)

    --- Override UI values to CA Config
    cauigmainrow.updateCAConfigToCurrentUIConfig(CAConfig.modules.ArmDisarm, CAConfig.modules.Skinning)     --- Main
    cauigcommands.updateCAConfigToCurrentUIConfig(CAConfig.userCommands)                                    --- Commands
    cauigattack.updateCAConfigToCurrentUIConfig(CAConfig.modules.Attack)                                    --- Attack
    cauigheal.updateCAConfigToCurrentUIConfig(CAConfig.modules.Bandages, CAConfig.modules.CurePotions, CAConfig.modules.HealingPotions, CAConfig.modules.Buffs.Strength)    --- Heal
    cauigbuffs.updateCAConfigToCurrentUIConfig(CAConfig.modules.Buffs)                                      --- Buffs
    cauigscavenge.updateCAConfigToCurrentUIConfig(CAConfig.modules.Scavenging)                              --- Scavenge

    --- Because of internal error, nightsight may disable itself (don't override that part, unless there is a user interaction)
    if not nightsightUIChanged then
        CAConfig.modules.Buffs.Nightsight.Enable = capn.getEnable()
        cauigbuffs.onNightsightButtonPressed(capn.getEnable(), CAUI.Buffs.Config.enableNightsight)
    end

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
    CAUI.Commands.enableButton , CAUI.Commands.enableLabel = cauigcommands.initUI(CAUI.mainWindow, 2)       --- Commands
    CAUI.Attack.enableButton, CAUI.Attack.enableLabel, CAUI.Attack.configButton, CAUI.Attack.Config.window, CAUI.Attack.Config.rangeMaxButton, CAUI.Attack.Config.exceptionModeButton = cauigattack.initUI(CAUI.mainWindow, 3)                                                                                                                          --- Attack
    CAUI.Heal.enableButton, CAUI.Heal.enableLabel, CAUI.Heal.configButton, CAUI.Heal.Config.window, CAUI.Heal.Config.bandageSelfButton, CAUI.Heal.Config.bandageOtherButton, CAUI.Heal.Config.healPotionsModeButton, CAUI.Heal.Config.healPotionAfterStrengthPotionButton, CAUI.Heal.Config.curePotionsButton = cauigheal.initUI(CAUI.mainWindow, 4)    --- Heal
    CAUI.Buffs.enableButton, CAUI.Buffs.enableLabel, CAUI.Buffs.configButton, CAUI.Buffs.Config.window, CAUI.Buffs.Config.enableNightsight, CAUI.Buffs.Config.enableStrength, CAUI.Buffs.Config.enableAgility, CAUI.Buffs.Config.refreshAfterAgility, CAUI.Buffs.Config.staminaPotionsModeButton = cauigbuffs.initUI(CAUI.mainWindow, 5)                --- Buffs
    CAUI.Scavenge.enableButton, CAUI.Scavenge.enableLabel, CAUI.Scavenge.configButton, CAUI.Scavenge.Config.window, CAUI.Scavenge.Config.activateGoldButton, CAUI.Scavenge.Config.activateBandagesButton, CAUI.Scavenge.Config.activateBonesButton, CAUI.Scavenge.Config.activateGrimoireButton, CAUI.Scavenge.Config.activateRibsButton = cauigscavenge.initUI(CAUI.mainWindow, 6)                  --- Scavenge
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