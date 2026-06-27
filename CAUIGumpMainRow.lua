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

--------------
--- Layout ---
--------------

local CAUIGumpMainRowLayout = {
    TitleLabelPosX = 10,
    TitleLabelPosY = 40,
    ConfigButtonPosX = 175,
    ConfigButtonPosY = 35,
    ConfigButtonSizeX = 85,
    ConfigButtonSizeY = 25
}

local CAUIGMR = {
    mainWindow = nil,
    titleLabel = nil,
    configButton = nil,
    Config = {
        window = nil,
        rearmButton = nil,
        skinnButton = nil
    }
}

-----------------
--- Constants ---
-----------------

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

local SkinnModeValues = {
    None = 1,
    All = 2,
    ShaddowPlus = 3,
    CopperPlus = 4,
    BronzePlus = 5,
    VeritePlus = 6,
    Valorite = 7
}

local SkinnModeStrings = {
    'Skinn (None)',
    'Skinn (All)',
    'Skinn (Shaddow +)',
    'Skinn (Copper +)',
    'Skinn (Bronze +)',
    'Skinn (Verite +)',
    'Skinn (Valorite)'
}

local LeatherHuesToKeepNone = {
}

local LeatherHuesToKeepAll = {
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

local LeatherHuesToKeepShadowPlus = {
    0x0966,             --- Shadow Iron
    0x096D,             --- Copper
    0x0972,             --- Bronze
    0x089F,             --- Verite
    0x08AB              --- Valorite
}

local LeatherHuesToKeepCopperPlus = {
    0x096D,             --- Copper
    0x0972,             --- Bronze
    0x089F,             --- Verite
    0x08AB              --- Valorite
}

local LeatherHuesToKeepBronzePlus = {
    0x0972,             --- Bronze
    0x089F,             --- Verite
    0x08AB              --- Valorite
}

local LeatherHuesToKeepVeritePlus = {
    0x089F,             --- Verite
    0x08AB              --- Valorite
}

local LeatherHuesToKeepValorite = {
    0x08AB              --- Valorite
}

local SkinnModeHueKeepTables = {
    LeatherHuesToKeepNone,
    LeatherHuesToKeepAll,
    LeatherHuesToKeepShadowPlus,
    LeatherHuesToKeepCopperPlus,
    LeatherHuesToKeepBronzePlus,
    LeatherHuesToKeepVeritePlus,
    LeatherHuesToKeepValorite
}

-------------
--- State ---
-------------

CAUIGumpMainRowState = {
    MainConfigClosed = true,
    RearmMode = RearmModeValues.Move,
    SkinnMode = SkinnModeValues.None
}

-----------------
--- Functions ---
-----------------

local function updateMainConfigWindow_(targetValue, closeOtherCWs)
    CAUIGumpMainRowState.MainConfigClosed = cauiglogicb.onConfigMenuButtonPressed(not targetValue, CAUIGMR.configButton, CAUIGMR.Config.window, 'Main Config', closeOtherCWs, 'CONFIG (+)', 'CONFIG (-)')
end

local function closeMainConfigWindow_()
    updateMainConfigWindow_(true, false)
end

local function processConfigMenuButtonInteractions_()
    if CAUIGMR.configButton:WasClicked() then
        updateMainConfigWindow_(not CAUIGumpMainRowState.MainConfigClosed, true)
    end
end

local function processRearmModeButtonInteractions_()
    if CAUIGMR.Config.rearmButton:WasClicked() then
        CAUIGumpMainRowState.RearmMode = cauiglogicb.onEnumStateButtonPressed(CAUIGumpMainRowState.RearmMode, RearmModeValues.MoveAndTime, RearmModeStrings, CAUIGMR.Config.rearmButton, 'Rearm Mode')
    end
end

local function processSkinnModeButtonInteractions_()
    if CAUIGMR.Config.skinnButton:WasClicked() then
        CAUIGumpMainRowState.SkinnMode = cauiglogicb.onEnumStateButtonPressed(CAUIGumpMainRowState.SkinnMode, SkinnModeValues.Valorite, SkinnModeStrings, CAUIGMR.Config.skinnButton, 'Skinning Mode')
    end
end

local function processUIInteractions_()
    processConfigMenuButtonInteractions_()
    processRearmModeButtonInteractions_()
    processSkinnModeButtonInteractions_()
end

local function updateCAConfigToCurrentUIConfig_(CAConfig)
    local armDisarmConfig = CAConfig.modules.ArmDisarm
    local armDisarmEnabled = CAUIGumpMainRowState.RearmMode ~= RearmModeValues.None
    local rearmOnMove = CAUIGumpMainRowState.RearmMode == RearmModeValues.Move or CAUIGumpMainRowState.RearmMode == RearmModeValues.MoveAndTime
    local rearmOnDelay = CAUIGumpMainRowState.RearmMode == RearmModeValues.Time or CAUIGumpMainRowState.RearmMode == RearmModeValues.MoveAndTime
    armDisarmConfig.Enable = armDisarmEnabled
    armDisarmConfig.AutoRearmOnMove = armDisarmEnabled and rearmOnMove
    armDisarmConfig.AutoRearmWithDelay = armDisarmEnabled and rearmOnDelay
    
    local skinningConfig = CAConfig.modules.Skinning
    local skinningEnabled = CAUIGumpMainRowState.SkinnMode ~= SkinnModeValues.None
    skinningConfig.Enable = skinningEnabled
    skinningConfig.LeatherHuesToKeep = SkinnModeHueKeepTables[CAUIGumpMainRowState.SkinnMode]
end

local function initUI_(mainWindow)
    cal.debug('Creating Main Row UI...')
    CAUIGMR.titleLabel = mainWindow:AddLabel(CAUIGumpMainRowLayout.TitleLabelPosX, CAUIGumpMainRowLayout.TitleLabelPosY, 'SAGAS Combat Assistant')
    CAUIGMR.titleLabel:SetColor(0.2, 0.8, 1, 1)
    CAUIGMR.configButton = mainWindow:AddButton(CAUIGumpMainRowLayout.ConfigButtonPosX, CAUIGumpMainRowLayout.ConfigButtonPosY, 'CONFIG (+)', CAUIGumpMainRowLayout.ConfigButtonSizeX, CAUIGumpMainRowLayout.ConfigButtonSizeY)
    CAUIGMR.Config.window = cauiglayoutb.createModuleConfigWindow('MainConfigWindow', 'Main Config', 2, 1)
    cauiglogicb.registerSharedVisibilityConfigWindowsCloseFunction(closeMainConfigWindow_)
    CAUIGMR.Config.rearmButton = cauiglayoutb.createModuleConfigWindowButtonAtRow(CAUIGMR.Config.window, 1, RearmModeStrings[CAUIGumpMainRowState.RearmMode], 180, cauiglayoutb.getLayoutConstants().ModuleConfigWindowFeatureEnableButtonSizeY)
    CAUIGMR.Config.skinnButton = cauiglayoutb.createModuleConfigWindowButtonAtRow(CAUIGMR.Config.window, 2, SkinnModeStrings[CAUIGumpMainRowState.SkinnMode], 180, cauiglayoutb.getLayoutConstants().ModuleConfigWindowFeatureEnableButtonSizeY)
end

--------------
--- Export ---
--------------

local Obj = {
    updateCAConfigToCurrentUIConfig = updateCAConfigToCurrentUIConfig_,
    processUIInteractions = processUIInteractions_,
    initUI = initUI_
}

return Obj