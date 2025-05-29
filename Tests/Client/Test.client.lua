local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage.Net)

local CustomFunctions = {
	Tick = Net.Type.CustomFunction,
}

function CustomFunctions:_start()
	-- task.spawn(function()
	while true do
		print(`Tick`)
		self.Tick:Fire()
		task.wait(1)
	end
	-- end)
end

Net:SetCustomFunctions(CustomFunctions)

local Controller = Net:Controller({
	Name = "TestController",
})

-- function Controller.Custom:Tick()
-- 	print(`Tock`)
-- end

function Controller:_init()
	print("Controller Init")
end

function Controller:_start()
	print("Controller start")
	local ServerService = Net:GetService("TestService")

	local TableTest = ServerService.TableTest
	TableTest:OnReady():await()
	TableTest.Changed:Connect(function(value, lastValue)
		warn("Changed", value)
		print(value, lastValue)
	end)

	print("Got: ", ServerService.TestFn:Invoke():expect())
end

Net:StartNet():andThen(function()
	print("Net Client Started")
end)
