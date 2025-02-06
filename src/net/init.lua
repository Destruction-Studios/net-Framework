local RunService = game:GetService("RunService")

export type Net = {
    Controller: {},
    Service: {},
    Network:{},
}

local Net:Net = {}

if RunService:IsServer() then
    return require(script.Server)
else
    return require(script.Client)
end

return Net