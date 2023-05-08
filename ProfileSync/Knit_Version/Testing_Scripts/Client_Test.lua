-- SERVICES --
local RS = game:GetService("ReplicatedStorage")

-- FRAMEWORKS --
local Knit = require(RS.Packages.Knit)

-- CONTROLLERS --
local Controllers = Knit.AddControllers(RS.Controllers)

-- STARTING KNIT --
Knit.Start():await()

-- DATA CONTROLLER --
local DataController = Knit.GetController("DataController")

-- TEST --
while task.wait(1) do
	print(DataController:GetData(game.Players.LocalPlayer, "Coins"))
end