-- SERVICES --
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- MODULES --
local DataService = require(RS.DataService) -- Change to your path.
DataService:Init()

-- TEST --
task.spawn(function()
	while task.wait(1) do
		if DataService.Server_Initialized == false then return end -- If the Service has not been initialized yet, we don't do anything.
		DataService:Add(Players:GetPlayers()[1], "Coins", 100) -- This will increase the player's coins by 100 every 1 second once his data has been loaded.
	end   
end)    
