--!native
--!strict
--!optimize 2
local ServerProcess = {}

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Util = script.Parent.Parent.Util

local Type = require(script.Parent.Parent.Type)
local Event = require(script.Parent.Parent.Event)
local Spawn = require(Util.Spawn)
local Key = require(Util.Key)
local RateLimit = require(Util.RateLimit)
local Buffer = require(Util.Buffer)
local Logger = require(script.Logger)

local serverQueue: Type.QueueMap = {}
local unreliableServerQueue: Type.QueueMap = {}
local serverCallback: Type.CallbackMap = {}
local serverRequestQueue: Type.QueueMap = {}

local queueOut: {
	[Player]: {
		[string]: {any},
	}
} = {}
local queueIn: {
	[string]: {
		[Player]: {any},
	}
} = {}
local queueInRequest: {
	[number]: {
		[string]: {
			[Player]: {any}
		}
	}
} = {}
local queueOutRequest: {
	[number]: {
		[string]: {
			[Player]: {any}
		}
	}
} = {}
local logger: {
	[string]: boolean
} = {}

queueInRequest[1] = {}
queueInRequest[2] = {}
queueOutRequest[1] = {}
queueOutRequest[2] = {}

local ReliableEvent = Event.Reliable
local UnreliableEvent = Event.Unreliable
local RequestEvent = Event.Request

local function initializeEachPlayer(player: Player)
	if not player then return end
	if not queueOut[player] then
		queueOut[player] = {}
	end
	for Identifier: string in serverQueue do
		if not player then break end
		if not queueOut[player][Identifier] then
			queueOut[player][Identifier] = {}
		end
		if not serverRequestQueue[Identifier][player] then
			serverRequestQueue[Identifier][player] = {}
		end
		if not queueIn[Identifier][player] then
			queueIn[Identifier][player] = {}
		end
		if not queueInRequest[1][Identifier][player] then
			queueInRequest[1][Identifier][player] = {}
			queueInRequest[2][Identifier][player] = {}
		end
		if not queueOutRequest[1][Identifier][player] then
			queueOutRequest[1][Identifier][player] = {}
			queueOutRequest[2][Identifier][player] = {}
		end
	end
end

Players.PlayerAdded:Connect(initializeEachPlayer)

function ServerProcess.insertQueue(Identifier: string, reliable: boolean, player: Player, ...: any)
	if not reliable then
		if not unreliableServerQueue[Identifier][player] then
			unreliableServerQueue[Identifier][player] = {}
		end
		table.insert(unreliableServerQueue[Identifier][player], { ... })
		return
	end
	if not serverQueue[Identifier][player] then
		serverQueue[Identifier][player] = {}
	end
	table.insert(serverQueue[Identifier][player], { ... })
end

function ServerProcess.insertRequest(Identifier: string, timeout: number, player: Player, ...: any)
	if not serverQueue[Identifier][player] then
		serverQueue[Identifier][player] = {}
	end
	local yieldThread: thread, start = coroutine.running(), os.clock()
	local cancel = task.delay(timeout, function()
		task.spawn(yieldThread, nil)
	end)
	table.insert(serverRequestQueue[Identifier][player], { tostring(Key()), function(...: any)
		if (os.clock() - start) > timeout then return end
		task.cancel(cancel)
		task.spawn(yieldThread, ...)
	end :: any, { ... } :: any })
	return coroutine.yield()
end

function ServerProcess.add(Identifier: string, originId: string, ratelimit: Type.rateLimitArg)
	if not serverQueue[Identifier] then
		RateLimit.create(originId, ratelimit.maxEntrance or 200, ratelimit.interval or 2)
		serverQueue[Identifier] = {}
		unreliableServerQueue[Identifier] = {}
		serverCallback[Identifier] = {}
		serverRequestQueue[Identifier] = {}
		
		queueIn[Identifier] = {}
		queueInRequest[1][Identifier] = {}
		queueInRequest[2][Identifier] = {}
		queueOutRequest[1][Identifier] = {}
		queueOutRequest[2][Identifier] = {}
		
		for _, player: Player in ipairs(Players:GetPlayers()) do
			task.spawn(initializeEachPlayer, player)
		end
	end
end

function ServerProcess.logger(Identifier: string, store: boolean, log: boolean)
	logger[Identifier] = store
	Logger.write(Identifier, `state: change -> {log == true and "enabled" or "disabled"} logger.`, log)
end

function ServerProcess.getlogs(Identifier: string)
	return Logger.read(Identifier)
end

function ServerProcess.addCallback(Identifier: string, key: string, callback)
	serverCallback[Identifier][key] = callback
	if logger[Identifier] then
		task.defer(Logger.write, Identifier, `state: change -> new callback added.`)
	end
end

function ServerProcess.removeCallback(Identifier: string, key: string)
	serverCallback[Identifier][key] = nil
	if logger[Identifier] then
		task.defer(Logger.write, Identifier, `state: change -> removed a callback.`)
	end
end

