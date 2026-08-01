----------------------------------------------------------------------
--- IP (Item Properties) Material Predicates
--- Author: JohnB9
---
--- Description: Predicates for deciding material types of items
----------------------------------------------------------------------

local bl = Import('BaseLib')
local ipl = Import('IPLib')

-----------------
--- Variables ---
-----------------

local MaterialTypes = {
    Iron = 1,
    Shadow = 2,
    Copper = 3,
    Bronze = 4,
    Verite = 5,
    Valorite = 6
}

local MaterialTypesStrings = {
    "Iron",
    "Shadow",
    "Copper",
    "Bronze",
    "Verite",
    "Valorite"
}

-----------------
--- Accessors ---
-----------------

local function getMaterialTypes_()
    return MaterialTypes
end

-----------------
--- Functions ---
-----------------

local function itemIsOfMaterialType_(item, materialType)
    local itemMaterial = ipl.getMaterial(item)
    bl.printIfDebug(true, itemMaterial)
    if itemMaterial == MaterialTypesStrings[materialType] then
        return true
    end
    return false
end

local function itemIsOfIron_(item)
    return itemIsOfMaterialType_(item, MaterialTypes.Iron)
end

local function itemIsOfShadow_(item)
    return itemIsOfMaterialType_(item, MaterialTypes.Shadow)
end

local function itemIsOfCopper_(item)
    return itemIsOfMaterialType_(item, MaterialTypes.Copper)
end

local function itemIsOfBronze_(item)
    return itemIsOfMaterialType_(item, MaterialTypes.Bronze)
end

local function itemIsOfVerite_(item)
    return itemIsOfMaterialType_(item, MaterialTypes.Verite)
end

local function itemIsOfValorite_(item)
    return itemIsOfMaterialType_(item, MaterialTypes.Valorite)
end

AcceptPredicate = {
    itemIsOfIron_,
    itemIsOfShadow_,
    itemIsOfCopper_,
    itemIsOfBronze_,
    itemIsOfVerite_,
    itemIsOfValorite_
}

local function getAcceptPredicateForMaterialType_(materialType)
    return AcceptPredicate[materialType]
end

--------------
--- Export ---
--------------

local Obj = {
    getMaterialTypes = getMaterialTypes_,
    itemIsOfMaterialType = itemIsOfMaterialType_,
    itemIsOfIron = itemIsOfIron_,
    itemIsOfShadow = itemIsOfShadow_,
    itemIsOfCopper = itemIsOfCopper_,
    itemIsOfBronze = itemIsOfBronze_,
    itemIsOfVerite = itemIsOfVerite_,
    itemIsOfValorite = itemIsOfValorite_,
    getAcceptPredicateForMaterialType = getAcceptPredicateForMaterialType_
}

return Obj