local RunService = game:GetService("RunService")

local DEFAULT_FLAGS = require(script.DefaultFlags)

local Flags = {}

local currentFlags = table.clone(DEFAULT_FLAGS)

function Flags.setFlag(flagName:string, studio:boolean?, server:boolean?)
    if DEFAULT_FLAGS[flagName] == nil then
        error(`{flagName} is not a valid Net Flag`, 2)
    end
    local oldFlagValue = currentFlags[flagName]
    currentFlags[flagName] = {Studio = studio or oldFlagValue.Studio, Server = server or oldFlagValue.Server}
end

function Flags.isFlagEnabled(flagName:string): boolean
    if DEFAULT_FLAGS[flagName] == nil then
        error(`{flagName} is not a valid Net Flag`, 2)
    end
    local flagValue = currentFlags[flagName]
    if RunService:IsStudio() then
        return flagValue.Studio
    end
    return flagValue.Server
end

function Flags.runIfFlag<T>(flagName:string, fn:(...any)->T?, ...:any): T?
    if DEFAULT_FLAGS[flagName] == nil then
        error(`{flagName} is not a valid Net Flag`, 2)
    end
    local isFlagEnabled = Flags.isFlagEnabled(flagName)
    if isFlagEnabled then
        return fn(...)
    end
end

function Flags.runIfNotFlag<T>(flagName:string, fn:(...any)->T?, ...:any): T?
    if DEFAULT_FLAGS[flagName] == nil then
        error(`{flagName} is not a valid Net Flag`, 2)
    end
    local isFlagEnabled = Flags.isFlagEnabled(flagName)
    if not isFlagEnabled then
        return fn(...)
    end
end

return Flags