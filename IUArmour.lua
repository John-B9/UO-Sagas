----------------------------------------------------------------------
--- IU (Item Usage) Armour
--- Author: JohnB9
---
--- Description: Import this if you want to call its functions from
---              another script
--- 
---              Utility methods for armours:
---               - Wrapers for getting equiped armour properties
----------------------------------------------------------------------

local cal = Import('CALog')
local ipl = Import('IPLib')

-----------------
--- Variables ---
-----------------

local ArmourLayers = {
    4,  --- Pants
    6,  --- Helmet
    7,  --- Gloves
    10, --- Necklace
    13, --- Torso
    19  --- Arms
}

-----------------
--- Functions ---
-----------------

local function getDurabilityPercentageOfArmourAtLayer_(layer)
    local armourPiece = Items.FindByLayer(layer)
    if not armourPiece then
        return nil
    end
    local armourPieceDurabilityPercentage = ipl.getDurabilityPercentage(armourPiece)
    if not armourPieceDurabilityPercentage then
        return nil
    end
    return math.floor(armourPieceDurabilityPercentage)
end

local function getEquipedArmourAverageDurabilityPercentage_()
    local durabilityPercentageSum = 0
    local totalArmourItemsEquiped = 0
    for _, armourLayer in ipairs(ArmourLayers) do
        local armourDurabilityPercentage = getDurabilityPercentageOfArmourAtLayer_(armourLayer)
        if armourDurabilityPercentage then
            durabilityPercentageSum = durabilityPercentageSum + armourDurabilityPercentage
            totalArmourItemsEquiped = totalArmourItemsEquiped + 1
        end
    end
    if totalArmourItemsEquiped == 0 then
        return nil
    end
    return math.floor((durabilityPercentageSum/totalArmourItemsEquiped))
end

local function getEquipedArmourWorstDurabilityPercentageItem_()
    local worstDurabilityPercentageItem = nil
    for _, armourLayer in ipairs(ArmourLayers) do
        local armourDurabilityPercentage = getDurabilityPercentageOfArmourAtLayer_(armourLayer)
        if armourDurabilityPercentage ~= nil then
            if (not worstDurabilityPercentageItem) or worstDurabilityPercentageItem > armourDurabilityPercentage then
                worstDurabilityPercentageItem = armourDurabilityPercentage
            end
        end
    end
    if not worstDurabilityPercentageItem then
        return nil
    end
    return math.floor(worstDurabilityPercentageItem)
end

--------------
--- Export ---
--------------

local Obj = {
    getEquipedArmourAverageDurabilityPercentage = getEquipedArmourAverageDurabilityPercentage_,
    getEquipedArmourWorstDurabilityPercentageItem = getEquipedArmourWorstDurabilityPercentageItem_
}

return Obj