----------------------------------------------------------------------
--- CL (Crafting Leveling) Lib
--- Author: JohnB9
---
--- Mentions: Rum Runner (script base)
---           
---           I then addapted it for a more general purpose, so to
---           also level other crafting skills
---
--- Version: 1.0.0  - Abstraction for general purpose
---                 - Added PreWork and PostWork
--- 
--- Description: A generic loop to craft items of incresing dificulty
---              so to level up the a crafting skill
--- 
---              Accepts PreWork and PostWork calbacks to execute
---              before and after of every crafting of items
---
--- Caveats: Whatever list of items you provide for crafting, it is
---          best to have them in the correct page of the gump for
---          that item, as sript won't change pages on the right gump
---
----------------------------------------------------------------------

local il = Import('IPLib')
local bl = Import('BaseLib')

-----------------
--- Variables ---
-----------------

--- Define Color Scheme
local Colors = {
    ALERT = 33,
    WARNING = 48,
    CAUTION = 53,
    ACTION = 67,
    CONFIRM = 73,
    INFO = 84,
    STATUS = 93
}

-----------------
--- Functions ---
-----------------

local function getItemToCraft_(config)
    local skill = bl.getSkillValue(config.SKILL_TO_LEVEL)
    local itemToCraft = nil
    for _, item in ipairs(config.ITEMS) do
        if skill >= item.minSkill and skill <= item.maxSkill then
            itemToCraft = item
            break
        end
    end
    return itemToCraft
end

--- Start Message
local function printInitialStartUpGreeting_(config)
    Messages.Print("___________________________________", Colors.INFO)
    Messages.Print("Train Crating Assistant Script v0.2.0 ("..config.SKILL_TO_LEVEL..")", Colors.INFO)
    Messages.Print("___________________________________", Colors.INFO)
end

--- Main crafting function
local lastItem = nil
local function craftItem_(config)
    local tool = il.getItemWithLessUsesRemaining(config.TOOL_ID, nil)
    if not tool then
        Messages.Overhead("No "..config.SKILL_TO_LEVEL.." Tools!", Colors.ALERT, Player.Serial)
        return false
    end

    local itemToCraft = getItemToCraft_(config)
    if not itemToCraft then
        Messages.Overhead("No item matches current skill level!", Colors.ALERT, Player.Serial)
        return false
    end

    --- call pre-work function
    if config.PREWORK_FUNCTION ~= nil then
        local success = config.PREWORK_FUNCTION()
            if success == false then
                Messages.Overhead("Pre-Work failed for Crafting ("..config.SKILL_TO_LEVEL..")!...", Colors.ALERT, Player.Serial)
                return false
            end
        end

        Player.UseObject(tool.Serial)
        if not Gumps.WaitForGump(config.GUMP_ID, 1000) then
            Messages.Overhead("Failed to open Crafting ("..config.SKILL_TO_LEVEL..") menu!", Colors.ALERT, Player.Serial)
            return false
        end

        if lastItem ~= itemToCraft.name then
            Gumps.PressButton(config.GUMP_ID, itemToCraft.category)
            Pause(600)
            Gumps.PressButton(config.GUMP_ID, itemToCraft.craft)
            Pause(600)
            Gumps.PressButton(config.GUMP_ID, itemToCraft.final)
            lastItem = itemToCraft.name
        else
            Pause(500)
            Gumps.PressButton(config.GUMP_ID, config.MAKE_LAST_BUTTON_ID)
        end

        Messages.Overhead("Crafting: " .. itemToCraft.name, Colors.ACTION, Player.Serial)
        Pause(3000)


        --- call post-work function
        if config.POSTWORK_FUNCTION ~= nil then
            local success = config.POSTWORK_FUNCTION(config)
                if success == false then
                    Messages.Overhead("Post-Work failed for Crafting ("..config.SKILL_TO_LEVEL..")!...", Colors.ALERT, Player.Serial)
                    return false
                end
            end

            return true
        end

        --- Crafting Loop
        local function craftingLoop_(config)
            printInitialStartUpGreeting_(config)
            while true do
                local crafted = craftItem_(config)
                if not crafted then
                    break
                end
            end
        end

        --------------
        --- Export ---
        --------------

        local Obj = {
            getItemToCraft = getItemToCraft_,
            craftingLoop = craftingLoop_
        }

        return Obj