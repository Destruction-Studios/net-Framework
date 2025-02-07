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

    local DictTable = ServerService.DictTable

    DictTable:OnReady():await()

    DictTable.KeyChanged:Connect(function(_newValue, k, v)
        print(`Key {k} was changed to {v}`)
    end)
    DictTable.Changed:Connect(function(newValue)
        print("New Value", newValue)
    end)
end

Net:StartNet():andThen(function()
    print("Net Client Started")
end)