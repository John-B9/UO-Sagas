----------------------------------------------------------------------
--- Combat Assistant (CA) Main Loop
--- Author: JohnB9
---
--- Mentions: Halesluker  - Base script
---           
--- Version: 1.0.0  - Module separation of Base script
---                 - Added user triggered commands
---
--- Description: Launch a Combat Bot for a given configuration
----------------------------------------------------------------------

local cal = Import('CALog')
local cat = Import('CATime')
local caad = Import('CAArmDisarm')
local cae = Import('CAEscape')
local caph = Import('CAPotionsHealing')
local capc = Import('CAPotionsCure')
local caban = Import('CABandage')
local cabuf = Import('CABuffs')
local cadbuf = Import('CADebuffs')
local cadp = Import('CADetectPlayers')
local cas = Import('CAScavenge')
local cautc = Import('CAUserTriggeredCommands')

-----------------
--- Variables ---
-----------------

local MainLoopConfig = {
    EnableCancel = false
}

local MainLoopState = {
    lastJournalTickTime = 0
}

local CancelConfig = {
    Command = "I Yeld!", -- The command to say, make it unique to you
}

---------------------------
--- Configure Functions ---
---------------------------

local function configureModules_(config)
    caad.setConfig(config.modules.ArmDisarm)
    cae.setConfig(config.modules.Escape)
    capc.setConfig(config.modules.CurePotions)
    caph.setConfig(config.modules.HealingPotions)
    caban.setConfig(config.modules.Bandages)
    cabuf.setConfig(config.modules.Buffs)
    cadbuf.setConfig(config.modules.Debuffs)
    cadp.setConfig(config.modules.DetectPlayers)
    cas.setConfig(config.modules.Scavenging)
end

local function configure_(config)
    MainLoopConfig.EnableCancel = config.EnableCancel
    cat.setActionWaitTime(config.time.ActionWaitTime)
    cal.setConfig(config.debug)
    configureModules_(config)
    cautc.setConfig(config.userCommands)
end

-----------------
--- Functions ---
-----------------

local function cancel_()

    return Journal.Contains(CancelConfig.Command)
end

local function journalDependantActions_()
    caad.disarmPlayerIfWeaponDurabilityIsLow()
    cae.popPouch()
    cae.escape()
    capc.cure(false)
    caph.health(false)
    caban.bandage()
    cabuf.buffs()
    cadbuf.debuffs()
    caad.rearmPlayer()
    cadp.detectPlayers()
end

local function journalIndependantActions_()
    caad.disarmed()
    cas.scavenge()
    cae.moongate()
end

local function mainLoop_(config)

    --- Configure and Greet
    configure_(config)
    cal.mainInfo("Sagas Combat Assistant")
    cal.debug("Sagas Combat Assistant - Started")

    --- Start with a clean journal
    Journal.Clear()

    while true do
    
        local newTickTime = cat.updateCurrentTickTime()
        cal.debug("Main tick loop start")

        if Player.IsDead then
            cal.debug("Player is dead, skipping main loop.")
            goto mainloopend
        end

        --- Journal dependent functions
        cal.debug("Before journal tick.")
        if cat.exceedsDuration(MainLoopState.lastJournalTickTime, newTickTime, config.time.JournalTick) then

            cal.debug("Journal tick time exceeded, processing journal...")

            --- Journal dependent functions
            journalDependantActions_()

            MainLoopState.lastJournalTickTime = newTickTime
        end

        --- Journal independent functions
        journalIndependantActions_()

        --- Handle user commands (right before Journal Clear)
        cautc.processUserCommands()

        cal.debug("Main tick loop end")
        :: mainloopend ::
        Journal.Clear()
        Pause(config.time.MainLoopTick)
    end
end

--------------
--- Export ---
--------------

local Obj = {
    mainLoop = mainLoop_
}

return Obj