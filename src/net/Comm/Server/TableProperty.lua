local Players = game:GetService("Players")

local Type = require(script.Parent.Parent.Type)

type TablePropertyClass = Type.TablePropertyClass

local TableProperty = {}
local TablePropertyMT = {}
TablePropertyMT.__index = TablePropertyMT

local properties:{[string]:TablePropertyClass} = {}

local function isDict(tbl)
    local loopAmount = 0
    for _, _ in tbl do
        loopAmount += 1
    end
    local amount = #tbl

    if loopAmount > 0 and amount == 0 then
        return true
    end
    return false
end

local function onPlayerAdded(player:Player)
    for _, v in properties do
        v._remote:FireClient(player, "Init", v._value)
    end
end

function TableProperty.new(originalTable, location:Instance, name:string, override:string)
    local self = {}

    local isDictOverride = nil
    if override ~= nil then
        assert(override == "Dictionary" or override == "Array", `Invalid Net Table Override type expected Dictionary or Array got {override}`)
        isDictOverride = override == "Dictionary"
    end

    self._isDict = isDictOverride ~= nil and isDictOverride or isDict(originalTable)
    self._value = originalTable
    self._lastValue = table.clone(originalTable)

    self.ClassName = "NetTableProperty"

    self._remote = Instance.new("RemoteEvent")
    self._remote:SetAttribute("_property", true)
    self._remote.Name = name
    self._remote.Parent = location

    self._remote:FireAllClients("Init", self._value)
    
    setmetatable(self, TablePropertyMT)

    properties[self._remote.Name] = self

    return self
end

function TablePropertyMT._fireIfChanged(self:TablePropertyClass, event:string, ...)
    local isDifferent = false
    for k, v in self._value do
        if self._lastValue[k] ~= v then
            isDifferent = true
            break
        end
    end

    self._lastValue = table.clone(self._value)

    if isDifferent then
        print("Firing")
        self._remote:FireAllClients(event, ...)
    end
end

function TablePropertyMT.Get(self:TablePropertyClass): any
    return self._value
end

function TablePropertyMT.Insert<T>(self:TablePropertyClass, value:T): T
    if self._isDict then
        warn(`{self._remote.Name} is not an array`)
        return
    end

    table.insert(self._value, value)

    -- self._remote:FireAllClients("Insert", self._value, value)
    self:_fireIfChanged("Insert", value)

    return value
end

function TablePropertyMT.Remove(self:TablePropertyClass, index:number?)
    if self._isDict then
        warn(`{self._remote.Name} is not an array`)
        return
    end

    local result = table.remove(self._value, index)

    -- self._remote:FireAllClients("Remove", self._value, result)
    self:_fireIfChanged("Remove", index, result)

    return result
end

function TablePropertyMT.Find(self:TablePropertyClass, value:any, init:number?): number?
    local result = table.find(self._value, value, init)

    return result
end

function TablePropertyMT.Key<T>(self:TablePropertyClass, key:any, value:T): T
    if not self._isDict then
        warn(`{self._remote.Name} is not a dictionary`)
        return
    end

    self._value[key] = value

    -- self._remote:FireAllClients("Key", self._value, key, value)
    self:_fireIfChanged("Key", key, value)

    return value
end

Players.PlayerAdded:Connect(onPlayerAdded)

return TableProperty