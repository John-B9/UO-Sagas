----------------------------------------------------------------------
-- Drop Trash
-- Author: JohnB9
--
-- Description: Put all "trash" from inventory and ground into a
--              pouch that you have in your inventory.
--
--              When close to inventory item limit, current pouch
--              will be droped on ground, and continue filling
--              another pouch you have in your inventory.
----------------------------------------------------------------------

local iol = Import('IOLib')

local pouch_graphics_id = 3705
local trash = { 0x09F4, -- forks
                0x1010, -- iron key
                0x1004, -- barrel tap
                0x13B4, -- Club
                0x14F5, -- Spyglass
                --0x175D, -- Oil Cloth
                0x1852 -- Scales
              }

iol.dropTrashLoop(pouch_graphics_id, trash, true)