----------------------------------------------------------------------
--- Combat Assistant (CA) User Interface (UI) Gump Scavenge
--- Author: JohnB9
---
--- Version: 1.0.0  - 
---
--- Description: UI for Scavenge module
----------------------------------------------------------------------

local cal = Import('CALog')
local cauiglayout = Import('CAUIGumpLayout')

-----------------
--- Variables ---
-----------------

CAUIGumpScavengeConfig = {
    OverrideWithNoScavenger = true,
    ScavengerConfigOpen = true,
    ScavengerAllowGold = true,
    ScavengerAllowBones = true,
    ScavengerAllowGrimoire = true,
    ScavengerAllowRibs = true
}

-----------------
--- Functions ---
-----------------

function onScavengeButtonPressed_(isChecked, label)
    cal.debug('Scavenger disabled checkbox changed: '..tostring(isChecked))
    CAUIGumpScavengeConfig.OverrideWithNoScavenger = not isChecked
    if isChecked then
        label:SetText('Enabled')
        label:SetColor(0, 1, 0, 1)
    else
        label:SetText('Disabled')
        label:SetColor(1, 0, 0, 1)
    end
end

function onScavengerConfigButtonPressed_(isChecked, button, window)
    cal.debug('Scavenger config checkbox changed: '..tostring(isChecked))
    CAUIGumpScavengeConfig.ScavengerConfigOpen = isChecked
    if isChecked then
        button:SetText('+')
        window:Hide()
    else
        button:SetText('-')
        window:Show()
    end
end

function onScavengerGoldButtonPressed_(isChecked, button)
    cal.debug('Scavenger allow gold checkbox changed: '..tostring(isChecked))
    CAUIGumpScavengeConfig.ScavengerAllowGold = isChecked
    if isChecked then
        button:SetText('Gold (Y)')
    else
        button:SetText('Gold (N)')
    end
end

function onScavengerBonesButtonPressed_(isChecked, button)
    cal.debug('Scavenger allow bones checkbox changed: '..tostring(isChecked))
    CAUIGumpScavengeConfig.ScavengerAllowBones = isChecked
    if isChecked then
        button:SetText('Bones (Y)')
    else
        button:SetText('Bones (N)')
    end
end

function onScavengerGrimoireButtonPressed_(isChecked, button)
    cal.debug('Scavenger allow grimoire checkbox changed: '..tostring(isChecked))
    CAUIGumpScavengeConfig.ScavengerAllowGrimoire = isChecked
    if isChecked then
        button:SetText('Grimoires (Y)')
    else
        button:SetText('Grimoires (N)')
    end
end

function onScavengerRibsButtonPressed_(isChecked, button)
    cal.debug('Scavenger allow grimoire checkbox changed: '..tostring(isChecked))
    CAUIGumpScavengeConfig.ScavengerAllowRibs = isChecked
    if isChecked then
        button:SetText('Ribs (Y)')
    else
        button:SetText('Ribs (N)')
    end
end

local function processUIInteractions_(enableB, enableL, configB, configW, goldB, bonesB, grimoireB, ribsB)
    if enableB:WasClicked() then
        onScavengeButtonPressed_(CAUIGumpScavengeConfig.OverrideWithNoScavenger, enableL)
    end
    if configB:WasClicked() then
        onScavengerConfigButtonPressed_(not CAUIGumpScavengeConfig.ScavengerConfigOpen, configB, configW)
    end
    if goldB:WasClicked() then
        onScavengerGoldButtonPressed_(not CAUIGumpScavengeConfig.ScavengerAllowGold, goldB)
    end
    if bonesB:WasClicked() then
        onScavengerBonesButtonPressed_(not CAUIGumpScavengeConfig.ScavengerAllowBones, bonesB)
    end
    if grimoireB:WasClicked() then
        onScavengerGrimoireButtonPressed_(not CAUIGumpScavengeConfig.ScavengerAllowGrimoire, grimoireB)
    end
    if ribsB:WasClicked() then
        onScavengerRibsButtonPressed_(not CAUIGumpScavengeConfig.ScavengerAllowRibs, ribsB)
    end
end

local function updateCAConfigToCurrentUIConfig_(CAConfigScavenge)
    CAConfigScavenge.Enable = not CAUIGumpScavengeConfig.OverrideWithNoScavenger
    CAConfigScavenge.DisallowGold = not CAUIGumpScavengeConfig.ScavengerAllowGold
    CAConfigScavenge.DisallowBones = not CAUIGumpScavengeConfig.ScavengerAllowBones
    CAConfigScavenge.DisallowGrimoire = not CAUIGumpScavengeConfig.ScavengerAllowGrimoire
    CAConfigScavenge.DisallowRibs = not CAUIGumpScavengeConfig.ScavengerAllowRibs
end

local function initUI_(mainWindow, row)
    cal.debug('Creating Scavenge UI...')
    local enableB = cauiglayout.createModuleEnableButtonAtRow(mainWindow, row, 'Scavenge')
    local enableL = cauiglayout.createModuleEnableLabelAtRow(mainWindow, row, 'Disabled')
    enableL:SetColor(1, 0, 0, 1)
    local configB = cauiglayout.createModuleConfigButtonAtRow(mainWindow, row)
    local configW = cauiglayout.createModuleConfigWindow('scavengerConfigWindow', 'Scavenger', 4)
    local goldB = cauiglayout.createModuleConfigWindowButtonAtRow(configW, 1, 'Gold (Y)')
    local bonesB = cauiglayout.createModuleConfigWindowButtonAtRow(configW, 2, 'Bones (Y)')
    local grimoireB = cauiglayout.createModuleConfigWindowButtonAtRow(configW, 3, 'Grimoires (Y)')
    local ribsB = cauiglayout.createModuleConfigWindowButtonAtRow(configW, 4, 'Ribs (Y)')
    return enableB, enableL, configB, configW, goldB, bonesB, grimoireB, ribsB
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