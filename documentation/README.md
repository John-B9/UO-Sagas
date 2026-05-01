
# Documentation

## Base Lib

Functions with common util functions, and used by all scripts here

## CA (Combat Assistant)

A fully automatic combat assistant with QOL:
 - Handle disarm and low durability weapon
 - Handle escape: Pop Pouch, moongate
 - Auto bandage
 - Usage of cure, health and stamina potions
 - Apply buffs: food, strength, agility and nightsight potions, song of healing
 - Apply debuffs: peacemaking
 - Player Detection
 - Scavenging
 - Config for Dexer

Based on https://uoaddicts.com/script/halesluker-s-sagas-bot-cmb5kn6y, but modularized and extended

The Combat Assistant is also integrated with other methods in the (Item Usage) Lib, via user triggered commands

**To launch the Combat Assistant:**
 - Select parameters in **CAConfigDexer**
 - Run **CARunDexer**
 - Run **CARunDexerNoCommands** to run with user triggered commands disabled

## CL (Crafting Leveling) Lib

A generic lib for repeated crafting towards leveling up a skill

Based on Rum Runner scipt, modularized and extended

### CLBowcraftFletching, CLCarpentry, CLCooking, CLSmithing, CLTayloring

Individual scripts to level up each crafting skill:
 - Hava an already defined list with crafting items for every skill range
 - May include some pre-work (like picking up a fishsteak from the ground and putting it in the inventory)
 - May include some post-work (like smelting your item back to ingotss in blacksmithing)

## IO (Items Organization) Lib

Utility functions for organizing items

### IODropTrash

Don't craft and leave things on the ground... That is not good for the environment!

Put them into a pouch, and drop the pouch instead!

## IP (Item Properties) Lib

Utility functions to handle item "Properties"

### Parse values from the "Properties" of an item:
- getUsesRemaining
- getIdentificationCharges
- getContents
- ...
- getItemSingleValueProperty/getItemDoubleValueProperty (generic)

### Get the item with the "best properties":
- getItemWithLessUsesRemaining (Hatchet/Mortar&Pestel/...)
- getItemWithLessIdentificationCharges
- getItemWithMostContent (Container in backpack that is most full)
- ...
- getItemWithLessSinglePropertyValue/getItemWithLessDoublePropertyFirstValue/... (generic)

## IU (Item Usage) Lib

Utility functions to use items:
 - **IUIDWandRun**: use ID Wand (and continue combat bot)
 - **IUScissorsUse**: use scissors (and continue combat bot)
 - **IUSkinnUse**: use skinning knife (and continue combat bot)
 
QOL utility functions to use items for a Dexer gather (for a good switch between
minning/lumberjacking and fighting):
 - **IUMinerSwapIron/IUMinerSwapCopper** Swap miner pickaxe and waraxe (and continue dexer combat bot)
    - iron (use for regular ore)
    - and bronse (use to not fail on valorite veigns)
 - **IULumberjackSwapIron/IULumberjackSwapCopper** Swap lumbejack hatchet and axe (and continue dexer combat bot)
    - iron (use for regular ore)
    - and bronse (use to not fail on valorite veigns)

### IUIDWand

Use the ID Wand in backpack with less charges (drop it at feet if it has zero charges), wait for target, but resume combat bot.

NOTE: carry 2 ID wands at all times so you never run out of charges.

### IUSkinn

Use the skinning knife in backpack with less charges, wait for target, but resume combat bot.

### IUMinerSwap

QOL for the dexer miner:
 - easy swap between pickaxe and waraxe (easy transition between minning and fighting)
 - clean inventory (always mine with lowest durability pickaxe)
 - choose between iron (regular veigns) and bronse (to not fail on valorite veigns) pickaxe
 - launches combat bot when equiping waraxe

### IULumberjackSwap

QOL for the dexer lumberjack:
 - easy swap between hatchet and axe (easy transition between lumberjacking and fighting)
 - clean inventory (always lumberjack with lowest durability hatchet)
 - choose between iron (regular trees) and bronse (to not fail on valorite trees) hatchet
 - launches combat bot when equiping axe
