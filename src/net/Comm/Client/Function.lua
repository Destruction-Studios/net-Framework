
local Type = require(script.Parent.Parent.Type)
local Promise = require(script.Parent.Parent.Parent.Parent.Promise)

type FunctionClass = Type.FunctionClass

local FunctionClient = {}
local FunctionClientMT = {}
FunctionClientMT.__index = FunctionClientMT

function FunctionClient.new(object:RemoteFunction): FunctionClass
    local self = {}

    self._instance = object
    self.ClassName = "NetFunction"

    setmetatable(self, FunctionClientMT)
    return self
end

function FunctionClientMT.Invoke(self:FunctionClass, ...)
    local packed = table.pack(...)
    return Promise.new(function(resolve, _reject, _onCancel)
        local result = self._instance:InvokeServer(table.unpack(packed))

        resolve(result)
    end)
end

return FunctionClient