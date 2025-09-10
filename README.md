# UO-Sagas

Scripts for UO Sagas by JohnB9.

These are some of the scripts I've developed and use in the UO Sagas in-game assistant.

When I have something that is clean enough and wothy of sharing, I will add it here.

As I want this to be modular, most of the scripts are not stand-alone, they include/depend-on other scripts. But as long as you get the full set, it will work (see Installing).

Enjoy!

# Conduct

As being new to lua and to the UO Sagas assitant API, I've used and took inspiration from scripts from many other scripters/players.

In some cases, part of the code I show here could have been partialy copyed and adapted (sometimes, fully copied!). When it is the case, I leave a comment in the top of the script with a mention. So thank you to all those there (like: Halesluker, Rum Runner, Zeran, ...) and feel free to do the same.

Then if you do use that is here for your own scripts and then publish an adaption, a mention would be nice!

# Installing

1) Get every .lua file here:

   Download the zip via top right "<> Code" green button

   OR
   
   Just git clone (if you know what that is)

2) Copy every .lua file to the UO Sagas script directory, which should:

   "Your_Instalation_Path"\ClassicUO\Data\Profiles\Scripts

3) Close all clients, launch again

4) All scripts will be available in the assistant and ready to use

# Scripts Descriptions

## Base Lib

Functions with common util functions, and used by all scripts here

## CL (Crafting Leveling) Lib

This all started with wanting to make a craftsman, and using the script from Rum Runner for tinkering.

As I wanted to level more crafting (blacksmithing, tayloring, ...) it was clear this could be generalized and re-used.

What I did here was just that, with some additional touches

### CLBowcraftFletching, CLCarpentry, CLCooking, CLSmithing, CLTayloring

These are the scripts you can run, which define a list with crafting items for every skill range, maybe some pre-work (like picking up a fishsteak from the ground and putting it in the inventory), and then call the crafting loop from CLLib.

NOTE: The list of items for every skill range is not complete to 120 progression, some go only to 70 (I didn't continue after Adena for some), but you can extend with what you want. All you need is to add an entry, knowing the gump button IDs (you can get those via "Start Recording" in the assistant, clicking in the buttons of what you want to craft, and putting the values in "category", "craft" and "final"). When I get to those skill levels, I'll update what I have here.

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
