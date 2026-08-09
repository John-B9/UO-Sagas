----------------------------------------------------------------------
--- Combat Assistant (CA) UI Gump Stats Display
--- Author: JohnB9
---
--- Version: 1.0.0  - UI Gump Stats Display base implementation
---
--- Description: UI Gump Stats Display functions
----------------------------------------------------------------------

local bl = Import('BaseLib')
local cal = Import('CALog')
local cat = Import('CATime')
local iuw = Import('IUWeapons')
local iua = Import('IUArmour')
local iug = Import('IUGathering')
local cauiglogicb = Import('CAUIGumpLogicBase')

-----------------
--- Variables ---
-----------------

CAUIGumpStatsDisplayConfig = {
    PosYStart = nil
}

local CAUIGumpStatsDisplayStaticConfig = {
    TotalSizeY = 155,
    RowIncrementSizeY = 20,
    RefreshRate = 1000,
    ItemsGraphicIDs = {
        Bandage = 0x0e21,
        TrappedPouch = 0x0e79,
        HealingPotion = 0x0f0c,
        CurePotion = 0x0f07,
        StaminaPotion = 0x0f0b,
        AgilityPotion = 0x0f08,
        StrengthPotion = 0x0f09,
        NightsightPotion = 0x0f06
    },
    ItemsHues = {
        TrappedPouch = 0x0025
    }
}

CAUIGumpStatsDisplayState = {
    LastRefreshTime = 0     --- Refresh right away at startup
}

local noItemString = '---'

-----------------
--- Accessors ---
-----------------

local function setPosYStart_(val)
    CAUIGumpStatsDisplayConfig.PosYStart = val
end

local function getTotalSizeY_()
    return CAUIGumpStatsDisplayStaticConfig.TotalSizeY
end

--------------
--- Layout ---
--------------

local CAUIGumpStatsDisplayLayout = {
    RowPosYIncrement = 30,
    Row1 = {
        CharLabelPosX = 10,
        HitPointsPercentageLabelPosX = 70,
        StaminaPercentageLabelPosX = 135,
        WeightPercentageLabelPosX = 200
    },
    Row2 = {
        ItemsLabelPosX = 10,
        BandagesLabelPosX = 70,
        TrappedPouchesLabelPosX = 150
    },
    Row3 = {
        PotionsLabelPosX = 10,
        HealingPotionsLabelPosX = 70,
        CurePotionsLabelPosX = 130,
        StaminaPotionsLabelPosX = 190
    },
    Row4 = {
        AgilityPotionsLabelPosX = 70,
        StrengthPotionsLabelPosX = 130,
        NightsightPotionsLabelPosX = 190
    },
    Row5 = {
        GatheringLabelPosX = 10,
        PickaxesLabelPosX = 70,
        HatchetsLabelPosX = 130,
        SkinningKnifesLabelPosX = 190
    },
    Row6 = {
        HandsLabelPosX = 10,
        WeaponDurabilityLabelPosX = 70,
        ShieldLabelPosX = 150
    },
    Row7 = {
        ArmourLabelPosX = 10,
        ArmourAverageDurabilityLabelPosX = 70,
        ArmourWorstPieceDurabilityLabelPosX = 150
    }
}

local CAUIGSD = {
    Row1 = {
        CharLabel = nil,
        HitPointsPercentageLabel = nil,
        StaminaPercentageLabel = nil,
        WeightPercentageLabel = nil
    },
    Row2 = {
        ItemsLabel = nil,
        BandagesLabel = nil,
        TrappedPouchesLabel = nil
    },
    Row3 = {
        PotionsLabel = nil,
        HealingPotionsLabel = nil,
        CurePotionsLabel = nil,
        StaminaPotionsLabel = nil
    },
    Row4 = {
        AgilityPotionsLabel = nil,
        StrengthPotionsLabel = nil,
        NightsightPotionsLabel = nil
    },
    Row5 = {
        GatheringLabel = nil,
        PickaxesLabel = nil,
        HatchetsLabel = nil,
        SkinningKnifesLabel = nil
    },
    Row6 = {
        HandsLabel = nil,
        WeaponDurabilityLabel = nil,
        ShieldDurabilityLabel = nil
    },
    Row7 = {
        ArmourLabel = nil,
        ArmourAverageDurabilityLabel = nil,
        ArmourWorstPieceDurabilityLabel = nil
    }
}

------------------------
--- Helper Functions ---
------------------------

