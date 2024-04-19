--// Only modify this script if you know what you're doing 👍

-- INTERNAL --
local Settings = require(script.Settings)

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

for _, Dependency: Instance in script.Dependencies:GetChildren() do
	if not Dependency:IsA('ModuleScript') or Libraries:FindFirstChild(Dependency.Name) then continue end
	Dependency.Parent = Libraries
end

local AddonsFolder = script:FindFirstChild("DataAddons")
if AddonsFolder then
	AddonsFolder.Parent = ReplicatedStorage
end

-- INIT CONTROLLER --
task.spawn(function()
	local ControllerInitializer = script.ControllerInitializer
	local Controller = script.DataController
	script.Settings:Clone().Parent = Controller

	for attributeName, value in pairs(Settings.Attributes) do
		Controller:SetAttribute(attributeName, value)
	end
    
	ControllerInitializer.Parent = StarterPlayerScripts
	Controller.Parent = ControllerInitializer
end)

-- INIT SERVICE --
local Service = script.DataService

for attributeName, value in pairs(Settings.Attributes) do
	Service:SetAttribute(attributeName, value)
end

script.Settings.Parent = Service --// Make a copy of the settings for future usage
Service.Parent = Settings.ServiceLocation
require(Service)
