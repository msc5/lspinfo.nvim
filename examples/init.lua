-- Example configuration for LSPInfo.nvim
-- This file shows different ways to configure the plugin

-- Basic setup (minimal configuration)
-- This should work after the plugin is properly installed
require('lspinfo').setup()

-- Advanced setup with custom configuration
require('lspinfo').setup {
    -- Custom telescope theme
    telescope_theme = {
        layout_strategy = 'horizontal',
        layout_config = {
            preview_width = 0.6,
            width = 0.8,
            height = 0.8,
        },
        results_title = 'LSP Clients',
        sorting_strategy = 'descending',
    },

    -- Custom command name
    command_name = 'LSPStatus',

    -- Disable dynamic updates for better performance
    enable_dynamic_updates = false,

    -- Faster update interval (500ms)
    update_interval = 500,
}

-- Example with keymaps
vim.keymap.set('n', '<leader>li', '<cmd>LSPInfo<cr>', {
    desc = 'Show LSP Info',
    silent = true,
})

-- Example with lazy.nvim configuration
-- Add this to your lazy.nvim setup:
--[[
{
    'msc5/lspinfo.nvim',
    dependencies = {
        'nvim-telescope/telescope.nvim',
        'nvim-lua/plenary.nvim',
    },
    config = function()
        require('lspinfo').setup({
            telescope_theme = {
                layout_strategy = 'vertical',
                layout_config = {
                    preview_height = 40,
                    width = 0.6,
                    height = 0.8,
                },
            },
            enable_dynamic_updates = true,
            update_interval = 1000,
        })
        
        -- Optional: Add keymap
        vim.keymap.set('n', '<leader>li', '<cmd>LSPInfo<cr>', {
            desc = 'Show LSP Info',
            silent = true
        })
    end,
}
--]]

-- Minimal configuration example
--[[
require('lspinfo').setup({
    display = { show_diagnostics = false },
})
--]]