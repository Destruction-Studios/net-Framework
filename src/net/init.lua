---@diagnostic disable: undefined-type
local RunService = game:GetService("RunService")

export type Net = {
    Controller: {},
    Service: {},
    Network:{},
}

local Type = require(script.Comm.Type)

export type NetworkEvent = Type.RemoteEventClass
export type NetworkProperty = Type.PropertyClass

if RunService:IsServer() then
    return require(script.Server)
else
    return require(script.Client)
end