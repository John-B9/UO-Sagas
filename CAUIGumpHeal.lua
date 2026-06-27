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

local CAUIGH = {
    enableButton = nil,
    enableLabel = nil,
    configButton = nil,
    Config = {
        window = nil,
        bandageSelfButton = nil,
        bandageOtherButton = nil,
        healPotionsModeButton = nil,
        healPotionAfterStrengthPotionButton = nil,
        curePotionsButton = nil
    }
}
    
-----------------
--- Constants ---
-----------------

local HealPotsModeValues = {
    None = 1,
    TenPercent = 2,
    TwentyPercent = 3,
    ThirtyPercent = 4,
    FiftyPercent = 5
}

local HealPotsPercentageThreshoulds = {
    0,
    10,
    20,
    30,
    50
}

local HealPotsModeStrings = {
    'Heal Pots (Disabled)',
    'Heal Pots (10% HP)',
    'Heal Pots (20% HP)',
    'Heal Pots (30% HP)',
    'Heal Pots (50% HP)'
}

-------------
--- State ---
-------------

CAUIGumpHealConfig = {
    HealEnabled = true,
    ConfigWindowClosed = true,
    BandageSelf = true,
    BandageOther = true,
    HealPotsMode = HealPotsModeValues.TwentyPercent,
    HealPotsAfterStrPot = true,
    CurePots = false
}

-----------------
--- Functions ---
-----------------

local function processHealButtonInteractions_()
    if CAUIGH.enableButton:WasClicked() then
        CAUIGumpHealConfig.HealEnabled = cauiglogicb.onEnabledDisabledButtonPressed(CAUIGumpHealConfig.HealEnabled, CAUIGH.enableLabel, 'Heal')
    end
end

local function updateHealConfigWindow_(targetValue, closeOtherCWs)
    CAUIGumpHealConfig.ConfigWindowClosed = cauiglogicb.onConfigMenuButtonPressed(not targetValue, CAUIGH.configButton, CAUIGH.Config.window, 'Heal Config', closeOtherCWs)
end

local function closeHealConfigWindow_()
    updateHealConfigWindow_(true, false)
end

local function processHealConfigButtonInteractions_()
    if CAUIGH.configButton:WasClicked() then
        updateHealConfigWindow_(not CAUIGumpHealConfig.ConfigWindowClosed, true)
    end
end

local function processBandageSelfButtonInteractions_()
    if CAUIGH.Config.bandageSelfButton:WasClicked() then
        CAUIGumpHealConfig.BandageSelf = cauiglogicb.onBooleanButtonPressed(CAUIGumpHealConfig.BandageSelf, CAUIGH.Config.bandageSelfButton, 'Bandage Self')
    end
end

local function processBandageOtherButtonInteractions_()
    if CAUIGH.Config.bandageOtherButton:WasClicked() then
        CAUIGumpHealConfig.BandageOther = cauiglogicb.onBooleanButtonPressed(CAUIGumpHealConfig.BandageOther, CAUIGH.Config.bandageOtherButton, 'Bandage Other')
    end
end

local function processHealPotionsModeButtonInteractions_()
    if CAUIGH.Config.healPotionsModeButton:WasClicked() then
        CAUIGumpHealConfig.HealPotsMode = cauiglogicb.onEnumStateButtonPressed(CAUIGumpHealConfig.HealPotsMode, HealPotsModeValues.FiftyPercent, HealPotsModeStrings, CAUIGH.Config.healPotionsModeButton, 'Healing Potions Mode')
    end
end

local function processHealPotionAfterStrengthPotionButtonInteractions_()
    if CAUIGH.Config.healPotionAfterStrengthPotionButton:WasClicked() then
        CAUIGumpHealConfig.HealPotsAfterStrPot = cauiglogicb.onBooleanButtonPressed(CAUIGumpHealConfig.HealPotsAfterStrPot, CAUIGH.Config.healPotionAfterStrengthPotionButton, 'Heal On Str')
    end
end

local function processCurePotionsButtonInteractions_()
    if CAUIGH.Config.curePotionsButton:WasClicked() then
        CAUIGumpHealConfig.CurePots = cauiglogicb.onBooleanButtonPressed(CAUIGumpHealConfig.CurePots, CAUIGH.Config.curePotionsButton, 'Use Cure')
    end
end

