----------------------------------------------------------------------
--- Combat Assistant (CA) Run Dexer User Interface Gump
--- Author: JohnB9
---
--- Version: 1.0.0  - Run Combat Bot User Interface with Dexer Config
---                   base configuration
---
--- Description: Running this script will run Combat Bot User Interface
---              starting with a Dexer main loop configuration
----------------------------------------------------------------------

-----------
--- Run ---
-----------

local cacd = Import('CAConfigDexer')
cacd.runUiGump()