
local Type = require(script.Parent.Parent.Type)

type TablePropertyClass = Type.TablePropertyClass

local TableProperty = {}
local TablePropertyMT = {}
TablePropertyMT.__index = TablePropertyMT

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

function TableProperty.new(originalTable, location:Instance, name:string)
    local self = {}

    self._isDict = isDict(originalTable)
    self._value = originalTable

    self._remote = Instance.new("RemoteEvent")
    self._remote.Name = name
    self._remote.Parent = location

    self._remote:FireAllClients("Init", self._value)
    
    setmetatable(self, TablePropertyMT)

    return self
end

function TablePropertyMT.Get(self:TablePropertyClass): any
    return self._value
end

function TablePropertyMT.Insert<T>(self:TablePropertyClass, value:T): T
    if self._isDict then
        warn(`{self._location.Name} is not an array`)
        return
    end

    table.insert(self._value, value)

    self._remote:FireAllClients("Insert", self._value, value)

    return value
end

function TablePropertyMT.Remove(self:TablePropertyClass, index:number?)
    if self._isDict then
        warn(`{self._location.Name} is not an array`)
        return
    end

    local result = table.remove(self._value, index)

    self._remote:FireAllClients("Remove", self._value, result)

    return result
end

function TablePropertyMT.Find(self:TablePropertyClass, value:any, init:number?): number?
    local result = table.find(self._value, value, init)

    return result
end

function TablePropertyMT.Key<T>(self:TablePropertyClass, key:any, value:T): T
    if not self._isDict then
        warn(`{self._location.Name} is not a dictionary`)
        return
    end

    self._value[key] = value

    self._remote:FireAllClients("Key", self._value, key, value)

    return value
end

return TableProperty