local function getAmountColor_(amount, amountRed, amountOrange)
    if amount <= amountRed then
        return cauiglogicb.getColorOptions().LightRed
    elseif amount <= amountOrange then
        return cauiglogicb.getColorOptions().LightOrange
    else
        return cauiglogicb.getColorOptions().LightGreen
    end
end

local function getPercentageAmountColor_(percentageAmount)
    return getAmountColor_(percentageAmount, 30, 70)
end

local function getGatheringPercentageAmountColor_(percentageAmount)
    return getAmountColor_(percentageAmount, 100, 300)
end

local function getReverseAmountColor_(amount, amountGreen, amountOrange)
    if amount <= amountGreen then
        return cauiglogicb.getColorOptions().LightGreen
    elseif amount <= amountOrange then
        return cauiglogicb.getColorOptions().LightOrange
    else
        return cauiglogicb.getColorOptions().LightRed
    end
end

local function getReversePercentageAmountColor_(percentageAmount)
    return getReverseAmountColor_(percentageAmount, 30, 70)
end

local function getBandagesAmountColor_(bandagesAmount)
    return getAmountColor_(bandagesAmount, 30, 100)
end

local function getTrappedPouchesAmountColor_(bandagesAmount)
    return getAmountColor_(bandagesAmount, 3, 7)
end

local function getPotionAmountColor_(potionAmount)
    return getAmountColor_(potionAmount, 2, 5)
end

local function getNightsightPotionAmountColor_(potionAmount)
    return getAmountColor_(potionAmount, 1, 2)
end

-------------
--- Row 1 ---
-------------

local function initRow1UI_(mainWindow)
    local row1PosY = CAUIGumpStatsDisplayConfig.PosYStart
    CAUIGSD.Row1.CharLabel = mainWindow:AddLabel(CAUIGumpStatsDisplayLayout.Row1.CharLabelPosX, row1PosY, '')
    CAUIGSD.Row1.HitPointsPercentageLabel = mainWindow:AddLabel(CAUIGumpStatsDisplayLayout.Row1.HitPointsPercentageLabelPosX, row1PosY, '')
    CAUIGSD.Row1.StaminaPercentageLabel = mainWindow:AddLabel(CAUIGumpStatsDisplayLayout.Row1.StaminaPercentageLabelPosX, row1PosY, '')
    CAUIGSD.Row1.WeightPercentageLabel = mainWindow:AddLabel(CAUIGumpStatsDisplayLayout.Row1.WeightPercentageLabelPosX, row1PosY, '')
end

local function updateCharLabel_()
    CAUIGSD.Row1.CharLabel:SetText('(CHAR)')
    cauiglogicb.setLabelColor(CAUIGSD.Row1.CharLabel, cauiglogicb.getColorOptions().Blue)
end

local function updateHitPointsPercentageLabel_()
    local hitPointsPercentage = math.floor(bl.getHpPercentage(Player))
    CAUIGSD.Row1.HitPointsPercentageLabel:SetText('HP: '..hitPointsPercentage..'%%')
    cauiglogicb.setLabelColor(CAUIGSD.Row1.HitPointsPercentageLabel, getPercentageAmountColor_(hitPointsPercentage))
end

local function updateStaminaPercentageLabel_()
    local staminaPercentage = math.floor(bl.getStaminaPercentage(Player))
    CAUIGSD.Row1.StaminaPercentageLabel:SetText('ST: '..staminaPercentage..'%%')
    cauiglogicb.setLabelColor(CAUIGSD.Row1.StaminaPercentageLabel, getPercentageAmountColor_(staminaPercentage))
end

local function updateWeightPercentageLabel_()
    local carryCapacityPercentage = math.floor(bl.getCarryCapacityPercentage(Player))
    CAUIGSD.Row1.WeightPercentageLabel:SetText('WT: '..carryCapacityPercentage..'%%')
    cauiglogicb.setLabelColor(CAUIGSD.Row1.WeightPercentageLabel, getReversePercentageAmountColor_(carryCapacityPercentage))
end

local function updateRow1UI_()
    updateCharLabel_()
    updateHitPointsPercentageLabel_()
    updateStaminaPercentageLabel_()
    updateWeightPercentageLabel_()
end

-------------
--- Row 2 ---
-------------

