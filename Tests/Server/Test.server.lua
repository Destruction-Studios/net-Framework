local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Net)

local Service1 = Net:Service {
    Name = "TestService",
    Network = {
        RandomNumber = Net.Network.Event(),
        AmountOfPlayers = Net.Network.Property(0),
        GiveRandomNumber = Net.Network.Function(function(player)
            local rand = math.random(1, 100)

            print(`{player.Name} heres your random number: `, rand)
            return rand
        end),
        DictTable = Net.Network.Property{
            Key1 = 342,
            Key2 = "Hello World",
            Key3 = false
        },
        ArrayTable = Net.Network.Property{
            1, 324, 1000, 4252
        }
    }
}

function Service1:_start()
    print("Starting Test Service with network: ", self.Network)

    task.delay(5, function()
        print("Adding Value")
        self.Network.ArrayTable:Insert(40000000000)
        self.Network.DictTable:Key("SuperEpic", true)
        self.Network.ArrayTable:Remove(1)
        task.wait(3)
        self.Network.DictTable:Key("SuperEpic", false)
    end)

    while true do
        self.Network.AmountOfPlayers:Set(math.random(1, 5))
        task.wait(1)
    end
end

Net:StartNet():andThen(function()
    print("Net Server Started!")
end)