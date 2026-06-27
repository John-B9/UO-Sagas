----------------------------------------------------------------------
--- Combat Assistant (CA) User Interface (UI) Gump Attack
--- Author: JohnB9
---
--- Version: 1.0.0  - 
---
--- Description: UI for Attack module
----------------------------------------------------------------------

local cal = Import('CALog')
local cauiglayoutb = Import('CAUIGumpLayoutBase')
local cauiglogicb = Import('CAUIGumpLogicBase')

--------------
--- Layout ---
--------------

local CAUIGA = {
    enableButton = nil,
    enableLabel = nil,
    configButton = nil,
    Config = {
        window = nil,
        rangeMaxButton = nil,
        exceptionModeButton = nil
    }
}

-----------------
--- Constants ---
-----------------

local AttackRangeValues = {
    One = 1,
    Three = 2,
    Five = 3,
    Seven = 4,
    Nine = 5,
    Eleven = 6
}

local AttackRangeStrings = {
    'Range (1)',
    'Range (3)',
    'Range (5)',
    'Range (7)',
    'Range (9)',
    'Range (11)',
}

local AttackRangeConfigValues = {
    1,
    3,
    5,
    7,
    9,
    11
}

local AttackExceptionModeValues = {
    None = 1,
    IDAndNames = 2
}

local AttackExceptionModeStrings = {
    'Exceptions (None)',
    'Exceptions (ID + Names)'
}

-------------
--- State ---
-------------

CAUIGumpAttackConfig = {
    AttackEnabled = false,
    ConfigWindowClosed = true,
    AttackRangeMax = AttackRangeValues.Five,
    AttackExceptionsMode = AttackExceptionModeValues.IDAndNames
}

-----------------
--- Functions ---
-----------------

local function processAttackButtonInteractions_()
    if CAUIGA.enableButton:WasClicked() then
        CAUIGumpAttackConfig.AttackEnabled = cauiglogicb.onEnabledDisabledButtonPressed(CAUIGumpAttackConfig.AttackEnabled, CAUIGA.enableLabel, 'Attack')
    end
end

local function updateAttackConfigWindow_(targetValue, closeOtherCWs)
    CAUIGumpAttackConfig.ConfigWindowClosed = cauiglogicb.onConfigMenuButtonPressed(not targetValue, CAUIGA.configButton, CAUIGA.Config.window, 'Attack Config', closeOtherCWs)
end

local function closeAttackConfigWindow_()
    updateAttackConfigWindow_(true, false)
end

local function processAttackConfigButtonInteractions_()
    if CAUIGA.configButton:WasClicked() then
        updateAttackConfigWindow_(not CAUIGumpAttackConfig.ConfigWindowClosed, true)
    end
end

local function processAttackRangeMaxButtonInteractions_()
    if CAUIGA.Config.rangeMaxButton:WasClicked() then
        CAUIGumpAttackConfig.AttackRangeMax = cauiglogicb.onEnumStateButtonPressed(CAUIGumpAttackConfig.AttackRangeMax, AttackRangeValues.Eleven, AttackRangeStrings, CAUIGA.Config.rangeMaxButton, 'Attack Range')
    end
end

local function processAttackExceptionsModeButtonInteractions_()
    if CAUIGA.Config.exceptionModeButton:WasClicked() then
        CAUIGumpAttackConfig.AttackExceptionsMode = cauiglogicb.onEnumStateButtonPressed(CAUIGumpAttackConfig.AttackExceptionsMode, AttackExceptionModeValues.IDAndNames, AttackExceptionModeStrings, CAUIGA.Config.exceptionModeButton, 'Attack Exceptions Mode')
    end
end

local function processUIInteractions_()
    processAttackButtonInteractions_()
    processAttackConfigButtonInteractions_()
    processAttackRangeMaxButtonInteractions_()
    processAttackExceptionsModeButtonInteractions_()
end

local function updateCAConfigToCurrentUIConfig_(CAConfig)
    local attackConfig = CAConfig.modules.Attack
    attackConfig.Enable = CAUIGumpAttackConfig.AttackEnabled
    attackConfig.Rangemax = AttackRangeConfigValues[CAUIGumpAttackConfig.AttackRangeMax]
    attackConfig.AllowMobilesExceptionsGraphicIDs = CAUIGumpAttackConfig.AttackExceptionsMode == AttackExceptionModeValues.IDAndNames
    attackConfig.AllowMobilesExceptionsNames = CAUIGumpAttackConfig.AttackExceptionsMode == AttackExceptionModeValues.IDAndNames
end

local function initUI_(mainWindow, row)
    cal.debug('Creating Attack UI...')
    CAUIGA.enableButton = cauiglayoutb.createModuleEnableButtonAtRow(mainWindow, row, 'Attack')
    CAUIGA.enableLabel = cauiglayoutb.createModuleEnableLabelAtRow(mainWindow, row, 'Disabled')
    CAUIGA.enableLabel:SetColor(1, 0, 0, 1)
    CAUIGA.configButton = cauiglayoutb.createModuleConfigButtonAtRow(mainWindow, row)
    CAUIGA.Config.window = cauiglayoutb.createModuleConfigWindow('attackConfigWindow', 'Attack Config', 2, row)
    cauiglogicb.registerSharedVisibilityConfigWindowsCloseFunction(closeAttackConfigWindow_)
    CAUIGA.Config.rangeMaxButton = cauiglayoutb.createModuleConfigWindowButtonAtRow(CAUIGA.Config.window, 1, AttackRangeStrings[CAUIGumpAttackConfig.AttackRangeMax])
    CAUIGA.Config.exceptionModeButton = cauiglayoutb.createModuleConfigWindowButtonAtRow(CAUIGA.Config.window, 2, 'Exceptions (ID + Names)', 180, cauiglayoutb.getLayoutConstants().ModuleConfigWindowFeatureEnableButtonSizeY)
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