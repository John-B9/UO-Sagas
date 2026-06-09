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

local CAUIGumpBuffsState = {
    OverrideWithNoBuffs = false,
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

local function processUIInteractions_(button, label)
    if button:WasClicked() then
        onOverrideWithNoBuffsButtonPressed_(CAUIGumpBuffsState.OverrideWithNoBuffs, label)
    end
end

local function updateCAConfigToCurrentUIConfig_(CAConfigBuffs)
    CAConfigBuffs.Enable = not CAUIGumpBuffsState.OverrideWithNoBuffs
end

local function initUI_(mainWindow, row)
    cal.debug('Creating Buffs UI...')
    local button = cauiglayout.createModuleEnableButtonAtRow(mainWindow, row, 'Buffs')
    local label = cauiglayout.createModuleEnableLabelAtRow(mainWindow, row, 'Enabled')
    return button, label
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