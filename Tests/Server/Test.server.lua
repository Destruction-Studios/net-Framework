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
        }
    }
}

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