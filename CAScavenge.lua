----------------------------------------------------------------------
--- Combat Assistant (CA) Scavenge
--- Author: JohnB9
---
--- Mentions: Halesluker  - Base script
---
--- Version: 1.0.0  - Module separation of Base script
---
--- Description: Scavenge functions
----------------------------------------------------------------------

local cal = Import('CALog')
local cat = Import('CATime')

-----------------
--- Variables ---
-----------------

ScavengeConfig = {
    Enable = false,
    Frequency = 0, -- milliseconds, zero means immediate
    Items = {
        0x0F3F,
        0x1BFB
    }
}

local ScavengeState = {
    lastTickTime = 0
}

---------------
--- Setters ---
---------------

local function setEnable_(val)
    ScavengeConfig.Enable = val
end

local function setFrequency_(val)
    ScavengeConfig.Frequency = val
end

local function setItems_(val)
    ScavengeConfig.Items = val
end

local function setConfig_(config)
    setEnable_(config.Enable)
    setFrequency_(config.Frequency)
    setItems_(config.Items)
end

-----------------
--- Functions ---
-----------------

local function scavenge_()

    if not ScavengeConfig.Enable then
        return
    end
    
    local currentTickTime = cat.getCurrentTickTime()

    if not cat.exceedsDuration(ScavengeState.lastTickTime, currentTickTime, ScavengeConfig.Tick) then
        cal.debug("Scavenging is not ready yet, skipping this tick.")
        return
    end

    cal.debug("Trying to scavenge...")

    ScavengeState.lastTickTime = currentTickTime

    local filter = { onground = true, rangemax = 2, graphics = ScavengeConfig.items }
    local list = Items.FindByFilter(filter)

    for _, item in ipairs(list) do
        if not Player.PickUp(item.Serial, 1000) then
            cal.debug("Scavenging failed to pick up item: " .. (item.Name or "No Item Name"))
            goto continue
        end

        Pause(250)

        if not Player.DropInBackpack() then
            cal.debug("Scavenging failed to drop item in backpack: " .. (item.Name or "No Item Name"))
            goto continue
        end

        cal.debug("Scavenged item: " .. (item.Name or "No Item Name"))
        Pause(250)

        ::continue::
    end
end

--------------
--- Export ---
--------------
---
local Obj = {
    setEnable = setEnable_,
    setFrequency = setFrequency_,
    setItems = setItems_,
    setConfig = setConfig_,
    scavenge = scavenge_
}

return Obj