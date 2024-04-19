local AddonTypes = require(script.AddonTypes)

--// This is your data structure, you should change it to fit your game needs.
--// This is the same as a SaveStructure in ProfileService.
local STRUCTURE = {
	Preferences = {
		Trading = "All", --// All, Friends, None
		Music = true,
		SFX = true
	},
	
	Level = 1,
	EXP = 0,
	MaxEXP = 100,
	
	Coins = 0,
	Gems = 50,
	
	Strength = 0,
	Magic = 0,
	Defense = 0,
	
	Inventory = {},
	InventoryCapacity = 100,
	
	Weapon = "None",
	Spells = {},
	
	Helmet = "None",
	Chestplate = "None",
	Legwear = "None",
	
	Vanity = {
		Weapon = "None",
		Helmet = "None",
		Chestplate = "None",
		Legwear = "None",
	},
	
	Passes = {},
	Boosters = {},
	
	LastJoin = -1,
	LoginStreak = 0,
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
local FILTER_LIST = {
	'Boosters',
	'Gamepasses'
}

--// "Light": Each player's data is shared among all players in the game.
--// "Heavy": Only the player who owns the data will have access to it.
local FILTER_STRICTNESS: "Light" | "Heavy" = "Light"

--// Dictionary of addons, it might not work very well yet, so keep it empty for now.
--// You can see more about it in the official documentation: 
--// https://docs.inkrnl.com/projects/profilesync/addons
local ADDONS: AddonTypes.Addons = {
	Attributes = true,
	Leaderstats = {
		dataToShow = {'EXP', 'MaxEXP', 'Level'}
	}
}

return {
	["Name"] = "PlayerData_".. DATA_VERSION .. "_" .. ((DEVELOPMENT_ENVIRONMENT and "DEV") or "PRODUCTION"),
	["InDevelopmentEnv"] = DEVELOPMENT_ENVIRONMENT,
	["Version"] = DATA_VERSION,
	["Structure"] = STRUCTURE,
	["FilterType"] = FILTER_TYPE,
	["Filter"] = FILTER_LIST,
	["FilterStrictness"] = FILTER_STRICTNESS,
	
	--// Should not be changed, but I won't stop you.
	["Attributes"] = {
		["Debug"] = true,
		["LoadedTag"] = "Data_Loaded",
		["InitializedTag"] = "Data_Initialized",
		["FilterStrictness"] = FILTER_STRICTNESS,
		["Addons"] = game:GetService('HttpService'):JSONEncode(ADDONS)
	},
	
	--// You can change these if you want, just remember to keep the controller accessible to the client.
	["ControllerLocation"] = game:GetService('ReplicatedStorage'), 
	["ServiceLocation"] = game:GetService('ServerScriptService'),
}
