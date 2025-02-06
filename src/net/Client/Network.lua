
local Promise = require(script.Parent.Parent.Parent.Promise)
local Comm = require(script.Parent.Parent.Comm)

local Network = {}

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
    print("Building Client Service ", folder.Name)

    local newService = {}
    newService.Name = folder.Name

    for _, v in folder:GetDescendants() do
        if v:IsA("Folder") then
            continue
        end
        if v:IsA("RemoteEvent") or v:IsA("UnreliableRemoteEvent") then
            newService[v.Name] = Comm.RemoteEvent.new(v)
        elseif v.ClassName:find("Value") then
            
        end
    end

    print("Built client service:", newService)

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

return Network