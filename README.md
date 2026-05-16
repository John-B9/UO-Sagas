# UO-Sagas

**Scripts** for **UO Sagas** by **JohnB9**.

This is the code base of the scripts I've developed and use in the UO Sagas in-game assistant.

When I have something that is clean enough and wothy of sharing, I will add it here (Enjoy!).

## Features (summary)

 - **CA (Combat Assistant)**: A fully automatic combat assistant (auto bandage, potions, buffs, debuffs, escape, rearm, find players, scavenge, user triggered commands and more...):
   - [CAMainLoop](https://github.com/John-B9/UO-Sagas/blob/main/CAMainLoop.lua) (needs a config)
   - [CARunDexer](https://github.com/John-B9/UO-Sagas/blob/main/CARunDexer.lua) (run with [CAConfigDexer](https://github.com/John-B9/UO-Sagas/blob/main/CAConfigDexer.lua), change what you want there)
   - [CARunDexerUIGump](https://github.com/John-B9/UO-Sagas/blob/main/CARunDexerUIGump.lua) (UI Gump: start/stop, enable/disable buffs and commands)
   - [CAUserTriggeredCommands](https://github.com/John-B9/UO-Sagas/blob/main/CAUserTriggeredCommands.lua) (specify commands and actions; interact with the combat assistant via "Say")
 - **CL (Crafting Leveling)**: Repeat crafting to level up all crafting skill [[CLTinkering](https://github.com/John-B9/UO-Sagas/blob/main/CLTinkering.lua), [CLSmithing](https://github.com/John-B9/UO-Sagas/blob/main/CLSmithing.lua), ...]
 - **IO (Item Organization)**: Generic functions (drop item in trash, and more...) [[IODropTrash](https://github.com/John-B9/UO-Sagas/blob/main/IODropTrash.lua), ...]
 - **IP (Item Properties)**: API to access item properties, like durability and charges
 - **IU (Item Usage)**: QOL scripts for item usage + QOL scripts focused on dexer gatherers, swaping between a gather/combat mode (_integrated with Combat Bot_):
   - [IUIDWandRun](https://github.com/John-B9/UO-Sagas/blob/main/IUIDWandRun.lua), [IUSkinnUse](https://github.com/John-B9/UO-Sagas/blob/main/IUSkinnUse.lua), [IUScissorsUse](https://github.com/John-B9/UO-Sagas/blob/main/IUScissorsUse.lua):
     - You choose the target, combat bot is resumed
     - _CB triggered commands_: **"(DEXER) ID Wand"**, **"(DEXER) Skinn"**, **"(DEXER) Scissors"**
   - [IULumberjackSwapIron](https://github.com/John-B9/UO-Sagas/blob/main/IULumberjackSwapIron.lua):
     - Swap between hatchet/axe, run combat bot if axe equiped
     - _CB triggered commands_: **"(DEXER) Lumberjack Swap Iron"**, **"(DEXER) Lumberjack Swap Copper"**
   - [IUMinerSwapIron](https://github.com/John-B9/UO-Sagas/blob/main/IUMinerSwapIron.lua):
     - Swap between pickaxe/waraxe, run combat bot if waraxe equiped
     - _CB triggered commands_: **"(DEXER) Miner Swap Iron"**, **"(DEXER) Miner Swap Copper"**

See more feature details in [documentation](https://github.com/John-B9/UO-Sagas/blob/main/documentation/README.md).

**NOTE:** These scripts are not stand-alone (see **Installing** and **Architecture** below), but some have a [standalone version here](https://github.com/John-B9/UO-Sagas/tree/main/standalone).

## Installing

1) **Get every .lua file:**

   Download the zip via top right "<> Code" green button

   **OR**
   
   Just git clone (if you know what that is)

2) **Close all clients**

3) **Copy every .lua file to the UO Sagas script directory, which should:**

   "Your_Instalation_Path"\ClassicUO\Data\Profiles\Scripts

4) **Launch client again**

5) **All scripts will be available in the assistant and ready to use**

## Architecture

As I want this code-base to be modular:

 - Most of the scripts are not stand-alone:
   - They include/depend-on other scripts
   - But as long as you get the full set, it will work (see Installing)
 - SAGAS assistant does not support directories, so scripts are organised together by a filename pre-fix
 - Each script is strucured to have:
   - A global config (and setters for other scripts to change the config)
   - A static config (for constants)
   - A state (for mutable local variables)
   - Function names end with "\_" (but exported versions drop the "\_")
   - All files follow this structure, which is consolidated in the [TEMPLATE](https://github.com/John-B9/UO-Sagas/blob/main/TEMPLATE.lua) file

## Developer Conduct

I've used and took inspiration from scripts from many other scripters/players.

When I do, I leave a mention in the file header.

**Special thanks to**: **Halesluker**, **Rum Runner**, **Zeran**, **OmgArturo**
