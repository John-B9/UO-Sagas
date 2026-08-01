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
local cagl = Import('CAGatheringLumberjacking')
local cagm = Import('CAGatheringMining')

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
local titleLabelString =
'  ___________________\n'..
'_/( Dexxer Gatherer )\\_\n'..
'¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯'

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

local GatheringModeValues = {
    None = 1,
    All = 2,
    ShaddowPlus = 3,
    CopperPlus = 4,
    BronzePlus = 5,
    VeritePlus = 6,
    Valorite = 7
}

local SkinningGatheringModeStrings = {
    'Skinning (None)',
    'Skinning (All)',
    'Skinning (Shaddow +)',
    'Skinning (Copper +)',
    'Skinning (Bronze +)',
    'Skinning (Verite +)',
    'Skinn (Valorite)'
}

local LumberjackingGatheringModeStrings = {
    'Lumberjack (None)',
    'Lumberjack (All)',
    'Lumberjack (Shaddow +)',
    'Lumberjack (Copper +)',
    'Lumberjack (Bronze +)',
    'Lumberjack (Verite +)',
    'Lumberjack (Valorite)'
}

local MiningGatheringModeStrings = {
    'Mining (None)',
    'Mining (All)',
    'Mining (Shaddow +)',
    'Mining (Copper +)',
    'Mining (Bronze +)',
    'Mining (Verite +)',
    'Mining (Valorite)'
}

local HuesToKeepTableNone = {
}

local HuesToKeepTableAll = {
    0x0000,             --- Regular
    ---0x0973,             --- Dull Copper
    0x0966,             --- Shadow Iron
    0x096D,             --- Copper
    0x0972,             --- Bronze
    ---0x08A5,             --- Gold
    ---0x0979,             --- Agapite
    0x089F,             --- Verite
    0x08AB              --- Valorite
}

local HuesToKeepTableShadowPlus = {
    0x0966,             --- Shadow Iron
    0x096D,             --- Copper
    0x0972,             --- Bronze
    0x089F,             --- Verite
    0x08AB              --- Valorite
}

local HuesToKeepTableCopperPlus = {
    0x096D,             --- Copper
    0x0972,             --- Bronze
    0x089F,             --- Verite
    0x08AB              --- Valorite
}

local HuesToKeepTableBronzePlus = {
    0x0972,             --- Bronze
    0x089F,             --- Verite
    0x08AB              --- Valorite
}

local HuesToKeepTableVeritePlus = {
    0x089F,             --- Verite
    0x08AB              --- Valorite
}

local HuesToKeepTableValorite = {
    0x08AB              --- Valorite
}

local HuesToKeepTables = {
    HuesToKeepTableNone,
    HuesToKeepTableAll,
    HuesToKeepTableShadowPlus,
    HuesToKeepTableCopperPlus,
    HuesToKeepTableBronzePlus,
    HuesToKeepTableVeritePlus,
    HuesToKeepTableValorite
}

-------------
--- State ---
-------------

CAUIGumpMainRowState = {
    MainConfigClosed = true,
    ConfigWindowTimeoutMode = ConfigWindowTimeoutModeValues.TimeoutFourSeconds,
    RearmMode = RearmModeValues.Move,
    SkinningGatheringMode = GatheringModeValues.None,
    LumberjackingGatheringMode = GatheringModeValues.All,
    MiningGatheringMode = GatheringModeValues.All
}

-----------------
--- Functions ---
-----------------

local function getTotalSizeY_()
    return CAUIGumpMainRowLayout.ConfigButtonPosY + CAUIGumpMainRowLayout.ConfigButtonSizeY + CAUIGumpMainRowLayout.ConfigButtonYOffset
end

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
    end
end

local function processRearmModeButtonInteractions_()
    if CAUIGMR.Config.rearmButton:WasClicked() then
        CAUIGumpMainRowState.RearmMode = cauiglogicb.onEnumStateButtonPressed(CAUIGumpMainRowState.RearmMode, RearmModeValues.MoveAndTime, RearmModeStrings, CAUIGMR.Config.rearmButton, 'Rearm Mode')
    end
end

local function processSkinningGatheringModeButtonInteractions_()
    if CAUIGMR.Config.skinningGatheringModeButton:WasClicked() then
        CAUIGumpMainRowState.SkinningGatheringMode = cauiglogicb.onEnumStateButtonPressed(CAUIGumpMainRowState.SkinningGatheringMode, GatheringModeValues.Valorite, SkinningGatheringModeStrings, CAUIGMR.Config.skinningGatheringModeButton, 'Skinning Mode')
    end
end

local function processLumberjackingGatheringModeButtonInteractions_()
    if CAUIGMR.Config.lumberjackingGatheringModeButton:WasClicked() then
        CAUIGumpMainRowState.LumberjackingGatheringMode = cauiglogicb.onEnumStateButtonPressed(CAUIGumpMainRowState.LumberjackingGatheringMode, GatheringModeValues.Valorite, LumberjackingGatheringModeStrings, CAUIGMR.Config.lumberjackingGatheringModeButton, 'Lumberjacking Mode')
    end
end

