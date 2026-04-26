local bl = Import('BaseLib')

local debugEnabled = false

local function swapItemInHand_(config)

    local first_item = Items.FindByType(config.first.serial)
    local second_item = Items.FindByType(config.second.serial)

    local item_in_hand = Items.FindByLayer(1)
    if not item_in_hand then
        item_in_hand = Items.FindByLayer(2)
    end

    local equipFirstItem = true
    if item_in_hand ~= nil then
        bl.printIfDebug(debugEnabled, "Have item in hand")
        Player.PickUp(item_in_hand.Serial)
        Player.DropInBackpack()
        Pause(500)
        local a = string.find(item_in_hand.Name, first_item.Name)
        local b = string.find(first_item.Name, item_in_hand.Name)
        local itemInHandMatchesType = (a ~= nil or b ~= nil)
        if first_item == nil or itemInHandMatchesType then
            equipFirstItem = false
        end
    end

    if first_item ~= nil and equipFirstItem == true then
        bl.printIfDebug(debugEnabled, "Equip First")
        config.first.equip()
    elseif second_item ~= nil then
        bl.printIfDebug(debugEnabled, "Equip Second")
        config.second.equip()
    end
end

------------
-- Export --
------------

local Obj = {
    swapItemInHand = swapItemInHand_
}

return Obj