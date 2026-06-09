----------------------------------------------------------------------
--- Combat Assistant (CA) User Interface (UI) Gump Attack
--- Author: JohnB9
---
--- Version: 1.0.0  - 
---
--- Description: UI for Attack module
----------------------------------------------------------------------

-----------------
--- Variables ---
-----------------

CAUIGumpAttackConfig = {
    Enable = false --- 
}

local CAUIGumpAttackStaticConfig = {
}

local CAUIGumpAttackState = {
}

-----------------
--- Accessors ---
-----------------

local function setEnable_(val)
    CAUIGumpAttackConfig.Enable = val
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