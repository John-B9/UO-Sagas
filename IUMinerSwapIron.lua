----------------------------------------------------------------------
--- IU (Item Usage) Miner Swap Iron
--- Author: JohnB9
---
--- Description: Import this if you want to call 'minerSwap from
---              another script for a iron pickaxe
--- 
---              Swaps between a iron pickaxe and a warhammer
---              (considers items in hand or in inventory only)
---              
---              Chooses lowest durability items first:
---               - keeps your inventory clean
---               - forces to choose the same pickaxe every time
---                 you swap, untill it fully wears out from minning
---               - you would distribute the usages over all pickaxes
---                 in your inventory otherwise
--- 
---              Sends Combat Bot Dexxer run as callback for after swap
----------------------------------------------------------------------

local ipmp = Import('IPMaterialPredicates')
local iums = Import('IUMinerSwap')
local cacd = Import('CAConfigDexxer')

-----------
--- Run ---
-----------

iums.minerSwap(ipmp.itemIsOfIron, cacd.run)
