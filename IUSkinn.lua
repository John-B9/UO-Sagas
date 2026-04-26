local il = Import('IPLib')
--local cbl = Import('combatBotLib')

local messageHue = 69

local skinning_knife_type_id = 65193
local skinning_knife = Items.FindByType(skinning_knife_type_id)
if skinning_knife == nil then
    Messages.Overhead("Missing Skinning Knife", messageHue, Player.Serial)
else
    local best_skinning_knife = il.getItemWithLessUsesRemaining(skinning_knife_type_id, nil)
    Player.UseObject(best_skinning_knife.Serial)
end

--Pause(1000)
--cbl.mainLoop()