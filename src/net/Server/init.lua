
local ModulePool = require(script.Parent.ModulePool)
local Comm = require(script.Parent.Comm)

local NetServer = {}
local Network = require(script.Network)

NetServer.Network = Network

local modulePool = ModulePool.new()
local networkFolder:Folder = nil

local folderNames = {
    [Network.UNRELIABLE_EVENT] = "Events",
    [Network.EVENT] = "Events",
    [Network.FUNCTION] = "Functions",
    [Network.PROPERTY] = "Properties"
}

local valueObjectTypes = {
    number = "NumberValue",
    boolean = "BoolValue",
    CFrame = "CFrameValue",
    Color3 = "Color3Value",
}

local function createNetworkFolder()
    networkFolder = Instance.new("Folder")
    networkFolder.Name = "_network"
end

local function getOrCreateFolder(parent:Instance, name:string)
    if parent:FindFirstChild(name) ~= nil and parent:FindFirstChild(name):IsA("Folder") then
        return parent:FindFirstChild(name)
    end
    local folder = Instance.new("Folder")
    folder.Name = name
    folder.Parent = parent

    return folder
end

local function createInstance(parent, name, instanceType)
    local inst = Instance.new(instanceType)
    inst.Name = name
    inst.Parent = parent

    return inst
end

local function getDictLen(dict)
    local result = 0
    for _, _ in dict do 
        result += 1 
    end
    return result
end

function NetServer:GetService(serviceName:string)
    if modulePool:HasStartBeenCalled() == true and modulePool:HasInitialized() == false then
        error(`Net:GetService() can not be called during _init functions`)
    end
    assert(typeof(serviceName) == "string", `Service name must be 'string' got {typeof(serviceName)}`)
    assert(modulePool:HasModule(serviceName), `Net Service '{serviceName}' does not exist`)

    return modulePool:GetModule(serviceName)
end

function NetServer:Service(service)
    assert(not modulePool:HasStartBeenCalled(), "Net Services can not be added after Net start")
    assert(typeof(service) == "table", `Service must be of type 'table' got {typeof(service)}`)
    assert(service.Name, "Service name can not be nil")
    assert(not modulePool:HasModule(service.Name), `Service '{service.Name}' already exists`)
    
    local oldNetwork = service.Network or {}
    local newNetwork = {}
    local newService = service

    if getDictLen(oldNetwork) > 0 then
        local serviceNetworkFolder = Instance.new("Folder")
        serviceNetworkFolder.Name = newService.Name
        serviceNetworkFolder.Parent = networkFolder

        for name, networkType in oldNetwork do
            local key = typeof(networkType) == "table" and networkType[1] or networkType
            local parentFolder = getOrCreateFolder(serviceNetworkFolder, folderNames[key])
            
            if networkType == Network.EVENT then
                newNetwork[name] = Comm.RemoteEvent.new(createInstance(parentFolder, name, "RemoteEvent"))
            elseif networkType == Network.UNRELIABLE_EVENT then
                newNetwork[name] = Comm.RemoteEvent.new(createInstance(parentFolder, name, "UnreliableRemoteEvent"))
            elseif typeof(networkType) == "table" and networkType[1] == Network.FUNCTION then
                local comm = Comm.Function.new(createInstance(parentFolder, name, "RemoteFunction"))
                comm:SetInvokeFunction(networkType[2])
                
                newNetwork[name] = comm
            elseif typeof(networkType) == "table" and networkType[1] == Network.PROPERTY then
                local initValue = networkType[2]
                if valueObjectTypes[typeof(initValue)] == nil then
                    error(`Can not create property with value type '{typeof(initValue)}'`, 2)
                end
                local inst = createInstance(parentFolder, name, valueObjectTypes[typeof(initValue)])
                inst.Value = initValue
                
                newNetwork[name] = Comm.Property.new(inst)
            end
        end
    end

    newService.Network = newNetwork

    modulePool:AddToPool(newService.Name, newService)

    return newService
end

function NetServer:StartNet()
    return modulePool:StartAll():andThen(function()
        networkFolder.Parent = script.Parent
    end)
end

createNetworkFolder()
modulePool:SetModuleType("Service")

return NetServer