function ServerProcess.start()
	RunService.PostSimulation:Connect(function()
		for Identifier: string, players in unreliableServerQueue do
			for player: Player, data: any in players do
				if #data == 0 then continue end
				UnreliableEvent:FireClient(player, Buffer.revert(Identifier), data)
				if logger[Identifier] then
					task.defer(Logger.write, Identifier, `state: out -> unreliable -> {#data} data.`)
				end
				table.clear(data)
			end
		end
		for _, player: Player in ipairs(Players:GetPlayers()) do
			if not queueOut[player] then continue end
			for Identifier: string, data: any in queueOut[player] do
				if #data == 0 then continue end
				ReliableEvent:FireClient(player, Buffer.revert(Identifier), data)
				if logger[Identifier] then
					task.defer(Logger.write, Identifier, `state: out -> reliable -> {#data} data.`)
				end
				table.clear(data)
			end
		end
		for Identifier: string, players in serverQueue do
			local callback = serverCallback[Identifier] or nil
			for player: Player, data in players do
				if #data > 0 and queueOut[player] then
					queueOut[player][Identifier] = table.clone(data)
					table.clear(data)
				end
				if #serverRequestQueue[Identifier][player] > 0 then
					for _, requestData in serverRequestQueue[Identifier][player] do
						if not requestData[3] then continue end
						table.insert(queueOutRequest[1][Identifier][player], { requestData[1], requestData[3] })
						table.remove(requestData, #requestData)
					end
				end
				if callback then
					if #queueIn[Identifier][player] > 0 then
						for _, packedDatas: any in queueIn[Identifier][player] do
							if #packedDatas == 0 then continue end
							for _, fn: any in callback do
								for i=1,math.min(1e3, #packedDatas) do
									Spawn(fn, player, table.unpack(packedDatas[i] or {}))
								end
							end
						end
						table.clear(queueIn[Identifier][player])
					end
					if #queueInRequest[1][Identifier][player] > 0 then
						for idx, packetDatas: any in queueInRequest[1][Identifier][player] do
							if #packetDatas == 0 then continue end
							for _, fn: any in callback do
								for i=1,math.min(1e3, #packetDatas) do
									local packetData = packetDatas[i]
									if not packetData then continue end
									Spawn(function()
										local requestReturn = { fn(player, table.unpack(packetData[2])) }
										table.insert(queueOutRequest[2][Identifier][player], { packetData[1], requestReturn })
									end)
								end
							end
						end
						table.clear(queueInRequest[1][Identifier][player])
					end
					if #queueInRequest[2][Identifier][player] > 0 then
						for _, packetDatas: any in queueInRequest[2][Identifier][player] do
							for idx, packetData in packetDatas do
								if #packetData == 1 then continue end
								for y=1, math.min(1e3, #serverRequestQueue[Identifier][player]) do
									local serverRequest = serverRequestQueue[Identifier][player][y]
									if not serverRequest then continue end
									if serverRequest[1] == packetData[1] then
										Spawn(serverRequest[2], table.unpack(packetData[2]))
										table.remove(packetDatas, idx)
										table.remove(serverRequestQueue[Identifier][player], y)
										break
									end
								end
							end
						end
						table.clear(queueInRequest[2][Identifier][player])
					end
					for player: Player, requestsData: any in queueOutRequest[1][Identifier] do
						if #requestsData == 0 then continue end
						RequestEvent:FireClient(player, Buffer.revert(Identifier), "\1", requestsData)
						if logger[Identifier] then
							task.defer(Logger.write, Identifier, `state: out -> request -> {#requestsData} data.`)
						end
						table.clear(requestsData)
					end
					for player: Player, toReturnDatas: any in queueOutRequest[2][Identifier] do
						if #toReturnDatas == 0 then continue end
						RequestEvent:FireClient(player, Buffer.revert(Identifier), "\0", toReturnDatas)
						if logger[Identifier] then
							task.defer(Logger.write, Identifier, `state: out -> return request -> {#toReturnDatas} data.`)
						end
						table.clear(toReturnDatas)
					end
				end
			end
		end
	end)
	local function onServerNetworkReceive(player: Player, Identifier: any, data: any)
		if not Identifier or not data then return end
		Identifier = Buffer.convert(Identifier)
		if not serverQueue[Identifier] then
			serverQueue[Identifier] = {}
		end
		if not serverQueue[Identifier][player] then
			serverQueue[Identifier][player] = {}
		end
		if not queueIn[Identifier][player] then
			queueIn[Identifier][player] = {}
		end
		if logger[Identifier] then
			task.defer(Logger.write, Identifier, `state: in -> net -> {#data} data.`)
		end
		table.insert(queueIn[Identifier][player], data)
	end
	ReliableEvent.OnServerEvent:Connect(onServerNetworkReceive)
	UnreliableEvent.OnServerEvent:Connect(onServerNetworkReceive)
	RequestEvent.OnServerEvent:Connect(function(player: Player, Identifier: any, action: string, data: any)
		if not Identifier or not data then return end
		Identifier = Buffer.convert(Identifier)
		if not queueInRequest[1][Identifier][player] then
			queueInRequest[1][Identifier][player] = {}
			queueInRequest[2][Identifier][player] = {}
		end
		if not serverQueue[Identifier][player] then
			serverQueue[Identifier][player] = {}
		end
		if action == "\1" then
			table.insert(queueInRequest[1][Identifier][player], data)
		else
			table.insert(queueInRequest[2][Identifier][player], data)
		end
		if logger[Identifier] then
			task.defer(Logger.write, Identifier, `state: in -> request -> {#data} data.`)
		end
	end)
end

for _, player: Player in ipairs(Players:GetPlayers()) do
	task.spawn(initializeEachPlayer, player)
end

return ServerProcess