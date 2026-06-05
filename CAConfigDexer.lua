----------------------------------------------------------------------
--- Combat Assistant (CA) Config Dexer
--- Author: JohnB9
---
--- Version: 1.0.0  - Combat Bot Dexer Config and Run function
---
--- Description: If you import, you'll have access to the 'run' method 
---              to lunch the combat bot, and to the configuration for 
---              the main loop
---
---              You can import to have another script launch the
---              combat bot
--- 
---              Change the configuration bellow to your liking
--- 
----------------------------------------------------------------------

local caml = Import('CAMainLoop')
local caruig = Import('CARunUIGump')

local DexerMainLoopConfig = {
    time = {
        ActionWaitTime = 1000,  --- in milliseconds, how long to wait for actions like using items, targeting etc.
                                --- Adjust ActionWaitTime if you experience issues, set it longer, ex. 1500 on high ping
        MainLoopTick = 60,      --- in milliseconds
        JournalTick = 0,        --- milliseconds, zero means immediate
    },
    debug = {
        EnableDebugLog = true,          --- enable console log
        DebugLogTick = 60,              --- in milliseconds
        EnableDebugTick = false,        --- <<== (TURN ON TO FOR DEBUGGING): forces a slower exececution
        DebugTick = 500,                --- slower exececution tick frequency
        EnableOverheadMessages = false  --- Enables overhead messages, if false then messages will be printed in journal
    },
    modules = {
        ArmDisarm = {
            Enable = true,          --- Re-arms when disarmed, disarms if weapon durability too low
            AlwaysRearm = false     --- rearm without moving, warning will spam messages if you drag from hands
        },
        Escape = {
            EnablePopPouch = true,  --- Pops pouch if you are paralyzed in PvP mode
            EnableComand = false,   --- Saying escape and the escape command in the escape config will port you
            EnableMoongate = true   --- Opens moongate if you are near one
        },
        CurePotions = {
            Enable = false,          --- Cures poison with potions first (can be a waste of potions)
            ColldownTime = 1000     --- in milliseconds
        },
        HealingPotions = {
            Enable = true,          --- Drink a healling potion if health too low
            HPDrinkThreshould = 20  --- in percentage, when to use heal potion
        },
        Bandages = {
            Enable = true,                  --- Bandages player if HP is below BandageSelfHPThreshould or if poisoned and no cure potions
            BandageSelfHPThreshould = 99,   --- in percentage, when to use bandage
            BandageAllies = true,           --- Whether to attempt to bandage allies when player is not in need of bandaging
            BandageAlliesHPThreshould = 90, --- in percentage, when to use bandage
            AlliesSerials = {}              --- List of allies serials to bandage, if BandageAllies is true
        },
        Buffs = {
            Enable = true,              --- Enables automatic buffs, see bellow (disable if you prefer to use manually)
            SongOfHealing = {
                Enable = false,
                FailWait = 30 * 1000,   --- in ms, how long to retry if already under effects by manual cast
                Instruments = {"Drum", "Lute", "Tambourine", "Lap Harp" }
            },
            Nightsight = {
                Enable = true   --- Drink nightsight potion if not buffed already
            },
            Stamina = {
                Enable = true,          --- Drink stamina potion when bellow a threshould
                DrinkThreshould = 60    --- in percentage, when to drink stamina potion
            },
            Strength = {
                Enable = true,          --- Drink strength potion if not buffed already
                BaseStrength = 100,
                DrinkHeal = true
            },
            Agility = {
                Enable = true,          --- Drink potion potion if not buffed already
                BaseAgility = 81,       --- Because of full plate (without gorget: using luck gear)
                DrinkRefresh = true
            },
            EatFood = {
                Enable = false   --- BUGGED: Buff foods don't prevent eating if already under the effect
            }
        },
        Debuffs = {
            Enable = false,     --- Enables automatic debuffs, see bellow (disable if you prefer to use manually)
            Peacemaking = {
                Enable = false
            }
        },
        DetectPlayers = {
            Enable = false  --- Alerts you when a player from the hunt list is visible
        },
        Skinning = {
            Enable = false,
            NoisyMode = true,       --- To Log XOR Say when dropping or keeping a resource
            LeatherHuesToKeep = {
                --- 0x0000,         --- Regular
                --- 0x0973,         --- Dull Copper
                --- 0x0966,         --- Shadow Iron
                --- 0x096D,         --- Copper
                0x0972,             --- Bronze
                0x08A5,             --- Gold
                0x0979,             --- Agapite
                0x089F,             --- Verite
                0x08AB              --- Valorite
            }
        },
        Scavenging = {
            Enable = false,         --- Scavenges items from the ground, only arrows, add more if needed
            Frequency = 0,          --- milliseconds, zero means immediate
            LootItemsSerials = {    --- List of items to scavenge
                0x0F3F,
                0x1BFB
            },
            LootItemsNames = {},        --- Use if serial not available
            DisallowGold = false,       --- Disallow scavenging gold (should it already be on the list above)
            DisallowBones = false,      --- Disallow scavenging bones (should it already be on the list above)
            DisallowGrimoire = false    --- Disallow scavenging grimoires (should it already be on the list above)
        },
        Attack = {
            Enable = false,                     --- Attacks nearby enemies automatically
            Rangemax = 10,                      --- Attack search range
            MobilesExceptionsSerials = {},      --- Mobiles Serials to ignore (add friends so to not attack should they become grey)
            MobilesExceptionsGraphicIDs = {},   --- Mobiles GraphicIDs to ignore (don't kill: cows, dogs...)
            MobilesExceptionsNames = {},        --- Mobiles Names to ignore (use if don't have serial or graphic available)
            CheckFrequency = 500                --- in milliseconds, how often to check for new targets, adjust if needed
        }
    },
    userCommands = {
        Enable = true,  --- Parse and process user commands (via journal)
        CommandStringPrefix = "(DEXER)"
    }
}

local function run_()
    caml.mainLoop(DexerMainLoopConfig)
end

local function runUiGump_()
    caruig.runGump(DexerMainLoopConfig)
end

local function runWithCommandsDisabled_()
    DexerMainLoopConfig.userCommands.Enable = false
    caml.mainLoop(DexerMainLoopConfig)
end

local function runWithBuffsDisabled_()
    DexerMainLoopConfig.modules.Buffs.Enable = false
    caml.mainLoop(DexerMainLoopConfig)
end

--------------
--- Export ---
--------------

local Obj = {
    run = run_,
    runUiGump = runUiGump_,
    runWithCommandsDisabled = runWithCommandsDisabled_,
    runWithBuffsDisabled = runWithBuffsDisabled_
}

return Obj