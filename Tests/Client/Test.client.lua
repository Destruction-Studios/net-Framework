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
    local MC = Net:GetController("MathController")
    print("Added 12, 56 ", MC:Add(12, 56))
end

local MathController = Net:Controller {
    Name = "MathController"
}

function MathController:Add(a, b)
    print(`{a} + {b} = {a + b}`)
    return a+b
end

Net:StartAll():andThen(function()
    print("Net Client Started")
end)