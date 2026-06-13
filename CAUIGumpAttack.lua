----------------------------------------------------------------------
--- Combat Assistant (CA) User Interface (UI) Gump Attack
--- Author: JohnB9
---
--- Version: 1.0.0  - 
---
--- Description: UI for Attack module
----------------------------------------------------------------------

local cal = Import('CALog')
local cauiglayout = Import('CAUIGumpLayout')

-----------------
--- Variables ---
-----------------

CAUIGumpAttackConfig = {
    OverrideWithNoAttacks = true,
    ConfigWindowOpen = true,
    AttackRangeMax = 5,
    AttackExceptionsMode = true
}

-----------------
--- Functions ---
-----------------

local function onAttackButtonPressed_(isChecked, label)
    cal.debug('Attack disabled checkbox changed: '..tostring(isChecked))
    CAUIGumpAttackConfig.OverrideWithNoAttacks = not isChecked
    if isChecked then
        label:SetText('Enabled')
        label:SetColor(0, 1, 0, 1)
    else
        label:SetText('Disabled')
        label:SetColor(1, 0, 0, 1)
    end
end

function onAttackConfigButtonPressed_(isChecked, button, window)
    cal.debug('Attack config button pressed: '..tostring(isChecked))
    CAUIGumpAttackConfig.ConfigWindowOpen = isChecked
    if isChecked then
        button:SetText('+')
        window:Hide()
    else
        button:SetText('-')
        window:Show()
    end
end

function onAttackRangeMaxButtonPressed_(button)
    cal.debug('Attack Range Max button pressed: '..tostring(isChecked))
    CAUIGumpAttackConfig.AttackRangeMax = (CAUIGumpAttackConfig.AttackRangeMax == 11 and 1) or CAUIGumpAttackConfig.AttackRangeMax+2
    button:SetText('Range ('..CAUIGumpAttackConfig.AttackRangeMax..')')
end

function onAttackExceptionsModeButtonPressed_(isChecked, button)
    cal.debug('Attack Mode button pressed: '..tostring(isChecked))
    CAUIGumpAttackConfig.AttackExceptionsMode = isChecked
    if isChecked then
        button:SetText('Exceptions (ID + Names)')
    else
        button:SetText('Exceptions (None)')
    end
end

local function processUIInteractions_(enableB, enableL, configB, configW, rangeMB, attackEB)
    if enableB:WasClicked() then
        onAttackButtonPressed_(CAUIGumpAttackConfig.OverrideWithNoAttacks, enableL)
    end
    if configB:WasClicked() then
        onAttackConfigButtonPressed_(not CAUIGumpAttackConfig.ConfigWindowOpen, configB, configW)
    end
    if rangeMB:WasClicked() then
        onAttackRangeMaxButtonPressed_(rangeMB)
    end
    if attackEB:WasClicked() then
        onAttackExceptionsModeButtonPressed_(not CAUIGumpAttackConfig.AttackExceptionsMode, attackEB)
    end
end

local function updateCAConfigToCurrentUIConfig_(CAConfigAttack)
    CAConfigAttack.Enable = not CAUIGumpAttackConfig.OverrideWithNoAttacks
    CAConfigAttack.Rangemax = CAUIGumpAttackConfig.AttackRangeMax
    CAConfigAttack.AllowMobilesExceptionsGraphicIDs = CAUIGumpAttackConfig.AttackExceptionsMode
    CAConfigAttack.AllowMobilesExceptionsNames = CAUIGumpAttackConfig.AttackExceptionsMode
end

local function initUI_(mainWindow, row)
    cal.debug('Creating Attack UI...')
    local enableB = cauiglayout.createModuleEnableButtonAtRow(mainWindow, row, 'Attack')
    local enableL = cauiglayout.createModuleEnableLabelAtRow(mainWindow, row, 'Disabled')
    enableL:SetColor(1, 0, 0, 1)
    local configB = cauiglayout.createModuleConfigButtonAtRow(mainWindow, row)
    local configW = cauiglayout.createModuleConfigWindow('attackConfigWindow', 'Attack Config', 2, row)
    local rangeMB = cauiglayout.createModuleConfigWindowButtonAtRow(configW, 1, 'Range ('..CAUIGumpAttackConfig.AttackRangeMax..')')
    local attackEB = cauiglayout.createModuleConfigWindowButtonAtRow(configW, 2, 'Exceptions (ID + Names)', 180, cauiglayout.getLayoutConstants().ModuleConfigWindowFeatureEnableButtonSizeY)
    return enableB, enableL, configB, configW, rangeMB, attackEB
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