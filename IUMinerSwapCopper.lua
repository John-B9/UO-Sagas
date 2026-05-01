----------------------------------------------------------------------
--- IU (Item Usage) Miner Swap Copper
--- Author: JohnB9
---
--- Description: Import this if you want to call 'minerSwap from
---              another script for a copper pickaxe
--- 
---              Swaps between a copper pickaxe and a warhammer
---              (considers items in hand or in inventory only)
--- 
---              Chooses lowest durability items first:
---               - keeps your inventory clean
---               - forces to choose the same pickaxe every time
---                 you swap, untill it fully wears out from minning
---               - you would distribute the usages over all pickaxes
---                 in your inventory otherwise
--- 
---              Sends Combat Bot Dexer run as callback for after swap
----------------------------------------------------------------------

local ipmp = Import('IPMaterialPredicates')
local iums = Import('IUMinerSwap')
local cacd = Import('CAConfigDexer')

-----------
--- Run ---
-----------

iums.minerSwap(ipmp.itemIsOfCopper, cacd.run)
