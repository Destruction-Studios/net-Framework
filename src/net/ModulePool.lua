
local Promise = require(script.Parent.Parent.Promise)

local ModulePool = {}
local ModulePoolMT = {}
ModulePoolMT.__index = ModulePoolMT

function ModulePool.new()
    print("New")
    local self = {}

    self._pool = {}
    self._started = false
    self._info = {Loaded = 0, Failed = 0}

    return setmetatable(self, ModulePoolMT)
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

function ModulePoolMT:IsStarted()
    return self._started
end

function ModulePoolMT:_runInitFunc()
    return Promise.new(function(resolve, reject)
        if self:IsStarted() then
            reject("Net is already started")
        end

        local initFunctions = {}
        for _, v in self:GetPool() do
            if typeof(v._init) == "function" then
                table.insert(initFunctions, Promise.new(function(resolve)
                    v:_init()
                    print("Initializing ", v)
                    resolve()
                end)) 
            end
        end
        
        resolve(Promise.all(initFunctions))
    end):andThen(function()
        for _, v in self:GetPool() do
            if typeof(v._start) == "function" then
                print("STARTING ", v)
                Promise.try(v._start, v)
            end
        end
        
        self._started = true
    end)
end

function ModulePoolMT:StartAll()
    return self:_runInitFunc()
end

return ModulePool