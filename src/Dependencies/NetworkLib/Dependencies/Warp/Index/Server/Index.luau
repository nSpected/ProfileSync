--!strict
--!native
--!optimize 2
local Server = {}
Server.__index = Server

local Players = game:GetService("Players")
local Util = script.Parent.Parent.Util

local Type = require(script.Parent.Parent.Type)
local ServerProcess = require(script.Parent.ServerProcess)
local Assert = require(Util.Assert)
local Key = require(Util.Key)
local Serdes = require(Util.Serdes)
local Buffer = require(Util.Buffer)

function Server.new(Identifier: string, rateLimit: Type.rateLimitArg?)
	local self = setmetatable({}, Server)
	self._buffer = Buffer.new()
	self._buffer:wu8(Serdes(Identifier))
	self.id = Buffer.convert(self._buffer:build())
	self.fn = {}
	self.IsConnected = false
	ServerProcess.add(self.id, Identifier, rateLimit or { maxEntrance = 200, interval = 2 })
	self._buffer:remove()
	return self
end

function Server:Logging(store: boolean, opt: boolean)
	ServerProcess.logger(self.id, store, opt)
	return function()
		return ServerProcess.getlogs(self.id)
	end
end

function Server:Fire(reliable: boolean, player: Player, ...: any)
	ServerProcess.insertQueue(self.id, reliable, player, ...)
end

function Server:Fires(reliable: boolean, ...: any)
	for _, player: Player in ipairs(Players:GetPlayers()) do
		ServerProcess.insertQueue(self.id, reliable, player, ...)
	end
end

function Server:FireExcept(reliable: boolean, except: { Player }, ...: any)
	for _, player: Player in ipairs(Players:GetPlayers()) do
		if table.find(except, player) then continue end
		ServerProcess.insertQueue(self.id, reliable, player, ...)
	end
end

function Server:Invoke(timeout: number, player: Player, ...: any): any
	return ServerProcess.insertRequest(self.id, timeout, player, ...)
end

function Server:Connect(callback: (plyer: Player, args: any) -> ()): string
	local key = tostring(Key())
	table.insert(self.fn, key)
	ServerProcess.addCallback(self.id, key, callback)
	self.IsConnected = #self.fn > 0
	return key
end

function Server:Once(callback: (plyer: Player, args: any) -> ()): string
	local key = tostring(Key())
	table.insert(self.fn, key)
	self.IsConnected = #self.fn > 0
	ServerProcess.addCallback(self.id, key, function(...)
		self:Disconnect(key)
		task.spawn(callback, ...)
	end)
	return key
end

function Server:Wait()
	local thread: thread, t = coroutine.running(), os.clock()
	self:Once(function()
		task.spawn(thread, os.clock()-t)
	end)
	return coroutine.yield()
end

function Server:DisconnectAll()
	for _, key: string in self.fn do
		self:Disconnect(key)
	end
end

function Server:Disconnect(key: string): boolean
	Assert(typeof(key) == "string", "Key must be a string type.")
	ServerProcess.removeCallback(self.id, key)
	table.remove(self.fn, table.find(self.fn, key))
	self.IsConnected = #self.fn > 0
	return table.find(self.fn, key) == nil
end

function Server:Destroy()
	self:DisconnectAll()
	setmetatable(self, nil)
end

return Server.new