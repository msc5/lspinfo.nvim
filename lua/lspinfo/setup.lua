local M = {}

-- Default configuration
local default_config = {
    -- Telescope theme configuration
    telescope_theme = {
        layout_strategy = 'vertical',
        layout_config = {
            preview_height = 35,
            width = 0.5,
            height = 0.9,
        },
        results_title = 'Configured LSP Clients',
        sorting_strategy = 'ascending',
    },
    -- Command name for the LSPInfo command
    command_name = 'LSPInfo',
    -- Whether to enable dynamic updates in the previewer
    enable_dynamic_updates = true,
    -- Update interval for dynamic updates (in milliseconds)
    update_interval = 1000,
}

-- Current configuration
local config = {}

--- Setup function for the plugin
---@param user_config table|nil User configuration
function M.setup(user_config)
    config = vim.tbl_deep_extend('force', default_config, user_config or {})
    
    -- Create the user command
    vim.api.nvim_create_user_command(config.command_name, function()
        require('lspinfo').show()
    end, {
        desc = 'Show LSP client information in telescope picker',
    })
    
    -- Update constants with the configured theme
    local constants = require('lspinfo.constants')
    constants.default_telescope_theme = config.telescope_theme
end

--- Get the current configuration
---@return table
function M.get_config()
    return config
end

return M
