----------------------------------------------------------------------
--- Combat Assistant (CA) Run Dexer No Commands
--- Author: JohnB9
---
--- Version: 1.0.0  - Run Combat Bot with Dexer Config (user commands 
---                   disabled)
---
--- Description: Running this script will run Combat Bot with a Dexer
---              main loop configuration (user commands disabled)
----------------------------------------------------------------------

-----------
--- Run ---
-----------

local cacd = Import('CAConfigDexer')
cacd.runWithBuffsDisabled()
