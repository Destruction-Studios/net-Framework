
local UniqueKey = require(script.Parent.Parent.Parent.UniqueKey)

local Network = {}

Network.EVENT = UniqueKey("Net Network Event")
Network.UNRELIABLE_EVENT = UniqueKey("Net Network Unreliable Event")
Network.PROPERTY = UniqueKey("Net Network Property")
Network.FUNCTION = UniqueKey("Net Network Function")

function Network.Event(isUnreliable:boolean)
    return isUnreliable and Network.UNRELIABLE_EVENT or Network.EVENT
end

function Network.Function(fn:(player:Player, ...any)->any)
    return {Network.FUNCTION, fn}
end

function Network.Property(...)
    return {Network.PROPERTY, ...}
end

return Network