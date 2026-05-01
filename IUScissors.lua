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

-----------------
--- Functions ---
-----------------

local function useScissors_(callback)
    local scissors = Items.FindByName('Scissors')
    Player.UseObject(scissors.Serial)
    Pause(1000)
    if callback then
        callback()
    end
end

--------------
--- Export ---
--------------

local Obj = {
    useScissors = useScissors_
}

return Obj
