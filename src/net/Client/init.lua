
local ModulePool = require(script.Parent.ModulePool)

local NetClient = {}
local Network = require(script.Network)
NetClient.Network = Network

local modulePool = ModulePool.new()
modulePool:SetModuleType("Controller")

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

function NetClient:StartAll()
    return modulePool:StartAll()
end

return NetClient