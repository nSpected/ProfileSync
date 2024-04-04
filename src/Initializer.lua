--// Just a sample of the one inside the rbxm file.
--// Only modify this script if you know what you're doing 👍

-- INTERNAL --
local DataFolder = script.Parent
local Utilities = DataFolder.Utilities
local Settings = require(Utilities.Settings)

-- SERVICES --
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local StarterPlayerScripts = game:GetService('StarterPlayer').StarterPlayerScripts

-- DEPENDENCY INJECTION --
local Libraries = ReplicatedStorage:FindFirstChild('Libraries')
if not Libraries then
	Libraries = Instance.new('Folder')
	Libraries.Name = 'Libraries'
	Libraries.Parent = ReplicatedStorage
end

for _, Dependency: Instance in DataFolder.Dependencies:GetChildren() do
	if not Dependency:IsA('ModuleScript') or Libraries:FindFirstChild(Dependency.Name) then continue end
	Dependency.Parent = Libraries
end

local AddonsFolder = DataFolder:FindFirstChild("DataAddons")
if AddonsFolder then
	AddonsFolder.Parent = ReplicatedStorage
end

-- INIT CONTROLLER --
task.spawn(function()
	local ControllerInitializer = script.ControllerInitializer
	local Controller = DataFolder.DataController
	
	for attributeName, value in pairs(Settings.Attributes) do
		Controller:SetAttribute(attributeName, value)
	end
	
	Controller.Parent = Settings.ControllerLocation
	
	--ControllerInitializer.ControllerReference.Value = Controller
	ControllerInitializer.Parent = StarterPlayerScripts
	ControllerInitializer.Enabled = true
end)

-- INIT SERVICE --
local Service = DataFolder.DataService

for attributeName, value in pairs(Settings.Attributes) do
	Service:SetAttribute(attributeName, value)
end

Utilities.Settings.Parent = Service --// Make a copy of the settings for future usage
Service.Parent = Settings.ServiceLocation
require(Service)
