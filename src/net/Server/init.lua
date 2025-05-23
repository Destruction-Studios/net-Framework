local ModulePool = require(script.Parent.ModulePool)
local Comm = require(script.Parent.Comm)
local Promise = require(script.Parent.Parent.Promise)
local UniqueKey = require(script.Parent.Parent.UniqueKey)

local SERVICE = UniqueKey("Service")

local NetServer = {
	Type = {
		Service = SERVICE,
	},
}
local NetServiceMT = {}
NetServiceMT.__index = NetServiceMT

local NetModuleMT = {}
function NetModuleMT:__index(key)
	error(`Controller/Service ({key}) is nil; Net has not yet initialized`)
end

local Network = require(script.Network)
local Flags = require(script.Parent.Flags)

NetServer.Network = Network
NetServer.Flag = Flags

local modulePool = ModulePool.new()
local networkFolder: Folder = nil
local onStartBindable = Instance.new("BindableEvent")

local FOLDER_NAMES = {
	[Network.UNRELIABLE_EVENT] = "Events",
	[Network.EVENT] = "Events",
	[Network.FUNCTION] = "Functions",
	[Network.PROPERTY] = "Properties",
}

local VALUE_OBJECT_TYPES = {
	number = "NumberValue",
	boolean = "BoolValue",
	CFrame = "CFrameValue",
	Color3 = "Color3Value",
	string = "StringValue",
}

local function createNetworkFolder()
	networkFolder = Instance.new("Folder")
	networkFolder.Name = "_network"
end

local function getOrCreateFolder(parent: Instance, name: string)
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

function NetServer:GetService(serviceName: string)
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
	local newService = setmetatable(service, NetServiceMT)

	if getDictLen(oldNetwork) > 0 then
		local serviceNetworkFolder = Instance.new("Folder")
		serviceNetworkFolder.Name = newService.Name
		serviceNetworkFolder.Parent = networkFolder

		for name, networkType in oldNetwork do
			local key = typeof(networkType) == "table" and networkType[1] or networkType
			local parentFolder = getOrCreateFolder(serviceNetworkFolder, FOLDER_NAMES[key])

			if networkType == Network.EVENT then
				newNetwork[name] = Comm.RemoteEvent.new(createInstance(parentFolder, name, "RemoteEvent"))
			elseif networkType == Network.UNRELIABLE_EVENT then
				newNetwork[name] = Comm.RemoteEvent.new(createInstance(parentFolder, name, "UnreliableRemoteEvent"))
			elseif networkType == Network.FUNCTION then
				local comm = Comm.Function.new(createInstance(parentFolder, name, "RemoteFunction"))

				newNetwork[name] = comm
			elseif typeof(networkType) == "table" and networkType[1] == Network.PROPERTY then
				local initValue = networkType[2]
				if typeof(initValue) == "table" then
					newNetwork[name] = Comm.TableProperty.new(initValue, parentFolder, name, networkType[3])
				elseif VALUE_OBJECT_TYPES[typeof(initValue)] ~= nil then
					local inst = createInstance(parentFolder, name, VALUE_OBJECT_TYPES[typeof(initValue)])
					inst.Value = initValue

					newNetwork[name] = Comm.Property.new(inst)
				else
					error(`Can not create property with value type '{typeof(initValue)}'`, 2)
				end
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
		onStartBindable:Fire()
		task.defer(onStartBindable.Destroy, onStartBindable)
	end)
end

function NetServer:OnStart()
	if modulePool:HasStarted() then
		return Promise.resolve()
	end
	return Promise.fromEvent(onStartBindable.Event)
end

function NetServer:OnLoad(netModules: { [string]: typeof(SERVICE) })
	local new = table.clone(netModules)
	table.clear(netModules)
	setmetatable(netModules, NetModuleMT)

	modulePool:AwaitInit():andThen(function()
		for name, netModuleType in new do
			Promise.new(function(resolve, reject)
				local module = nil
				if netModuleType == SERVICE then
					module = NetServer:GetService(name)
				else
					reject(
						`{name}: {netModuleType} ({typeof(netModuleType)}) Is not a valid 'Net.Type' value for Net:OnLoad`
					)
				end

				netModules[name] = module

				resolve()
			end)
		end
	end)

	return netModules
end

function NetServiceMT:GetEvent(eventName: string)
	local networkObject = self.Network[eventName]
	if networkObject.ClassName ~= "NetEvent" then
		error(`{eventName} is not a Net Event ({networkObject.ClassName})`)
	end

	return networkObject
end

function NetServiceMT:GetFunction(functionName: string)
	local networkObject = self.Network[functionName]
	if networkObject.ClassName ~= "NetFunction" then
		error(`{functionName} is not a Net Function ({networkObject.ClassName})`)
	end

	return networkObject
end

function NetServiceMT:GetProperty(propertyName: string)
	local networkObject = self.Network[propertyName]
	if networkObject.ClassName ~= "NetProperty" then
		error(`{propertyName} is not a Net Property ({networkObject.ClassName})`)
	end

	return networkObject
end

function NetServiceMT:GetTableProperty(propertyName: string)
	local networkObject = self.Network[propertyName]
	if networkObject.ClassName ~= "NetTableProperty" then
		error(`{propertyName} is not a Net Table Property ({networkObject.ClassName})`)
	end

	return networkObject
end

createNetworkFolder()
modulePool:SetModuleType("Service")

return NetServer
