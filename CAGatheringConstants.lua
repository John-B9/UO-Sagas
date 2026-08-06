----------------------------------------------------------------------
--- Combat Assistant (CA) Gathering Constants
--- Author: JohnB9
---
--- Version: 1.0.0  - Base Implementation
---
--- Description: Gathering constants functions
----------------------------------------------------------------------

-----------------
--- Constants ---
-----------------

local HuesToKeepValues = {
    None = 1,
    All = 2,
    ShadowPlus = 3,
    CopperPlus = 4,
    BronzePlus = 5,
    VeritePlus = 6,
    Valorite = 7
}

local HuesToKeepTableNone = {
}

local HuesToKeepTableAll = {
    0x0000,             --- Regular
    0x0966,             --- Shadow
    0x096D,             --- Copper
    0x0972,             --- Bronze
    0x089F,             --- Verite
    0x08AB              --- Valorite
}

local HuesToKeepTableShadowPlus = {
    0x0966,             --- Shadow
    0x096D,             --- Copper
    0x0972,             --- Bronze
    0x089F,             --- Verite
    0x08AB              --- Valorite
}

local HuesToKeepTableCopperPlus = {
    0x096D,             --- Copper
    0x0972,             --- Bronze
    0x089F,             --- Verite
    0x08AB              --- Valorite
}

local HuesToKeepTableBronzePlus = {
    0x0972,             --- Bronze
    0x089F,             --- Verite
    0x08AB              --- Valorite
}

local HuesToKeepTableVeritePlus = {
    0x089F,             --- Verite
    0x08AB              --- Valorite
}

local HuesToKeepTableValorite = {
    0x08AB              --- Valorite
}

local HuesToKeepTables = {
    HuesToKeepTableNone,
    HuesToKeepTableAll,
    HuesToKeepTableShadowPlus,
    HuesToKeepTableCopperPlus,
    HuesToKeepTableBronzePlus,
    HuesToKeepTableVeritePlus,
    HuesToKeepTableValorite
}

-----------------
--- Functions ---
-----------------

local function getHuesToKeepValues_()
    return HuesToKeepValues
end

local function getHuesToKeepLootTable_(gatheringMode)
    return HuesToKeepTables[gatheringMode]
end

--------------
--- Export ---
--------------

local Obj = {
    getHuesToKeepValues = getHuesToKeepValues_,
    getHuesToKeepLootTable = getHuesToKeepLootTable_,
}

return Obj