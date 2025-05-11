local Type = require(script.Parent.Parent.Type)

type RemoteEventClass = Type.RemoteEventClass

local RemoteEventClient = {}
local RemoteEventClientMT = {}
RemoteEventClientMT.__index = RemoteEventClientMT

function RemoteEventClient.new(object): RemoteEventClass
	local self = {}

	self._instance = object
	self.ClientEvent = object.OnClientEvent
	self.ClassName = "NetEvent"

	setmetatable(self, RemoteEventClientMT)
	return self
end

function RemoteEventClientMT.Fire(self: RemoteEventClass, ...)
	self._instance:FireServer(...)
end

return RemoteEventClient