local function initRow2UI_(mainWindow)
    local row2PosY = CAUIGumpStatsDisplayConfig.PosYStart + CAUIGumpStatsDisplayStaticConfig.RowIncrementSizeY
    CAUIGSD.Row2.ItemsLabel = mainWindow:AddLabel(CAUIGumpStatsDisplayLayout.Row2.ItemsLabelPosX, row2PosY, '')
    CAUIGSD.Row2.BandagesLabel = mainWindow:AddLabel(CAUIGumpStatsDisplayLayout.Row2.BandagesLabelPosX, row2PosY, '')
    CAUIGSD.Row2.TrappedPouchesLabel = mainWindow:AddLabel(CAUIGumpStatsDisplayLayout.Row2.TrappedPouchesLabelPosX, row2PosY, '')
end

local function updateItemsLabel_()
    CAUIGSD.Row2.ItemsLabel:SetText('(ITEM)')
    cauiglogicb.setLabelColor(CAUIGSD.Row2.ItemsLabel, cauiglogicb.getColorOptions().Blue)
end

local function updateBandagesLabel_()
    local numBandages = bl.countAmountInInventory(CAUIGumpStatsDisplayStaticConfig.ItemsGraphicIDs.Bandage)
    CAUIGSD.Row2.BandagesLabel:SetText('Band: '..numBandages)
    cauiglogicb.setLabelColor(CAUIGSD.Row2.BandagesLabel, getBandagesAmountColor_(numBandages))
end

local function updateTrappedPouchesLabel_()
    local numTrappedPouches = bl.countAmountInInventory(CAUIGumpStatsDisplayStaticConfig.ItemsGraphicIDs.TrappedPouch, CAUIGumpStatsDisplayStaticConfig.ItemsHues.TrappedPouch)
    CAUIGSD.Row2.TrappedPouchesLabel:SetText('Pouch: '..numTrappedPouches)
    cauiglogicb.setLabelColor(CAUIGSD.Row2.TrappedPouchesLabel, getTrappedPouchesAmountColor_(numTrappedPouches))
end

local function updateRow2UI_()
    updateItemsLabel_()
    updateBandagesLabel_()
    updateTrappedPouchesLabel_()
end

-------------
--- Row 3 ---
-------------

local function initRow3UI_(mainWindow)
    local row3PosY = CAUIGumpStatsDisplayConfig.PosYStart + 2*CAUIGumpStatsDisplayStaticConfig.RowIncrementSizeY
    CAUIGSD.Row3.PotionsLabel = mainWindow:AddLabel(CAUIGumpStatsDisplayLayout.Row3.PotionsLabelPosX, row3PosY, '')
    CAUIGSD.Row3.HealingPotionsLabel = mainWindow:AddLabel(CAUIGumpStatsDisplayLayout.Row3.HealingPotionsLabelPosX, row3PosY, '')
    CAUIGSD.Row3.CurePotionsLabel = mainWindow:AddLabel(CAUIGumpStatsDisplayLayout.Row3.CurePotionsLabelPosX, row3PosY, '')
    CAUIGSD.Row3.StaminaPotionsLabel = mainWindow:AddLabel(CAUIGumpStatsDisplayLayout.Row3.StaminaPotionsLabelPosX, row3PosY, '')
end

local function updatePotionsLabel_()
    CAUIGSD.Row3.PotionsLabel:SetText('(POTS)')
    cauiglogicb.setLabelColor(CAUIGSD.Row3.PotionsLabel, cauiglogicb.getColorOptions().Blue)
end

local function updateHealingPotionsLabel_()
    local numHealingPotions = bl.countAmountInInventory(CAUIGumpStatsDisplayStaticConfig.ItemsGraphicIDs.HealingPotion)
    CAUIGSD.Row3.HealingPotionsLabel:SetText('Heal: '..numHealingPotions)
    cauiglogicb.setLabelColor(CAUIGSD.Row3.HealingPotionsLabel, getPotionAmountColor_(numHealingPotions))
end

local function updateCurePotionsLabel_()
    local numCurePotions = bl.countAmountInInventory(CAUIGumpStatsDisplayStaticConfig.ItemsGraphicIDs.CurePotion)
    CAUIGSD.Row3.CurePotionsLabel:SetText('Cure: '..numCurePotions)
    cauiglogicb.setLabelColor(CAUIGSD.Row3.CurePotionsLabel, getPotionAmountColor_(numCurePotions))
end

