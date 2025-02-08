
local Type = require(script.Parent.Parent.Type)

local PropertyClient = {}
local PropertyClientMT = {}
PropertyClientMT.__index = PropertyClientMT

function PropertyClient.new<T>(object:NumberValue): Type.PropertyClass<T>
    local self = {}

    self._instance = object
    self.Changed = object.Changed
    self.ClassName = "NetProperty"
    
    setmetatable(self, PropertyClientMT)

    return self
end

function PropertyClientMT.Get<T>(self:Type.PropertyClass<T>): T
    return self._instance.Value
end

return PropertyClient