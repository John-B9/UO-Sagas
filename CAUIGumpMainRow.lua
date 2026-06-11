----------------------------------------------------------------------
--- Combat Assistant (CA) User Interface (UI) Gump Scavenge
--- Author: JohnB9
---
--- Version: 1.0.0  - 
---
--- Description: UI for Scavenge module
----------------------------------------------------------------------

local cal = Import('CALog')
local cauiglayout = Import('CAUIGumpLayout')

--------------
--- Layout ---
--------------

local CAUIGumpMainRowLayout = {
    TitleLabelPosX = 10,
    TitleLabelPosY = 40,
    ConfigButtonPosX = 200,
    ConfigButtonPosY = 35,
    ConfigButtonSizeX = 60,
    ConfigButtonSizeY = 25
}

-----------------
--- Constants ---
-----------------

local RearmModeValues = {
    None = 1,
    Move = 2,
    Time = 3
}

local RearmModeStrings = {
    'Rearm (None)',
    'Rearm (On Move)',
    'Rearm (On Move + Timer)'
}

local SkinnModeValues = {
    None = 1,
    All = 2,
    ShaddowPlus = 3,
    CopperPlus = 4,
    BronzePlus = 5,
    VeritePlus = 6,
    ValoritePlus = 7
}

local SkinnModeStrings = {
    'Skinn (None)',
    'Skinn (All)',
    'Skinn (Shaddow +)',
    'Skinn (Copper +)',
    'Skinn (Bronze +)',
    'Skinn (Verite +)',
    'Skinn (Valorite +)'
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

local LeatherHuesToKeepValoritePlus = {
    0x08AB              --- Valorite
}

local SkinnModeHueKeepTables = {
    LeatherHuesToKeepNone,
    LeatherHuesToKeepAll,
    LeatherHuesToKeepShadowPlus,
    LeatherHuesToKeepCopperPlus,
    LeatherHuesToKeepBronzePlus,
    LeatherHuesToKeepVeritePlus,
    LeatherHuesToKeepValoritePlus
}

-------------
--- State ---
-------------

CAUIGumpMainRowState = {
    MainConfigOpen = true,
    RearmMode = RearmModeValues.Move,
    SkinnMode = SkinnModeValues.None
}

-----------------
--- Functions ---
-----------------

function onconfigButtonPressed_(isChecked, button, window)
    cal.debug('Main config button changed: '..tostring(isChecked))
    CAUIGumpMainRowState.MainConfigOpen = isChecked
    if isChecked then
        button:SetText('CONFIG')
        window:Hide()
    else
        button:SetText('-')
        window:Show()
    end
end

function onRearmModePressed_(button)
    cal.debug('Rearm Mode button pressed...')
    CAUIGumpMainRowState.RearmMode = (CAUIGumpMainRowState.RearmMode == RearmModeValues.Time and RearmModeValues.None) or CAUIGumpMainRowState.RearmMode+1
    button:SetText(RearmModeStrings[CAUIGumpMainRowState.RearmMode])
end

function onSkinnModePressed_(button)
    cal.debug('Skinn Mode button pressed...')
    CAUIGumpMainRowState.SkinnMode = (CAUIGumpMainRowState.SkinnMode == SkinnModeValues.ValoritePlus and SkinnModeValues.None) or CAUIGumpMainRowState.SkinnMode+1
    button:SetText(SkinnModeStrings[CAUIGumpMainRowState.SkinnMode])
end

local function processUIInteractions_(configB, configW, rearmB, skinnB)
    if configB:WasClicked() then
        onconfigButtonPressed_(not CAUIGumpMainRowState.MainConfigOpen, configB, configW)
    end
    if rearmB:WasClicked() then
        onRearmModePressed_(rearmB)
    end
    if skinnB:WasClicked() then
        onSkinnModePressed_(skinnB)
    end
end

local function updateCAConfigToCurrentUIConfig_(CAConfigArmDisarm, CAConfigSkinning)
    CAConfigArmDisarm.Enable = CAUIGumpMainRowState.RearmMode ~= RearmModeValues.None
    CAConfigArmDisarm.AutoRearmWithDelay = CAConfigArmDisarm.Enable and CAUIGumpMainRowState.RearmMode == RearmModeValues.Time
    
    CAConfigSkinning.Enable = CAUIGumpMainRowState.SkinnMode ~= SkinnModeValues.None
    CAConfigSkinning.LeatherHuesToKeep = SkinnModeHueKeepTables[CAUIGumpMainRowState.SkinnMode]
end

local function initUI_(mainWindow)

    cal.debug('Creating Scavenge UI...')

    local titleLabel = mainWindow:AddLabel(CAUIGumpMainRowLayout.TitleLabelPosX, CAUIGumpMainRowLayout.TitleLabelPosY, 'SAGAS Combat Assistant')
    titleLabel:SetColor(0.2, 0.8, 1, 1)

    local configButton = mainWindow:AddButton(CAUIGumpMainRowLayout.ConfigButtonPosX, CAUIGumpMainRowLayout.ConfigButtonPosY, 'CONFIG', CAUIGumpMainRowLayout.ConfigButtonSizeX, CAUIGumpMainRowLayout.ConfigButtonSizeY)

    local configW = cauiglayout.createModuleConfigWindow('MainConfigWindow', 'Main Config', 2)
    local rearmB = cauiglayout.createModuleConfigWindowButtonAtRow(configW, 1, RearmModeStrings[CAUIGumpMainRowState.RearmMode], 180, cauiglayout.getLayoutConstants().ModuleConfigWindowFeatureEnableButtonSizeY)
    local skinnB = cauiglayout.createModuleConfigWindowButtonAtRow(configW, 2, SkinnModeStrings[CAUIGumpMainRowState.SkinnMode], 180, cauiglayout.getLayoutConstants().ModuleConfigWindowFeatureEnableButtonSizeY)

    return titleLabel, configButton, configW, rearmB, skinnB
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