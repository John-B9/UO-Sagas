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

-----------------
--- Variables ---
-----------------

local HealPotsModeValues = {
    None = 1,
    TenPercent = 2,
    TwentyPercent = 3,
    ThirtyPercent = 4,
    FiftyPercent = 5
}

local HealPotsPercentageThreshoulds = {
    0,
    10,
    20,
    30,
    50
}

local HealPotsModeStrings = {
    'Heal Pots (Disabled)',
    'Heal Pots (10% HP)',
    'Heal Pots (20% HP)',
    'Heal Pots (30% HP)',
    'Heal Pots (50% HP)'
}

CAUIGumpHealConfig = {
    OverrideWithNoHeal = false,
    ConfigWindowOpen = true,
    BandageSelf = true,
    BandageOther = true,
    HealPotsMode = HealPotsModeValues.TwentyPercent,
    HealPotsAfterStrPot = true,
    CurePots = false
}

-----------------
--- Functions ---
-----------------

function onHealButtonPressed_(isChecked, label)
    cal.debug('Heal button pressed: '..tostring(isChecked))
    CAUIGumpHealConfig.OverrideWithNoHeal = not isChecked
    if isChecked then
        label:SetText('Enabled')
        label:SetColor(0, 1, 0, 1)
    else
        label:SetText('Disabled')
        label:SetColor(1, 0, 0, 1)
    end
end

function onHealConfigButtonPressed_(isChecked, button, window)
    cal.debug('Heal config button pressed: '..tostring(isChecked))
    CAUIGumpHealConfig.ConfigWindowOpen = isChecked
    if isChecked then
        button:SetText('+')
        window:Hide()
    else
        button:SetText('-')
        window:Show()
    end
end

function onBandageSelfButtonPressed_(isChecked, button)
    cal.debug('Bandage Self button pressed: '..tostring(isChecked))
    CAUIGumpHealConfig.BandageSelf = isChecked
    if isChecked then
        button:SetText('Bandage Self (Y)')
    else
        button:SetText('Bandage Self (N)')
    end
end

function onBandageOtherButtonPressed_(isChecked, button)
    cal.debug('Bandage Other button pressed: '..tostring(isChecked))
    CAUIGumpHealConfig.BandageOther = isChecked
    if isChecked then
        button:SetText('Bandage Others (Y)')
    else
        button:SetText('Bandage Others (N)')
    end
end

function onHealPotsModeButtonPressed_(button)
    cal.debug('Healing Pots Mode button pressed...')
    CAUIGumpHealConfig.HealPotsMode = (CAUIGumpHealConfig.HealPotsMode == HealPotsModeValues.FiftyPercent and HealPotsModeValues.None) or CAUIGumpHealConfig.HealPotsMode+1
    button:SetText(HealPotsModeStrings[CAUIGumpHealConfig.HealPotsMode])
end

function onHealPotAfterStrenghPotButtonPressed_(isChecked, button)
    cal.debug('Use Heal after Strength button pressed: '..tostring(isChecked))
    CAUIGumpHealConfig.HealPotsAfterStrPot = isChecked
    if isChecked then
        button:SetText('Heal On Str (Y)')
    else
        button:SetText('Heal On Str (N)')
    end
end

function onCurePotsModeButtonPressed_(isChecked, button)
    cal.debug('Use Cure button pressed: '..tostring(isChecked))
    CAUIGumpHealConfig.CurePots = isChecked
    if isChecked then
        button:SetText('Use Cure (Y)')
    else
        button:SetText('Use Cure (N)')
    end
end