local function processMiningGatheringModeButtonInteractions_()
    if CAUIGMR.Config.miningGatheringModeButton:WasClicked() then
        CAUIGumpMainRowState.MiningGatheringMode = cauiglogicb.onEnumStateButtonPressed(CAUIGumpMainRowState.MiningGatheringMode, GatheringModeValues.Valorite, MiningGatheringModeStrings, CAUIGMR.Config.miningGatheringModeButton, 'Mining Mode')
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

local function updateCAConfigToCurrentUIConfig_(CAConfig)
    cauiglogicb.setWindowAutoCloseTime(ConfigWindowTimeoutValues[CAUIGumpMainRowState.ConfigWindowTimeoutMode])

    local armDisarmConfig = CAConfig.modules.ArmDisarm
    local armDisarmEnabled = CAUIGumpMainRowState.RearmMode ~= RearmModeValues.None
    local rearmOnMove = CAUIGumpMainRowState.RearmMode == RearmModeValues.Move or CAUIGumpMainRowState.RearmMode == RearmModeValues.MoveAndTime
    local rearmOnDelay = CAUIGumpMainRowState.RearmMode == RearmModeValues.Time or CAUIGumpMainRowState.RearmMode == RearmModeValues.MoveAndTime
    armDisarmConfig.Enable = armDisarmEnabled
    armDisarmConfig.AutoRearmOnMove = armDisarmEnabled and rearmOnMove
    armDisarmConfig.AutoRearmWithDelay = armDisarmEnabled and rearmOnDelay

    local skinningConfig = CAConfig.modules.Skinning
    local skinningEnabled = CAUIGumpMainRowState.SkinningGatheringMode ~= GatheringModeValues.None
    skinningConfig.Enable = skinningEnabled
    skinningConfig.LeatherHuesToKeep = HuesToKeepTables[CAUIGumpMainRowState.SkinningGatheringMode]

    cagl.setLogHuesToKeep(HuesToKeepTables[CAUIGumpMainRowState.LumberjackingGatheringMode])
    cagm.setOreHuesToKeep(HuesToKeepTables[CAUIGumpMainRowState.MiningGatheringMode])
end

local function initUI_(mainWindow)
    cal.debug('Creating Main Row UI...')
    CAUIGMR.titleLabel = mainWindow:AddLabel(CAUIGumpMainRowLayout.TitleLabelPosX, CAUIGumpMainRowLayout.TitleLabelPosY, titleLabelString)
    CAUIGMR.titleLabel:SetColor(0.2, 0.8, 1, 1)
    CAUIGMR.configButton = mainWindow:AddButton(CAUIGumpMainRowLayout.ConfigButtonPosX, CAUIGumpMainRowLayout.ConfigButtonPosY, ConfigButtonClosedString, CAUIGumpMainRowLayout.ConfigButtonSizeX, CAUIGumpMainRowLayout.ConfigButtonSizeY)
    CAUIGMR.Config.window = cauiglayoutb.createModuleConfigWindow('MainConfigWindow', 'Main Config', 5, 1)
    cauiglogicb.registerSharedVisibilityConfigWindowsCloseFunction(closeMainConfigWindow_)
        CAUIGMR.Config.configWindowTimeoutModeButton = cauiglayoutb.createModuleConfigWindowButtonAtRow(CAUIGMR.Config.window, 1, ConfigWindowTimeoutModeStrings[CAUIGumpMainRowState.ConfigWindowTimeoutMode], 180, cauiglayoutb.getLayoutConstants().ModuleConfigWindowFeatureEnableButtonSizeY)
        CAUIGMR.Config.rearmButton = cauiglayoutb.createModuleConfigWindowButtonAtRow(CAUIGMR.Config.window, 2, RearmModeStrings[CAUIGumpMainRowState.RearmMode], 180, cauiglayoutb.getLayoutConstants().ModuleConfigWindowFeatureEnableButtonSizeY)
        CAUIGMR.Config.skinningGatheringModeButton = cauiglayoutb.createModuleConfigWindowButtonAtRow(CAUIGMR.Config.window, 3, SkinningGatheringModeStrings[CAUIGumpMainRowState.SkinningGatheringMode], 180, cauiglayoutb.getLayoutConstants().ModuleConfigWindowFeatureEnableButtonSizeY)
        CAUIGMR.Config.lumberjackingGatheringModeButton = cauiglayoutb.createModuleConfigWindowButtonAtRow(CAUIGMR.Config.window, 4, LumberjackingGatheringModeStrings[CAUIGumpMainRowState.LumberjackingGatheringMode], 180, cauiglayoutb.getLayoutConstants().ModuleConfigWindowFeatureEnableButtonSizeY)
        CAUIGMR.Config.miningGatheringModeButton = cauiglayoutb.createModuleConfigWindowButtonAtRow(CAUIGMR.Config.window, 5, MiningGatheringModeStrings[CAUIGumpMainRowState.MiningGatheringMode], 180, cauiglayoutb.getLayoutConstants().ModuleConfigWindowFeatureEnableButtonSizeY)
    end

    --------------
    --- Export ---
    --------------

    local Obj = {
        getTotalSizeY = getTotalSizeY_,
        updateCAConfigToCurrentUIConfig = updateCAConfigToCurrentUIConfig_,
        processUIInteractions = processUIInteractions_,
        initUI = initUI_
    }

    return Obj