-- SERVICES --
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local HttpService = game:GetService('HttpService')
local CollectionService = game:GetService('CollectionService')
local RunService = game:GetService('RunService')

-- DEPENDENCIES --
local Libraries = ReplicatedStorage:WaitForChild('Libraries')
local Promise = require(Libraries:WaitForChild('Promise'))
local NetworkLib = require(Libraries:WaitForChild('NetworkLib'))
local TableUtil = require(Libraries:WaitForChild('TableUtil'))

-- NETWORK --
local DataReplicator: RemoteEvent = NetworkLib.new("DataReplicator", "RemoteEvent")
local DataRequester = NetworkLib.new("DataRequester", "RemoteFunction")

-- SETTINGS --
local _debug: boolean = script:GetAttribute("Debug") or false
local _loadedTag: string = script:GetAttribute('LoadedTag') or "DataLoaded" --// Player data has been loaded on Server
local _initializedTag: string = script:GetAttribute('InitializedTag') or "DataInitialized" --// Data service has been initialized
local _addons: {} = script:GetAttribute('Addons') and HttpService:JSONDecode(script:GetAttribute('Addons')) or {}

-- INTERNAL --
local _profilesBeingUpdated = {}
local _addonsFolder = ReplicatedStorage:FindFirstChild('DataAddons')

local Profiles = {}
local Bindings = {}

-- INTERNAL FUNCTIONS --
function IsPlayerValid(player: Player) : boolean?
	if not player 
		or typeof(player) ~= 'Instance' 
		or not player:IsDescendantOf(Players) 
	then return end
	
	return true
end

function FetchServerProfile(player: Player, usePromise: boolean?, maxAttempts: number?)
	local maxAttempts = maxAttempts or 1000
	local currentAttempt = 1
	_profilesBeingUpdated[player.UserId] = true
	
	if not usePromise then
		local profile = DataRequester:InvokeServer("GetProfile", player)
		if profile == nil then
			repeat
				currentAttempt += 1
				profile = DataRequester:InvokeServer("GetProfile", player)
			until not IsPlayerValid(player) or currentAttempt > maxAttempts or profile ~= nil or Profiles[player.UserId] ~= nil
		end
		
		_profilesBeingUpdated[player.UserId] = nil
		return profile
	end
		
	return Promise.new(function(resolve, reject, onCancel)
		local profile = DataRequester:InvokeServer("GetProfile", player)
		if profile == nil then
			repeat
				currentAttempt += 1
				profile = DataRequester:InvokeServer("GetProfile", player)
			until not IsPlayerValid(player) or currentAttempt > maxAttempts or profile ~= nil or Profiles[player.UserId] ~= nil
		end

		_profilesBeingUpdated[player.UserId] = nil
		resolve(profile)
	end)
end

function UpdatePlayerFromServer(player: Player)
	if not IsPlayerValid(player) then warn(12) return end
	if _profilesBeingUpdated[player.UserId] then warn(43) return end
	
	local fetchPromise = FetchServerProfile(player, true):andThen(function(profile)
		if profile == nil then return end
		local CachedProfile = Profiles[player.UserId] or {}
		Profiles[player.UserId] = profile
	end):catch(warn):finally(function()
		if _debug then warn(player, " data fetch promise has been finished.") end
	end)
	
	player.AncestryChanged:Once(function()
		fetchPromise:cancel()
		_profilesBeingUpdated[player.UserId] = nil
		Profiles[player.UserId] = nil
		
		if Bindings[player.UserId] then
			for dataName, binds : {(any)} in Bindings[player.UserId] do
				Bindings[player.UserId][dataName] = nil
			end
			
			Bindings[player.UserId] = nil
		end
	end)
end

local Controller = {}

