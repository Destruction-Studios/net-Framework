local Players = game:GetService("Players")

local Type = require(script.Parent.Parent.Type)
local noYield = require(script.Parent.Parent.noYield)

type RemoteEventClass = Type.RemoteEventClass

local RemoteEventServer = {}
local RemoteEventServerMT = {}
RemoteEventServerMT.__index = RemoteEventServerMT

function RemoteEventServer.new(object: RemoteEvent | UnreliableRemoteEvent): RemoteEventClass
	local self = {}

	self._instance = object
	self.ServerEvent = object.OnServerEvent
	self.ClassName = "NetEvent"

	setmetatable(self, RemoteEventServerMT)

	return self
end

function RemoteEventServerMT.GetInstance(self: RemoteEventClass): RemoteEvent
	return self._instance
end

function RemoteEventServerMT.FireAll(self: RemoteEventClass, ...)
	self._instance:FireAllClients(...)
end

function RemoteEventServerMT.FireTo(self: RemoteEventClass, player, ...)
	self._instance:FireClient(player, ...)
end

function RemoteEventServerMT.FireFor(self: RemoteEventClass, players, ...)
	for _, plr in players do
		self:FireTo(plr, ...)
	end
end

function RemoteEventServerMT.FireFilter(self: RemoteEventClass, predicate: () -> boolean, ...)
	for _, plr in Players:GetPlayers() do
		local result = noYield(predicate, plr)
		if result == true then
			self:FireTo(plr, ...)
		end
	end
end

function RemoteEventServerMT.FireExcept(self: RemoteEventClass, except, ...)
	for _, plr in Players:GetPlayers() do
		if plr == except then
			continue
		end
		self:FireTo(plr, ...)
	end
end

return RemoteEventServer
