
local Type = require(script.Parent.Parent.Type)
local Promise = require(script.Parent.Parent.Parent.Parent.Promise)

type FunctionServerClass = Type.FunctionClass

local FunctionClient = {}
local FunctionClientMT = {}
FunctionClientMT.__index = FunctionClientMT

function FunctionClient.new(object:RemoteFunction)
    local self = {}

    self._instance = object

    setmetatable(self, FunctionClientMT)
    return self
end

function FunctionClientMT.Invoke(self:FunctionServerClass, args)
    return Promise.new(function(resolve, _reject, _onCancel)
        local result = self._instance:InvokeServer(args)

        resolve(result)
    end)
end

return FunctionClient