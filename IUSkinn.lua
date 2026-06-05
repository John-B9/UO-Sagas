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

local function getSkinningKnife_(verbose)
    local best_skinning_knife = il.getItemWithLessUsesRemaining(skinning_knife_type_id, nil)
    if verbose and best_skinning_knife == nil then
        Messages.OverheadMobile(Player.Serial, "Missing Skinning Knife", messageHue)
    end
    return best_skinning_knife
end

local function useSkinningKnife_(callback, verbose)
    local best_skinning_knife = getSkinningKnife_(verbose)
    if best_skinning_knife then
        Player.UseObject(best_skinning_knife.Serial)
    end
    if callback then
        callback()
    end
    return best_skinning_knife ~= nil
end

--------------
--- Export ---
--------------

local Obj = {
    getSkinningKnife = getSkinningKnife_,
    useSkinningKnife = useSkinningKnife_
}

return Obj
