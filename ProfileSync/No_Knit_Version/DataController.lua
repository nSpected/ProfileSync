-- SERVICES --
local RS = game:GetService("ReplicatedStorage")
local CS = game:GetService("CollectionService")
local Players = game:GetService("Players")

-- RESOURCES --
local Signal = require(RS.Utils.Signal)
local TableUtil = require(RS.Utils.TableUtil)
local Promise = require(RS.Utils.Promise)

local Controller = {
	Profiles = {},
	
	Changed = Signal.new(),
	
	Remotes = {
		Changed = RS:WaitForChild("Data_Changed"),
		Initialized = RS:WaitForChild("Data_Initialized"),
		Communicator = RS:WaitForChild("Data_Communicator"),
	},
	
}

function Controller:GetServerProfile(Player : Player)
	if not Controller.Profiles[Player.UserId] then
		Controller.Profiles[Player.UserId] = true
		Controller.Profiles[Player.UserId] = Controller.Remotes.Communicator:InvokeServer("GetProfile", Player)
	end
end

function Controller:GetProfile(Player : Player)
	if not Player then return end
	if Controller.Profiles[Player.UserId] == true then return end
	return Controller.Profiles[Player.UserId]
end

function Controller:GetData(Player : Player, Data_Name : string)
	if Controller.Profiles[Player.UserId] == nil then Controller:GetServerProfile(Player) warn("No profile for player: ", Player, Player.UserId, Controller.Profiles) return end
	if Controller.Profiles[Player.UserId] == true then return end
	
	return Controller.Profiles[Player.UserId][Data_Name]
end

function Controller:Init()
	Controller.Remotes.Initialized.OnClientEvent:Connect(function(Profile : {}, UserID : number)
		Controller.Profiles[UserID] = TableUtil.Copy(Profile, true)
		print("[", UserID," Profile]: ", Controller.Profiles[UserID])
	end)	

	Controller.Remotes.Changed.OnClientEvent:Connect(function(Player : Player, New_Value : any, Data_Name : string)
		if Controller.Profiles[Player.UserId] == nil then warn(Player, " has not been init in this client.") return end
		if Controller.Profiles[Player.UserId] == true then return end
		if not Controller.Profiles[Player.UserId][Data_Name] then warn(Data_Name, " is not a valid client data.", Player) return end

		Controller.Profiles[Player.UserId][Data_Name] = New_Value
		
		if Player == Players.LocalPlayer then -- You can edit this part if you wish to fire the changed signal to changes on every player data (not limited to local player).
			Controller.Changed:Fire(Controller.Profiles[Player.UserId], Data_Name)
		end
	end)

	Players.PlayerRemoving:Connect(function(Player : Player)
		if Controller.Profiles[Player.UserId] == nil then return end
		Controller.Profiles[Player.UserId] = nil
	end)
end

return Controller

