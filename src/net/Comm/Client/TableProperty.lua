
local Promise = require(script.Parent.Parent.Parent.Parent.Promise)
local Signal = require(script.Parent.Parent.Parent.Parent.Signal)
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

function TableProperty.new(remoteEvent:RemoteEvent)
    local self = {}

    self._remote = remoteEvent
    self._value = nil
    self._isDict = false
    self._ready = false
    self._readyBindable = Instance.new("BindableEvent")

    self.ClassName = "NetTableProperty"

    self.Inserted = Signal.new()
    self.Removed = Signal.new()
    self.KeyChanged = Signal.new()
    self.Changed = Signal.new()
    self.SubTableEdited = Signal.new()


    self._remote.OnClientEvent:Connect(function(action, value, ...)
        self._value = value
        self.Changed:Fire(self._value)

        if action == "Init" and self._ready == false then
            self._isDict = isDict(value)
            self._ready = true
            self._readyBindable:Fire()
            task.defer(self._readyBindable.Destroy, self._readyBindable)
            return
        elseif action == "Insert" then
            self.Inserted:Fire(value, ...)
        elseif action == "Remove" then
            self.Removed:Fire(value, ...)
        elseif action == "Key" then
            self.KeyChanged:Fire(value, ...)
        elseif action == "EditSubTable" then
            self.SubTableEdited:Fire(value, ...)
        end
    end)


    setmetatable(self, TablePropertyMT)
    return self
end

function TablePropertyMT.Get(self:TablePropertyClass):any?
    if self._ready == false then
        warn(`Net Table Property {self._remote.Name} is not ready`)
    end
    return self._value
end

function TablePropertyMT.OnReady(self:TablePropertyClass):Type.PromiseLike
    if not self._ready then
        return Promise.fromEvent(self._readyBindable.Event)
    end
    return Promise.resolve()
end

return TableProperty