----------------------------------------------------------------------
--- Combat Assistant (CA) User Interface (UI) Gump Attack
--- Author: JohnB9
---
--- Version: 1.0.0  - 
---
--- Description: UI for Attack module
----------------------------------------------------------------------

local cal = Import('CALog')

-----------------
--- Variables ---
-----------------

local CAUIGumpLayoutConstants = {
    ModuleEnableButtonPosX = 10,
    ModuleEnableButtonSizeX = 100,
    ModuleEnableButtonSizeY = 30,
    ModuleEnableLabelPosX = 140,
    ModuleRowPosYStart = 70,
    ModuleRowPosYIncrement = 50,
    ModuleRowPosYLabelAlignIncrement = 8,
    ModuleConfigButtonPosX = 220,
    ModuleConfigButtonSizeX = 30,
    ModuleConfigButtonSizeY = 30,
    ModuleConfigWindowStartPosX = 200,
    ModuleConfigWindowStartPosY = 200,
    ModuleConfigWindowSizeX = 90,
    ModuleConfigWindowFeatureEnableButtonPosX = 10,
    ModuleConfigWindowFeatureEnableButtonPosYStart = 40,
    ModuleConfigWindowFeatureEnableButtonPosYIncrement = 50,
    ModuleConfigWindowFeatureEnableButtonSizeX = 110,
    ModuleConfigWindowFeatureEnableButtonSizeY = 30
}

-----------------
--- Functions ---
-----------------

local function createModuleEnableButtonAtRow_(mainWindow, row, buttonText, sizeX, sizeY)
    cal.debug('Initializing Module Enable "..buttonText.." Button (At Row: "..row..")...')
    local buttonPosX = CAUIGumpLayoutConstants.ModuleEnableButtonPosX
    local buttonPosY = CAUIGumpLayoutConstants.ModuleRowPosYStart + ((row -1) * CAUIGumpLayoutConstants.ModuleRowPosYIncrement)
    local buttonSizeX = (sizeX ~= nil and sizeX) or CAUIGumpLayoutConstants.ModuleEnableButtonSizeX
    local buttonSizeY = (sizeY ~= nil and sizeY) or CAUIGumpLayoutConstants.ModuleEnableButtonSizeY
    local button = mainWindow:AddButton(buttonPosX, buttonPosY, buttonText, buttonSizeX, buttonSizeY)
    return button
end

local function createModuleEnableLabelAtRow_(mainWindow, row, labelText)
    cal.debug('Initializing Module Enable Label (At Row: "..row..")...')
    local labelPosX = CAUIGumpLayoutConstants.ModuleEnableLabelPosX
    local labelPosY = CAUIGumpLayoutConstants.ModuleRowPosYStart + ((row -1) * CAUIGumpLayoutConstants.ModuleRowPosYIncrement) + CAUIGumpLayoutConstants.ModuleRowPosYLabelAlignIncrement
    local label = mainWindow:AddLabel(labelPosX, labelPosY, labelText)
    label:SetColor(0, 1, 0, 1)
    return label
end

local function createModuleConfigButtonAtRow_(mainWindow, row)
    cal.debug('Initializing Module Config Button (At Row: "..row..")...')
    local buttonPosX = CAUIGumpLayoutConstants.ModuleConfigButtonPosX
    local buttonPosY = CAUIGumpLayoutConstants.ModuleRowPosYStart + ((row -1) * CAUIGumpLayoutConstants.ModuleRowPosYIncrement)
    local buttonSizeX = CAUIGumpLayoutConstants.ModuleConfigButtonSizeX
    local buttonSizeY = CAUIGumpLayoutConstants.ModuleConfigButtonSizeY
    local button = mainWindow:AddButton(buttonPosX, buttonPosY, '+', buttonSizeX, buttonSizeY)
    return button
end

local function createModuleConfigWindow_(windowIDString, windowHeader, numRows)
    cal.debug('Creating Module Config window '..windowIDString..'...')
    local moduleConfigWindow = UI.CreateWindow(windowIDString, windowHeader)
    if not moduleConfigWindow then
        cal.debug('Failed to create Module Config window '..windowIDString..'!')
        return nil
    end
    cal.debug('Initializing Module Config window '..windowIDString..'...')
    moduleConfigWindow:SetPosition(CAUIGumpLayoutConstants.ModuleConfigWindowStartPosX, CAUIGumpLayoutConstants.ModuleConfigWindowStartPosY)
    local moduleConfigWindowSizeY = CAUIGumpLayoutConstants.ModuleConfigWindowFeatureEnableButtonPosYStart + ((numRows - 1) * CAUIGumpLayoutConstants.ModuleConfigWindowFeatureEnableButtonPosYIncrement) + 50
    moduleConfigWindow:SetSize(CAUIGumpLayoutConstants.ModuleConfigWindowSizeX, moduleConfigWindowSizeY)
    moduleConfigWindow:Hide()
    return moduleConfigWindow
end

local function createModuleConfigWindowButtonAtRow_(configWindow, row, buttonText)
    cal.debug('Initializing Module Config Window "..buttonText.." Button (At Row: "..row..")...')
    local buttonPosX = CAUIGumpLayoutConstants.ModuleConfigWindowFeatureEnableButtonPosX
    local buttonPosY = CAUIGumpLayoutConstants.ModuleConfigWindowFeatureEnableButtonPosYStart + ((row -1) * CAUIGumpLayoutConstants.ModuleConfigWindowFeatureEnableButtonPosYIncrement)
    local buttonSizeX = CAUIGumpLayoutConstants.ModuleConfigWindowFeatureEnableButtonSizeX
    local buttonSizeY = CAUIGumpLayoutConstants.ModuleConfigWindowFeatureEnableButtonSizeY
    local button = configWindow:AddButton(buttonPosX, buttonPosY, buttonText, buttonSizeX, buttonSizeY)
    return button
end

--------------
--- Export ---
--------------

local Obj = {
    createModuleEnableButtonAtRow = createModuleEnableButtonAtRow_,
    createModuleEnableLabelAtRow = createModuleEnableLabelAtRow_,
    createModuleConfigButtonAtRow = createModuleConfigButtonAtRow_,
    createModuleConfigWindow = createModuleConfigWindow_,
    createModuleConfigWindowButtonAtRow = createModuleConfigWindowButtonAtRow_
}

return Obj