local function processUIInteractions_()
    processHealButtonInteractions_()
    processHealConfigButtonInteractions_()
    processBandageSelfButtonInteractions_()
    processBandageOtherButtonInteractions_()
    processHealPotionsModeButtonInteractions_()
    processHealPotionAfterStrengthPotionButtonInteractions_()
    processCurePotionsButtonInteractions_()
end

local function updateCAConfigToCurrentUIConfig_(CAConfig)
    local bandagesConfig = CAConfig.modules.Bandages
    local healingPotionsConfig = CAConfig.modules.HealingPotions
    local strengthPotionsConfig = CAConfig.modules.Buffs.Strength
    local curePotionsConfig = CAConfig.modules.CurePotions
    if CAUIGumpHealConfig.HealEnabled then
        bandagesConfig.Enable = CAUIGumpHealConfig.BandageSelf
        bandagesConfig.BandageAllies = CAUIGumpHealConfig.BandageOther
        healingPotionsConfig.Enable = CAUIGumpHealConfig.HealPotsMode ~= HealPotsModeValues.None
        healingPotionsConfig.HPDrinkThreshould = HealPotsPercentageThreshoulds[CAUIGumpHealConfig.HealPotsMode]
        strengthPotionsConfig.DrinkHeal = CAUIGumpHealConfig.HealPotsAfterStrPot
        curePotionsConfig.Enable = CAUIGumpHealConfig.CurePots
    else
        bandagesConfig.Enable = false
        bandagesConfig.BandageAllies = false
        healingPotionsConfig.Enable = false
        healingPotionsConfig.HPDrinkThreshould = 0
        strengthPotionsConfig.DrinkHeal = false
        curePotionsConfig.Enable = false
    end
end

local function initUI_(mainWindow, row)
    cal.debug('Creating Healing UI...')
    CAUIGH.enableButton = cauiglayoutb.createModuleEnableButtonAtRow(mainWindow, row, 'Heal')
    CAUIGH.enableLabel = cauiglayoutb.createModuleEnableLabelAtRow(mainWindow, row, 'Enabled')
    CAUIGH.configButton = cauiglayoutb.createModuleConfigButtonAtRow(mainWindow, row)
    CAUIGH.Config.window = cauiglayoutb.createModuleConfigWindow('healConfigWindow', 'Heal Config', 5, row)
    cauiglogicb.registerSharedVisibilityConfigWindowsCloseFunction(closeHealConfigWindow_)
    CAUIGH.Config.bandageSelfButton = cauiglayoutb.createModuleConfigWindowButtonAtRow(CAUIGH.Config.window, 1, cauiglogicb.getBoonleanButtonStateDisplayStr(CAUIGumpHealConfig.BandageSelf, 'Bandage Self'), 140, cauiglayoutb.getLayoutConstants().ModuleConfigWindowFeatureEnableButtonSizeY)
    CAUIGH.Config.bandageOtherButton = cauiglayoutb.createModuleConfigWindowButtonAtRow(CAUIGH.Config.window, 2, cauiglogicb.getBoonleanButtonStateDisplayStr(CAUIGumpHealConfig.BandageOther, 'Bandage Others'), 140, cauiglayoutb.getLayoutConstants().ModuleConfigWindowFeatureEnableButtonSizeY)
    CAUIGH.Config.healPotionsModeButton = cauiglayoutb.createModuleConfigWindowButtonAtRow(CAUIGH.Config.window, 3, HealPotsModeStrings[CAUIGumpHealConfig.HealPotsMode], 180, cauiglayoutb.getLayoutConstants().ModuleConfigWindowFeatureEnableButtonSizeY)
    CAUIGH.Config.healPotionAfterStrengthPotionButton = cauiglayoutb.createModuleConfigWindowButtonAtRow(CAUIGH.Config.window, 4, cauiglogicb.getBoonleanButtonStateDisplayStr(CAUIGumpHealConfig.HealPotsAfterStrPot, 'Heal On Str'), 140, cauiglayoutb.getLayoutConstants().ModuleConfigWindowFeatureEnableButtonSizeY)
    CAUIGH.Config.curePotionsButton = cauiglayoutb.createModuleConfigWindowButtonAtRow(CAUIGH.Config.window, 5, cauiglogicb.getBoonleanButtonStateDisplayStr(CAUIGumpHealConfig.CurePots, 'Use Cure'), 140, cauiglayoutb.getLayoutConstants().ModuleConfigWindowFeatureEnableButtonSizeY)
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