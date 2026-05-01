----------------------------------------------------------------------
--- IU (Item Usage) Lumberjack Swap Iron
--- Author: JohnB9
---
--- Description: Import this if you want to call 'lumberjackSwap from
---              another script for a iron hatchet
--- 
---              Swaps between a iron hatchet and an axe
---              (considers items in hand or in inventory only)
---              
---              Chooses lowest durability items first:
---               - keeps your inventory clean
---               - forces to choose the same hatchet every time
---                 you swap, untill it fully wears out from lumberjacking
---               - you would distribute the usages over all hatchets
---                 in your inventory otherwise
--- 
---              Sends Combat Bot Dexer run as callback for after swap
----------------------------------------------------------------------

local ipmp = Import('IPMaterialPredicates')
local iuls = Import('IUlumberjackSwap')
local cacd = Import('CAConfigDexer')

-----------
--- Run ---
-----------

iuls.lumberjackSwap(ipmp.itemIsOfIron, cacd.run)
