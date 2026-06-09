----------------------------------------------------------------------
--- Combat Assistant (CA) User Interface (UI) Gump Scavenge
--- Author: JohnB9
---
--- Version: 1.0.0  - 
---
--- Description: UI for Scavenge module
----------------------------------------------------------------------

-----------------
--- Variables ---
-----------------

CAUIGumpScavengeConfig = {
    Enable = false --- 
}

local CAUIGumpScavengeStaticConfig = {
}

local CAUIGumpScavengeState = {
}

-----------------
--- Accessors ---
-----------------

local function setEnable_(val)
    CAUIGumpScavengeConfig.Enable = val
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