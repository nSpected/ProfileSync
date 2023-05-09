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
DataController.Changed:Connect(function(Player_Data : {}, DataName : string)
	print(game.Players.LocalPlayer, "'s [", DataName, "] has been changed to: ", Player_Data[DataName])
end)