local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Net)

local Service1 = Net:Service {
    Name = "TestService",
    Network = {
        TableTest = Net.Network.Property{
            ["Destruction_Studio"] = {
                Item = "",
                Points = 30,
            }
        },
        TestFn = Net.Network.Function()
    }
}

Service1.Network.TestFn:OnInvoke(function(player:Player, ...:any)
    print(`from {player.Name} data: `, ...)
    return math.random(1, 100)
end)

function Service1:_start()
    print("Starting Test Service with network: ", self.Network)

    local TableTest = self:GetTableProperty("TableTest")

    task.wait(8)

    TableTest:Transform(function(value)
        value.Destruction_Studio.Item = "Cheese"

        return true
    end)
end

Net:StartNet():andThen(function()
    print("Net Server Started!")
end)