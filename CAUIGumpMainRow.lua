----------------------------------------------------------------------
--- Combat Assistant (CA) User Interface (UI) Gump Main Row
--- Author: JohnB9
---
--- Version: 1.0.0  -
---
--- Description: UI for Main Row
----------------------------------------------------------------------

local cal = Import('CALog')
local cauiglayoutb = Import('CAUIGumpLayoutBase')
local cauiglogicb = Import('CAUIGumpLogicBase')
local cagc = Import('CAGatheringConstants')

--------------
--- Layout ---
--------------

local CAUIGumpMainRowLayout = {
    TitleLabelPosX = 10,
    TitleLabelPosY = 30,
    ConfigButtonPosX = 175,
    ConfigButtonPosY = 35,
    ConfigButtonSizeX = 85,
    ConfigButtonSizeY = 25,
    ConfigButtonYOffset = 10
}

local function getTotalSizeY_()
    return CAUIGumpMainRowLayout.ConfigButtonPosY + CAUIGumpMainRowLayout.ConfigButtonSizeY + CAUIGumpMainRowLayout.ConfigButtonYOffset
end

local CAUIGMR = {
    titleLabel = nil,
    configButton = nil,
    Config = {
        window = nil,
        configWindowTimeoutModeButton = nil,
        rearmButton = nil,
        skinningGatheringModeButton = nil,
        lumberjackingGatheringModeButton = nil,
        miningGatheringModeButton = nil
    }
}

local ConfigButtonClosedString = 'CONFIG (+)'
local ConfigButtonOpenString = 'CONFIG (-)'
---local titleLabelString =
---'  ___________________\n'..
---'_/( Dexxer Gatherer )\\_\n'..
---'¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯'
local titleLabelString =
'  ___________________\n'..
'_/( Dexxer Gatherer )\\_\n'

-----------------
--- Constants ---
-----------------

local ConfigWindowTimeoutModeValues = {
    NoTimeout = 1,
    TimeoutThreeSeconds = 2,
    TimeoutFourSeconds = 3,
    TimeoutFiveSeconds = 4,
    TimeoutSevenSeconds = 5,
}

local ConfigWindowTimeoutModeStrings = {
    'Config W Timeout (None)',
    'Config W Timeout (3s)',
    'Config W Timeout (4s)',
    'Config W Timeout (5s)',
    'Config W Timeout (7s)',
    'Config W Timeout (10s)',
}

local ConfigWindowTimeoutValues = {
    nil,
    3000,
    4000,
    5000,
    7000,
}

local RearmModeValues = {
    None = 1,
    Move = 2,
    Time = 3,
    MoveAndTime = 4
}

local RearmModeStrings = {
    'Rearm (None)',
    'Rearm (On Move)',
    'Rearm (On Timer)',
    'Rearm (On Move + Timer)'
}

local SkinningGatheringModeStrings = {
    'Skinning (None)',
    'Skinning (All)',
    'Skinning (Shadow +)',
    'Skinning (Copper +)',
    'Skinning (Bronze +)',
    'Skinning (Verite +)',
    'Skinning (Valorite)'
}

local LumberjackingGatheringModeStrings = {
    'Lumberjack (None)',
    'Lumberjack (All)',
    'Lumberjack (Shadow +)',
    'Lumberjack (Copper +)',
    'Lumberjack (Bronze +)',
    'Lumberjack (Verite +)',
    'Lumberjack (Valorite)'
}

local MiningGatheringModeStrings = {
    'Mining (None)',
    'Mining (All)',
    'Mining (Shadow +)',
    'Mining (Copper +)',
    'Mining (Bronze +)',
    'Mining (Verite +)',
    'Mining (Valorite)'
}

-------------
--- State ---
-------------

CAUIGumpMainRowState = {
    MainConfigClosed = true,
    ConfigWindowTimeoutMode = ConfigWindowTimeoutModeValues.TimeoutFourSeconds,
    RearmMode = nil,
    SkinningHuesToKeep = nil,
    LumberjackingHuesToKeep = nil,
    MiningHuesToKeep = nil
}

