-- SERVICES --
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local HttpService = game:GetService('HttpService')
local RunService = game:GetService('RunService')

-- DEPENDENCIES --
local Libraries = ReplicatedStorage:WaitForChild('Libraries')
local Promise = require(Libraries:WaitForChild('Promise'))
local NetworkLib = require(Libraries:WaitForChild('NetworkLib'))
local ProfileService = require(Libraries:WaitForChild('ProfileService'))

-- NETWORK --
local DataReplicator: RemoteEvent = NetworkLib.new("DataReplicator", "RemoteEvent")
local DataRequester = NetworkLib.new("DataRequester", "RemoteFunction")

-- SETTINGS --
local _settings = require(script:WaitForChild('Settings'))
local _addons = _settings.Attributes.Addons and HttpService:JSONDecode(_settings.Attributes.Addons) or {}
local _debug: boolean = _settings.Attributes.Debug or false
local _loadedTag: string = _settings.Attributes.LoadedTag or "DataLoaded" --// Player data has been loaded on Server
local _initializedTag: string = _settings.Attributes.InitializedTag or "DataInitialized" --// Data service has been initialized
local _filterStrictness: "Light" | "Heavy" = _settings.FilterStrictness or "Light"

local _filter: {string} = _settings.Filter
local _filterType: 'Blacklist' | 'Whitelist' = _settings.FilterType

-- TYPES --
type IPromise<T> = Promise.Promise<T>
type IProfileData = {[string]: any}
type IProfile = { Data: {[string]: any}, Release: (self: IProfile) -> nil }
type IBinds = { (any) }
type IPlayerBindings = { [string]: IBinds }

-- INTERNAL --
local _DEFAULT_TIMEOUT = 3
local _profilesBeingUpdated = {}
local _addonsFolder = ReplicatedStorage:FindFirstChild('DataAddons')

local Profiles: {IProfile} = {}
local Bindings: {[number]: IPlayerBindings} = {}
local Service = {}

local ProfileStore = not _settings.InDevelopmentEnv and ProfileService.GetProfileStore(_settings.Name, _settings.Structure) 
	or ProfileService.GetProfileStore(_settings.Name, _settings.Structure).Mock

-- INTERNAL FUNCTIONS --
function IsPlayerValid(player: Player?) : boolean?
	if not player 
		or typeof(player) ~= 'Instance' 
		or not player:IsDescendantOf(Players) 
	then return end

	return true
end

function ProcessPlayerBindings(player: Player, dataName: string, value: any)
	-- Handle bind
	local playerBindings: IBinds = Bindings[player.UserId]
	if playerBindings and (playerBindings[dataName]) then
		for _, callback: (any) in playerBindings[dataName] do
			task.spawn(function() 
				callback(value) 
			end)
		end
	end

	-- Handle bind all
	if playerBindings and playerBindings['ALL_DATA'] then
		for _, callback: (any) in playerBindings['ALL_DATA'] do
			task.spawn(function() 
				callback(value, dataName) 
			end)
		end
	end
end

