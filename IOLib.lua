----------------------------------------------------------------------
-- IO (Items Organization) Lib
-- Author: JohnB9
--
-- Description: Utility functions for organizing items
----------------------------------------------------------------------

local bl = Import('BaseLib')
local il = Import('IPLib')

---------------
-- CONSTANTS --
---------------

local inventory_fill_drop_disposal_container_threshold = 5

---------------
-- FUNCTIONS --
---------------

local function getFreeBackpackItemsSlots_()
    -- In some cases we may end +1 above max item capacity due to having item picked up
    local backpackContents = il.getContents(Player.Backpack)
    --Messages.Print("Free Backpack space ("..backpackContents[2] - backpackContents[1]..")", 55)
    return math.max(backpackContents[2] - backpackContents[1], 0)
end

local function checkThreshouldDropDisposalContainer_(disposalContainer)
    -- Pouches can store 125 items, but items in pouches also count for player inventory items
    -- that also has a limit of 125. Therefore when close to this limit in inventory, drop the pouch
    -- to free player inventory space, and find another one to drop put trash in it
    local freeInventorySpace = getFreeBackpackItemsSlots_()
    if freeInventorySpace <= inventory_fill_drop_disposal_container_threshold then
        Messages.Print("No more room in inventory! (free space: " .. freeInventorySpace ..
        ") Droping disposal container!", 55)
        Player.PickUp(disposalContainer.Serial)
        Player.DropOnGround()
        Pause(700)
        return true
    end
    return false
end

local function getMostFilledContainerDropIfFull_(containerGraphicID)
    local dropedContainer = false
    local mostFilledContainer = il.getItemWithMostContent(containerGraphicID)
    if mostFilledContainer ~= nil then
        if checkThreshouldDropDisposalContainer_(mostFilledContainer) then
            mostFilledContainer = nil
            dropedContainer = true
        end
    end
    return { mostFilledContainer, dropedContainer }
end

local function getTrashItemList_(trashGraphicIDs, includeItemsOnGround)
    local trashItemList = nil
    if includeItemsOnGround == true then
        local filter = { graphics = trashGraphicIDs }
        trashItemList = Items.FindByFilter(filter)
    else
        trashItemList = bl.findInInventory(trashGraphicIDs)
    end
    return trashItemList
end

local function dropTrashUntillDisposalContainerUntillFull_(disposalContainerGraphicID, trashGraphicIDs,
                                                           includeItemsOnGround)
    while true do
        local trashItemList = getTrashItemList_(trashGraphicIDs, includeItemsOnGround)
        for index, trashItem in ipairs(trashItemList) do
            -- get a disposal container to put trash in
            local retVal = getMostFilledContainerDropIfFull_(disposalContainerGraphicID)
            local disposalContainer = retVal[1]
            local dropedContainer = retVal[2]
            if disposalContainer == nil then
                if dropedContainer == false then
                    Messages.Print("Found no disposal container...", 55)
                    return false
                end
                return true
            end
            -- NOTE: Print before picking up. For some reason, after pick-up, sometimes
            --       "trashItem.Name" is nil and crashes the script
            --
            -- drop trash in disposal container
            Messages.Print("Dropping " .. trashItem.Name .. " in disposal container.", 55)
            Player.PickUp(trashItem.Serial)
            Player.DropInContainer(disposalContainer.Serial)
            Pause(550)
        end

        -- Important Pause for CPU
        Pause(150)
    end
end

local function dropTrashLoop_(disposalContainerGraphicID, trashGraphicIDs, includeItemsOnGround)
    while true do
        local continue = dropTrashUntillDisposalContainerUntillFull_(disposalContainerGraphicID, trashGraphicIDs, includeItemsOnGround)
        if continue == false then
            return
        end
    end
end

------------
-- Export --
------------

local Obj = {
    dropTrashUntillDisposalContainerUntillFull = dropTrashUntillDisposalContainerUntillFull_,
    dropTrashLoop = dropTrashLoop_
}

return Obj
