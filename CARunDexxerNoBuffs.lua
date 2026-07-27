----------------------------------------------------------------------
--- Combat Assistant (CA) Run Dexxer No Commands
--- Author: JohnB9
---
--- Version: 1.0.0  - Run Combat Bot with Dexxer Config (user commands 
---                   disabled)
---
--- Description: Running this script will run Combat Bot with a Dexxer
---              main loop configuration (user commands disabled)
----------------------------------------------------------------------

-----------
--- Run ---
-----------

local cacd = Import('CAConfigDexxer')
cacd.runWithBuffsDisabled()
