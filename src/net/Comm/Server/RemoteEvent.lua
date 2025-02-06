local Players = game:GetService("Players")

local Type = require(script.Parent.Parent.Type)
local noYield = require(script.Parent.Parent.noYield)

type RemoteEventClass = Type.RemoteEventClass

local RemoteEventServer = {}
local RemoteEventServerMT = {}
RemoteEventServerMT.__index = RemoteEventServerMT

function RemoteEventServer.new(object:RemoteEvent|UnreliableRemoteEvent):RemoteEventClass
    local self = {}

    self._instance = object

    setmetatable(self, RemoteEventServerMT)

    return self
end

function RemoteEventServerMT.GetInstance(self:RemoteEventClass):RemoteEvent
    return self._instance
end

function RemoteEventServerMT.FireAll(self:RemoteEventClass, args)
    self._instance:FireAllClients(args)
end

function RemoteEventServerMT.FireTo(self:RemoteEventClass, player, args)
    self._instance:FireClient(player, args)
end

function RemoteEventServerMT.FireFor(self:RemoteEventClass, players, args)
    for _, plr in players do
        self:FireTo(plr, args)
    end
end

function RemoteEventServerMT.FireFilter(self:RemoteEventClass, predicate:()->boolean, args)
    for _, plr in Players:GetPlayers() do
        local result = noYield(predicate, plr)
        if result == true then
            self:FireTo(plr, args)
        end
    end
end

function RemoteEventServerMT.FireExcept(self:RemoteEventClass, except, args)
    for _, plr in Players:GetPlayers() do
        if plr == except then
            continue
        end
        self:FireTo(plr, args)
    end
end

return RemoteEventServer