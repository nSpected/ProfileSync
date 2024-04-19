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

-- NETWORK --
local DataReplicator: RemoteEvent = NetworkLib.new("DataReplicator", "RemoteEvent")
local DataRequester = NetworkLib.new("DataRequester", "RemoteFunction")

-- SETTINGS --
local _debug: boolean = script:GetAttribute("Debug") or false
local _loadedTag: string = script:GetAttribute('LoadedTag') or "DataLoaded" --// Player data has been loaded on Server
local _initializedTag: string = script:GetAttribute('InitializedTag') or "DataInitialized" --// Data service has been initialized
local _filterStrictness: "Light" | "Heavy" = script:GetAttribute('FilterStrictness') or "Light"
local _addons: {} = script:GetAttribute('Addons') and HttpService:JSONDecode(script:GetAttribute('Addons')) or {}

-- TYPES --
type IPromise<T> = Promise.Promise<T>
type IProfileData = {[string]: any}
type IBinds = { (any) }
type IPlayerBindings = { [string]: IBinds }

-- INTERNAL --
local _DEFAULT_TIMEOUT = 3
local _profilesBeingUpdated: {[number]: boolean} = {}
local _addonsFolder = ReplicatedStorage:FindFirstChild('DataAddons')

local Profiles: {IProfileData} = {}
local Bindings: {[number]: IPlayerBindings} = {}

-- INTERNAL FUNCTIONS --
function IsPlayerValid(player: Player) : boolean?
	if not player 
		or typeof(player) ~= 'Instance' 
		or not player:IsDescendantOf(Players) 
	then return end
	
	return true
end

function FetchServerProfile(player: Player, maxAttempts: number?): IPromise<IProfileData?>
	return Promise.new(function(resolve, reject, onCancel)
		if _filterStrictness == "Heavy" and player.UserId ~= Players.LocalPlayer.UserId then 
			reject("You're not allowed to see another player's data!") 
			return 
		end

		if not maxAttempts or typeof(maxAttempts) ~= 'number' or maxAttempts < 0 then
			maxAttempts = 1000
		end

		local currentAttempt = 1
		_profilesBeingUpdated[player.UserId] = true
		onCancel(function()
			_profilesBeingUpdated[player.UserId] = nil
		end)

		local profile = DataRequester:InvokeServer("GetProfile", player)
		if profile == nil then
			repeat
				currentAttempt += 1
				profile = DataRequester:InvokeServer("GetProfile", player)
			until not IsPlayerValid(player) or currentAttempt > maxAttempts or profile ~= nil or Profiles[player.UserId] ~= nil
		end

		_profilesBeingUpdated[player.UserId] = nil
		if not IsPlayerValid(player) then
			reject("Player is no longer in game.")
		elseif currentAttempt > maxAttempts then
			reject(`Could not fetch profile as it already exceeded the max amount of attempts allowed [{maxAttempts}].`)
		end

		resolve(profile)
	end)
end

function UpdatePlayerFromServer(player: Player)
	if not IsPlayerValid(player) then return end
	if _filterStrictness == "Heavy" and player.UserId ~= Players.LocalPlayer.UserId then return end
	if _profilesBeingUpdated[player.UserId] then return end
	
	local fetchPromise = FetchServerProfile(player, true):andThen(function(profile)
		if not profile then return end
		Profiles[player.UserId] = profile
	end):catch(warn):finally(function()
		if _debug then 
            warn(player, "data fetch promise has been finished.") 
        end
	end)
	
	player.AncestryChanged:Once(function()
		fetchPromise:cancel()
		_profilesBeingUpdated[player.UserId] = nil
		Profiles[player.UserId] = nil
		
		if Bindings[player.UserId] then
			for dataName, _ : {(any)} in Bindings[player.UserId] do
				Bindings[player.UserId][dataName] = nil
			end
			
			Bindings[player.UserId] = nil
		end
	end)
end

local Controller = {}

