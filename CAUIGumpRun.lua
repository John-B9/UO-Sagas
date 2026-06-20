----------------------------------------------------------------------
--- Combat Assistant (CA) User Interface (UI) Gump Run
--- Author: JohnB9
---
--- Version: 1.0.0  - 
---
--- Description: Run button
----------------------------------------------------------------------

local cal = Import('CALog')
local cauiglayoutb = Import('CAUIGumpLayoutBase')
local cauiglogicb = Import('CAUIGumpLogicBase')

--------------
--- Layout ---
--------------

local CAUIGumpRunLayout = {
    RunButtonSizeX = 80,
    RunButtonSizeY = 30
}

local CAUIGR = {
    enableButton = nil,
    enableLabel = nil
}

-------------
--- State ---
-------------

CAUIGumpRunConfig = {
    IterateCAMainLoop = false
}

-----------------
--- Functions ---
-----------------

local function getIterateCAMainLoop_()
    return CAUIGumpRunConfig.IterateCAMainLoop
end

local function processRunButtonInteractions_()
    if CAUIGR.enableButton:WasClicked() then
        CAUIGumpRunConfig.IterateCAMainLoop = cauiglogicb.onLabeledBooleanButtonPressed(CAUIGumpRunConfig.IterateCAMainLoop, CAUIGR.enableLabel, 'Run', {'Running...', cauiglogicb.getColorOptions().Green}, {'Stopped', cauiglogicb.getColorOptions().Red})
    end
end

local function processUIInteractions_()
    processRunButtonInteractions_()
end

local function initUI_(mainWindow, row)
    cal.debug('Creating Run Button UI...')
    CAUIGR.enableButton = cauiglayoutb.createModuleEnableButtonAtRow(mainWindow, row, 'Run', CAUIGumpRunLayout.RunButtonSizeX, CAUIGumpRunLayout.RunButtonSizeY)
    CAUIGR.enableLabel = cauiglayoutb.createModuleEnableLabelAtRow(mainWindow, row, 'Stopped')
    cauiglogicb.setLabelColor(CAUIGR.enableLabel, cauiglogicb.getColorOptions().Red)
end

local function startIteration_()
    cal.debug('Starting Combat Assistant Iteration!')
    CAUIGR.enableLabel:SetText('Running...')                --- Starting Iteration
    cauiglogicb.setLabelColor(CAUIGR.enableLabel, cauiglogicb.getColorOptions().Orange)
end

local function endIteration_()
    cal.debug('Combat Assistant Iteration Done!')
    CAUIGR.enableLabel:SetText('Running...')                --- Iteration Done
    cauiglogicb.setLabelColor(CAUIGR.enableLabel, cauiglogicb.getColorOptions().Green)
end

--------------
--- Export ---
--------------

local Obj = {
    getIterateCAMainLoop = getIterateCAMainLoop_,
    processUIInteractions = processUIInteractions_,
    initUI = initUI_,
    startIteration = startIteration_,
    endIteration = endIteration_
}

return Obj