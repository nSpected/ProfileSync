-- SERVICES --
local RS = game:GetService("ReplicatedStorage")

-- CONTROLLERS --
local DataController = require(RS:WaitForChild("DataController"))
DataController:Init() -- Initialize the Client.

-- TEST --
DataController.Changed:Connect(function(Player_Data : {}, DataName : string)
	print(game.Players.LocalPlayer, "'s [", DataName, "] has been changed to: ", Player_Data[DataName])
end)