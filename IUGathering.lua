----------------------------------------------------------------------
--- IU (Item Usage) Gathering
--- Author: JohnB9
---
--- Description: Import this if you want to call its functions from
---              another script
--- 
---              Utility methods for gathering items:
---               - Wrapers for getting gathering items properties
----------------------------------------------------------------------

local bl = Import('BaseLib')
local ipl = Import('IPLib')

-----------------
--- Variables ---
-----------------

local pickaxe_type_id = 3718
local hatchet_type_id = 3907
local skinning_knife_type_id = 65193

-----------------
--- Functions ---
-----------------

local function getTotalAmountOfUsesRemainingFromItemInInventory_(itemGraphicID)
    local totalCount = 0
    local items = bl.findInInventory(itemGraphicID)
    if not items or #items == 0 then
        return 0
    end
    for _, item in ipairs(items) do
        local usesRemaining = ipl.getUsesRemaining(item)
        totalCount = totalCount + usesRemaining
    end
    return totalCount
end

local function getTotalAmountOfPickaxeCharges_()
    return getTotalAmountOfUsesRemainingFromItemInInventory_(pickaxe_type_id)
end

local function getTotalAmountOfHatchetCharges_()
    return getTotalAmountOfUsesRemainingFromItemInInventory_(hatchet_type_id)
end

local function getTotalAmountOfSkinningKnifeCharges_()
    return getTotalAmountOfUsesRemainingFromItemInInventory_(skinning_knife_type_id)
end

--------------
--- Export ---
--------------

local Obj = {
    getTotalAmountOfUsesRemainingFromItemInInventory = getTotalAmountOfUsesRemainingFromItemInInventory_,
    getTotalAmountOfPickaxeCharges = getTotalAmountOfPickaxeCharges_,
    getTotalAmountOfHatchetCharges = getTotalAmountOfHatchetCharges_,
    getTotalAmountOfSkinningKnifeCharges = getTotalAmountOfSkinningKnifeCharges_
}
return Obj