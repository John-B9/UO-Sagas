----------------------------------------------------------------------
--- Combat Assistant (CA) User Interface (UI) Gump Commands
--- Author: JohnB9
---
--- Version: 1.0.0  - 
---
--- Description: UI for Commands module
----------------------------------------------------------------------

local cal = Import('CALog')
local cauiglayout = Import('CAUIGumpLayout')

-----------------
--- Variables ---
-----------------

CAUIGumpCommandsConfig = {
    OverrideWithNoCommands = false
}

-----------------
--- Functions ---
-----------------

local function onOverrideWithNoCommandsButtonPressed_(isChecked, label)
    cal.debug('Commands disabled checkbox changed: '..tostring(isChecked))
    CAUIGumpCommandsConfig.OverrideWithNoCommands = not isChecked
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
        onOverrideWithNoCommandsButtonPressed_(CAUIGumpCommandsConfig.OverrideWithNoCommands, label)
    end
end

local function updateCAConfigToCurrentUIConfig_(CAConfigCommands)
    CAConfigCommands.Enable = not CAUIGumpCommandsConfig.OverrideWithNoCommands
end

local function initUI_(mainWindow, row)
    cal.debug('Creating Commands UI...')
    local button = cauiglayout.createModuleEnableButtonAtRow(mainWindow, row, 'Commands')
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
