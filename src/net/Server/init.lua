
local ModulePool = require(script.Parent.ModulePool)

local NetServer = {}
local Network = require(script.Network)

NetServer.Network = Network

local modulePool = ModulePool.new()
local networkFolder:Folder = nil

local folderNames = {
    [Network.UNRELIABLE_SIGNAL] = "_signals",
    [Network.SIGNAL] = "_signals",
    [Network.FUNCTION] = "_functions",
    [Network.PROPERTY] = "_properties"
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

function NetServer.Service(service)
    assert(not modulePool:IsStarted(), "Net Services can not be added after Net start")
    assert(typeof(service) == "table", `Service must be of type 'table' got {typeof(service)}`)
    assert(service.Name, "Service name can not be nil")
    assert(not modulePool:HasModule(service.Name), `Service '{service.Name}' already exists`)
    
    local newService = service

    newService.Network = newService.Network or {}

    if getDictLen(newService.Network) > 0 then
        local serviceNetworkFolder = Instance.new("Folder")
        serviceNetworkFolder.Name = newService.Name
        serviceNetworkFolder.Parent = networkFolder

        for name, networkType in newService.Network do
            local key = typeof(networkType) == "table" and networkType[1] or networkType
            local parentFolder = getOrCreateFolder(serviceNetworkFolder, folderNames[key])
            
            if networkType == Network.SIGNAL then
                createInstance(parentFolder, name, "RemoteEvent")
            elseif networkType == Network.UNRELIABLE_SIGNAL then
                createInstance(parentFolder, name, "UnreliableRemoteEvent")
            elseif networkType == Network.FUNCTION then
                createInstance(parentFolder, name, "RemoteFunction")
            elseif typeof(networkType) == "table" and networkType[1] == Network.PROPERTY then
                local initValue = networkType[2]
                if valueObjectTypes[typeof(initValue)] == nil then
                    error(`Can not create property with value type '{typeof(initValue)}'`, 2)
                end
                local inst = createInstance(parentFolder, name, valueObjectTypes[typeof(initValue)])
                inst.Value = initValue
            end
        end
    end

    modulePool:AddToPool(newService.Name, newService)

    return newService
end

function NetServer:StartNet()
    print(modulePool:GetPool())
    return modulePool:StartAll():andThen(function()
        networkFolder.Parent = script.Parent
    end)
end

createNetworkFolder()

return NetServer