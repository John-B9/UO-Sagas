----------------------------------------------------------------------
--- Combat Assistant (CA) Run Dexxer User Interface Gump
--- Author: JohnB9
---
--- Version: 1.0.0  - Run Combat Bot User Interface with Dexxer Config
---                   base configuration
---
--- Description: Running this script will run Combat Bot User Interface
---              starting with a Dexxer main loop configuration
----------------------------------------------------------------------

-----------
--- Run ---
-----------

local cacd = Import('CAConfigDexxer')
cacd.runUiGump()