----------------------------------------------------------------------
--- Combat Assistant (CA) User Interface (UI) Gump Gathering Row
--- Author: JohnB9
---
--- Version: 1.0.0  - Base implementation
---
--- Description: UI for Gathering Row
----------------------------------------------------------------------

local cal = Import('CALog')
local cauiglayoutb = Import('CAUIGumpLayoutBase')
local cauiglogicb = Import('CAUIGumpLogicBase')
local cag = Import('CAGathering')

--------------
--- Layout ---
--------------

CAUIGatheringRowLayoutConfig = {
    PosYStart = nil
}

local CAUIGumpMainRowLayout = {
    FirstButtonPosX = 25,
    ButtonsSizeX = 60,
    ButtonsSpacingX = 20,
    ButtonsSizeY = 25,
    ButtonsOffsetY = 20
}

local CAUIGGR = {
    LumberjackingButton = nil,
    MiningButton = nil,
    SkinningButton = nil
}

-----------------
--- Accessors ---
-----------------

local function setPosYStart_(val)
    CAUIGatheringRowLayoutConfig.PosYStart = val
end

local function getTotalSizeY_()
    return CAUIGumpMainRowLayout.ButtonsSizeY + CAUIGumpMainRowLayout.ButtonsOffsetY
end

-----------------
--- Constants ---
-----------------

local LumberjackingModeStrings = {
    [true] = "LJ (Y)",
    [false] = "LJ (N)"
}

local MiningModeStrings = {
    [true] = "MN (Y)",
    [false] = "MN (N)"
}

local SkinningModeStrings = {
    [true] = "SK (Y)",
    [false] = "SK (N)"
}

-------------
--- State ---
-------------

CAUIGumpGatheringRowState = {
    LumberjackingModeEnabled = false,
    MiningModeEnabled = false,
    SkinningEnabled = nil
}

----------------------
--- UI Interaction ---
----------------------

local function updateLumberjackingButton_(newState)
    CAUIGumpGatheringRowState.LumberjackingModeEnabled = newState
    CAUIGGR.LumberjackingButton:SetText(CAUIGumpGatheringRowState.LumberjackingModeEnabled and LumberjackingModeStrings[true] or LumberjackingModeStrings[false])
end

local function updateMiningButton_(newState)
    CAUIGumpGatheringRowState.MiningModeEnabled = newState
    CAUIGGR.MiningButton:SetText(CAUIGumpGatheringRowState.MiningModeEnabled and MiningModeStrings[true] or MiningModeStrings[false])
end

local function onGatheringModesChanged_(lumberjackingModeActive, miningModeActive)
    updateLumberjackingButton_(lumberjackingModeActive)
    updateMiningButton_(miningModeActive)
end

local function processLumberjackingButtonInteractions_()
    if CAUIGGR.LumberjackingButton and CAUIGGR.LumberjackingButton:WasClicked() then
        cag.toggleLumberjackingMode()
    end
end

local function processMiningButtonInteractions_()
    if CAUIGGR.MiningButton and CAUIGGR.MiningButton:WasClicked() then
        cag.toggleMiningMode()
    end
end

local function processSkinningButtonInteractions_()
    if CAUIGGR.SkinningButton and CAUIGGR.SkinningButton:WasClicked() then
        CAUIGumpGatheringRowState.SkinningEnabled = cauiglogicb.onBooleanButtonPressed(CAUIGumpGatheringRowState.SkinningEnabled, CAUIGGR.SkinningButton, 'SK')
    end
end

local function processUIInteractions_()
    processLumberjackingButtonInteractions_()
    processMiningButtonInteractions_()
    processSkinningButtonInteractions_()
end

-------------------------------------
--- CA Config values to UI values ---
-------------------------------------

local function setUIValuesFromCAConfig_(CAConfig)
    cal.debug('Setting Gathering Row UI values from CAConfig...')
    CAUIGumpGatheringRowState.SkinningEnabled = CAConfig.gathering.SkinningEnabled
end

-------------------------------------
--- UI values to CA Config values ---
-------------------------------------

local function updateCAConfigToCurrentUIConfig_(CAConfig)
    cal.debug('Setting Gathering Row UI values into CAConfig...')
    CAConfig.gathering.SkinningEnabled = CAUIGumpGatheringRowState.SkinningEnabled
end

---------------
--- UI Init ---
---------------

local function createUIElements_(mainWindow)
    cal.debug('Creating Gathering Row UI...')
    CAUIGGR.LumberjackingButton = mainWindow:AddButton(CAUIGumpMainRowLayout.FirstButtonPosX, CAUIGatheringRowLayoutConfig.PosYStart, LumberjackingModeStrings[CAUIGumpGatheringRowState.LumberjackingModeEnabled], CAUIGumpMainRowLayout.ButtonsSizeX, CAUIGumpMainRowLayout.ButtonsSizeY)
    CAUIGGR.MiningButton = mainWindow:AddButton(CAUIGumpMainRowLayout.FirstButtonPosX + CAUIGumpMainRowLayout.ButtonsSizeX + CAUIGumpMainRowLayout.ButtonsSpacingX, CAUIGatheringRowLayoutConfig.PosYStart, MiningModeStrings[CAUIGumpGatheringRowState.MiningModeEnabled], CAUIGumpMainRowLayout.ButtonsSizeX, CAUIGumpMainRowLayout.ButtonsSizeY)
    CAUIGGR.SkinningButton = mainWindow:AddButton(CAUIGumpMainRowLayout.FirstButtonPosX + 2 * (CAUIGumpMainRowLayout.ButtonsSizeX + CAUIGumpMainRowLayout.ButtonsSpacingX), CAUIGatheringRowLayoutConfig.PosYStart, SkinningModeStrings[CAUIGumpGatheringRowState.SkinningEnabled], CAUIGumpMainRowLayout.ButtonsSizeX, CAUIGumpMainRowLayout.ButtonsSizeY)
end

local function initUI_(mainWindow, CAConfig)
    setUIValuesFromCAConfig_(CAConfig)
    createUIElements_(mainWindow)
    cag.registerConfigChangedListenersCallback(onGatheringModesChanged_)
end

--------------
--- Export ---
--------------

local Obj = {
    getTotalSizeY = getTotalSizeY_,
    setPosYStart = setPosYStart_,
    updateCAConfigToCurrentUIConfig = updateCAConfigToCurrentUIConfig_,
    processUIInteractions = processUIInteractions_,
    initUI = initUI_
}

return Obj