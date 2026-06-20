----------------------------------------------------------------------
--- Combat Assistant (CA) User Interface (UI) Gump Scavenge
--- Author: JohnB9
---
--- Version: 1.0.0  - 
---
--- Description: UI for Scavenge module
----------------------------------------------------------------------

local cal = Import('CALog')
local cauiglayoutb = Import('CAUIGumpLayoutBase')
local cauiglogicb = Import('CAUIGumpLogicBase')

--------------
--- Layout ---
--------------

local CAUIGS = {
    enableButton = nil,
    enableLabel = nil,
    configButton = nil,
    Config = {
        window = nil,
        activateGoldButton = nil,
        activateBandagesButton = nil,
        activateBonesButton = nil,
        activateGrimoiresButton = nil,
        activateRibsButton = nil
    }
}

-------------
--- State ---
-------------

CAUIGumpScavengeConfig = {
    ScavengerEnabled = false,
    ConfigWindowOpen = true,
    ScavengeGold = true,
    ScavengeCleanBandages = true,
    ScavengeBones = true,
    ScavengeGrimoires = true,
    ScavengeRibs = true
}

-----------------
--- Functions ---
-----------------

local function processScavengerButtonInteractions_()
    if CAUIGS.enableButton:WasClicked() then
        CAUIGumpScavengeConfig.ScavengerEnabled = cauiglogicb.onEnabledDisabledButtonPressed(CAUIGumpScavengeConfig.ScavengerEnabled, CAUIGS.enableLabel, 'Scavenger')
    end
end

local function processScavengerConfigButtonInteractions_()
    if CAUIGS.configButton:WasClicked() then
        CAUIGumpScavengeConfig.ConfigWindowOpen = cauiglogicb.onConfigMenuButtonPressed(CAUIGumpScavengeConfig.ConfigWindowOpen, CAUIGS.configButton, CAUIGS.Config.window, 'Scavenger Config')
    end
end

local function processScavengeGoldButtonInteractions_()
    if CAUIGS.Config.activateGoldButton:WasClicked() then
        CAUIGumpScavengeConfig.ScavengeGold = cauiglogicb.onBooleanButtonPressed(CAUIGumpScavengeConfig.ScavengeGold, CAUIGS.Config.activateGoldButton, 'Gold')
    end
end

local function processScavengeBandagesButtonInteractions_()
    if CAUIGS.Config.activateBandagesButton:WasClicked() then
        CAUIGumpScavengeConfig.ScavengeCleanBandages = cauiglogicb.onBooleanButtonPressed(CAUIGumpScavengeConfig.ScavengeCleanBandages, CAUIGS.Config.activateBandagesButton, 'Bandages')
    end
end

local function processScavengeBonesButtonInteractions_()
    if CAUIGS.Config.activateBonesButton:WasClicked() then
        CAUIGumpScavengeConfig.ScavengeBones = cauiglogicb.onBooleanButtonPressed(CAUIGumpScavengeConfig.ScavengeBones, CAUIGS.Config.activateBonesButton, 'Bones')
    end
end

local function processScavengeGrimoiresButtonInteractions_()
    if CAUIGS.Config.activateGrimoiresButton:WasClicked() then
        CAUIGumpScavengeConfig.ScavengeGrimoires = cauiglogicb.onBooleanButtonPressed(CAUIGumpScavengeConfig.ScavengeGrimoires, CAUIGS.Config.activateGrimoiresButton, 'Grimoires')
    end
end

local function processScavengeRibsButtonInteractions_()
    if CAUIGS.Config.activateRibsButton:WasClicked() then
        CAUIGumpScavengeConfig.ScavengeRibs = cauiglogicb.onBooleanButtonPressed(CAUIGumpScavengeConfig.ScavengeRibs, CAUIGS.Config.activateRibsButton, 'Ribs')
    end
end

local function processUIInteractions_()
    processScavengerButtonInteractions_()
    processScavengerConfigButtonInteractions_()
    processScavengeGoldButtonInteractions_()
    processScavengeBandagesButtonInteractions_()
    processScavengeBonesButtonInteractions_()
    processScavengeGrimoiresButtonInteractions_()
    processScavengeRibsButtonInteractions_()
end

local function updateCAConfigToCurrentUIConfig_(CAConfig)
    local scavengeConfig = CAConfig.modules.Scavenging
    scavengeConfig.Enable = CAUIGumpScavengeConfig.ScavengerEnabled
    scavengeConfig.DisallowGold = not CAUIGumpScavengeConfig.ScavengeGold
    scavengeConfig.DisallowCleanBandages = not CAUIGumpScavengeConfig.ScavengeCleanBandages
    scavengeConfig.DisallowBones = not CAUIGumpScavengeConfig.ScavengeBones
    scavengeConfig.DisallowGrimoire = not CAUIGumpScavengeConfig.ScavengeGrimoires
    scavengeConfig.DisallowRibs = not CAUIGumpScavengeConfig.ScavengeRibs
end

local function initUI_(mainWindow, row)
    cal.debug('Creating Scavenge UI...')
    CAUIGS.enableButton = cauiglayoutb.createModuleEnableButtonAtRow(mainWindow, row, 'Scavenge')
    CAUIGS.enableLabel = cauiglayoutb.createModuleEnableLabelAtRow(mainWindow, row, 'Disabled')
    CAUIGS.enableLabel:SetColor(1, 0, 0, 1)
    CAUIGS.configButton = cauiglayoutb.createModuleConfigButtonAtRow(mainWindow, row)
    CAUIGS.Config.window = cauiglayoutb.createModuleConfigWindow('scavengerConfigWindow', 'Scavenge Config', 5, row)
    CAUIGS.Config.activateGoldButton = cauiglayoutb.createModuleConfigWindowButtonAtRow(CAUIGS.Config.window, 1, cauiglogicb.getBoonleanButtonStateDisplayStr(CAUIGumpScavengeConfig.ScavengeGold, 'Gold'))
    CAUIGS.Config.activateBandagesButton = cauiglayoutb.createModuleConfigWindowButtonAtRow(CAUIGS.Config.window, 2, cauiglogicb.getBoonleanButtonStateDisplayStr(CAUIGumpScavengeConfig.ScavengeCleanBandages, 'Bandages'))
    CAUIGS.Config.activateBonesButton = cauiglayoutb.createModuleConfigWindowButtonAtRow(CAUIGS.Config.window, 3, cauiglogicb.getBoonleanButtonStateDisplayStr(CAUIGumpScavengeConfig.ScavengeBones, 'Bones'))
    CAUIGS.Config.activateGrimoiresButton = cauiglayoutb.createModuleConfigWindowButtonAtRow(CAUIGS.Config.window, 4, cauiglogicb.getBoonleanButtonStateDisplayStr(CAUIGumpScavengeConfig.ScavengeGrimoires, 'Grimoires'))
    CAUIGS.Config.activateRibsButton = cauiglayoutb.createModuleConfigWindowButtonAtRow(CAUIGS.Config.window, 5, cauiglogicb.getBoonleanButtonStateDisplayStr(CAUIGumpScavengeConfig.ScavengeRibs, 'Ribs'))
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