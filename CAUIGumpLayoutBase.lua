----------------------------------------------------------------------
--- Combat Assistant (CA) User Interface (UI) Gump Layout Base
--- Author: JohnB9
---
--- Version: 1.0.0  - 
---
--- Description: Base functions for definning the Layout
----------------------------------------------------------------------

local cal = Import('CALog')

--------------
--- Layout ---
--------------

CAUIGumpLayoutValues = {
    ModulesRowPosYStart = nil
}

local CAUIGumpLayoutConstants = {
    ModuleEnableButtonPosX = 10,
    ModuleEnableButtonSizeX = 100,
    ModuleEnableButtonSizeY = 30,
    ModuleEnableLabelPosX = 140,
    ModuleRowPosYIncrement = 35,
    ModuleRowPosYLabelAlignIncrement = 8,
    ModuleConfigButtonPosX = 220,
    ModuleConfigButtonSizeX = 30,
    ModuleConfigButtonSizeY = 30,
    ModuleConfigWindowStartPosX = 500,
    ModuleConfigWindowStartBasePosY = 200,
    ModuleConfigWindowSizeX = 90,
    ModuleConfigWindowOffsetY = 50,
    ModuleConfigWindowFeatureEnableButtonPosX = 10,
    ModuleConfigWindowFeatureEnableButtonPosYStart = 40,
    ModuleConfigWindowFeatureEnableButtonPosYIncrement = 35,
    ModuleConfigWindowFeatureEnableButtonSizeX = 110,
    ModuleConfigWindowFeatureEnableButtonSizeY = 30
}

-----------------
--- Accessors ---
-----------------

local function getModulesRowPosYStart_()
    return CAUIGumpLayoutValues.ModulesRowPosYStart
end

local function setModulesRowPosYStart_(val)
    CAUIGumpLayoutValues.ModulesRowPosYStart = val
end

local function getLayoutConstants_()
    return CAUIGumpLayoutConstants
end

-----------------
--- Functions ---
-----------------

local function createModuleEnableButtonAtRow_(mainWindow, row, buttonText, sizeX, sizeY)
    cal.debug('Initializing Module Enable "..buttonText.." Button (At Row: "..row..")...')
    local buttonPosX = CAUIGumpLayoutConstants.ModuleEnableButtonPosX
    local buttonPosY = CAUIGumpLayoutValues.ModulesRowPosYStart + ((row -1) * CAUIGumpLayoutConstants.ModuleRowPosYIncrement)
    local buttonSizeX = (sizeX ~= nil and sizeX) or CAUIGumpLayoutConstants.ModuleEnableButtonSizeX
    local buttonSizeY = (sizeY ~= nil and sizeY) or CAUIGumpLayoutConstants.ModuleEnableButtonSizeY
    local button = mainWindow:AddButton(buttonPosX, buttonPosY, buttonText, buttonSizeX, buttonSizeY)
    return button
end

local function createModuleEnableLabelAtRow_(mainWindow, row, labelValues)
    cal.debug('Initializing Module Enable Label (At Row: "..row..")...')
    local labelPosX = CAUIGumpLayoutConstants.ModuleEnableLabelPosX
    local labelPosY = CAUIGumpLayoutValues.ModulesRowPosYStart + ((row -1) * CAUIGumpLayoutConstants.ModuleRowPosYIncrement) + CAUIGumpLayoutConstants.ModuleRowPosYLabelAlignIncrement
    local label = mainWindow:AddLabel(labelPosX, labelPosY, labelValues[1])
    label:SetColor(labelValues[2][1], labelValues[2][2], labelValues[2][3], labelValues[2][4])
    return label
end

local function createModuleConfigButtonAtRow_(mainWindow, row)
    cal.debug('Initializing Module Config Button (At Row: "..row..")...')
    local buttonPosX = CAUIGumpLayoutConstants.ModuleConfigButtonPosX
    local buttonPosY = CAUIGumpLayoutValues.ModulesRowPosYStart + ((row -1) * CAUIGumpLayoutConstants.ModuleRowPosYIncrement)
    local buttonSizeX = CAUIGumpLayoutConstants.ModuleConfigButtonSizeX
    local buttonSizeY = CAUIGumpLayoutConstants.ModuleConfigButtonSizeY
    local button = mainWindow:AddButton(buttonPosX, buttonPosY, '+', buttonSizeX, buttonSizeY)
    return button
end

local function createModuleConfigWindow_(windowIDString, windowHeader, numRows, row)
    cal.debug('Creating Module Config window '..windowIDString..'...')
    local moduleConfigWindow = UI.CreateWindow(windowIDString, windowHeader)
    if not moduleConfigWindow then
        cal.debug('Failed to create Module Config window '..windowIDString..'!')
        return nil
    end
    cal.debug('Initializing Module Config window '..windowIDString..'...')
    local posX = CAUIGumpLayoutConstants.ModuleConfigWindowStartPosX
    local posY = CAUIGumpLayoutConstants.ModuleConfigWindowStartBasePosY + ((numRows - 1) * CAUIGumpLayoutConstants.ModuleConfigWindowFeatureEnableButtonPosYIncrement)
    moduleConfigWindow:SetPosition(posX, posY)
    local moduleConfigWindowSizeY = CAUIGumpLayoutConstants.ModuleConfigWindowFeatureEnableButtonPosYStart + ((numRows - 1) * CAUIGumpLayoutConstants.ModuleConfigWindowFeatureEnableButtonPosYIncrement) + CAUIGumpLayoutConstants.ModuleConfigWindowOffsetY
    moduleConfigWindow:SetSize(CAUIGumpLayoutConstants.ModuleConfigWindowSizeX, moduleConfigWindowSizeY)
    moduleConfigWindow:Hide()
    return moduleConfigWindow
end

local function createModuleConfigWindowButtonAtRow_(configWindow, row, buttonText, sizeX, sizeY)
    cal.debug('Initializing Module Config Window "..buttonText.." Button (At Row: "..row..")...')
    local buttonPosX = CAUIGumpLayoutConstants.ModuleConfigWindowFeatureEnableButtonPosX
    local buttonPosY = CAUIGumpLayoutConstants.ModuleConfigWindowFeatureEnableButtonPosYStart + ((row -1) * CAUIGumpLayoutConstants.ModuleConfigWindowFeatureEnableButtonPosYIncrement)
    local buttonSizeX = (sizeX ~= nil and sizeX) or CAUIGumpLayoutConstants.ModuleConfigWindowFeatureEnableButtonSizeX
    local buttonSizeY = (sizeY ~= nil and sizeY) or CAUIGumpLayoutConstants.ModuleConfigWindowFeatureEnableButtonSizeY
    local button = configWindow:AddButton(buttonPosX, buttonPosY, buttonText, buttonSizeX, buttonSizeY)
    return button
end

--------------
--- Export ---
--------------

local Obj = {
    getModulesRowPosYStart = getModulesRowPosYStart_,
    setModulesRowPosYStart = setModulesRowPosYStart_,
    getLayoutConstants = getLayoutConstants_,
    createModuleEnableButtonAtRow = createModuleEnableButtonAtRow_,
    createModuleEnableLabelAtRow = createModuleEnableLabelAtRow_,
    createModuleConfigButtonAtRow = createModuleConfigButtonAtRow_,
    createModuleConfigWindow = createModuleConfigWindow_,
    createModuleConfigWindowButtonAtRow = createModuleConfigWindowButtonAtRow_
}

return Obj