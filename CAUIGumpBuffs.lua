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

local activateBuffsButton = nil
local buffsStatusLabel = nil

local CAUIGumpBuffsState = {
    OverrideWithNoBuffs = false,
}

-----------------
--- Functions ---
-----------------

function onOverrideWithNoBuffsButtonPressed_(isChecked)
    cal.debug('Buffs disabled checkbox changed: '..tostring(isChecked))
    CAUIGumpBuffsState.OverrideWithNoBuffs = not isChecked
    if isChecked then
        buffsStatusLabel:SetText('Enabled')
        buffsStatusLabel:SetColor(0, 1, 0, 1)
    else
        buffsStatusLabel:SetText('Disabled')
        buffsStatusLabel:SetColor(1, 0, 0, 1)
    end
end

local function processUIInteractions_()
    if activateBuffsButton:WasClicked() then                                                --- Buffs
        onOverrideWithNoBuffsButtonPressed_(CAUIGumpBuffsState.OverrideWithNoBuffs)
    end
end

local function updateCAConfigToCurrentUIConfig_(CAConfigBuffs)
    CAConfigBuffs.Enable = not CAUIGumpBuffsState.OverrideWithNoBuffs
end

local function initUI_(mainWindow, position)
    cal.debug('Creating Buffs UI...')
    cauiglayout.createButtonAtPosition(mainWindow, position, activateBuffsButton, 'Buffs')
    cauiglayout.createLabelAtPosition(mainWindow, position, buffsStatusLabel, 'Enabled')
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