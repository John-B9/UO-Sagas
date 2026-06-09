----------------------------------------------------------------------
--- Combat Assistant (CA) User Interface (UI) Gump Run
--- Author: JohnB9
---
--- Version: 1.0.0  - 
---
--- Description: Run button
----------------------------------------------------------------------

local cal = Import('CALog')
local cauiglayout = Import('CAUIGumpLayout')

-----------------
--- Variables ---
-----------------

CAUIGumpRunConfig = {
    IterateCAMainLoop = false
}

local mainWindowRunButtonSizeX = 80
local mainWindowRunButtonSizeY = 30

-----------------
--- Functions ---
-----------------

local function getIterateCAMainLoop_()
    return CAUIGumpRunConfig.IterateCAMainLoop
end

local function onRunCombatAssistantButtonPressed_(isChecked, label)
    cal.debug('Run Button changed: '..tostring(isChecked))
    CAUIGumpRunConfig.IterateCAMainLoop = isChecked
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
        onRunCombatAssistantButtonPressed_(not CAUIGumpRunConfig.IterateCAMainLoop, label)
    end
end

local function initUI_(mainWindow, row)
    cal.debug('Creating Run Button UI...')
    local button = cauiglayout.createModuleEnableButtonAtRow(mainWindow, row, 'Run', mainWindowRunButtonSizeX, mainWindowRunButtonSizeY)
    local label = cauiglayout.createModuleEnableLabelAtRow(mainWindow, row, 'Stopped')
    label:SetColor(1, 0, 0, 1)
    return button, label
end

--------------
--- Export ---
--------------

local Obj = {
    getIterateCAMainLoop = getIterateCAMainLoop_,
    processUIInteractions = processUIInteractions_,
    initUI = initUI_
}

return Obj