-- SERVICES --
local RS = game:GetService("ReplicatedStorage")
local CS = game:GetService("CollectionService")
local Players = game:GetService("Players")

-- FRAMEWORKS --
local Knit = require(RS.Packages.Knit)

-- RESOURCES --
local Signal = require(RS.Utils.Signal)
local TableUtil = require(RS.Utils.TableUtil)
local Promise = require(RS.Utils.Promise)

local Controller = Knit.CreateController {
	Name = "DataController",
	Profiles = {},
	Changed = Signal.new()
}

local DataService = nil

function Controller:GetServerProfile(Player : Player)
	if not DataService then return end
	if not Controller.Profiles[Player.UserId] then
		Controller.Profiles[Player.UserId] = true
		DataService:GetProfile(Player):andThen(function(Profile : {})
			if Controller.Profiles[Player.UserId] == true then
				Controller.Profiles[Player.UserId] = Profile
			end
		end)
	end
end

function Controller:GetProfile(Player : Player)
	if not DataService then return end
	if not Player then return end
	if Controller.Profiles[Player.UserId] == true then return end
	return Controller.Profiles[Player.UserId]
end

function Controller:GetData(Player : Player, Data_Name : string)
	if not DataService then return end
	if Controller.Profiles[Player.UserId] == nil then Controller:GetServerProfile(Player) warn("No profile for player: ", Player, Player.UserId, Controller.Profiles) return end
	if Controller.Profiles[Player.UserId] == true then return end
	--warn(Player, "Profiles: ", Controller.Profiles)
	return Controller.Profiles[Player.UserId][Data_Name]
end

function Controller:KnitStart()
	-- SERVICES --
	DataService = Knit.GetService("DataService")

	DataService.Initialized:Connect(function(Profile : {}, UserID : number)
		Controller.Profiles[UserID] = TableUtil.Copy(Profile, true)
		print("[", UserID," Profile]: ", Controller.Profiles[UserID])
	end)	

	DataService.Changed:Connect(function(Data_Name : string, New_Value : any, Player : Player)
		if Controller.Profiles[Player.UserId] == nil then warn(Player, " has not been init in this client.") return end
		if Controller.Profiles[Player.UserId] == true then return end
		if not Controller.Profiles[Player.UserId][Data_Name] then warn(Data_Name, " is not a valid client data.", Player) return end

		Controller.Profiles[Player.UserId][Data_Name] = New_Value
		Controller.Changed:Fire(Data_Name, New_Value, Player)
	end)

	Players.PlayerRemoving:Connect(function(Player : Player)
		if Controller.Profiles[Player.UserId] == nil then return end
		Controller.Profiles[Player.UserId] = nil
	end)

	print(script.Name .. " Started!")
end

return Controller

