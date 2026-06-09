----------------------------------------------------------------------
--- Combat Assistant (CA) User Interface (UI) Gump Heal
--- Author: JohnB9
---
--- Version: 1.0.0  - 
---
--- Description: UI for Heal module
----------------------------------------------------------------------

-----------------
--- Variables ---
-----------------

CAUIGumpHealConfig = {
    Enable = false --- 
}

local CAUIGumpHealStaticConfig = {
}

local CAUIGumpHealState = {
}

-----------------
--- Accessors ---
-----------------

local function setEnable_(val)
    CAUIGumpHealConfig.Enable = val
end

local function setConfig_(config)
    setEnable_(config.Enable)
end

-----------------
--- Functions ---
-----------------

--------------
--- Export ---
--------------

local Obj = {
    setEnable = setEnable_,
    setConfig = setConfig_
}

return Obj