local function numberConfigWindowTimeoutMode_(num)
    for _, v in pairs(ConfigWindowTimeoutModeValues) do
        if ConfigWindowTimeoutValues[v] ~= nil and num <= ConfigWindowTimeoutValues[v] and num+2000 > ConfigWindowTimeoutValues[v] then
            return v
        end
    end
    return ConfigWindowTimeoutModeValues.NoTimeout   --- Default is no timeout if not found
end

local function setConfigWindowTimeoutMode_(value)
    CAUIGumpMainRowState.ConfigWindowTimeoutMode = numberConfigWindowTimeoutMode_(value*1000)
    cauiglogicb.setWindowAutoCloseTime(ConfigWindowTimeoutValues[CAUIGumpMainRowState.ConfigWindowTimeoutMode])
end

----------------------
--- UI Interaction ---
----------------------

local closeMainConfigWindow_ = nil

local function updateMainConfigWindow_(targetValue, closeOtherCWs)
    CAUIGumpMainRowState.MainConfigClosed = cauiglogicb.onConfigMenuButtonPressed(not targetValue, CAUIGMR.configButton, CAUIGMR.Config.window, 'Main Config', closeOtherCWs, closeMainConfigWindow_, ConfigButtonClosedString, ConfigButtonOpenString)
end

closeMainConfigWindow_ = function ()
    updateMainConfigWindow_(true, false)
end

local function processConfigMenuButtonInteractions_()
    if CAUIGMR.configButton:WasClicked() then
        updateMainConfigWindow_(not CAUIGumpMainRowState.MainConfigClosed, true)
    end
end

local function processConfigWindowTimeoutModeButtonInteractions_()
    if CAUIGMR.Config.configWindowTimeoutModeButton:WasClicked() then
        CAUIGumpMainRowState.ConfigWindowTimeoutMode = cauiglogicb.onEnumStateButtonPressed(CAUIGumpMainRowState.ConfigWindowTimeoutMode, ConfigWindowTimeoutModeValues.TimeoutSevenSeconds, ConfigWindowTimeoutModeStrings, CAUIGMR.Config.configWindowTimeoutModeButton, 'Config Window Timeout Mode')
        cauiglogicb.setWindowAutoCloseTime(ConfigWindowTimeoutValues[CAUIGumpMainRowState.ConfigWindowTimeoutMode])
    end
end

local function processRearmModeButtonInteractions_()
    if CAUIGMR.Config.rearmButton:WasClicked() then
        CAUIGumpMainRowState.RearmMode = cauiglogicb.onEnumStateButtonPressed(CAUIGumpMainRowState.RearmMode, RearmModeValues.MoveAndTime, RearmModeStrings, CAUIGMR.Config.rearmButton, 'Rearm Mode')
    end
end

local function processSkinningGatheringModeButtonInteractions_()
    if CAUIGMR.Config.skinningGatheringModeButton:WasClicked() then
        CAUIGumpMainRowState.SkinningHuesToKeep = cauiglogicb.onEnumStateButtonPressed(CAUIGumpMainRowState.SkinningHuesToKeep, cagc.getHuesToKeepValues().Valorite, SkinningGatheringModeStrings, CAUIGMR.Config.skinningGatheringModeButton, 'Skinning Mode')
    end
end

local function processLumberjackingGatheringModeButtonInteractions_()
    if CAUIGMR.Config.lumberjackingGatheringModeButton:WasClicked() then
        CAUIGumpMainRowState.LumberjackingHuesToKeep = cauiglogicb.onEnumStateButtonPressed(CAUIGumpMainRowState.LumberjackingHuesToKeep, cagc.getHuesToKeepValues().Valorite, LumberjackingGatheringModeStrings, CAUIGMR.Config.lumberjackingGatheringModeButton, 'Lumberjacking Mode')
    end
end

