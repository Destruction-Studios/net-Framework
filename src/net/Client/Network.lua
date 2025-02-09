
local Promise = require(script.Parent.Parent.Parent.Promise)
local Comm = require(script.Parent.Parent.Comm)

local Network = {}
local NetServiceMT = {}
NetServiceMT.__index = NetServiceMT

Network.Services = {}

local function waitForChildToExist(parent, childName)
    return Promise.new(function(resolve)
        while parent:FindFirstChild(childName) == nil do
            task.wait()
        end
        resolve(parent:FindFirstChild(childName))
    end)
end

local function buildService(folder:Folder)
    local newService = {}
    newService.Name = folder.Name

    for _, v in folder:GetDescendants() do
        if v:IsA("Folder") then
            continue
        end
        if v:IsA("RemoteEvent") or v:IsA("UnreliableRemoteEvent") then
            if v:GetAttribute("_property") == true then
                newService[v.Name] = Comm.TableProperty.new(v)
            else
                newService[v.Name] = Comm.RemoteEvent.new(v)
            end
        elseif v:IsA("RemoteFunction") then
            newService[v.Name] = Comm.Function.new(v)
        elseif v.ClassName:find("Value") then
            newService[v.Name] = Comm.Property.new(v)
        end
    end

    table.freeze(newService)
    Network.Services[newService.Name] = newService
end

function Network:Start()
    local netFolder: Folder = waitForChildToExist(script.Parent.Parent, "_network"):expect()

    local function serviceFolderAdded(folder:Folder)
        if not folder:IsA("Folder") then
            return
        end
        buildService(folder)
    end

    for _, child in netFolder:GetChildren() do
        task.spawn(serviceFolderAdded, child)
    end

    netFolder.ChildAdded:Connect(serviceFolderAdded)
end

function NetServiceMT:GetEvent(eventName:string)
    local networkObject = self[eventName]
    if networkObject.ClassName ~= "NetEvent" then
        error(`{eventName} is not a Net Event ({networkObject.ClassName})`)
    end

    return networkObject
end

function NetServiceMT:GetFunction(functionName:string)
    local networkObject = self[functionName]
    if networkObject.ClassName ~= "NetFunction" then
        error(`{functionName} is not a Net Function ({networkObject.ClassName})`)
    end

    return networkObject
end

function NetServiceMT:GetProperty(propertyName:string)
    local networkObject = self[propertyName]
    if networkObject.ClassName ~= "NetProperty" then
        error(`{propertyName} is not a Net Property ({networkObject.ClassName})`)
    end

    return networkObject
end

function NetServiceMT:GetTableProperty(propertyName:string)
    local networkObject = self[propertyName]
    if networkObject.ClassName ~= "NetTableProperty" then
        error(`{propertyName} is not a Net Table Property ({networkObject.ClassName})`)
    end

    return networkObject
end

return Network