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

local function itemIsOfIron_(item)
    local itemMaterial = ipl.getMaterial(item)
    bl.printIfDebug(true, itemMaterial)
    if itemMaterial == "Iron" then
        return true
    end
    return false
end

local function itemIsOfShadow_(item)
    local itemMaterial = ipl.getMaterial(item)
    bl.printIfDebug(true, itemMaterial)
    if itemMaterial == "Shadow" then
        return true
    end
    return false
end

local function itemIsOfCopper_(item)
    local itemMaterial = ipl.getMaterial(item)
    bl.printIfDebug(true, itemMaterial)
    if itemMaterial == "Copper" then
        return true
    end
    return false
end

local function itemIsOfBronze_(item)
    local itemMaterial = ipl.getMaterial(item)
    bl.printIfDebug(true, itemMaterial)
    if itemMaterial == "Bronze" then
        return true
    end
    return false
end

local function itemIsOfVerite_(item)
    local itemMaterial = ipl.getMaterial(item)
    bl.printIfDebug(true, itemMaterial)
    if itemMaterial == "Verite" then
        return true
    end
    return false
end

local function itemIsOfValorite_(item)
    local itemMaterial = ipl.getMaterial(item)
    bl.printIfDebug(true, itemMaterial)
    if itemMaterial == "Valorite" then
        return true
    end
    return false
end

--------------
--- Export ---
--------------

local Obj = {
    itemIsOfIron = itemIsOfIron_,
    itemIsOfShadow = itemIsOfShadow_,
    itemIsOfCopper = itemIsOfCopper_,
    itemIsOfBronze = itemIsOfBronze_,
    itemIsOfVerite = itemIsOfVerite_,
    itemIsOfValorite = itemIsOfValorite_
}

return Obj