local function processMiningGatheringModeButtonInteractions_()
    if CAUIGMR.Config.miningGatheringModeButton:WasClicked() then
        CAUIGumpMainRowState.MiningHuesToKeep = cauiglogicb.onEnumStateButtonPressed(CAUIGumpMainRowState.MiningHuesToKeep, cagc.getHuesToKeepValues().Valorite, MiningGatheringModeStrings, CAUIGMR.Config.miningGatheringModeButton, 'Mining Mode')
    end
end

local function processUIInteractions_()
    processConfigMenuButtonInteractions_()
    processConfigWindowTimeoutModeButtonInteractions_()
    processRearmModeButtonInteractions_()
    processSkinningGatheringModeButtonInteractions_()
    processLumberjackingGatheringModeButtonInteractions_()
    processMiningGatheringModeButtonInteractions_()
end

-------------------------------------
--- CA Config values to UI values ---
-------------------------------------

local function setRearmUIValuesFromCAConfig_(CAConfig)
    cal.debug('Setting ArmDisarm mode UI values from CAConfig...')
    local armDisarmConfig = CAConfig.modules.ArmDisarm
    if armDisarmConfig.Enable == false then
        CAUIGumpMainRowState.RearmMode = RearmModeValues.None
    elseif armDisarmConfig.AutoRearmOnMove == true and armDisarmConfig.AutoRearmWithDelay == true then
        CAUIGumpMainRowState.RearmMode = RearmModeValues.MoveAndTime
    elseif armDisarmConfig.AutoRearmOnMove == true then
        CAUIGumpMainRowState.RearmMode = RearmModeValues.Move
    elseif armDisarmConfig.AutoRearmWithDelay == true then
        CAUIGumpMainRowState.RearmMode = RearmModeValues.Time
    else
        CAUIGumpMainRowState.RearmMode = RearmModeValues.None
    end
end

local function setGatheringUIValuesFromCAConfig_(CAConfig)
    cal.debug('Setting Gathering mode UI values from CAConfig...')
    CAUIGumpMainRowState.SkinningHuesToKeep = CAConfig.gathering.SkinningHuesToKeep
    CAUIGumpMainRowState.LumberjackingHuesToKeep = CAConfig.gathering.LumberjackingHuesToKeep
    CAUIGumpMainRowState.MiningHuesToKeep = CAConfig.gathering.MiningHuesToKeep
end

local function setUIValuesFromCAConfig_(CAConfig)
    cal.debug('Setting Main Row UI values from CAConfig...')
    setRearmUIValuesFromCAConfig_(CAConfig)
    setGatheringUIValuesFromCAConfig_(CAConfig)
end

-------------------------------------
--- UI values to CA Config values ---
-------------------------------------

local function updateCAConfigArmDisarm_(CAConfig)
    local armDisarmConfig = CAConfig.modules.ArmDisarm
    local armDisarmEnabled = CAUIGumpMainRowState.RearmMode ~= RearmModeValues.None
    local rearmOnMove = CAUIGumpMainRowState.RearmMode == RearmModeValues.Move or CAUIGumpMainRowState.RearmMode == RearmModeValues.MoveAndTime
    local rearmOnDelay = CAUIGumpMainRowState.RearmMode == RearmModeValues.Time or CAUIGumpMainRowState.RearmMode == RearmModeValues.MoveAndTime
    armDisarmConfig.Enable = armDisarmEnabled
    armDisarmConfig.AutoRearmOnMove = armDisarmEnabled and rearmOnMove
    armDisarmConfig.AutoRearmWithDelay = armDisarmEnabled and rearmOnDelay
end

local function updateCAConfigGathering_(CAConfig)
    local gatheringConfig = CAConfig.gathering
    gatheringConfig.SkinningEnabled = CAUIGumpMainRowState.SkinningHuesToKeep ~= cagc.getHuesToKeepValues().None
    gatheringConfig.SkinningHuesToKeep = CAUIGumpMainRowState.SkinningHuesToKeep
    gatheringConfig.LumberjackingHuesToKeep = CAUIGumpMainRowState.LumberjackingHuesToKeep
    gatheringConfig.MiningHuesToKeep = CAUIGumpMainRowState.MiningHuesToKeep
