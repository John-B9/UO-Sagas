----------------------------------------------------------------------
-- CL (Crafting Leveling) Lib
-- Author: JohnB9
--
-- Mentions: Rum Runner (this lib was started from his script,
--                       as I was leveling a crafter;
--                       I then addapted it for a more general purpose,
--                       so to also level other crafting skills)
--
-- Description: A generic loop to craft items of incresing dificulty
--              so to level up the a crafting skill
--
--              The main funtion is craftingLoop(config)
--
--              To see how to call it, see one of the skill specific
--              scripts (like CLSmithing)
--
-- Caveats: Whatever list of items you provide for crafting, it is
--          best to have them in the 1st page of the gump, as the
--          script won't change pages
----------------------------------------------------------------------

local il = Import('IPLib')
local bl = Import('BaseLib')

-- Define Color Scheme
local Colors = {
    ALERT = 33,
    WARNING = 48,
    CAUTION = 53,
    ACTION = 67,
    CONFIRM = 73,
    INFO = 84,
    STATUS = 93
}

-- Start Message
local function printInitialStartUpGreeting_
(config)
    Messages.Print("___________________________________", Colors.INFO)
    Messages.Print("Train Crating Assistant Script v0.2.0 ("..config.SKILL_TO_LEVEL..")", Colors.INFO)
    Messages.Print("___________________________________", Colors.INFO)
end

-- Main crafting function
local lastItem = nil
local function craftItem_(config)
    local tool = il.getItemWithLessUsesRemaining(config.TOOL_ID)
    if not tool then
        Messages.Overhead("No "..config.SKILL_TO_LEVEL.." Tools!", Colors.ALERT, Player.Serial)
        return false
    end

    local skill = bl.getSkillValue(config.SKILL_TO_LEVEL)
    local itemToCraft = nil
    for _, item in ipairs(config.ITEMS) do
        if skill >= item.minSkill and skill <= item.maxSkill then
            itemToCraft = item
            break
        end
    end

    if not itemToCraft then
        Messages.Overhead("No item matches current skill level!", Colors.ALERT, Player.Serial)
        return false
    end
    
    -- call pre-work function
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
    return true
end

-- Crafting Loop
local function craftingLoop_(config)
    printInitialStartUpGreeting_(config)
    while true do
        local crafted = craftItem_(config)
            if not crafted then
                break
        end
    end
end

------------
-- Export --
------------

local Obj = {
    craftingLoop = craftingLoop_
}

return Obj