local function updateStaminaPotionsLabel_()
    local numStaminaPotions = bl.countAmountInInventory(CAUIGumpStatsDisplayStaticConfig.ItemsGraphicIDs.StaminaPotion)
    CAUIGSD.Row3.StaminaPotionsLabel:SetText('Stam: '..numStaminaPotions)
    cauiglogicb.setLabelColor(CAUIGSD.Row3.StaminaPotionsLabel, getPotionAmountColor_(numStaminaPotions))
end

local function updateRow3UI_()
    updatePotionsLabel_()
    updateHealingPotionsLabel_()
    updateCurePotionsLabel_()
    updateStaminaPotionsLabel_()
end

-------------
--- Row 4 ---
-------------

local function initRow4UI_(mainWindow)
    local row4PosY = CAUIGumpStatsDisplayConfig.PosYStart + 3*CAUIGumpStatsDisplayStaticConfig.RowIncrementSizeY
    CAUIGSD.Row4.AgilityPotionsLabel = mainWindow:AddLabel(CAUIGumpStatsDisplayLayout.Row4.AgilityPotionsLabelPosX, row4PosY, '')
    CAUIGSD.Row4.StrengthPotionsLabel = mainWindow:AddLabel(CAUIGumpStatsDisplayLayout.Row4.StrengthPotionsLabelPosX, row4PosY, '')
    CAUIGSD.Row4.NightsightPotionsLabel = mainWindow:AddLabel(CAUIGumpStatsDisplayLayout.Row4.NightsightPotionsLabelPosX, row4PosY, '')
end

local function updateAgilityPotionsLabel_()
    local numAgilityPotions = bl.countAmountInInventory(CAUIGumpStatsDisplayStaticConfig.ItemsGraphicIDs.AgilityPotion)
    CAUIGSD.Row4.AgilityPotionsLabel:SetText('Agi:  '..numAgilityPotions)
    cauiglogicb.setLabelColor(CAUIGSD.Row4.AgilityPotionsLabel, getPotionAmountColor_(numAgilityPotions))
end

local function updateStrengthPotionsLabel_()
    local numStrengthPotions = bl.countAmountInInventory(CAUIGumpStatsDisplayStaticConfig.ItemsGraphicIDs.StrengthPotion)
    CAUIGSD.Row4.StrengthPotionsLabel:SetText('Str:  '..numStrengthPotions)
    cauiglogicb.setLabelColor(CAUIGSD.Row4.StrengthPotionsLabel, getPotionAmountColor_(numStrengthPotions))
end

local function updateNightsightPotionsLabel_()
    local numNightsightPotions = bl.countAmountInInventory(CAUIGumpStatsDisplayStaticConfig.ItemsGraphicIDs.NightsightPotion)
    CAUIGSD.Row4.NightsightPotionsLabel:SetText('Nigh: '..numNightsightPotions)
    cauiglogicb.setLabelColor(CAUIGSD.Row4.NightsightPotionsLabel, getNightsightPotionAmountColor_(numNightsightPotions))
end

local function updateRow4UI_()
    updateAgilityPotionsLabel_()
    updateStrengthPotionsLabel_()
    updateNightsightPotionsLabel_()
end

-------------
--- Row 5 ---
-------------

local function initRow5UI_(mainWindow)
    local row5PosY = CAUIGumpStatsDisplayConfig.PosYStart + 4*CAUIGumpStatsDisplayStaticConfig.RowIncrementSizeY
    CAUIGSD.Row5.GatheringLabel = mainWindow:AddLabel(CAUIGumpStatsDisplayLayout.Row5.GatheringLabelPosX, row5PosY, '')
    CAUIGSD.Row5.PickaxesLabel = mainWindow:AddLabel(CAUIGumpStatsDisplayLayout.Row5.PickaxesLabelPosX, row5PosY, '')
    CAUIGSD.Row5.HatchetsLabel = mainWindow:AddLabel(CAUIGumpStatsDisplayLayout.Row5.HatchetsLabelPosX, row5PosY, '')
    CAUIGSD.Row5.SkinningKnifesLabel = mainWindow:AddLabel(CAUIGumpStatsDisplayLayout.Row5.SkinningKnifesLabelPosX, row5PosY, '')
end

local function updateGatheringLabel_()
    CAUIGSD.Row5.GatheringLabel:SetText('(GATH)')
    cauiglogicb.setLabelColor(CAUIGSD.Row5.GatheringLabel, cauiglogicb.getColorOptions().Blue)
end

