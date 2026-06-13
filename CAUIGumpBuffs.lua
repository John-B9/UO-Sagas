----------------------------------------------------------------------
--- Combat Assistant (CA) User Interface (UI) Gump Buffs
--- Author: JohnB9
---
--- Version: 1.0.0  - 
---
--- Description: UI for Buffs module
----------------------------------------------------------------------

local cal = Import('CALog')
local cauiglayout = Import('CAUIGumpLayout')

-----------------
--- Variables ---
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

CAUIGumpBuffsState = {
    OverrideWithNoBuffs = true,
    ConfigWindowOpen = true,
    EnableNightsight = true,
    EnableStrength = true,
    EnableAgility = true,
    HealPotsAfterStrPot = true,
    StaminaPotsMode = StaminaPotsModeValues.SixtyPercent
}

-----------------
--- Functions ---
-----------------

local function onOverrideWithNoBuffsButtonPressed_(isChecked, label)
    cal.debug('Buffs disabled checkbox changed: '..tostring(isChecked))
    CAUIGumpBuffsState.OverrideWithNoBuffs = not isChecked
    if isChecked then
        label:SetText('Enabled')
        label:SetColor(0, 1, 0, 1)
    else
        label:SetText('Disabled')
        label:SetColor(1, 0, 0, 1)
    end
end

function onBuffsConfigButtonPressed_(isChecked, button, window)
    cal.debug('Buffs config button pressed: '..tostring(isChecked))
    CAUIGumpBuffsState.ConfigWindowOpen = isChecked
    if isChecked then
        button:SetText('+')
        window:Hide()
    else
        button:SetText('-')
        window:Show()
    end
end

function onNightsightButtonPressed_(isChecked, button)
    cal.debug('Nightsight button pressed: '..tostring(isChecked))
    CAUIGumpBuffsState.EnableNightsight = isChecked
    if isChecked then
        button:SetText('Nightsight (Y)')
    else
        button:SetText('Nightsight (N)')
    end
end

function onStrengthButtonPressed_(isChecked, button)
    cal.debug('Strength button pressed: '..tostring(isChecked))
    CAUIGumpBuffsState.EnableStrength = isChecked
    if isChecked then
        button:SetText('Strength (Y)')
    else
        button:SetText('Strength (N)')
    end
end

function onAgilityButtonPressed_(isChecked, button)
    cal.debug('Agility button pressed: '..tostring(isChecked))
    CAUIGumpBuffsState.EnableAgility = isChecked
    if isChecked then
        button:SetText('Agility (Y)')
    else
        button:SetText('Agility (N)')
    end
end

function onStaminaPotAfterStrenghPotButtonPressed_(isChecked, button)
    cal.debug('Use Stamina Pot after Agility Pot button pressed: '..tostring(isChecked))
    CAUIGumpHealConfig.HealPotsAfterStrPot = isChecked
    if isChecked then
        button:SetText('Refresh On Agi (Y)')
    else
        button:SetText('Refresh On Agi (N)')
    end
end

function onStaminaPotsModeButtonPressed_(button)
    cal.debug('Stamina Pots Mode button pressed...')
    CAUIGumpBuffsState.StaminaPotsMode = (CAUIGumpBuffsState.StaminaPotsMode == StaminaPotsModeValues.EightyPercent and StaminaPotsModeValues.None) or CAUIGumpBuffsState.StaminaPotsMode+1
    button:SetText(StaminaPotsModeStrings[CAUIGumpBuffsState.StaminaPotsMode])
end

local function processUIInteractions_(enableB, enableL, configB, configW, nightsightB, strengthB, agilityB, staminaPAAPB, staminaPMB)
    if enableB:WasClicked() then
        onOverrideWithNoBuffsButtonPressed_(CAUIGumpBuffsState.OverrideWithNoBuffs, enableL)
    end
    if configB:WasClicked() then
        onBuffsConfigButtonPressed_(not CAUIGumpBuffsState.ConfigWindowOpen, configB, configW)
    end
    if nightsightB:WasClicked() then
        onNightsightButtonPressed_(not CAUIGumpBuffsState.EnableNightsight, nightsightB)
    end
    if strengthB:WasClicked() then
        onStrengthButtonPressed_(not CAUIGumpBuffsState.EnableStrength, strengthB)
    end
    if agilityB:WasClicked() then
        onAgilityButtonPressed_(not CAUIGumpBuffsState.EnableAgility, agilityB)
    end
    if staminaPAAPB:WasClicked() then
        onStaminaPotAfterStrenghPotButtonPressed_(not CAUIGumpBuffsState.HealPotsAfterStrPot, staminaPAAPB)
    end
    if staminaPMB:WasClicked() then
        onStaminaPotsModeButtonPressed_(staminaPMB)
    end
end

local function updateCAConfigToCurrentUIConfig_(CAConfigBuffs)
    CAConfigBuffs.Enable = not CAUIGumpBuffsState.OverrideWithNoBuffs
    CAConfigBuffs.Nightsight.Enable = CAUIGumpBuffsState.EnableNightsight
    CAConfigBuffs.Strength.Enable = CAUIGumpBuffsState.EnableStrength
    CAConfigBuffs.Agility.Enable = CAUIGumpBuffsState.EnableAgility
    CAConfigBuffs.Stamina.Enable = CAUIGumpBuffsState.StaminaPotsMode ~= StaminaPotsModeValues.None
    CAConfigBuffs.Stamina.DrinkThreshould = StaminaPotsModeThreshoulds[CAUIGumpBuffsState.StaminaPotsMode]
end

local function initUI_(mainWindow, row)
    cal.debug('Creating Buffs UI...')
    local enableB = cauiglayout.createModuleEnableButtonAtRow(mainWindow, row, 'Buffs')
    local enableL = cauiglayout.createModuleEnableLabelAtRow(mainWindow, row, 'Disabled')
    enableL:SetColor(1, 0, 0, 1)
    local configB = cauiglayout.createModuleConfigButtonAtRow(mainWindow, row)
    local configW = cauiglayout.createModuleConfigWindow('buffsConfigWindow', 'Buffs Config', 5, row)
    local nightsightB = cauiglayout.createModuleConfigWindowButtonAtRow(configW, 1, 'Nightsight (Y)')
    local strengthB = cauiglayout.createModuleConfigWindowButtonAtRow(configW, 2, 'Strength (Y)')
    local agilityB = cauiglayout.createModuleConfigWindowButtonAtRow(configW, 3, 'Agility (Y)')
    local staminaPAAPB = cauiglayout.createModuleConfigWindowButtonAtRow(configW, 4, 'Refresh On Agi (Y)', 140, cauiglayout.getLayoutConstants().ModuleConfigWindowFeatureEnableButtonSizeY)
    local staminaPMB = cauiglayout.createModuleConfigWindowButtonAtRow(configW, 5, StaminaPotsModeStrings[CAUIGumpBuffsState.StaminaPotsMode], 180, cauiglayout.getLayoutConstants().ModuleConfigWindowFeatureEnableButtonSizeY)
    return enableB, enableL, configB, configW, nightsightB, strengthB, agilityB, staminaPAAPB, staminaPMB
end

--------------
--- Export ---
--------------

local Obj = {
    onNightsightButtonPressed = onNightsightButtonPressed_,
    updateCAConfigToCurrentUIConfig = updateCAConfigToCurrentUIConfig_,
    processUIInteractions = processUIInteractions_,
    initUI = initUI_
}

return Obj