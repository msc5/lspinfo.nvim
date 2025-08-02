local o = {}

local packages = {
    'constants',
    'format',
    'clients',
    'actions',
    'capabilities',
    'setup',
}

for _, pack in pairs(packages) do
    local name = 'lspinfo.' .. pack
    package.loaded[name] = nil
    o[pack] = require(name)
end

-- Main show function that users can call
function o.show()
    require('lspinfo.clients')()
end

-- Setup function for plugin configuration
function o.setup(user_config)
    require('lspinfo.setup').setup(user_config)
end

return o
