
local Type = require(script.Parent.Parent.Type)

type FunctionClass = Type.FunctionClass

local FunctionServer = {}
local FunctionServerMT = {}
FunctionServerMT.__index = FunctionServerMT

function FunctionServer.new(object:RemoteFunction): FunctionClass
    local self = {}

    self._instance = object
    self._hasInvokeBeenSet = false

    setmetatable(self, FunctionServerMT)
    return self
end

function FunctionServerMT.SetInvokeFunction(self:FunctionClass, fn:(player:Player, ...any)->any)
    if self._hasInvokeBeenSet then
        warn(`Invoke function for {self._instance.Name} has already been set, overriding`)
    end
    self._hasInvokeBeenSet = true

    self._instance.OnServerInvoke = fn
end

return FunctionServer