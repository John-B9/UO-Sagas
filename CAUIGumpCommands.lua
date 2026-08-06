----------------------------------------------------------------------
--- Combat Assistant (CA) User Interface (UI) Gump Commands
--- Author: JohnB9
---
--- Version: 1.0.0  - 
---
--- Description: UI for Commands module
----------------------------------------------------------------------

local cal = Import('CALog')
local cauiglayoutb = Import('CAUIGumpLayoutBase')
local cauiglogicb = Import('CAUIGumpLogicBase')

--------------
--- Layout ---
--------------

local CAUIGC = {
    enableButton = nil,
    enableLabel = nil
}

-------------
--- State ---
-------------

CAUIGumpCommandsConfig = {
    CommandsEnabled = true
}

----------------------
--- UI Interaction ---
----------------------

local function processCommandsButtonInteractions_()
    if CAUIGC.enableButton:WasClicked() then
        CAUIGumpCommandsConfig.CommandsEnabled = cauiglogicb.onEnabledDisabledButtonPressed(CAUIGumpCommandsConfig.CommandsEnabled, CAUIGC.enableLabel, 'Commands')
    end
end

local function processUIInteractions_()
    processCommandsButtonInteractions_()
end

-------------------------------------
--- CA Config values to UI values ---
-------------------------------------

local function setUIValuesFromCAConfig_(CAConfig)
    cal.debug('Setting Commands UI values from CAConfig...')
    local commandsConfig = CAConfig.userCommands
    CAUIGumpCommandsConfig.CommandsEnabled = commandsConfig.Enable
end

-------------------------------------
--- UI values to CA Config values ---
-------------------------------------

local function updateCAConfigToCurrentUIConfig_(CAConfig)
    local commandsConfig = CAConfig.userCommands
    commandsConfig.Enable = CAUIGumpCommandsConfig.CommandsEnabled
end

---------------
--- UI Init ---
---------------

local function createUIElements_(mainWindow, CAConfig, row)
    cal.debug('Creating Commands UI...')
    CAUIGC.enableButton = cauiglayoutb.createModuleEnableButtonAtRow(mainWindow, row, 'Commands')
    CAUIGC.enableLabel = cauiglayoutb.createModuleEnableLabelAtRow(mainWindow, row, cauiglogicb.getEnabledDisabledLabelValues(CAUIGumpCommandsConfig.CommandsEnabled))
end

local function initUI_(mainWindow, CAConfig, row)
    setUIValuesFromCAConfig_(CAConfig)
    createUIElements_(mainWindow, CAConfig, row)
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