local function updatePickaxesLabel_()
    local numPickaxeCharges = iug.getTotalAmountOfPickaxeCharges()
    CAUIGSD.Row5.PickaxesLabel:SetText('PA: '..numPickaxeCharges)
    cauiglogicb.setLabelColor(CAUIGSD.Row5.PickaxesLabel, getGatheringPercentageAmountColor_(numPickaxeCharges))
end

local function updateHatchetsLabel_()
    local numHatchetCharges = iug.getTotalAmountOfHatchetCharges()
    CAUIGSD.Row5.HatchetsLabel:SetText('HA: '..numHatchetCharges)
    cauiglogicb.setLabelColor(CAUIGSD.Row5.HatchetsLabel, getGatheringPercentageAmountColor_(numHatchetCharges))
end

local function updateSkinningKnifesLabel_()
    local numSkinnCharges = iug.getTotalAmountOfSkinningKnifeCharges()
    CAUIGSD.Row5.SkinningKnifesLabel:SetText('SK: '..numSkinnCharges)
    cauiglogicb.setLabelColor(CAUIGSD.Row5.SkinningKnifesLabel, getGatheringPercentageAmountColor_(numSkinnCharges))
end

local function updateRow5UI_()
    updateGatheringLabel_()
    updatePickaxesLabel_()
    updateHatchetsLabel_()
    updateSkinningKnifesLabel_()
end

-------------
--- Row 6 ---
-------------

local function initRow6UI_(mainWindow)
    local row6PosY = CAUIGumpStatsDisplayConfig.PosYStart + 5*CAUIGumpStatsDisplayStaticConfig.RowIncrementSizeY
    CAUIGSD.Row6.HandsLabel = mainWindow:AddLabel(CAUIGumpStatsDisplayLayout.Row6.HandsLabelPosX, row6PosY, '')
    CAUIGSD.Row6.WeaponDurabilityLabel = mainWindow:AddLabel(CAUIGumpStatsDisplayLayout.Row6.WeaponDurabilityLabelPosX, row6PosY, '')
    CAUIGSD.Row6.ShieldDurabilityLabel = mainWindow:AddLabel(CAUIGumpStatsDisplayLayout.Row6.ShieldLabelPosX, row6PosY, '')
end

local function updateHandsLabel_()
    CAUIGSD.Row6.HandsLabel:SetText('(WEAP)')
    cauiglogicb.setLabelColor(CAUIGSD.Row6.HandsLabel, cauiglogicb.getColorOptions().Blue)
end

local function updateWeaponDurabilityLabel_()
    local weaponDurabilityPercentage = iuw.getEquipedWeaponDurabilityPercentage()
    if not weaponDurabilityPercentage then
        CAUIGSD.Row6.WeaponDurabilityLabel:SetText('WP:  '..noItemString)
        cauiglogicb.setLabelColor(CAUIGSD.Row6.WeaponDurabilityLabel, cauiglogicb.getColorOptions().LightRed)
    else
        local displayPercentage = math.floor(weaponDurabilityPercentage)
        CAUIGSD.Row6.WeaponDurabilityLabel:SetText('WP:  '..displayPercentage..'%%')
        cauiglogicb.setLabelColor(CAUIGSD.Row6.WeaponDurabilityLabel, getPercentageAmountColor_(displayPercentage))
    end
end

local function updateShieldDurabilityLabel_()
    local shieldDurabilityPercentage = iuw.getEquipedShieldDurabilityPercentage()
    if not shieldDurabilityPercentage then
        CAUIGSD.Row6.ShieldDurabilityLabel:SetText('SH: '..noItemString)
        cauiglogicb.setLabelColor(CAUIGSD.Row6.ShieldDurabilityLabel, cauiglogicb.getColorOptions().LightRed)
    else
        local displayPercentage = math.floor(shieldDurabilityPercentage)
        CAUIGSD.Row6.ShieldDurabilityLabel:SetText('SH: '..displayPercentage..'%%')
        cauiglogicb.setLabelColor(CAUIGSD.Row6.ShieldDurabilityLabel, getPercentageAmountColor_(displayPercentage))
    end
end

local function updateRow6UI_()
    updateHandsLabel_()
    updateWeaponDurabilityLabel_()
    updateShieldDurabilityLabel_()
end

-------------
--- Row 7 ---
-------------

