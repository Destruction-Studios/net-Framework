
local Type = require(script.Parent.Parent.Type)

type FunctionClass = Type.FunctionClass

local FunctionServer = {}
local FunctionServerMT = {}
FunctionServerMT.__index = FunctionServerMT

function FunctionServer.new(object:RemoteFunction): FunctionClass
    local self = {}

    self._instance = object
    self._hasInvokeBeenSet = false

    self.ClassName = "NetFunction"

    setmetatable(self, FunctionServerMT)
    return self
end

function FunctionServerMT.OnInvoke(self:FunctionClass, func:(player:Player, ...any) -> any)
    if self._hasInvokeBeenSet then
        warn(`Invoke function for {self._instance.Name} has already been set, overriding`)
    end
    self._instance.OnServerInvoke = func
end

return FunctionServer