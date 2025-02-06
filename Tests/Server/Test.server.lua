local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Net)

local Service = Net.Service {
    Name = "TestService",
    Network = {
        Event = Net.Network.Signal(),
        UnRel = Net.Network.Signal(true),
        Func = Net.Network.Function(),
        BoolProp = Net.Network.Property(true),
    }
}

function Service:_init()
    print("Initializing Test Service")
end

function Service:_start()
    print("Starting Test Service")
end

Net:StartNet():andThen(function()
    print("Net Started!")
end)