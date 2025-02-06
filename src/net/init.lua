local RunService = game:GetService("RunService")

export type Net = {
    Controller: {},
    Service: {},
    Network:{},
}

local Net:Net = {}

Net.Network = require(script.Network)

if RunService:IsClient() then
    Net.Controller = require(script.Client)
else
    Net.Service = require(script.Server)
end

return Net