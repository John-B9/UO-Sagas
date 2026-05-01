----------------------------------------------------------------------
--- IU (Item Usage) Swap Item In Hand
--- Author: JohnB9
---
--- Description: Import this if you want to call 'swapItemInHand' from
---              another script
--- 
---              Swaps between a given 'first' and 'second' options
---              for items in hand
---              
---              Accepts a callback function, to be executed after
---              swap is done
----------------------------------------------------------------------

local bl = Import('BaseLib')

-----------------
--- Variables ---
-----------------

local debugEnabled = true

---------------
-- Functions --
---------------

local function swapItemInHand_(config, callback)

    --- Get items to swap
    local first_item = Items.FindByType(config.first.serial)
    local second_item = Items.FindByType(config.second.serial)

    --- Get item in hand
    local item_in_hand = Items.FindByLayer(1)
    if not item_in_hand then
        item_in_hand = Items.FindByLayer(2)
    end

    --- Check item in hand
    local equipItemOfFirstType = true
    if item_in_hand ~= nil then

        bl.printIfDebug(debugEnabled, "Have item in hand")

        --- Drop item in hand
        Player.PickUp(item_in_hand.Serial)
        Player.DropInBackpack()
        Pause(500)

        --- Is item in hand of first type?
        local itemInHandMatchesFirstType = true
        if first_item and first_item.Name then
            local a = string.find(item_in_hand.Name, first_item.Name)
            local b = string.find(first_item.Name, item_in_hand.Name)
            itemInHandMatchesFirstType = (a ~= nil or b ~= nil)
        end
        local itemInHandVerifiesFirstTypeAcceptPredicate = not config.first.acceptPredicate or config.first.acceptPredicate(item_in_hand)
        bl.printIfDebug(debugEnabled, "Have first type item: "..tostring(first_item ~= nil))
        bl.printIfDebug(debugEnabled, "Item in hand of first type: "..tostring(itemInHandMatchesFirstType))
        bl.printIfDebug(debugEnabled, "Item in hand of first type and verifies first type accept predicate evaluation: "..tostring(itemInHandVerifiesFirstTypeAcceptPredicate))
        
        --- Target an item the second type if:
        ---  - no item of first type exists
        ---  - If item in hand is of first type and accepted
        if first_item == nil or (itemInHandMatchesFirstType and itemInHandVerifiesFirstTypeAcceptPredicate) then
            equipItemOfFirstType = false
        end

    end

    --- Which item to equip?
    if first_item ~= nil and equipItemOfFirstType == true then
        bl.printIfDebug(debugEnabled, "Equip First")
        config.first.equip()
        Pause(500)
    elseif second_item ~= nil then
        bl.printIfDebug(debugEnabled, "Equip Second")
        config.second.equip()
        Pause(500)
    end

    --- Handle callback
    if callback then
        callback()
    end

end

--------------
--- Export ---
--------------

local Obj = {
    swapItemInHand = swapItemInHand_
}

return Obj