
local Type = require(script.Parent.Parent.Type)

local PropertyServer = {}
local ProperyServerMT = {}
ProperyServerMT.__index = ProperyServerMT

function PropertyServer.new<T>(object:NumberValue): Type.PropertyClass<T>
    local self = {}

    self._instance = object
    self.Changed = object.Changed
    self.ClassName = "NetProperty"

    setmetatable(self, ProperyServerMT)

    return self
end

function ProperyServerMT.Get<T>(self:Type.PropertyClass<T>): T
    return self._instance.Value
end

function ProperyServerMT.Set<T>(self:Type.PropertyClass<T>, value:T)
    self._instance.Value = value
end

return PropertyServer