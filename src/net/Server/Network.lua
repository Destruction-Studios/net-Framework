
local Symbol = require(script.Parent.Parent.Parent.Symbol)

local Network = {}

Network.SIGNAL = Symbol("Net Network Signal")
Network.UNRELIABLE_SIGNAL = Symbol("Net Network Unreliable Signal")
Network.PROPERTY = Symbol("Net Network Property")
Network.FUNCTION = Symbol("Net Network Function")

function Network.Signal(isUnreliable:boolean)
    return isUnreliable and Network.UNRELIABLE_SIGNAL or Network.SIGNAL
end

function Network.Function()
    return Network.FUNCTION
end

function Network.Property(initValue)
    return {Network.PROPERTY, initValue}
end

return Network