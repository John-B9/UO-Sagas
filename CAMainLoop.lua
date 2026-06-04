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
local caa = Import('CAAttack')

-----------------
--- Variables ---
-----------------

local MainLoopState = {
    lastJournalTickTime = 0
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
    caa.setConfig(config.modules.Attack)
end

local function configure_(config)
    cat.setActionWaitTime(config.time.ActionWaitTime)
    cal.setConfig(config.debug)
    configureModules_(config)
    cautc.setConfig(config.userCommands)
end

-----------------
--- Functions ---
-----------------

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
    caa.attack()
    cas.scavenge()
    cae.moongate()
end

local function mainLoopInit_(config)

    --- Configure and Greet
    configure_(config)
    cal.mainInfo("Sagas Combat Assistant")
    cal.debug("Sagas Combat Assistant - Started")

    --- Start with a clean journal
    Journal.Clear()
end

local function mainLoopIterate_(config)

    local newTickTime = cat.updateCurrentTickTime()
    cal.debug("Main tick loop start")

    if Player.IsDead then
        cal.debug("Player is dead, skipping main loop.")
        goto main_loop_iteration_end
    end

    cal.debug("Before journal tick.")
    if cat.exceedsDuration(MainLoopState.lastJournalTickTime, newTickTime, config.time.JournalTick) then
        cal.debug("Journal tick time exceeded, processing journal...")
        journalDependantActions_()                                          --- Journal dependent functions
        MainLoopState.lastJournalTickTime = newTickTime
    end

    journalIndependantActions_()        --- Journal independent functions
    cautc.processUserCommands()         --- Handle user commands (right before Journal Clear)
    cal.debug("Main tick loop end")

    :: main_loop_iteration_end ::
    Journal.Clear()                     --- Clear Journal
    Pause(config.time.MainLoopTick)     --- Wait before next iteration
end

local function mainLoop_(config)
    mainLoopInit_(config)                   --- Init main loop
    while true do
        mainLoopIterate_(config)            --- Iterate main loop
    end
end

--------------
--- Export ---
--------------

local Obj = {
    configure = configure_,
    mainLoopInit = mainLoopInit_,
    mainLoopIterate = mainLoopIterate_,
    mainLoop = mainLoop_
}

return Obj