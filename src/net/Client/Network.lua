local Promise = require(script.Parent.Parent.Parent.Promise)
local Comm = require(script.Parent.Parent.Comm)

local Network = {}
local NetServiceMT = {}
NetServiceMT.__index = NetServiceMT

Network.Services = {}

local function waitForChildToExist(parent, childName)
	return Promise.new(function(resolve)
		local connection
		connection = parent.ChildAdded:Connect(function(child)
			if child.Name == childName then
				connection:Disconnect()
				resolve(child)
			end
		end)
		local existing = parent:FindFirstChild(childName)
		if existing then
			connection:Disconnect()
			resolve(existing)
		end
	end)
end

local function buildService(folder: Folder)
	local newService = setmetatable({}, NetServiceMT)
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

	local function serviceFolderAdded(folder: Folder)
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

function NetServiceMT:GetEvent(eventName: string)
	local networkObject = self.Network[eventName]
	assert(networkObject, `Net Event '{eventName}' does not exist on Service '{self.Name}'`)
	assert(networkObject.ClassName == "NetEvent", `'{eventName}' is not a Net Event, got '{networkObject.ClassName}'`)
	return networkObject
end

function NetServiceMT:GetFunction(functionName: string)
	local networkObject = self.Network[functionName]
	assert(networkObject, `Net Function '{functionName}' does not exist on Service '{self.Name}'`)
	assert(
		networkObject.ClassName == "NetFunction",
		`'{functionName}' is not a Net Function, got '{networkObject.ClassName}'`
	)
	return networkObject
end

function NetServiceMT:GetProperty(propertyName: string)
	local networkObject = self.Network[propertyName]
	assert(networkObject, `Net Property '{propertyName}' does not exist on Service '{self.Name}'`)
	assert(
		networkObject.ClassName == "NetProperty",
		`'{propertyName}' is not a Net Property, got '{networkObject.ClassName}'`
	)
	return networkObject
end

function NetServiceMT:GetTableProperty(propertyName: string)
	local networkObject = self.Network[propertyName]
	assert(networkObject, `Net Table Property '{propertyName}' does not exist on Service '{self.Name}'`)
	assert(
		networkObject.ClassName == "NetTableProperty",
		`'{propertyName}' is not a Net Table Property, got '{networkObject.ClassName}'`
	)
	return networkObject
end

return Network
