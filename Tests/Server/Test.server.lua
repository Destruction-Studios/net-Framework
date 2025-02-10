local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Net)

local Service1 = Net:Service {
    Name = "TestService",
    Network = {
        TableTest = Net.Network.Property{
            Key1 = 123,
            AmIAwesome = true,
        }
    }
}

function Service1:_start()
    print("Starting Test Service with network: ", self.Network)

    task.wait(10)

    print("Setting Key1 to 321")
    self.Network.TableTest:Key("Key1", 321)
    task.wait(.1)
    print("Setting Key1 to 123 again")
    self.Network.TableTest:Key("Key1", 321)
end

Net:StartNet():andThen(function()
    print("Net Server Started!")
end)