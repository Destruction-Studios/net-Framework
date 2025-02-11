
local Promise = require(script.Parent.Parent.Promise)
local Flags = require(script.Parent.Flags)

local ModulePool = {}
local ModulePoolMT = {}
ModulePoolMT.__index = ModulePoolMT

function ModulePool.new()
    local self = {}

    self._pool = {}
    self._moduleType = "Unknown"
    self._hasStartBeenCalled = false
    self._initialized = false
    self._started = false
    self._info = {Complete = 0, Failed = 0}

    return setmetatable(self, ModulePoolMT)
end

function ModulePoolMT:SetModuleType(moduleType:string)
    self._moduleType = moduleType
end

function ModulePoolMT:AddToPool(name, tbl)
    self._pool[name] = tbl
end

function ModulePoolMT:GetModule(name:string)
    return self._pool[name]
end

function ModulePoolMT:HasModule(name:string)
    return self._pool[name] ~= nil
end

function ModulePoolMT:GetPool()
    return self._pool
end

function ModulePoolMT:HasStartBeenCalled()
    return self._hasStartBeenCalled
end

function ModulePoolMT:HasStarted()
    return self._started
end

function ModulePoolMT:HasInitialized()
    return self._initialized
end

function ModulePoolMT:_runInitFunc()
    return Promise.new(function(resolve, reject)
        if self:HasStartBeenCalled() then
            reject("Net is already started")
        end
        self._hasStartBeenCalled = true

        local netStartMS = DateTime.now().UnixTimestampMillis

        local initFunctions = {}
        for _, v in self:GetPool() do
            if typeof(v._init) == "function" then
                table.insert(initFunctions, Promise.new(function(r)
                    local start = DateTime.now().UnixTimestampMillis
                    v:_init()
                    Flags.runIfFlag("debug", print, `Initialized Net {self._moduleType} '{v.Name}' ({DateTime.now().UnixTimestampMillis - start} ms)`)
                    r()
                end):catch(function(err)
                    Flags.runIfNotFlag("silent", warn, `\n\nError initializing Net {self._moduleType} '{v.Name}'\n\n{err}\n\n`)
                end)) 
            end
        end

        self._initialized = true
        
        Promise.all(initFunctions):await()
        
        resolve(netStartMS)
    end):andThen(function(netStartMS)
        for _, v in self:GetPool() do
            if typeof(v._start) == "function" then
                local start = DateTime.now().UnixTimestampMillis
                Promise.try(v._start, v):andThen(function()
                    Flags.runIfFlag("debug", print, `Started Net {self._moduleType} '{v.Name}' ({DateTime.now().UnixTimestampMillis - start} milliseconds)`)
                end):catch(function(err)
                    Flags.runIfNotFlag("silent", warn, `\n\nError starting Net {self._moduleType} '{v.Name}'\n\n{err}\n\n`)
                end)
            end
        end

        Flags.runIfFlag("debug", print, `Net Started ({DateTime.now().UnixTimestampMillis - netStartMS} milliseconds)`)
        
        self._started = true
    end)
end

function ModulePoolMT:StartAll()
    return self:_runInitFunc()
end

return ModulePool