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
        end)
    }
}

function Service1:_init()
    print("Initializing Test Service")
end

function Service1:_start()
    print("Starting Test Service with network: ", self.Network)

    while true do
        self.Network.AmountOfPlayers:Set(math.random(1, 5))
        task.wait(1)
    end
end

Net:StartNet():andThen(function()
    print("Net Server Started!")
end)