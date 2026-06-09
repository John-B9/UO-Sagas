----------------------------------------------------------------------
--- Combat Assistant (CA) User Interface (UI) Gump Commands
--- Author: JohnB9
---
--- Version: 1.0.0  - 
---
--- Description: UI for Commands module
----------------------------------------------------------------------

-----------------
--- Variables ---
-----------------

CAUIGumpCommandsConfig = {
    Enable = false --- 
}

local CAUIGumpCommandsStaticConfig = {
}

local CAUIGumpCommandsState = {
}

-----------------
--- Accessors ---
-----------------

local function setEnable_(val)
    CAUIGumpCommandsConfig.Enable = val
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