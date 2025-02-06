local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Net)

local Service1 = Net:Service {
    Name = "TestService",
    Network = {
        RandomNumber = Net.Network.Event(),
        AmountOfPlayers = Net.Network.Property(0)
    }
}

function Service1:_init()
    print("Initializing Test Service")
end

function Service1:_start()
    local MathService = Net:GetService("MathService")
    print("Added 6, 7", MathService:Add(6, 7))
    print("Starting Test Service with network: ", self.Network)

    while true do
        self.Network.AmountOfPlayers:Set(math.random(1, 5))
        task.wait(1)
    end
end

local Service2 = Net:Service {
    Name = "MathService",
}

function Service2:Add(num1, num2)
    print(`{num1} + {num2} = {num1 + num2}`)
    return num1 + num2
end

Net:StartNet():andThen(function()
    print("Net Server Started!")
end)