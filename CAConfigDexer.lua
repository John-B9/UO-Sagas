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
local cauig = Import('CAUIGump')

---------------
--- Configs ---
---------------

--- The Combat Assistant will need to be configured before use.
--- Here is the starting configuration I use, but you can extend and modify it to your liking.
--- Some of the config values can be changed when running the script Gump, but not all of them.

local FriendsSerialList = {     --- FriendsSerialList: add serials of friends to this list so that:
                                ---  1) Attack module does not attack them, even when they are grey
                                ---  2) To cross-heal them if they are damaged
    0x003306A5  --- Dardez Jum Zir (if you want to attack me, remove me from the list)
}

local MobilesExceptionsGraphicIDs = {   --- MobilesExceptionsGraphicIDs: add graphic IDs of mobiles you want attack module to ignore
    0x00ED  --- A Hind
}

local MobilesExceptionsNames = {    --- MobilesExceptionsNames: add names of mobiles you want attack module to ignore
    "a cow",            
    "a horse",
    "a rat",
    "a magpie",
    "a crow",
    "a towhee",
    "a dog",
    "a cat",
    "a bull",
    "a sheep",
    "a gorila",
    "a forest ostard"
                        
}

local ScavengerLootTable = {  --- ScavengerLootTable: add here the graphic IDs of items to auto-loot
    --- (highest priority)
    0xFDAD,  --- Eren Coin
    0x0F91,  --- Fragment
    0xFD8C,  --- Soul
    0xFD8F,  --- Mastery Gem
    0x0E73,  --- Skill Cap Ball
    0xFF3A,  --- Skill Scroll
    0x9FF8,  --- Paragon Chest
    0x9FF9,  --- Paragon Chest
    0x14EC,  --- Treasure Map
    0x573B,  --- Pigments
    ---0x0EB2,  --- Lap Harp
    ---0x0EB1,  --- Standing Harp
    ---0x0EB3,  --- Lute
    ---0x0E9D,  --- Tambourine
    ---0x0E9E,  --- Tambourine
    ---0x0E9C,  --- Drum
    0x0F26,  --- Diamond
    0x0F10,  --- Emerald
    0x0F16,  --- Amethyst
    0x0F10,  --- Emerald
    0x0F19,  --- Saphire
    0x0F25,  --- Amber
    0x0F13,  --- Ruby
    0x26B4,  --- Daemon Scales
    0xFCA9,  --- Hardened Resin
    0x318B,  --- Enchanted Bark
    0x0E21,  --- Clean Bandage
    ---0x0F8D,  --- Spider Silk
    ---0x0F86,  --- Mandrake Root
    ---0x0F8C,  --- Ash
    ---0x0F7B,  --- Blood Moss
    ---0x0F88,  --- Night Shade
    ---0x0F84,  --- Garlic
    ---0x0F7A,  --- Black Pearl
    ---0x0F85,  --- Ginseng
    ---0x0F3F,  --- Arrows
    ---0x1BFB,  --- Bolts
    ---0x09F1,  --- Raw Ribs
    ---0x0E86,  --- Pickaxe
    0xFF30,  --- Potato
    0x0F7E,  --- Bones
    0x2D9D,  --- Grimoire
    0x0EED,  --- Gold
    --- (lowest priority)
}

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
            Enable = true,              --- Re-arms once moved char when disarmed, disarms if weapon durability too low
            AlwaysRearm = false,        --- rearm without moving, warning will spam messages if you drag from hands
            AutoRearmOnMove = true,     --- Auto-rearm atempt everytime you move
            AutoRearmWithDelay = false  --- Auto-rearm atempt with a delay
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
            Enable = true,                      --- Bandages player if HP is below BandageSelfHPThreshould or if poisoned and no cure potions
            BandageSelfHPThreshould = 99,       --- in percentage, when to use bandage
            BandageAllies = true,               --- Whether to attempt to bandage allies when player is not in need of bandaging
            BandageAlliesHPThreshould = 90,     --- in percentage, when to use bandage
            AlliesSerials = FriendsSerialList   --- List of allies serials to bandage, if BandageAllies is true
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
            LeatherHuesToKeep = {}
        },
        Scavenging = {
            Enable = false,                             --- Scavenges items from the ground, only arrows, add more if needed
            Frequency = 0,                              --- milliseconds, zero means immediate
            LootItemsSerials = ScavengerLootTable,      --- List of items to scavenge,
            LootItemsNames = {},                        --- Use if serial not available
            DisallowGold = false,                       --- Toggle scavenging gold
            DisallowCleanBandage = false,               --- Toggle scavenging clean bandages
            DisallowBones = false,                      --- Toggle scavenging bones
            DisallowGrimoire = false,                   --- Toggle scavenging grimoires
            DisallowRibs = false                        --- Toggle scavenging ribs
        },
        Attack = {
            Enable = false,                                             --- Attacks nearby enemies automatically
            Rangemax = 10,                                              --- Attack search range
            AllowMobilesExceptionsSerials = true,                       --- Allow Mobiles Serials to ignore
            MobilesExceptionsSerials = FriendsSerialList,               --- Mobiles Serials to ignore (add friends so to not attack should they become grey)
            AllowMobilesExceptionsGraphicIDs = true,                    --- Allow Mobiles Mobiles GraphicIDs to ignore
            MobilesExceptionsGraphicIDs = MobilesExceptionsGraphicIDs,  --- Mobiles GraphicIDs to ignore (don't kill: cows, dogs...)
            AllowMobilesExceptionsNames = true,                         --- Allow Mobiles Mobiles Names to ignore
            MobilesExceptionsNames = MobilesExceptionsNames,            --- Mobiles Names to ignore (use if don't have serial or graphic available)
            CheckFrequency = 500                                        --- in milliseconds, how often to check for new targets, adjust if needed
        }
    },
    userCommands = {
        Enable = true,  --- Parse and process user commands (via journal)
        CommandStringPrefix = "(DEXER)"
    }
}

-----------------
--- Functions ---
-----------------


local function run_()
    caml.mainLoop(DexerMainLoopConfig)
end

local function runUiGump_()
    cauig.runGump(DexerMainLoopConfig)
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