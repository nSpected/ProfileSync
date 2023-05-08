-- SERVICES --
local RS = game:GetService("ReplicatedStorage")

-- CONTROLLERS --
local DataController = require(RS:WaitForChild("DataController"))
DataController:Init() -- Initialize the Client.

-- TEST --
while task.wait(1) do
	print(DataController:GetData(game.Players.LocalPlayer, "Coins")) -- This may not return right away as the data can take a while to load
end