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
    -- Display options
    display = {
        -- Whether to show diagnostic counts
        show_diagnostics = true,
        -- Whether to show buffer information
        show_buffers = true,
        -- Whether to show client capabilities
        show_capabilities = false,
        -- Whether to show root directory
        show_root_dir = true,
        -- Whether to show client status (running/stopped)
        show_status = true,
        -- Whether to show initialization status
        show_initialized = true,
    },
    -- Keymaps for the picker
    keymaps = {
        -- Key to restart LSP server
        restart = 'r',
        -- Key to stop LSP server
        stop = 's',
        -- Key to start LSP server
        start = 't',
        -- Key to show capabilities
        capabilities = 'c',
        -- Key to close picker
        close = '<Esc>',
    },
}

-- Current configuration
local config = {}

--- Setup function for the plugin
---@param user_config table|nil User configuration
function M.setup(user_config)
    config = vim.tbl_deep_extend('force', default_config, user_config or {})

    -- Create the user command
    vim.api.nvim_create_user_command(config.command_name, function() require('lspinfo').show() end, {
        desc = 'Show LSP client information in telescope picker',
    })

    -- Update constants with the configured theme
    local constants = require 'lspinfo.constants'
    constants.default_telescope_theme = config.telescope_theme

    -- Set up LSP handlers
    require('lspinfo.lsp').setup_lsp_listeners()
end

--- Get the current configuration
---@return table
function M.get_config() return config end

return M
