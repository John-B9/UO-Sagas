----------------------------------------------------------------------
--- IU (Item Usage) Skinn Use
--- Author: JohnB9
---
--- Description: Uses skinning knife resumes dexer combat bot
----------------------------------------------------------------------

local ius = Import('IUSkinn')
local cacd = Import('CAConfigDexer')

-----------
--- Run ---
-----------

ius.useSkinningKnife(cacd.run, true)
