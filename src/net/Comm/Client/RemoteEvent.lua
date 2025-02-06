
local Type = require(script.Parent.Parent.Type)

type RemoteEventClass = Type.RemoteEventClass

local RemoteEventClient = {}
local RemoteEventClientMT = {}
RemoteEventClientMT.__index = RemoteEventClientMT

function RemoteEventClient.new(object)
    local self = {}

    self._instance = object
    self.ClientEvent = object.OnClientEvent

    setmetatable(self, RemoteEventClientMT)
    return self
end

function RemoteEventClientMT.Fire(self:RemoteEventClass, args)
    self._instance:FireServer(args)
end

return RemoteEventClient