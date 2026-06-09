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

local CAUIGumpAttackStaticConfig = {
    MainWindowModuleEnableButtonPosX = 10,
    MainWindowModuleEnableButtonSizeX = 100,
    MainWindowModuleEnableButtonSizeY = 30,
    MainWindowModuleEnableLabelPosX = 140,
    MainWindowModuleRowPosYStart = 70,
    MainWindowModuleRowPosYIncrement = 50,
    MainWindowModuleRowPosYLabelAlignIncrement = 8
}

-----------------
--- Functions ---
-----------------

local function createButtonAtPosition_(mainWindow, buttonPosition, button, buttonText)
    cal.debug('Initializing "..buttonText.." button (Position: "..buttonPosition..")...')
    local buttonPosX = CAUIGumpAttackStaticConfig.MainWindowModuleEnableButtonPosX
    local buttonPosY = CAUIGumpAttackStaticConfig.MainWindowModuleRowPosYStart + (buttonPosition * CAUIGumpAttackStaticConfig.MainWindowModuleRowPosYIncrement)
    local buttonSizeX = CAUIGumpAttackStaticConfig.MainWindowModuleEnableButtonSizeX
    local buttonSizeY = CAUIGumpAttackStaticConfig.MainWindowModuleEnableButtonSizeY
    button = mainWindow:AddButton(buttonPosX, buttonPosY, buttonText, buttonSizeX, buttonSizeY)
end

local function createLabelAtPosition_(mainWindow, labelPosition, label, labelText)
    cal.debug('Initializing "..labelText.." label (Position: "..labelPosition..")...')
    local labelPosX = CAUIGumpAttackStaticConfig.MainWindowModuleEnableLabelPosX
    local labelPosY = CAUIGumpAttackStaticConfig.MainWindowModuleRowPosYStart + (labelPosition * CAUIGumpAttackStaticConfig.MainWindowModuleRowPosYIncrement) + CAUIGumpAttackStaticConfig.MainWindowModuleRowPosYLabelAlignIncrement
    label = mainWindow:AddLabel(labelPosX, labelPosY, labelText)
    label:SetColor(0, 1, 0, 1)
end

--------------
--- Export ---
--------------

local Obj = {
    createButtonAtPosition = createButtonAtPosition_,
    createLabelAtPosition = createLabelAtPosition_
}

return Obj