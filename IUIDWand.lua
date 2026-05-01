----------------------------------------------------------------------
--- IU (Item Usage) Identification Wand
--- Author: JohnB9
---
--- Description: Import this if you want to call 'useIdWand' from
---              another script
--- 
---              Accepts a callback function, to be executed after
---              identification is done
----------------------------------------------------------------------

local ipl = Import('IPLib')

-----------------
--- Functions ---
-----------------

local function useIdWand_(callback)

    --- get wand with less charges
    local wandGraphicIDs = { 3570, 3571, 3572, 3573 }
    wand = ipl.getItemWithLessIdentificationCharges(wandGraphicIDs, nil)
    if wand == nil then
        Messages.Overhead("Missing Wand", 69, Player.Serial)
        return
    end

    --- use or drop at feet if no charges
    charges = ipl.getIdentificationCharges(wand)
    if charges == 0 then
        Messages.Overhead("Wand out of charges", 69, Player.Serial)
        Messages.Overhead("Dropping wand", 69, Player.Serial)
        Player.PickUp(wand.Serial)
        Player.DropOnGround()
    else
        Messages.Overhead("Using ID Wand", 69, Player.Serial)
        Player.UseObject(wand.Serial)
    end
    Pause(500)

    --- handle callback
    if callback then
        callback()
    end

end

--------------
--- Export ---
--------------

local Obj = {
    useIdWand = useIdWand_
}

return Obj