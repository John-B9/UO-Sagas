----------------------------------------------------------------------
--- Combat Assistant (CA) Scavenge
--- Author: JohnB9
---
--- Mentions: OmgArturo  - Base script
---
--- Version: 1.0.0  - Base Implementation
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
    },
    DisallowGold = false,
    DisallowBones = false,
    DisallowGrimoire = false
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

local graphicIdLootableSet = {}
local graphicIdToPriority = {}

local function setConfig_(config)
    setEnable_(config.Enable)
    setFrequency_(config.Frequency)
    setItems_(config.Items)
    ScavengeConfig.DisallowGold = config.DisallowGold
    ScavengeConfig.DisallowBones = config.DisallowBones
    ScavengeConfig.DisallowGrimoire = config.DisallowGrimoire

    graphicIdLootableSet = {}
    graphicIdToPriority = {}
    for i, graphic in ipairs(ScavengeConfig.Items) do
        
        if graphic == 0x0EED and ScavengeConfig.DisallowGold then
            goto continue
        end
        
        if graphic == 0x0F7E and ScavengeConfig.DisallowBones then
            goto continue
        end
        
        if graphic == 0x2D9D and ScavengeConfig.DisallowGrimoire then
            goto continue
        end

        graphicIdLootableSet[graphic] = true
        graphicIdToPriority[graphic] = i

        ::continue::
    end

end

-----------------
--- Functions ---
-----------------

local CORPSE_GRAPHIC = 0x2006
local ACTION_DELAY = 800
local corpseFilter = {
    graphics = {CORPSE_GRAPHIC},
    onground = true,
    rangemin = 0,
    rangemax = 2
}
local fatAlertReadyMs = 0

function tableContains_(tbl, val)
    for _, value in ipairs(tbl) do
        if value == val then
            return true
        end
    end
    return false
end

local processedCorpses = {}

function HasProcessedCorpse_(serial)
    return processedCorpses[serial] == true
end

function MarkCorpseProcessed_(serial)
    processedCorpses[serial] = true
end

function extractWeight_(item)
    -- Pattern explanation:
    -- .*- matches any character (including newlines due to how Lua handles this in patterns) zero or more times, as few as possible.
    -- (?:...) - this is a general regex concept, but not directly supported in standard Lua patterns.
    -- The approach below uses Lua's native patterns and capture groups.

    -- Attempt to match "Weight: " followed by 1-3 digits.
    -- 'Weight:%s*(%d%d?%d?)'
    -- %s* matches zero or more whitespace characters.
    -- (%d%d?%d?) captures 1, 2, or 3 digits.
    local weight_str = string.match(item.Properties, "Weight:%s*(%d%d?%d?) Stone")

    if weight_str then
        return tonumber(weight_str) -- Convert the captured string to a number
    else
        -- If the "Weight: " pattern isn't found, you might want to return nil or a default value
        -- depending on your specific needs when it's missing entirely.
        -- In this case, it returns nil, so you can handle it.
        return nil
    end
end

function WordCheckMultiple_(str1, keywordString)
    local lowerStr = string.lower(str1)
    for word in string.gmatch(keywordString, "%S+") do
        local lowerWord = string.lower(word)
        if not string.find(lowerStr, lowerWord, 1, true) then
            return false
        end
    end
    return true
end

function GetSortedItemList_()
    local seriableIdLootPriorityList = {}
    local itemList = Items.FindByFilter({onground=false})
    for index, item in ipairs(itemList) do
        if item.RootContainer == Player.Serial then
            goto continue
        end

        if item.RootContainer == Player.Backpack.Serial then
            goto continue
        end

        --        if item.RootContainer == lootbag.Serial then
        --            goto continue
        --        end

        local container = Items.FindBySerial(item.Container)

        if container == nil or container.Name == nil or string.find(container.Name:lower(), "corpse") == nil or container.Distance > 2 then
            goto continue
        end

        if item.Distance == nil or (item.Distance > 2 and item.Distance < 16) then
            goto continue
        end

        if not graphicIdLootableSet[item.Graphic] then
            goto continue
        end

        if item.IsLootable == false then
            goto continue
        end

        if item.Name == nil then
            goto continue
        end

        if item.Properties == nil then
            goto continue
        end

        local isLockedDown = WordCheckMultiple_(item.Properties, "Locked Down")
        if isLockedDown == true then
            goto continue
        end

        local weight = extractWeight_(item)
        if weight ~= nil and weight + Player.Weight > Player.MaxWeight then
            --if not Cooldown("FatAlert") then
            if os.time() * 1000 > fatAlertReadyMs then
                --Messages.Overhead("too fat, big heavy .. no pick up " .. item.Name .. " (" .. tostring(weight) .. " stones)", 47, Player.Serial)
                Messages.OverheadMobile(Player.Serial, "too fat, big heavy .. no pick up " .. item.Name .. " (" .. tostring(weight) .. " stones)", 47)
                --Cooldown("FatAlert", 5000)
                fatAlertReadyMs = (os.time() * 1000) + 5000
            end
            goto continue
        end

        --Messages.Print("Found item " .. item.Name .. " in root container " .. item.RootContainer)

        table.insert(seriableIdLootPriorityList, item)
        ::continue::
    end

    table.sort(seriableIdLootPriorityList, function(a, b)
        local priorityA = graphicIdToPriority[a.Graphic] or math.huge
        local priorityB = graphicIdToPriority[b.Graphic] or math.huge
        if priorityA == priorityB then
            return (a.Name or "") < (b.Name or "")
        end
        return priorityA < priorityB
    end)

    return seriableIdLootPriorityList
end

function AutoLoot_()
    local sortedItemList = GetSortedItemList_()
    if #sortedItemList > 0 then
        for _, item in ipairs(sortedItemList) do
            Player.PickUp(sortedItemList[1].Serial, sortedItemList[1].Amount)
            Player.DropInBackpack()
            Pause(ACTION_DELAY)
        end
    end
end

local function scavenge_()

    if not ScavengeConfig.Enable then
        return
    end
    
    local currentTickTime = cat.getCurrentTickTime()

    if not cat.exceedsDuration(ScavengeState.lastTickTime, currentTickTime, ScavengeConfig.Tick) then
        cal.debug("Scavenging is not ready yet, skipping this tick.")
        return
    end
    ScavengeState.lastTickTime = currentTickTime

    cal.debug("Scavenging...")
    processedCorpses = {}
    local corpses = Items.FindByFilter(corpseFilter)
    for _, corpse in ipairs(corpses) do
        if not HasProcessedCorpse_(corpse.Serial) then
            --- Auto Loot
            AutoLoot_()
    
            --- Mark corpse processed so it never repeats
            MarkCorpseProcessed_(corpse.Serial)
        end
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