----------------------------------------------------------------------
--- Combat Assistant (CA) User Triggered Commands
--- Author: JohnB9
---
--- Version: 1.0.0  - Base implementation + base commands
---
--- Description: Interface to add user triggered commands to the
---              combat bot main loop via inspecting the journal:
--- 
---               - Your character can "Say" keywords
---               - This triggers commands in the combat bot
--- 
---              The idea is to interact with the combat bot (and
---              keep it continuously running), and this is only
---              possible by writing to the journal
--- 
---              Also, this will only be worth it if we can hotkey
---              these commands, and so the only option for that is
---              to use macros (papperdoll -> options -> macros) to
---              Say the keyword for the command with our character
---              (a script won't work because the combat bot is
---              already running!)
--- 
---              This raises the following security problem:
---              
---               - Everything anyone says in your vicinity is added
---                 to your journal, so other players will also be
---                 able to say themselves the keywords here defined,
---                 and trigger actions on our combat bot...
--- 
---              For this reason:
--- 
---               - A CommandStringPrefix must be provided in the
---                 config, to help make commands only work for you
--- 
---               - It can be important to set up a configuration to 
---                 launch the combat bot with commands disabled,
---                 so that a hostile won't be able to mess with
---                 your running script (stop the CB with commands
---                 enabled, and launch the one with commands disabled)
---
----------------------------------------------------------------------

local cal = Import('CALog')
local cat = Import('CATime')
local ipmp = Import('IPMaterialPredicates')
local iums = Import('IUMinerSwap')
local iuls = Import('IULumberjackSwap')
local iuski = Import('IUSkinn')
local iusci = Import('IUScissors')
local iuidw = Import('IUIDWand')

-----------------
--- Variables ---
-----------------

UserTriggeredCommandsConfig = {
    Enable = false, --- 
    CommandStringPrefix = "" --- 
    --Password = "" --- For security: so others can't interract with your combat bot!
                  --- Set and never share it
}

local UserTriggeredCommandsStaticConfig = {
    ---CommandDoneString = "Command Finished"
}

local UserTriggeredCommandsState = {
}

-----------------
--- Accessors ---
-----------------

local function setEnable_(val)
    UserTriggeredCommandsConfig.Enable = val
end

local function setCommandStringPrefix_(val)
    UserTriggeredCommandsConfig.CommandStringPrefix = val
end

local function setConfig_(config)
    setEnable_(config.Enable)
    setCommandStringPrefix_(config.CommandStringPrefix)
end

----------------
--- Commands ---
----------------

local function minerSwapIron_()
    iums.minerSwap(ipmp.itemIsOfIron, nil)
end

local function minerSwapCopper_()
    iums.minerSwap(ipmp.itemIsOfCopper, nil)
end

local function lumberjackSwapIron_()
    iuls.lumberjackSwap(ipmp.itemIsOfIron, nil)
end

local function lumberjackSwapCopper_()
    iuls.lumberjackSwap(ipmp.itemIsOfCopper, nil)
end

local function useSkinningKnife_()
    iuski.useSkinningKnife(nil)
end

local function useScissors_()
    iusci.useScissors(nil)
end

local function useIdWand_()
    iuidw.useIdWand(nil)
end

local Commands = {
    { Keyword = "Miner Swap Iron", Callback = minerSwapIron_ },
    { Keyword = "Miner Swap Copper", Callback = minerSwapCopper_ },
    { Keyword = "Lumberjack Swap Iron", Callback = lumberjackSwapIron_ },
    { Keyword = "Lumberjack Swap Copper", Callback = lumberjackSwapCopper_ },
    { Keyword = "Skinn", Callback = useSkinningKnife_ },
    { Keyword = "Scissors", Callback = useScissors_ },
    { Keyword = "ID Wand", Callback = useIdWand_ }
}

-----------------
--- Functions ---
-----------------

local function journalContainsCommand_(keyword)
    local searchString = UserTriggeredCommandsConfig.CommandStringPrefix.." "..keyword
    cal.debug("Searching for user triggered command: "..searchString)
    return Journal.Contains(searchString)
end

local function processUserCommands_()

    if not UserTriggeredCommandsConfig.Enable then
        return
    end

    cal.debug("Processing player triggered commands:")
    for _, command in ipairs(Commands) do
        if journalContainsCommand_(command.Keyword) then
            cal.debug("Executing command: "..command.Keyword)
            command.Callback()
            Pause(cat.getActionWaitTime())
        end
    end

end

---------------
--- Exports ---
---------------

local Obj = {
    setEnable = setEnable_,
    setConfig = setConfig_,
    processUserCommands = processUserCommands_
}

return Obj