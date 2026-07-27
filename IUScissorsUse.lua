----------------------------------------------------------------------
--- IU (Item Usage) Scissors Use
--- Author: JohnB9
---
--- Description: Uses scissors and resumes Dexxer combat bot
----------------------------------------------------------------------

local ius = Importn('IUScissors')
local cacd = Import('CAConfigDexxer')

-----------
--- Run ---
-----------

ius.useScissors(cacd.run, true)
