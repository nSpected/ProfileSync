-- SERVICES --
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- FRAMEWORKS --
local Knit = require(RS.Packages.Knit)

-- SERVICES --
local Services = Knit.AddServices(RS.Services)

-- STARTING KNIT --
Knit.Start():andThen(function()
	print("[SERVER] Knit Started.")
	
	local DataService = Knit.GetService("DataService")
	
	task.spawn(function()
		while task.wait(1) do
			DataService:Add(Players:GetPlayers()[1], "Coins", 100)
		end	
	end)	
	
end):catch(warn)