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

    local TableTest = ServerService.TableTest
    TableTest:OnReady():await()
    TableTest.Changed:Connect(function()
        warn("I changed")
    end)
    TableTest.SubTableEdited:Connect(function(a, b, c)
        print("EDITED ", a, b, c)
    end)
end

Net:StartNet():andThen(function()
    print("Net Client Started")
end)