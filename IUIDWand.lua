local ipl = Import('IPLib')
--local cbl = Import('combatBotLib')

local wandGraphicIDs = { 3570, 3571, 3572, 3573 }
wand = ipl.getItemWithLessIdentificationCharges(wandGraphicIDs)
if wand == nil then
    Messages.Overhead("Missing Wand", 69, Player.Serial)
    return
end

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

--Pause(500)
--cbl.mainLoop()