local function initRow7UI_(mainWindow)
    local row7PosY = CAUIGumpStatsDisplayConfig.PosYStart + 6*CAUIGumpStatsDisplayStaticConfig.RowIncrementSizeY
    CAUIGSD.Row7.ArmourLabel = mainWindow:AddLabel(CAUIGumpStatsDisplayLayout.Row7.ArmourLabelPosX, row7PosY, '')
    CAUIGSD.Row7.ArmourAverageDurabilityLabel = mainWindow:AddLabel(CAUIGumpStatsDisplayLayout.Row7.ArmourAverageDurabilityLabelPosX, row7PosY, '')
    CAUIGSD.Row7.ArmourWorstPieceDurabilityLabel = mainWindow:AddLabel(CAUIGumpStatsDisplayLayout.Row7.ArmourWorstPieceDurabilityLabelPosX, row7PosY, '')
end

local function updateArmourLabel_()
    CAUIGSD.Row7.ArmourLabel:SetText('(ARMO)')
    cauiglogicb.setLabelColor(CAUIGSD.Row7.ArmourLabel, cauiglogicb.getColorOptions().Blue)
end

local function updateArmourAverageDurabilityLabel_()
    local armourAverageDurabilityPercentage = iua.getEquipedArmourAverageDurabilityPercentage()
    if not armourAverageDurabilityPercentage then
        CAUIGSD.Row7.ArmourAverageDurabilityLabel:SetText('All: '..noItemString)
        cauiglogicb.setLabelColor(CAUIGSD.Row7.ArmourAverageDurabilityLabel, cauiglogicb.getColorOptions().LightRed)
    else
        CAUIGSD.Row7.ArmourAverageDurabilityLabel:SetText('All: '..armourAverageDurabilityPercentage..'%%')
        cauiglogicb.setLabelColor(CAUIGSD.Row7.ArmourAverageDurabilityLabel, getPercentageAmountColor_(armourAverageDurabilityPercentage))
    end
end

local function updateArmourWorstPieceDurabilityLabel_()
    local worstArmourDurabilityPercentage = iua.getEquipedArmourWorstDurabilityPercentageItem()
    if not worstArmourDurabilityPercentage then
        CAUIGSD.Row7.ArmourWorstPieceDurabilityLabel:SetText('Worst: '..noItemString)
        cauiglogicb.setLabelColor(CAUIGSD.Row7.ArmourWorstPieceDurabilityLabel, cauiglogicb.getColorOptions().LightRed)
    else
        CAUIGSD.Row7.ArmourWorstPieceDurabilityLabel:SetText('Worst: '..worstArmourDurabilityPercentage..'%%')
        cauiglogicb.setLabelColor(CAUIGSD.Row7.ArmourWorstPieceDurabilityLabel, getPercentageAmountColor_(worstArmourDurabilityPercentage))
    end
end

local function updateRow7UI_()
    updateArmourLabel_()
    updateArmourAverageDurabilityLabel_()
    updateArmourWorstPieceDurabilityLabel_()
end

---------------------------
--- UI inint and update ---
---------------------------

local function updateUI_()
    updateRow1UI_()
    updateRow2UI_()
    updateRow3UI_()
    updateRow4UI_()
    updateRow5UI_()
    updateRow6UI_()
    updateRow7UI_()
end

local function processUIInteractions_()

    local currentTickTime = cat.getCurrentTickTime()
    local exceedsDuration = cat.exceedsDuration(CAUIGumpStatsDisplayState.LastRefreshTime, currentTickTime, CAUIGumpStatsDisplayStaticConfig.RefreshRate)
    if not exceedsDuration then
        return
    end
    CAUIGumpStatsDisplayState.LastRefreshTime = currentTickTime
    cal.debug('Refreshing Stats Display...')

    updateUI_()
end

local function updateCAConfigToCurrentUIConfig_(CAConfig)
    --- nothing to do
end

local function initUI_(mainWindow, CAConfig)

    cal.debug('Creating Stats Display UI...')
    initRow1UI_(mainWindow)
    initRow2UI_(mainWindow)
    initRow3UI_(mainWindow)
    initRow4UI_(mainWindow)
    initRow5UI_(mainWindow)
    initRow6UI_(mainWindow)
    initRow7UI_(mainWindow)
    
    cal.debug('Doing initialUpdate for Stats Display UI...')
    updateUI_()
end

--------------
--- Export ---
--------------

local Obj = {
    setPosYStart = setPosYStart_,
    getTotalSizeY = getTotalSizeY_,
    updateCAConfigToCurrentUIConfig = updateCAConfigToCurrentUIConfig_,
    processUIInteractions = processUIInteractions_,
    initUI = initUI_
}

return Obj