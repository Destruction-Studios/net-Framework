
local Network = {}

local services = {}

local function buildService(folder:Folder)
    local newService = {}
    newService.Name = folder.Name

    table.freeze(newService)
    services[newService.Name] = newService
end

function Network:GetService(serviceName:string)
    
end

return Network