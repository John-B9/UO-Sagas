----------------------------------------------------------------------
--- IU (Item Usage) Scissors
--- Author: JohnB9
---
--- Description: Import this if you want to call 'useScissors' from
---              another script
--- 
---              Uses scissors from your inventory and waits for a
---              target
--- 
---              Accepts a callback function, to be run when done
----------------------------------------------------------------------

local messageHue = 42

-----------------
--- Functions ---
-----------------

local function getScissors_(verbose)
    local scissors = Items.FindByName('Scissors')
    if verbose and scissors == nil then
        Messages.OverheadMobile(Player.Serial, "Missing Scissors", messageHue)
    end
    return scissors
end

local function useScissors_(callback, verbose)
    local scissors = getScissors_(verbose)
    if scissors then
        Player.UseObject(scissors.Serial)
    end
    if callback then
        callback()
    end
    return scissors ~= nil
end

--------------
--- Export ---
--------------

local Obj = {
    getScissors = getScissors_,
    useScissors = useScissors_
}

return Obj
