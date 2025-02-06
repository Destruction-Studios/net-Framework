local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage.Net)

local Controller = Net:Controller {
    Name = "TestController"
}

function Controller:_init()
    print("Controller Init")
end

function Controller:_start()
    print("Controller start")
    local ServerService = Net:GetService("TestService")

    ServerService.RandomNumber.ClientEvent:Connect(function(randNum)
        print("GOT RAND NUM!, ", randNum)
    end)
    
    local function onChanged(value)
        print("Players: ", value)
    end
    onChanged(ServerService.AmountOfPlayers:Get())
    ServerService.AmountOfPlayers.Changed:Connect(onChanged)

    ServerService.GiveRandomNumber:Invoke():andThen(function(value)
        print("Got: ", value)
    end)
end

Net:StartAll():andThen(function()
    print("Net Client Started")
end)