----------------------------------------------------------------------
--- IU (Item Usage) Scissors Use
--- Author: JohnB9
---
--- Description: Uses scissors and resumes dexer combat bot
----------------------------------------------------------------------

local ius = Importn('IUScissors')
local cacd = Import('CAConfigDexer')

-----------
--- Run ---
-----------

ius.useScissors(cacd.run, true)