-- METHODS --
function Controller:GetProfile(player: Player, timeOut: number?): IProfileData?
	if not IsPlayerValid(player) then 
        return nil, 'Player is not ingame!'
    end
	
	local profile = Profiles[player.UserId]
	if profile ~= nil then return profile end
	
	local t = os.clock()
		
	repeat 
		profile = Profiles[player.UserId] 
		task.wait() 
	until (os.clock() - t > (timeOut or _DEFAULT_TIMEOUT)) or profile ~= nil or not IsPlayerValid(player)

	if os.clock() - t > (timeOut or _DEFAULT_TIMEOUT) then
		return nil, `Data could not be found in the given time window [{timeOut or _DEFAULT_TIMEOUT}]!`
	end

	if not IsPlayerValid(player) then
		return nil, `Player in no longer in game!`
	end

	return profile
end

function Controller:GetProfileAsync(player: Player, timeOut: number?): IPromise<IProfileData>
	return Promise.new(function(resolve, reject, onCancel)
		if not IsPlayerValid(player) then 
			reject('Player is not ingame anymore!') 
			return 
		end
		
		local profile = Profiles[player.UserId]
		if profile ~= nil then
			resolve(profile)
			return 
		end
		
		local t = os.clock()
		local wasCanceled = false
		
		onCancel(function()
			wasCanceled = true
		end)

		repeat 
			profile = Profiles[player.UserId] 
			task.wait() 
		until wasCanceled or (os.clock() - t > (timeOut or _DEFAULT_TIMEOUT)) or profile ~= nil or not IsPlayerValid(player)
		
		if wasCanceled then
			reject("Promise was canceled!")
			return
		end

		if os.clock() - t > (timeOut or _DEFAULT_TIMEOUT) then
			reject(`Data could not be found in the given time window [{timeOut or _DEFAULT_TIMEOUT}]!`)
			return
		end

		if not IsPlayerValid(player) then
			reject(`Player in no longer in game!`)
			return
		end

		resolve(profile)
	end)
end

function Controller:GetData<T>(player: Player, dataName: string, timeOut: number?): T?
	if not IsPlayerValid(player) then 
        return nil, 'Player is not ingame!'
    end

	if not dataName or typeof(dataName) ~= 'string' then 
        return nil, `[GetData] DataName must be a STRING!`
    end
	
	local profile = Controller:GetProfile(player, timeOut)
	if not profile then
		return nil, `[{player}]'s Profile could not be found!`
	end

	return profile[dataName]
end

function Controller:GetDataAsync<T>(player: Player, dataName: string, timeOut: number?): IPromise<T?>
	return Promise.new(function(resolve, reject)
		if not IsPlayerValid(player) then 
			reject('Player is not ingame!') 
			return 
		end
	
		if not dataName or typeof(dataName) ~= 'string' then 
			reject('[GetData] DataName must be a STRING!') 
			return 
		end
		
		local profile = Controller:GetProfileAsync(player, timeOut):expect()
		if not profile then
			reject(`Profile could not be loaded!`)
			return
		end
		
		resolve(profile[dataName])
	end)
end

function Controller:Bind(player: Player, dataName: string, callback: (any) -> ())
	if not IsPlayerValid(player) then 
        warn('Player: [', player,'] is not ingame!') 
        return 
    end

	if not dataName or typeof(dataName) ~= 'string' or dataName == "ALL_DATA" then 
        error('[Bind] DataName must be a STRING!') 
        return 
    end

	if not callback or typeof(callback) ~= 'function' then 
        warn('Callback must be a FUNCTION!') 
        return 
    end
	
	if not Bindings[player.UserId] then
		Bindings[player.UserId] = {}
	end
	
	if not Bindings[player.UserId][dataName] then
		Bindings[player.UserId][dataName] = {}
	end

	table.insert(Bindings[player.UserId][dataName], callback)
end

function Controller:BindAll(player: Player, callback: (any) -> ())
	if not IsPlayerValid(player) then 
        warn('Player: [', player,'] is not valid!') 
        return 
    end

	if not callback or typeof(callback) ~= 'function' then 
        warn('Callback must be a FUNCTION!') 
        return 
    end

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
	if not Profiles[player.UserId] then return end
	
	Profiles[player.UserId][dataName] = value
	
	-- Handle bind
	local playerBindings = Bindings[player.UserId]
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
end)

-- // INITIALIZE ADDONS
if _addonsFolder then
	task.defer(function()
		if not workspace:HasTag(_initializedTag) then 
			repeat task.wait() 
            until workspace:HasTag(_initializedTag)
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
