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

    ServerService.Event.ClientEvent:Connect(function(randNum)
        print("GOT RAND NUM!, ", randNum)
    end)
end


Net:StartAll():andThen(function()
    print("Net Client Started")
end)