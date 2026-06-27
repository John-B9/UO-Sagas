----------------------------------------------------------------------
--- Combat Assistant (CA) User Interface (UI) Gump Buffs
--- Author: JohnB9
---
--- Version: 1.0.0  - 
---
--- Description: UI for Buffs module
----------------------------------------------------------------------

local cal = Import('CALog')
local cauiglayoutb = Import('CAUIGumpLayoutBase')
local cauiglogicb = Import('CAUIGumpLogicBase')

--------------
--- Layout ---
--------------

local CAUIGB = {
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
}

-----------------
--- Constants ---
-----------------

local StaminaPotsModeValues = {
    None = 1,
    FiftyPercent = 2,
    SixtyPercent = 3,
    SeventyPercent = 4,
    EightyPercent = 5
}

local StaminaPotsModeThreshoulds = {
    0,
    50,
    60,
    70,
    80
}

local StaminaPotsModeStrings = {
    'Stamina Pots (Disabled)',
    'Stamina Pots (50% STA)',
    'Stamina Pots (60% STA)',
    'Stamina Pots (70% STA)',
    'Stamina Pots (80% STA)'
}

-------------
--- State ---
-------------

CAUIGumpBuffsState = {
    BuffsEnabled = false,
    ConfigWindowClosed = true,
    EnableNightsight = true,
    EnableStrength = true,
    EnableAgility = true,
    HealPotsAfterStrPot = true,
    StaminaPotsMode = StaminaPotsModeValues.SixtyPercent
}

-----------------
--- Functions ---
-----------------

local function processBuffsButtonInteractions_()
    if CAUIGB.enableButton:WasClicked() then
        CAUIGumpBuffsState.BuffsEnabled = cauiglogicb.onEnabledDisabledButtonPressed(CAUIGumpBuffsState.BuffsEnabled, CAUIGB.enableLabel, 'Buffs')
    end
end

local closeBuffsConfigWindow_ = nil

local function updateBuffsConfigWindow_(targetValue, closeOtherCWs)
    CAUIGumpBuffsState.ConfigWindowClosed = cauiglogicb.onConfigMenuButtonPressed(not targetValue, CAUIGB.configButton, CAUIGB.Config.window, 'Buffs Config', closeOtherCWs, closeBuffsConfigWindow_)
end

closeBuffsConfigWindow_ = function ()
    updateBuffsConfigWindow_(true, false)
end

local function processBuffsConfigButtonInteractions_()
    if CAUIGB.configButton:WasClicked() then
        updateBuffsConfigWindow_(not CAUIGumpBuffsState.ConfigWindowClosed, true)
    end
end

local function processNightsightButtonInteractions_(forced)
    if forced or CAUIGB.Config.enableNightsight:WasClicked() then
        CAUIGumpBuffsState.EnableNightsight = cauiglogicb.onBooleanButtonPressed(CAUIGumpBuffsState.EnableNightsight, CAUIGB.Config.enableNightsight, 'Nightsight', forced)
    end
end

local function processStrengthButtonInteractions_()
    if CAUIGB.Config.enableStrength:WasClicked() then
        CAUIGumpBuffsState.EnableStrength = cauiglogicb.onBooleanButtonPressed(CAUIGumpBuffsState.EnableStrength, CAUIGB.Config.enableStrength, 'Strength')
    end
end

local function processAgilityButtonInteractions_()
    if CAUIGB.Config.enableAgility:WasClicked() then
        CAUIGumpBuffsState.EnableAgility = cauiglogicb.onBooleanButtonPressed(CAUIGumpBuffsState.EnableAgility, CAUIGB.Config.enableAgility, 'Agility')
    end
end

local function processRefreshOnAgilityButtonInteractions_()
    if CAUIGB.Config.refreshAfterAgility:WasClicked() then
        CAUIGumpBuffsState.HealPotsAfterStrPot = cauiglogicb.onBooleanButtonPressed(CAUIGumpBuffsState.HealPotsAfterStrPot, CAUIGB.Config.refreshAfterAgility, 'Refresh On Agi')
    end
end

local function processStaminaPotionsModeButtonInteractions_()
    if CAUIGB.Config.staminaPotionsModeButton:WasClicked() then
        CAUIGumpBuffsState.StaminaPotsMode = cauiglogicb.onEnumStateButtonPressed(CAUIGumpBuffsState.StaminaPotsMode, StaminaPotsModeValues.EightyPercent, StaminaPotsModeStrings, CAUIGB.Config.staminaPotionsModeButton, 'Stamina Potions Mode')
    end