function ShouldReplicate(dataName: string) : boolean
	return ((not _filter or #_filter < 1) and true) or
		(_filterType == 'Blacklist' and table.find(_filter, dataName) and false) or
		(_filterType == 'Whitelist' and not table.find(_filter, dataName) and false) or 
		true
end

function GetFilteredProfileData(data: IProfileData): IProfileData
	local newData = {}
	for dataName, value in data do
		if not ShouldReplicate(dataName) then continue end
		newData[dataName] = value
	end

	return newData
end

function ReplicateSingleDataToClient(replicateTo: Player | 'All', replicateFrom: Player, dataName: string, value: any)
	if not IsPlayerValid(replicateTo) and replicateTo ~= 'All' then return end
	if not IsPlayerValid(replicateFrom) then return end
	if not dataName or typeof(dataName) ~= 'string' then return end
	if not ShouldReplicate(dataName) then return end
	
	if replicateTo == 'All' then
		DataReplicator:FireAllClients(replicateFrom, dataName, value)
	else
		DataReplicator:FireClient(replicateTo, replicateFrom, dataName, value)
	end
end

function GetDataStoreProfile(userId: number, offline: boolean): IPromise<IProfile?>
	return Promise.new(function(resolve, reject, onCancel)
		if Profiles[userId] then 
			resolve(Profiles[userId]) 
			return
		end

		_profilesBeingUpdated[userId] = true
		local profile

		onCancel(function()
			_profilesBeingUpdated[userId] = nil
			if not Profiles[userId] and profile ~= nil then
				profile:Release()
			end
		end)

		profile = ProfileStore:LoadProfileAsync('Player_' .. userId)
		local player = Players:GetPlayerByUserId(userId)

		if not profile then
			if player then
				player:Kick("Data could not be loaded, try again shortly. If the issue persists, please contact the support!")
			end

			_profilesBeingUpdated[userId] = nil
			reject(`Profile for [{userId}] failed to load, might be related to roblox servers.`)
			return
		end

		profile:AddUserId(userId)
		profile:Reconcile()
		
		-- PLAYER JOINED ANOTHER SESSION
		profile:ListenToRelease(function()
			Profiles[userId] = nil

			if player then
				player:Kick("Data has been loaded on another session, please rejoin. If the issue persists, please contact the support!")
			end
		end)
		
		_profilesBeingUpdated[userId] = nil
		if not offline then
			if player and player:IsDescendantOf(Players) then --// In case the player left before getting to this stage, so we check to make sure.
				Profiles[userId] = profile
			else -- If he left, we release his profile.
				profile:Release()
				reject(`Player [{userId}] is not longer in game.`)
			end
		end
		
		if player then
			player:AddTag(_loadedTag)
		end
		
		resolve(profile)
	end)
end

-- EDIT METHODS --
function Service:Add(player: Player, dataName: string, value: number) : number?
	if not IsPlayerValid(player) then warn('[GENERAL] Player: [', player,'] is no longer in game.') return end
	if not Profiles[player.UserId] then warn('[GENERAL] Player: [', player,'] has not been initialized yet, do not try to change his data before it is loaded!') return end
	if not dataName or typeof(dataName) ~= 'string' then warn('[GENERAL]: DataName must be a STRING and NOT NIL!') return end
	if not value or typeof(value) ~= 'number' or value < 0 then warn('[NUMERIC]: Value must be a NUMBER and OVER or EQUAL to 0!') return end
	if Profiles[player.UserId].Data[dataName] == nil then warn('[GENERAL]: Invalid DataName: [', dataName,'], it does not exist on the player data!') return end
	if typeof(Profiles[player.UserId].Data[dataName]) ~= 'number' then warn('[NUMERIC]: Invalid DataName Type: [', dataName,'], it is not a number!') return end
	
	local success, err = pcall(function()
		Profiles[player.UserId].Data[dataName] += value
	end)

	if success then
		ReplicateSingleDataToClient('All', player, dataName, Profiles[player.UserId].Data[dataName])
		ProcessPlayerBindings(player, dataName, Profiles[player.UserId].Data[dataName])
	else
		warn('[FATAL ERROR]: Failed during [Add] -- Error:', err)
	end
	
	return Profiles[player.UserId].Data[dataName]
end

function Service:Sub(player: Player, dataName: string, value: number) : number?
	if not IsPlayerValid(player) then warn('[GENERAL] Player: [', player,'] is no longer in game.') return end
	if not Profiles[player.UserId] then warn('[GENERAL] Player: [', player,'] has not been initialized yet, do not try to change his data before it is loaded!') return end
	if not dataName or typeof(dataName) ~= 'string' then warn('[GENERAL]: DataName must be a STRING and NOT NIL!') return end
	if not value or typeof(value) ~= 'number' or value < 0 then warn('[NUMERIC]: Value must be a NUMBER and OVER or EQUAL to 0!') return end
	if Profiles[player.UserId].Data[dataName] == nil then warn('[GENERAL]: Invalid DataName: [', dataName,'], it does not exist on the player data!') return end
	if typeof(Profiles[player.UserId].Data[dataName]) ~= 'number' then warn('[NUMERIC]: Invalid DataName Type: [', dataName,'], it is not a number!') return end

	local success, err = pcall(function()
		Profiles[player.UserId].Data[dataName] -= value
	end)

	if success then
		ReplicateSingleDataToClient('All', player, dataName, Profiles[player.UserId].Data[dataName])
		ProcessPlayerBindings(player, dataName, Profiles[player.UserId].Data[dataName])
	else
		warn('[FATAL ERROR]: Failed during [Sub] -- Error:', err)
	end

	return Profiles[player.UserId].Data[dataName]
end

function Service:Set(player: Player, dataName: string, value: any) : any
	if not IsPlayerValid(player) then warn('[GENERAL] Player: [', player,'] is no longer in game.') return end
	if not Profiles[player.UserId] then warn('[GENERAL] Player: [', player,'] has not been initialized yet, do not try to change his data before it is loaded!') return end
	if not dataName or typeof(dataName) ~= 'string' then warn('[GENERAL]: DataName must be a STRING and NOT NIL!') return end

	local success, err = pcall(function()
		Profiles[player.UserId].Data[dataName] = value
	end)

	if success then
		ReplicateSingleDataToClient('All', player, dataName, value)
		ProcessPlayerBindings(player, dataName, value)
	else
		warn('[FATAL ERROR]: Failed during [Set] -- Error:', err)
	end

	return Profiles[player.UserId].Data[dataName]
end

function Service:ArrayInsert(player: Player, dataName: string, value: any) : {any}?
	if not IsPlayerValid(player) then warn('[GENERAL] Player: [', player,'] is no longer in game.') return end
	if not Profiles[player.UserId] then warn('[GENERAL] Player: [', player,'] has not been initialized yet, do not try to change his data before it is loaded!') return end
	if not dataName or typeof(dataName) ~= 'string' then warn('[GENERAL]: DataName must be a STRING and NOT NIL!') return end
	if typeof(Profiles[player.UserId].Data[dataName]) ~= 'table' then warn('[ARRAY] Invalid Data Type: [', dataName,'] is not a table!') return end

	local success, err = pcall(function()
		table.insert(Profiles[player.UserId].Data[dataName], value) 
	end)

	if success then
		ReplicateSingleDataToClient('All', player, dataName, Profiles[player.UserId].Data[dataName])
		ProcessPlayerBindings(player, dataName, Profiles[player.UserId].Data[dataName])
	else
		warn('[FATAL ERROR]: Failed during [ArrayInsert] -- Error:', err)
	end

	return Profiles[player.UserId].Data[dataName]
end

function Service:ArrayRemove(player: Player, dataName: string, index: number) : {any}?
	if not IsPlayerValid(player) then warn('[GENERAL] Player: [', player,'] is no longer in game.') return end
	if not Profiles[player.UserId] then warn('[GENERAL] Player: [', player,'] has not been initialized yet, do not try to change his data before it is loaded!') return end
	if not dataName or typeof(dataName) ~= 'string' then warn('[GENERAL]: DataName must be a STRING and NOT NIL!') return end
	if typeof(Profiles[player.UserId].Data[dataName]) ~= 'table' then warn('[ARRAY] Invalid Data Type: [', dataName,'] is not a table!') return end

	local success, err = pcall(function()
		table.remove(Profiles[player.UserId].Data[dataName], index) 
	end)
	
	if success then
		ReplicateSingleDataToClient('All', player, dataName, Profiles[player.UserId].Data[dataName])
		ProcessPlayerBindings(player, dataName, Profiles[player.UserId].Data[dataName])
	else
		warn('[FATAL ERROR]: Failed during [ArrayRemove] -- Error:', err)
	end

	return Profiles[player.UserId].Data[dataName]
end

function Service:ArraySet(player: Player, dataName: string, value: any) : {any}?
	if not IsPlayerValid(player) then warn('[GENERAL] Player: [', player,'] is no longer in game.') return end
	if not Profiles[player.UserId] then warn('[GENERAL] Player: [', player,'] has not been initialized yet, do not try to change his data before it is loaded!') return end
	if not dataName or typeof(dataName) ~= 'string' then warn('[GENERAL]: DataName must be a STRING and NOT NIL!') return end
	if typeof(Profiles[player.UserId].Data[dataName]) ~= 'table' then warn('[ARRAY] Invalid Data Type: [', dataName,'] is not a table!') return end

	local success, err = pcall(function()
		Profiles[player.UserId].Data[dataName] = value 
	end)

	if success then
		ReplicateSingleDataToClient('All', player, dataName, Profiles[player.UserId].Data[dataName])
		ProcessPlayerBindings(player, dataName, Profiles[player.UserId].Data[dataName])
	else
		warn('[FATAL ERROR]: Failed during [ArraySet] -- Error:', err)
	end

	return Profiles[player.UserId].Data[dataName]
end

function Service:DictionaryInsert(player: Player, dataName: string, value: any, index: string | number) : {any}?
	if not IsPlayerValid(player) then warn('[GENERAL] Player: [', player,'] is no longer in game.') return end
	if not Profiles[player.UserId] then warn('[GENERAL] Player: [', player,'] has not been initialized yet, do not try to change his data before it is loaded!') return end
	if not dataName or typeof(dataName) ~= 'string' then warn('[GENERAL]: DataName must be a STRING and NOT NIL!') return end
	if typeof(Profiles[player.UserId].Data[dataName]) ~= 'table' then warn('[DICTIONARY] Invalid Data Type: [', dataName,'] is not a table!') return end
	if not index or (typeof(index) ~= 'number' and typeof(index) ~= 'string') then warn('[DICTIONARY] Invalid Parameter: [INDEX] MUST be a STRING or NUMBER!') return end
	
	local success, err = pcall(function()
		Profiles[player.UserId].Data[dataName][index] = value
	end)

	if success then
		ReplicateSingleDataToClient('All', player, dataName, Profiles[player.UserId].Data[dataName])
		ProcessPlayerBindings(player, dataName, Profiles[player.UserId].Data[dataName])
	else
		warn('[FATAL ERROR]: Failed during [DictionaryInsert] -- Error:', err)
	end

	return Profiles[player.UserId].Data[dataName]
end

function Service:DictionaryRemove(player: Player, dataName: string, index: string | number) : {any}?
	if not IsPlayerValid(player) then warn('[GENERAL] Player: [', player,'] is no longer in game.') return end
	if not Profiles[player.UserId] then warn('[GENERAL] Player: [', player,'] has not been initialized yet, do not try to change his data before it is loaded!') return end
	if not dataName or typeof(dataName) ~= 'string' then warn('[GENERAL]: DataName must be a STRING and NOT NIL!') return end
	if typeof(Profiles[player.UserId].Data[dataName]) ~= 'table' then warn('[DICTIONARY] Invalid Data Type: [', dataName,'] is not a table!') return end
	if not index or (typeof(index) ~= 'number' and typeof(index) ~= 'string') then warn('[DICTIONARY] Invalid Parameter: [INDEX] MUST be a STRING or NUMBER!') return end

	local success, err = pcall(function()
		Profiles[player.UserId].Data[dataName][index] = nil
	end)

	if success then
		ReplicateSingleDataToClient('All', player, dataName, Profiles[player.UserId].Data[dataName])
		ProcessPlayerBindings(player, dataName, Profiles[player.UserId].Data[dataName])
	else
		warn('[FATAL ERROR]: Failed during [DictionaryRemove] -- Error:', err)
	end

	return Profiles[player.UserId].Data[dataName]
end

-- FETCH METHODS --
function Service:GetProfile(player: Player | number, timeOut: number?, offline: boolean?): IProfileData?
	local userId = typeof(player) == 'number' and player or player.UserId
	local profile: IProfile? = Profiles[userId]
	if profile and profile.Data then 
		return profile.Data
	end

	if not _profilesBeingUpdated[userId] and offline then
		local serverProfile: IProfile? = GetDataStoreProfile(userId, true):expect()
		if not serverProfile or not serverProfile.Data then return nil, `Failed to load [{userId}]'s profile from a remote server!` end

		return serverProfile.Data
	end

	local t = os.clock()

	repeat 
		profile = Profiles[player.UserId] 
		task.wait() 
	until (profile and profile.Data) or not IsPlayerValid(player) or (os.clock() - t > (timeOut or _DEFAULT_TIMEOUT))

	if not IsPlayerValid(player) then
		return nil, `Player is no longer in game!`
	end

	if os.clock() - t > (timeOut or _DEFAULT_TIMEOUT) then
		return nil, `Data could not be loaded in the given time window [{timeOut or _DEFAULT_TIMEOUT}]!`
	end

	return profile.Data
end

function Service:GetProfileAsync(player: Player | number, timeOut: number?, offline: boolean?): IPromise<IProfileData>
	local userId = typeof(player) == 'number' and player or player.UserId
	local profile: IProfile? = Profiles[userId]
	if profile and profile.Data then
		return Promise.resolve(profile.Data)
	end

	if not _profilesBeingUpdated[userId] and offline then
		return GetDataStoreProfile(userId, offline):andThen(function(profile: IProfile)
			if not profile or not profile.Data then return Promise.reject(`Failed to load [{userId}]'s profile from a remote server!`) end
			return Promise.resolve(profile.Data)
		end)
	end

	return Promise.new(function(resolve, reject)
		local t = os.clock()
		
		repeat 
			profile = Profiles[userId] 
			task.wait() 
		until (profile and profile.Data) or not IsPlayerValid(player) or (os.clock() - t > (timeOut or _DEFAULT_TIMEOUT))

		if not IsPlayerValid(player) then
			reject(`Player is no longer in game.`)
			return
		end

		if os.clock() - t > (timeOut or _DEFAULT_TIMEOUT) then
			reject(`Profile took longer than {timeOut or _DEFAULT_TIMEOUT} to load`)
			return
		end

		resolve(profile.Data)
	end)
end

function Service:GetData<T>(player: Player, dataName: string, timeOut: number?): T?
	local profile = Profiles[player.UserId]

	--// Profile was found, so we return it
	if profile ~= nil then
		return profile.Data and profile.Data[dataName]
	end

	--// Wait for profile
	profile = Service:GetProfile(player, timeOut)
	return profile and profile.Data and profile.Data[dataName]
end

function Service:GetDataAsync<T>(player: Player, dataName: string, timeOut: number?): IPromise<T?>
	local profile = Profiles[player.UserId]
	if profile and profile.Data then
		return Promise.resolve(profile.Data[dataName])
	end

	return Promise.new(function(resolve, reject)
		profile = Service:GetProfileAsync(player, timeOut):expect()

		if profile and profile.Data and profile.Data[dataName] then
			resolve(profile.Data[dataName])
		else
			reject(`Data [{dataName}] of player [{player}] could not be loaded!`)
		end
	end)
end

-- LISTENER METHODS --
function Service:Bind(player: Player, dataName: string, callback: (any) -> ())
	if not IsPlayerValid(player) then warn('Player: [', player,'] is not valid!') return end
	if not dataName or typeof(dataName) ~= 'string' or dataName == "ALL_DATA" then error('DataName must be a STRING!') return end
	if not callback or typeof(callback) ~= 'function' then warn('Callback must be a FUNCTION!') return end

	if not Bindings[player.UserId] then
		Bindings[player.UserId] = {}
	end

	if not Bindings[player.UserId][dataName] then
		Bindings[player.UserId][dataName] = {}
	end

	table.insert(Bindings[player.UserId][dataName], callback)
end

function Service:BindAll(player: Player, callback: (any) -> ())
	if not IsPlayerValid(player) then warn('Player: [', player,'] is not valid!') return end
	if not callback or typeof(callback) ~= 'function' then warn('Callback must be a FUNCTION!') return end

	if not Bindings[player.UserId] then
		Bindings[player.UserId] = {}
	end

	if not Bindings[player.UserId]['ALL_DATA'] then
		Bindings[player.UserId]['ALL_DATA'] = {}
	end

	table.insert(Bindings[player.UserId]['ALL_DATA'], callback)
end

-- RELEASE PROFILE
function Service:ReleaseProfileAsync(userId: number)
	if not Profiles[userId] then
		return
	end

	Profiles[userId]:Release()
end

-- INIT --
local function initPlayer(player: Player)
	local t = os.clock()
	
	local loadPromise = GetDataStoreProfile(player.UserId):andThen(function(profile: IProfile)
		if _debug then 
			warn(player, " | Data Loaded - Load Time: ", string.sub(tostring(os.clock() - t), 1, 6), profile.Data) 
		end
	end):catch(warn)
	
	player.AncestryChanged:Once(function()
		loadPromise:cancel()
		_profilesBeingUpdated[player.UserId] = nil
		if Profiles[player.UserId] then
			Profiles[player.UserId]:Release()
			Profiles[player.UserId] = nil
		end

		if Bindings[player.UserId] then
			for dataName, _ : {(any)} in Bindings[player.UserId] do
				Bindings[player.UserId][dataName] = nil
			end

			Bindings[player.UserId] = nil
		end
		
		warn(Profiles)
		warn(Bindings)
	end)
end

for _, player: Player in ipairs(Players:GetPlayers()) do
	initPlayer(player)
end

Players.PlayerAdded:Connect(function(player: Player)
	initPlayer(player)
end)

workspace:AddTag(_initializedTag)

-- // INITIALIZE ADDONS
if _addonsFolder then
	task.defer(function()
		for addonName, params in _addons do
			local addonModule = _addonsFolder:FindFirstChild(addonName)
			if not addonModule or (not addonModule:GetAttribute("Runtime") or addonModule:GetAttribute("Runtime") ~= 'Server') then continue end
			if addonModule:HasTag('StudioOnly') and not RunService:IsStudio() then continue end

			require(addonModule)(Service, params)
		end
	end)
end

DataRequester.OnServerInvoke:Connect(function(requester: Player, action: string, ...)
	local args = {...}
	
	if action == 'GetProfile' then
		local player: Player? = args[1]
		if not IsPlayerValid(player) then return end
		if _filterStrictness == "Heavy" and player.UserId ~= requester.UserId then return end

		local profile = Service:GetProfile(player, 5)
		return profile and GetFilteredProfileData(profile)
	end

    return
end)

return Service
