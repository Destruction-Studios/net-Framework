local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Net)

local Service1 = Net:Service {
    Name = "TestService",
    Network = {
        TableTest = Net.Network.Property{
            Key1 = 123,
            AmIAwesome = true,
            Edited = {
                Value1 = 123,
                Value2 = false,
                Value3 = "hehe",
            },
        }
    }
}

function Service1:_start()
    print("Starting Test Service with network: ", self.Network)

    local TableTest = self:GetTableProperty("TableTest")

    task.wait(10)

    print(TableTest:Get())
    TableTest:EditSubTable("Edited", {
        Value3 = "sad"
    })
    print(TableTest:Get())
    -- print(TableTest:Get())
    -- TableTest:Key("Edited", {
    --     Value3 = "sad"
    -- })
    -- print(TableTest:Get())
end

Net:StartNet():andThen(function()
    print("Net Server Started!")
end)