end

local function processUIInteractions_()
    processBuffsButtonInteractions_()
    processBuffsConfigButtonInteractions_()
    processNightsightButtonInteractions_()
    processStrengthButtonInteractions_()
    processAgilityButtonInteractions_()
    processRefreshOnAgilityButtonInteractions_()
    processStaminaPotionsModeButtonInteractions_()
end

local function updateCAConfigToCurrentUIConfig_(CAConfig)
    local buffsConfig = CAConfig.modules.Buffs
    buffsConfig.Enable = CAUIGumpBuffsState.BuffsEnabled
    buffsConfig.Nightsight.Enable = CAUIGumpBuffsState.EnableNightsight
    buffsConfig.Strength.Enable = CAUIGumpBuffsState.EnableStrength
    buffsConfig.Agility.Enable = CAUIGumpBuffsState.EnableAgility
    buffsConfig.Stamina.Enable = CAUIGumpBuffsState.StaminaPotsMode ~= StaminaPotsModeValues.None
    buffsConfig.Stamina.DrinkThreshould = StaminaPotsModeThreshoulds[CAUIGumpBuffsState.StaminaPotsMode]
end

local function initUI_(mainWindow, row)
    cal.debug('Creating Buffs UI...')
    CAUIGB.enableButton = cauiglayoutb.createModuleEnableButtonAtRow(mainWindow, row, 'Buffs')
    CAUIGB.enableLabel = cauiglayoutb.createModuleEnableLabelAtRow(mainWindow, row, 'Disabled')
    CAUIGB.enableLabel:SetColor(1, 0, 0, 1)
    CAUIGB.configButton = cauiglayoutb.createModuleConfigButtonAtRow(mainWindow, row)
    CAUIGB.Config.window = cauiglayoutb.createModuleConfigWindow('buffsConfigWindow', 'Buffs Config', 5, row)
    cauiglogicb.registerSharedVisibilityConfigWindowsCloseFunction(closeBuffsConfigWindow_)
    CAUIGB.Config.enableNightsight = cauiglayoutb.createModuleConfigWindowButtonAtRow(CAUIGB.Config.window, 1, cauiglogicb.getBoonleanButtonStateDisplayStr(CAUIGumpBuffsState.EnableNightsight, 'Nightsight'))
    CAUIGB.Config.enableStrength = cauiglayoutb.createModuleConfigWindowButtonAtRow(CAUIGB.Config.window, 2, cauiglogicb.getBoonleanButtonStateDisplayStr(CAUIGumpBuffsState.EnableStrength, 'Strength'))
    CAUIGB.Config.enableAgility = cauiglayoutb.createModuleConfigWindowButtonAtRow(CAUIGB.Config.window, 3, cauiglogicb.getBoonleanButtonStateDisplayStr(CAUIGumpBuffsState.EnableAgility, 'Agility'))
    CAUIGB.Config.refreshAfterAgility = cauiglayoutb.createModuleConfigWindowButtonAtRow(CAUIGB.Config.window, 4, cauiglogicb.getBoonleanButtonStateDisplayStr(CAUIGumpBuffsState.HealPotsAfterStrPot, 'Refresh On Agi'), 140, cauiglayoutb.getLayoutConstants().ModuleConfigWindowFeatureEnableButtonSizeY)
    CAUIGB.Config.staminaPotionsModeButton = cauiglayoutb.createModuleConfigWindowButtonAtRow(CAUIGB.Config.window, 5, StaminaPotsModeStrings[CAUIGumpBuffsState.StaminaPotsMode], 180, cauiglayoutb.getLayoutConstants().ModuleConfigWindowFeatureEnableButtonSizeY)
end

local function getEnableNightsight_()
    return CAUIGumpBuffsState.EnableNightsight
end

local function setEnableNightsight_(isChecked)
    CAUIGumpBuffsState.EnableNightsight = not isChecked
    processNightsightButtonInteractions_(true)
end

--------------
--- Export ---
--------------

local Obj = {
    updateCAConfigToCurrentUIConfig = updateCAConfigToCurrentUIConfig_,
    processUIInteractions = processUIInteractions_,
    initUI = initUI_,
    getEnableNightsight = getEnableNightsight_,
    setEnableNightsight = setEnableNightsight_
}

return Obj