local AddonTypes = require(script.AddonTypes) --// Will error if not getting from the rbxm file.

--// This is your data structure, you should change it to fit your game needs.
--// This is the same as a SaveStructure in ProfileService.
local STRUCTURE = {
	Preferences = {
		Music = true,
		SFX = true
	},
	
	EXP = 0,
	MaxEXP = 100,
	Coins = 0,
	
	Passes = {},
}
--// ─────────────────────────────────────────────────────────────── //--

--// Changing the version will change the game's datastore scope, so be aware.
--// tl;dr it will cause data loss.
local DATA_VERSION: number = 1

--// This makes so that the datastore used in Studio is different than the one in the actual game.
local DEVELOPMENT_ENVIRONMENT: boolean = (game:GetService('RunService'):IsStudio() and true) or false

--// Whitelist makes so that it only replicates the data inside REPLICATION_FILTER.
--// Blacklist makes so that it replicates all player data, but the ones inside REPLICATION_FILTER.
local FILTER_TYPE: "Blacklist" | "Whitelist" = "Blacklist"

--// Array of strings, put the name of the Data that you want to filter.
local FILTER_LIST = {}

--// Dictionary of addons, it might not work very well yet, so keep it empty for now.
--// You can see more about it in the official documentation: 
--// https://docs.inkrnl.com/projects/profilesync/addons
local ADDONS: AddonTypes.Addons = {
	Attributes = true,
	Leaderstats = {
		dataToShow = {'Coins'}
	}
}

return {
	["Name"] = "PlayerData_".. DATA_VERSION .. "_" .. ((DEVELOPMENT_ENVIRONMENT and "DEV") or "PRODUCTION"),
	["InDevelopmentEnv"] = DEVELOPMENT_ENVIRONMENT,
	["Version"] = DATA_VERSION,
	["Structure"] = STRUCTURE,
	["FilterType"] = FILTER_TYPE,
	["Filter"] = FILTER_LIST,
	
	--// Should not be changed, but I won't stop you.
	["Attributes"] = {
		["Debug"] = true,
		["LoadedTag"] = "Data_Loaded",
		["InitializedTag"] = "Data_Initialized",
		["Addons"] = game:GetService('HttpService'):JSONEncode(ADDONS)
	},
	
	--// You can change these if you want, just remember to keep the controller accessible to the client.
	["ControllerLocation"] = game:GetService('ReplicatedStorage'), 
	["ServiceLocation"] = game:GetService('ServerScriptService'),
}