end

local function updateCAConfigToCurrentUIConfig_(CAConfig)
    updateCAConfigArmDisarm_(CAConfig)
    updateCAConfigGathering_(CAConfig)
end

---------------
--- UI Init ---
---------------

local function createUIElements_(mainWindow)
    cal.debug('Creating Main Row UI...')
    CAUIGMR.titleLabel = mainWindow:AddLabel(CAUIGumpMainRowLayout.TitleLabelPosX, CAUIGumpMainRowLayout.TitleLabelPosY, titleLabelString)
    CAUIGMR.titleLabel:SetColor(0.2, 0.8, 1, 1)
    CAUIGMR.configButton = mainWindow:AddButton(CAUIGumpMainRowLayout.ConfigButtonPosX, CAUIGumpMainRowLayout.ConfigButtonPosY, ConfigButtonClosedString, CAUIGumpMainRowLayout.ConfigButtonSizeX, CAUIGumpMainRowLayout.ConfigButtonSizeY)
    CAUIGMR.Config.window = cauiglayoutb.createModuleConfigWindow('MainConfigWindow', 'Main Config', 5, 1)
    cauiglogicb.registerSharedVisibilityConfigWindowsCloseFunction(closeMainConfigWindow_)
    cauiglogicb.setWindowAutoCloseTime(ConfigWindowTimeoutValues[CAUIGumpMainRowState.ConfigWindowTimeoutMode])
    CAUIGMR.Config.configWindowTimeoutModeButton = cauiglayoutb.createModuleConfigWindowButtonAtRow(CAUIGMR.Config.window, 1, ConfigWindowTimeoutModeStrings[CAUIGumpMainRowState.ConfigWindowTimeoutMode], 180, cauiglayoutb.getLayoutConstants().ModuleConfigWindowFeatureEnableButtonSizeY)
    CAUIGMR.Config.rearmButton = cauiglayoutb.createModuleConfigWindowButtonAtRow(CAUIGMR.Config.window, 2, RearmModeStrings[CAUIGumpMainRowState.RearmMode], 180, cauiglayoutb.getLayoutConstants().ModuleConfigWindowFeatureEnableButtonSizeY)
    CAUIGMR.Config.skinningGatheringModeButton = cauiglayoutb.createModuleConfigWindowButtonAtRow(CAUIGMR.Config.window, 3, SkinningGatheringModeStrings[CAUIGumpMainRowState.SkinningHuesToKeep], 180, cauiglayoutb.getLayoutConstants().ModuleConfigWindowFeatureEnableButtonSizeY)
    CAUIGMR.Config.lumberjackingGatheringModeButton = cauiglayoutb.createModuleConfigWindowButtonAtRow(CAUIGMR.Config.window, 4, LumberjackingGatheringModeStrings[CAUIGumpMainRowState.LumberjackingHuesToKeep], 180, cauiglayoutb.getLayoutConstants().ModuleConfigWindowFeatureEnableButtonSizeY)
    CAUIGMR.Config.miningGatheringModeButton = cauiglayoutb.createModuleConfigWindowButtonAtRow(CAUIGMR.Config.window, 5, MiningGatheringModeStrings[CAUIGumpMainRowState.MiningHuesToKeep], 180, cauiglayoutb.getLayoutConstants().ModuleConfigWindowFeatureEnableButtonSizeY)
end

local function initUI_(mainWindow, CAConfig)
    setUIValuesFromCAConfig_(CAConfig)
    createUIElements_(mainWindow)
end

--------------
--- Export ---
--------------

local Obj = {
    setConfigWindowTimeoutMode = setConfigWindowTimeoutMode_,
    getTotalSizeY = getTotalSizeY_,
    updateCAConfigToCurrentUIConfig = updateCAConfigToCurrentUIConfig_,
    processUIInteractions = processUIInteractions_,
    initUI = initUI_
}

return Obj