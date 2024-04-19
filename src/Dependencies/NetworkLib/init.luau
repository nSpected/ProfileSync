--// Made by @InKrnl due to high doses of stress with other network libraries...
-- SERVICES --
local RunService = game:GetService("RunService")

-- DEPENDENCIES --
local Warp = require(script:WaitForChild('Dependencies'):WaitForChild('Warp'))

-- FOLDERS --
local Objects = script:WaitForChild('Objects')

-- TYPES --
export type rateLimitArg = {
	maxEntrance: number?,
	interval: number?,
}

-- CONSTANTS --
local BindableEventPrefix = 'BE_'
local BindableFunctionPrefix = 'BF_'

-- MAIN --
local Network = {}
Network.__index = Network

local function checkType(Type : string?) : boolean
	if not Type then return false end
	if Type == 'RemoteEvent' then return true end
	if Type == 'RemoteFunction' then return true end
	if Type == 'BindableEvent' then return true end
	if Type == 'BindableFunction' then return true end
	if Type == 'UnreliableRemoteEvent' then return true end
	
	return false
end

function Network.new(Identifier : string, Type : 'RemoteEvent' | 'RemoteFunction' | 'BindableEvent' | 'BindableFunction' | 'UnreliableRemoteEvent' | nil, RateLimit : rateLimitArg?)
	if not Identifier or typeof(Identifier) ~= 'string' then warn('[ERROR][Network] Invalid Identifier!', Identifier) return end
	if not checkType(Type) then
		Type = 'RemoteEvent'
	end
	
	local self = setmetatable({}, Network)
	local Event = (Type == 'RemoteEvent' or Type == 'RemoteFunction' or Type == 'UnreliableRemoteEvent') and 
		(RunService:IsClient() and Warp.Client(Identifier) or Warp.Server(Identifier, RateLimit)) or nil

	if Type == 'RemoteEvent' or Type == 'UnreliableRemoteEvent' then
		
		if RunService:IsClient() then	
			function self:FireServer(...)
				Event:Fire(true, ...)
			end
			
			self.OnClientEvent = Event
		else
			function self:FireClient(Player : Player, ...)
				Event:Fire(true, Player, ...)
			end
			
			function self:FireAllClients(...)
				Event:Fires(true, ...)
			end
			
			self.OnServerEvent = Event
		end
		
	elseif Type == 'RemoteFunction' then
		
		if RunService:IsClient() then
			function self:InvokeServer(...)
				return Event:Invoke(30, ...)
			end
			
			self.OnClientInvoke = Event
		else
			function self:InvokeClient(Player : Player, ...)
				return Event:Invoke(5, Player, ...)
			end
			
			self.OnServerInvoke = Event
		end
		
	elseif Type == 'BindableEvent' then
		local Prefix = BindableEventPrefix
		
		Event = (RunService:IsClient() and Objects:WaitForChild(Prefix .. Identifier))
		if not Event then
			Event = Instance.new(Type)
			Event.Name = Prefix .. Identifier
			Event.Parent = Objects
		end
		
		function self:Fire(...)
			Event:Fire(...)
		end
		
		self.Event = Event.Event
	elseif Type == 'BindableFunction' then
		local Prefix = BindableFunctionPrefix

		Event = (RunService:IsClient() and Objects:WaitForChild(Prefix .. Identifier))
		if not Event then
			Event = Instance.new(Type)
			Event.Name = Prefix .. Identifier
			Event.Parent = Objects
		end

		function self:Invoke(...)
			Event:Invoke(...)
		end

		self.OnInvoke = Event.OnInvoke
	end
	
	return self
end

return Network
