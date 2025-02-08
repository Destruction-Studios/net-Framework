
local ModulePool = require(script.Parent.ModulePool)
local Promise = require(script.Parent.Parent.Promise)

local NetClient = {}
local Network = require(script.Network)
local Flags = require(script.Parent.Flags)

NetClient.Network = Network
NetClient.Flag = Flags

local modulePool = ModulePool.new()
modulePool:SetModuleType("Controller")
local onStartBindable = Instance.new("BindableEvent")

function NetClient:Controller(controller)
    assert(not modulePool:HasStartBeenCalled(), "Net Controllers can not be added after Net start")
    assert(typeof(controller) == "table", `Controller must be of type 'table' got {typeof(controller)}`)
    assert(controller.Name, "Controller name can not be nil")
    assert(not modulePool:HasModule(controller.Name), `Controller '{controller.Name}' already exists`)

    local newController = controller

    modulePool:AddToPool(controller.Name, newController)

    return newController
end

function NetClient:GetController(controllerName:string)
    if modulePool:HasStartBeenCalled() == true and modulePool:HasInitialized() == false then
        error(`Net:GetController() can not be called during _init functions`)
    end
    assert(typeof(controllerName) == "string", `Controller name must be 'string' got {typeof(controllerName)}`)
    assert(modulePool:HasModule(controllerName), `Net Controller '{controllerName}' does not exist`)

    return modulePool:GetModule(controllerName)
end

function NetClient:GetService(serviceName:string)
    assert(modulePool:HasStartBeenCalled(), `Net must be started to access server Services`)
    assert(typeof(serviceName) == "string", `Net Service name must be of type 'string' got {typeof(serviceName)}`)
    assert(Network.Services[serviceName], `Net Service '{serviceName}' does not exist on client`)
    
    return Network.Services[serviceName]
end

function NetClient:StartNet()
    Network:Start()
    return modulePool:StartAll()
end

function NetClient:OnStart()
    if modulePool:HasStarted() then
        return Promise.resolve()
    end
    return Promise.fromEvent(onStartBindable.Event)
end

return NetClient