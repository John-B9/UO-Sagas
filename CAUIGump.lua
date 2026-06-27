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
local cauiglayoutb = Import('CAUIGumpLayoutBase')
local cauigmainrow = Import('CAUIGumpMainRow')
local cauigrun = Import('CAUIGumpRun')
local cauigheal = Import('CAUIGumpHeal')
local cauigbuffs = Import('CAUIGumpBuffs')
local cauigcommands = Import('CAUIGumpCommands')
local cauigattack = Import('CAUIGumpAttack')
local cauigscavenge = Import('CAUIGumpScavenge')
local capn = Import('CAPotionsNightsight')
local cauiglogicb = Import('CAUIGumpLogicBase')

---------------------------------
--- Main Window - UI Elements ---
---------------------------------

local CAUI = {
    mainWindow = nil
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

    cauiglogicb.checkAndCloseOpenConfigWindow()

    local nightsightUIEnabled = cauigbuffs.getEnableNightsight()

    cauigmainrow.processUIInteractions()        --- Main Row
    cauigrun.processUIInteractions()            --- Run
    cauigcommands.processUIInteractions()       --- Commands
    cauigattack.processUIInteractions()         --- Attack
    cauigheal.processUIInteractions()           --- Heal
    cauigbuffs.processUIInteractions()          --- Buffs
    cauigscavenge.processUIInteractions()       --- Scavenge

    nightsightUIChanged = nightsightUIEnabled ~= cauigbuffs.getEnableNightsight()
end

local function updateCombatAssistantConfig_(CAConfig)

    --- Override UI values to CA Config
    cauigmainrow.updateCAConfigToCurrentUIConfig(CAConfig)      --- Main Row
    cauigcommands.updateCAConfigToCurrentUIConfig(CAConfig)     --- Commands
    cauigattack.updateCAConfigToCurrentUIConfig(CAConfig)       --- Attack
    cauigheal.updateCAConfigToCurrentUIConfig(CAConfig)         --- Heal
    cauigbuffs.updateCAConfigToCurrentUIConfig(CAConfig)        --- Buffs
    cauigscavenge.updateCAConfigToCurrentUIConfig(CAConfig)     --- Scavenge

    --- Because of internal error, nightsight may disable itself (don't override that part, unless there is a user interaction)
    if not nightsightUIChanged then
        CAConfig.modules.Buffs.Nightsight.Enable = capn.getEnable()
        cauigbuffs.setEnableNightsight(capn.getEnable())
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
    local furthestElementX = cauiglayoutb.getLayoutConstants().ModuleConfigButtonPosX + cauiglayoutb.getLayoutConstants().ModuleConfigButtonSizeX
    local furthestElementY = cauiglayoutb.getLayoutConstants().ModuleRowPosYStart + cauiglayoutb.getLayoutConstants().ModuleRowPosYIncrement * (CAUIMainWindowLayout.NumberOfModules -1) + cauiglayoutb.getLayoutConstants().ModuleEnableButtonSizeY
    CAUI.mainWindow:SetPosition(CAUIMainWindowLayout.StartPosX, CAUIMainWindowLayout.StartPosY)
    CAUI.mainWindow:SetSize(furthestElementX + CAUIMainWindowLayout.SizeXOffset, furthestElementY + CAUIMainWindowLayout.SizeYOffset)

    cal.debug("Window created and ready!")
end

local function initModules_()
    cauigmainrow.initUI(CAUI.mainWindow)        --- Main Row
    cauigrun.initUI(CAUI.mainWindow, 1)         --- Run
    cauigcommands.initUI(CAUI.mainWindow, 2)    --- Commands
    cauigattack.initUI(CAUI.mainWindow, 3)      --- Attack
    cauigheal.initUI(CAUI.mainWindow, 4)        --- Heal
    cauigbuffs.initUI(CAUI.mainWindow, 5)       --- Buffs
    cauigscavenge.initUI(CAUI.mainWindow, 6)    --- Scavenge
end

local function initMainGump_()
    initMainWindow_()
    initModules_()
end

local function runGump_(CAConfig)

    cal.debug('Starting Combat Assistant Iteration!')
    UI.DestroyAllWindows()                                  --- Cleanup
    initMainGump_()                                         --- Init main gump (create UI, set up event handlers, etc...)
    caml.mainLoopInit(CAConfig)                             --- Initialize main loop (configure modules, etc...)
    while true do

        processUIGumpInteractions_()                        --- Check for UI changes
        updateCombatAssistantConfig_(CAConfig)              --- Process Updates to Combat Assistant Config
        if cauigrun.getIterateCAMainLoop() then             --- Is the Combat Assistant set to run in the UI?
            cauigrun.startIteration()
            caml.mainLoopIterate(CAConfig)                  --- Iterate main loop once (process actions, etc...)
            cauigrun.endIteration()
        else
            cal.debug('Combat Assistant Disabled!')
        end

        Pause(50)                                           --- Wait 50ms before next update
    end
end

--------------
--- Export ---
--------------

local Obj = {
    runGump = runGump_
}

return Obj