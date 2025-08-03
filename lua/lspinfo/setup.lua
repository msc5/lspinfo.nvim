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
    -- Fidget.nvim integration
    fidget = {
        -- Whether to enable fidget.nvim integration
        enabled = false,
        -- How to display fidget status in the previewer
        display_mode = 'inline', -- 'inline', 'section', or 'minimal'
        -- Whether to show fidget notifications in the previewer
        show_notifications = true,
        -- Whether to show fidget progress in the previewer
        show_progress = true,
        -- Whether to auto-disable if fidget API is not available
        auto_disable = true,
    },
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
end

--- Get the current configuration
---@return table
function M.get_config() return config end

--- Get fidget status for a specific LSP client
---@param client_name string The name of the LSP client
---@return table|nil
function M.get_fidget_status(client_name)
    if not config.fidget.enabled then return nil end

    local success, fidget = pcall(require, 'fidget')
    if not success then return nil end

    local status = {}

    -- Try different possible API methods with error handling
    local get_status_success, result = pcall(function()
        if fidget.get_status then
            return fidget.get_status()
        elseif fidget.get_progress then
            return { progress = fidget.get_progress() }
        elseif fidget.get_notifications then
            return { notifications = fidget.get_notifications() }
        else
            return nil
        end
    end)

    if not get_status_success or not result then return nil end

    status = result

    -- Look for status related to this client
    if status and status.progress then
        for _, progress in pairs(status.progress) do
            if progress.lsp and progress.lsp.client_name == client_name then return progress end
        end
    end

    -- Also check notifications
    if status and status.notifications then
        for _, notification in pairs(status.notifications) do
            if notification.lsp and notification.lsp.client_name == client_name then return notification end
        end
    end

    return nil
end

return M
