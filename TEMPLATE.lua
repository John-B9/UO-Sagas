----------------------------------------------------------------------
--- Combat Assistant (CA) MODULE_NAME
--- Author: JohnB9
---
--- Mentions: 
---
--- Version: 1.0.0  - 
---
--- Description: DESCRIPTION functions
----------------------------------------------------------------------

-----------------
--- Variables ---
-----------------

MODULE_NAMEConfig = {
    Enable = false --- 
}

local MODULE_NAMEStaticConfig = {
}

local MODULE_NAMEState = {
}

-----------------
--- Accessors ---
-----------------

local function setEnable_(val)
    MODULE_NAMEConfig.Enable = val
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