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

-----------------
--- Functions ---
-----------------

local function processCommandsButtonInteractions_()
    if CAUIGC.enableButton:WasClicked() then
        CAUIGumpCommandsConfig.CommandsEnabled = cauiglogicb.onEnabledDisabledButtonPressed(CAUIGumpCommandsConfig.CommandsEnabled, CAUIGC.enableLabel, 'Commands')
    end
end

local function processUIInteractions_()
    processCommandsButtonInteractions_()
end

local function updateCAConfigToCurrentUIConfig_(CAConfig)
    local commandsConfig = CAConfig.userCommands
    commandsConfig.Enable = CAUIGumpCommandsConfig.CommandsEnabled
end

local function initUI_(mainWindow, row)
    cal.debug('Creating Commands UI...')
    CAUIGC.enableButton = cauiglayoutb.createModuleEnableButtonAtRow(mainWindow, row, 'Commands')
    CAUIGC.enableLabel = cauiglayoutb.createModuleEnableLabelAtRow(mainWindow, row, 'Enabled')
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