-- METHODS --
function Controller:GetProfile(player: Player, timeOut: number?, usePromise: boolean?)
	if not IsPlayerValid(player) then warn('Player: [', player,'] is not ingame!') return end
	
	local profile = Profiles[player.UserId]
	if profile ~= nil and not usePromise then return profile end
	if profile ~= nil and usePromise == true then
		return Promise.new(function(resolve)
			resolve(profile)
		end)
	end
	
	if not usePromise then
		local t = os.clock()
		
		repeat 
			profile = Profiles[player.UserId] 
			task.wait() 
		until (os.clock() - t > (timeOut or 5e10)) or profile ~= nil or not IsPlayerValid(player)
		
		return profile
	else
		return Promise.new(function(resolve, reject, onCancel)
			local t = os.clock()
			local wasCanceled = false
			
			onCancel(function()
				wasCanceled = true
			end)

			repeat 
				profile = Profiles[player.UserId] 
				task.wait() 
			until wasCanceled or (os.clock() - t > (timeOut or 5e10)) or profile ~= nil or not IsPlayerValid(player)
			
			resolve(profile)
		end)
	end
end

function Controller:GetData(player: Player, dataName: string, timeOut: number?, usePromise: boolean?)
	if not IsPlayerValid(player) then warn('Player: [', player,'] is not ingame!') return end
	if not dataName or typeof(dataName) ~= 'string' then warn('[GetData] DataName must be a STRING!') return end
	
	local profile = Profiles[player.UserId]
	
	--// Profile was found, so we return it
	if profile ~= nil and not usePromise then
		return profile 
	elseif profile ~= nil and usePromise == true then
		return Promise.new(function(resolve)
			resolve(profile)
		end)
	end
	
	--// Wait for profile
	if usePromise then
		return Promise.new(function(resolve, reject, onCancel)
			local profile = Controller:GetProfile(player, timeOut, false)
			
			if profile and profile[dataName] then
				resolve(profile[dataName])
			else
				reject()
			end
		end)
	else
		local profile = Controller:GetProfile(player, timeOut, false)
		return profile[dataName]
	end
end

function Controller:Bind(player: Player, dataName: string, callback: (any) -> ())
	if not IsPlayerValid(player) then warn('Player: [', player,'] is not ingame!') return end
	if not dataName or typeof(dataName) ~= 'string' or dataName == "ALL_DATA" then error('[Bind] DataName must be a STRING!') return end
	if not callback or typeof(callback) ~= 'function' then warn('Callback must be a FUNCTION!') return end
	
	if not Bindings[player.UserId] then
		Bindings[player.UserId] = {}
	end
	
	if not Bindings[player.UserId][dataName] then
		Bindings[player.UserId][dataName] = {}
	end

	table.insert(Bindings[player.UserId][dataName], callback)
end

function Controller:BindAll(player: Player, callback: (any) -> ())
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

-- INIT --
for _, player: Player in CollectionService:GetTagged(_loadedTag) do
	UpdatePlayerFromServer(player)
end

CollectionService:GetInstanceAddedSignal(_loadedTag):Connect(function(player: Player)
	UpdatePlayerFromServer(player)
end)

DataReplicator.OnClientEvent:Connect(function(...: any)
	local args = {...}
	
	local player: Player = args[1]
	local dataName: string = args[2]
	local value: any = args[3]
	if not IsPlayerValid(player) then return end
	if not dataName or typeof(dataName) ~= 'string' then return end
	
	local profile = Profiles[player.UserId]
	if not Profiles[player.UserId] then return end
	if profile[dataName] ~= nil and typeof(profile[dataName]) ~= typeof(value) then return end
	
	Profiles[player.UserId][dataName] = value
	
	-- Handle bind
	local playerBindings = Bindings[player.UserId]
	if playerBindings and (playerBindings[dataName]) then
		for _, callback: (any) in playerBindings[dataName] do
			task.spawn(function() callback(value) end)
		end
	end
	
	-- Handle bind all
	if playerBindings and playerBindings['ALL_DATA'] then
		for _, callback: (any) in playerBindings['ALL_DATA'] do
			task.spawn(function() callback(value, dataName) end)
		end
	end
end)

-- // INITIALIZE ADDONS
if _addonsFolder then
	task.defer(function()
		if not workspace:HasTag(_initializedTag) then 
			repeat task.wait() until workspace:HasTag(_initializedTag)
		end

		for addonName, params in _addons do
			local addonModule = _addonsFolder:FindFirstChild(addonName)
			if not addonModule or (not addonModule:GetAttribute("Runtime") or addonModule:GetAttribute("Runtime") ~= 'Client') then continue end
			if addonModule:HasTag('StudioOnly') and not RunService:IsStudio() then continue end

			require(addonModule)(Controller, params)
		end
	end)
end

return Controller
