if not lib then
    assert("Missing Ox Lib")
    return
end

local FRAMEWORK = {}
local CACHED_FRAMEWORKS = {}

local CONTEXT_PATHS = {
    CLIENT = 'client',
    SERVER = 'server'
}

--[[ NEED TO CALL THE FOLDER WHIT THE NAME ASSOCIATED]]
local FRAMEWORKS = {
    ['es_extended'] = { folder = 'esx' },
    ['qb-core'] = { folder = 'qbox' },
    ['ox_core'] = { folder = 'ox' },
    ['LEGACYCORE'] = { folder = 'legacy' },
    ['CUSTOM'] = { folder = 'custom' }
}


function FRAMEWORK:new()
    local OBJ = {}
    setmetatable(OBJ, self)
    self.__index = self
    return OBJ
end

--- Returns the appropriate framework object based on the server/client context.
-- @param IS_SERVER boolean: indicates if the context is server.
-- @return SHARED_OBJECT: the found framework object or nil if not found.

function FRAMEWORK:getFrameworkObject(IS_SERVER)
    local CONTEXT = IS_SERVER and CONTEXT_PATHS.SERVER or CONTEXT_PATHS.CLIENT

    if CACHED_FRAMEWORKS[CONTEXT] then
        Shared.DebugData(('Framework found in cache: %s'):format(CACHED_FRAMEWORKS[CONTEXT].RESOURCE_NAME))
        return CACHED_FRAMEWORKS[CONTEXT].SHARED_OBJECT
    end

    for RESOURCE_NAME, FRAMEWORK_DATA in pairs(FRAMEWORKS) do
        local FOLDER_NAME = FRAMEWORK_DATA.folder
        local EXPORT_FUNCTION_PATH = ("framework.%s.%s"):format(FOLDER_NAME, CONTEXT)

        if GetResourceState(RESOURCE_NAME) == 'started' then
            local SUCCESS, SHARED_OBJECT = pcall(require, EXPORT_FUNCTION_PATH)
            if SUCCESS then
                CACHED_FRAMEWORKS[CONTEXT] = { RESOURCE_NAME = RESOURCE_NAME, SHARED_OBJECT = SHARED_OBJECT }
                Shared.DebugData(('Framework found and cached: %s'):format(RESOURCE_NAME))
                return SHARED_OBJECT
            else
                Shared.DebugData(("Error retrieving shared object from %s: %s"):format(RESOURCE_NAME, SHARED_OBJECT))
            end
        end
    end

    Shared.DebugData('No framework found.')
    return nil
end




return FRAMEWORK
