--local cbl = Import('combatBotLib')

local scissors = Items.FindByName('Scissors')

Player.UseObject(scissors.Serial)

--Pause(1000)
--cbl.mainLoop()