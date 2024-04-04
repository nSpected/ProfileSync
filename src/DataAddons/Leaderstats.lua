-- SERVICES --
local Players = game:GetService("Players")

-- MAIN --
return function(DataController, ...)
	local params = {...}
	if not params[1] or typeof(params[1]) ~= 'table' then return end
	
	local dataToShow = params[1].dataToShow
	if not dataToShow or typeof(dataToShow) ~= 'table' or #dataToShow < 1 then return end

	local function InitPlayer(player : Player)
		DataController:GetProfile(player, nil, true):andThen(function(profile)
			if not profile then return end
			
			local leaderstats = player:FindFirstChild('leaderstats')
			if leaderstats then return end
			
			leaderstats = Instance.new('Folder')
			leaderstats.Name = 'leaderstats'
			leaderstats.Parent = player
			
			for _, dataName in dataToShow do
				local value = profile[dataName]
				if not value then continue end
				
				local valueObject = (typeof(value) == 'number' and Instance.new('IntValue')) or 
					(typeof(value) == 'string' and Instance.new('StringValue')) or nil
				
				if not valueObject then continue end
				
				valueObject.Name = dataName
				valueObject.Value = value
				valueObject.Parent = leaderstats
				
				DataController:Bind(player, dataName, function(newValue)
					if not valueObject then return end
					valueObject.Value = value
				end)
			end
		end):catch(warn)
	end
	
	for _, player : Player in ipairs(Players:GetPlayers()) do
		InitPlayer(player)
	end
	
	Players.PlayerAdded:Connect(function(player)
		InitPlayer(player)
	end)
end