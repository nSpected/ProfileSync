-- SERVICES --
local Players = game:GetService("Players")

-- MAIN --
return function(DataController, ...)
	local function InitPlayer(player : Player)
		DataController:GetProfile(player, nil, true):andThen(function(profile)
			if not profile then return end
			
			for dataName, value : any in profile do
				if typeof(value) ~= "number" and typeof(value) ~= "string" and typeof(value) ~= "boolean" then continue end

				player:SetAttribute("DATA_" .. dataName, value)
			end
			
			DataController:BindAll(player, function(value, dataName)
				warn(value, dataName)
				if typeof(value) ~= "number" and typeof(value) ~= "string" and typeof(value) ~= "boolean" then return end
				player:SetAttribute("DATA_" .. dataName, value)
			end)
		end):catch(warn)
	end
	
	for _, player : Player in ipairs(Players:GetPlayers()) do
		InitPlayer(player)
	end
	
	Players.PlayerAdded:Connect(function(player)
		InitPlayer(player)
	end)
end