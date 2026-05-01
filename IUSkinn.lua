----------------------------------------------------------------------
--- IU (Item Usage) Skinn
--- Author: JohnB9
---
--- Description: Import this if you want to call 'useSkinningKnife' from
---              another script
--- 
---              Uses a the skinning knife with lowest durability from
---              your inventory and waits for a target
--- 
---              Accepts a callback function, to be run when done
----------------------------------------------------------------------

local il = Import('IPLib')

-----------------
--- Variables ---
-----------------
    
local messageHue = 42
local skinning_knife_type_id = 65193

-----------------
--- Functions ---
-----------------

local function useSkinningKnife_(callback)

    local skinning_knife = Items.FindByType(skinning_knife_type_id)
    if skinning_knife == nil then
        Messages.Overhead("Missing Skinning Knife", messageHue, Player.Serial)
    else
        local best_skinning_knife = il.getItemWithLessUsesRemaining(skinning_knife_type_id, nil)
        Player.UseObject(best_skinning_knife.Serial)
    end

    Pause(1000)
    if callback then
        callback()
    end

end

--------------
--- Export ---
--------------

local Obj = {
    useSkinningKnife = useSkinningKnife_
}

return Obj
