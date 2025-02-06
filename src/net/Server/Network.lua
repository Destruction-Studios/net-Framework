
local Symbol = require(script.Parent.Parent.Parent.Symbol)

local Network = {}

Network.EVENT = Symbol("Net Network Event")
Network.UNRELIABLE_EVENT = Symbol("Net Network Unreliable Event")
Network.PROPERTY = Symbol("Net Network Property")
Network.FUNCTION = Symbol("Net Network Function")

function Network.Event(isUnreliable:boolean)
    return isUnreliable and Network.UNRELIABLE_EVENT or Network.EVENT
end

function Network.Function()
    return Network.FUNCTION
end

function Network.Property(initValue)
    return {Network.PROPERTY, initValue}
end

return Network