local function processUIInteractions_(enableB, enableL, configB, configW, bandageSB, bandageOB, healPMB, healPASPB, curePB)
    if enableB:WasClicked() then
        onHealButtonPressed_(CAUIGumpHealConfig.OverrideWithNoHeal, enableL)
    end
    if configB:WasClicked() then
        onHealConfigButtonPressed_(not CAUIGumpHealConfig.ConfigWindowOpen, configB, configW)
    end
    if bandageSB:WasClicked() then
        onBandageSelfButtonPressed_(not CAUIGumpHealConfig.BandageSelf, bandageSB)
    end
    if bandageOB:WasClicked() then
        onBandageOtherButtonPressed_(not CAUIGumpHealConfig.BandageOther, bandageOB)
    end
    if healPMB:WasClicked() then
        onHealPotsModeButtonPressed_(healPMB)
    end
    if healPASPB:WasClicked() then
        onHealPotAfterStrenghPotButtonPressed_(not CAUIGumpHealConfig.HealPotsAfterStrPot, healPASPB)
    end
    if curePB:WasClicked() then
        onCurePotsModeButtonPressed_(not CAUIGumpHealConfig.CurePots, curePB)
    end
end

local function updateCAConfigToCurrentUIConfig_(CAConfigBandages, CAConfigCurePotions, CAConfigHealingPotions, CAConfigBuffsStrength)

    if not CAUIGumpHealConfig.OverrideWithNoHeal then
        CAConfigBandages.Enable = CAUIGumpHealConfig.BandageSelf
        CAConfigBandages.BandageAllies = CAUIGumpHealConfig.BandageOther
        CAConfigHealingPotions.Enable = CAUIGumpHealConfig.HealPotsMode ~= HealPotsModeValues.None
        CAConfigHealingPotions.HPDrinkThreshould = HealPotsPercentageThreshoulds[CAUIGumpHealConfig.HealPotsMode]
        CAConfigBuffsStrength.DrinkHeal = CAUIGumpHealConfig.HealPotsAfterStrPot
        CAConfigCurePotions.Enable = CAUIGumpHealConfig.CurePots
    else
        CAConfigBandages.Enable = false
        CAConfigBandages.BandageAllies = false
        CAConfigHealingPotions.Enable = false
        CAConfigHealingPotions.HPDrinkThreshould = 0
        CAConfigBuffsStrength.DrinkHeal = false
        CAConfigCurePotions.Enable = false
    end
end

local function initUI_(mainWindow, row)
    cal.debug('Creating Healing UI...')
    local enableB = cauiglayout.createModuleEnableButtonAtRow(mainWindow, row, 'Heal')
    local enableL = cauiglayout.createModuleEnableLabelAtRow(mainWindow, row, 'Enabled')
    ---enableL:SetColor(1, 0, 0, 1)
    local configB = cauiglayout.createModuleConfigButtonAtRow(mainWindow, row)
    local configW = cauiglayout.createModuleConfigWindow('healConfigWindow', 'Heal Config', 5, row)
    local bandageSB = cauiglayout.createModuleConfigWindowButtonAtRow(configW, 1, 'Bandage Self (Y)', 140, cauiglayout.getLayoutConstants().ModuleConfigWindowFeatureEnableButtonSizeY)
    local bandageOB = cauiglayout.createModuleConfigWindowButtonAtRow(configW, 2, 'Bandage Others (Y)', 140, cauiglayout.getLayoutConstants().ModuleConfigWindowFeatureEnableButtonSizeY)
    local healPMB = cauiglayout.createModuleConfigWindowButtonAtRow(configW, 3, HealPotsModeStrings[CAUIGumpHealConfig.HealPotsMode], 180, cauiglayout.getLayoutConstants().ModuleConfigWindowFeatureEnableButtonSizeY)
    local healPASPB = cauiglayout.createModuleConfigWindowButtonAtRow(configW, 4, 'Heal On Str (N)', 140, cauiglayout.getLayoutConstants().ModuleConfigWindowFeatureEnableButtonSizeY)
    local curePB = cauiglayout.createModuleConfigWindowButtonAtRow(configW, 5, 'Use Cure (N)', 140, cauiglayout.getLayoutConstants().ModuleConfigWindowFeatureEnableButtonSizeY)
    return enableB, enableL, configB, configW, bandageSB, bandageOB, healPMB, healPASPB, curePB
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