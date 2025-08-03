# LSPInfo.nvim

A Neovim plugin that provides a dynamic telescope picker for viewing and managing LSP (Language Server Protocol) client information in real-time.

## Features

- 🔍 **Dynamic Telescope Picker**: View all running LSP clients with detailed information
- 📊 **Real-time Updates**: See LSP client status changes dynamically in the previewer
- 🎯 **Buffer Information**: View attached buffers with diagnostic counts for each LSP client
- ⚡ **LSP Actions**: Restart, stop, and start LSP servers directly from the picker
- 🎨 **Beautiful UI**: Clean, organized display with syntax highlighting
- 🔧 **Configurable**: Customize telescope theme and update intervals

## Requirements

- Neovim 0.8.0+
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)

## Installation

### Using lazy.nvim (Recommended)

```lua
{
    'msc5/lspinfo.nvim',
    dependencies = {
        'nvim-telescope/telescope.nvim',
        'nvim-lua/plenary.nvim',
    },
    config = function()
        require('lspinfo').setup({
            -- Configuration options (see Configuration section)
        })
    end,
}
```

### Using packer.nvim

```lua
use({
    'msc5/lspinfo.nvim',
    requires = {
        'nvim-telescope/telescope.nvim',
        'nvim-lua/plenary.nvim',
    },
    config = function()
        require('lspinfo').setup()
    end,
})
```

### Using vim-plug

```vim
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'msc5/lspinfo.nvim'
```

Then in your init.lua:
```lua
require('lspinfo').setup()
```

## Usage

### Commands

- `:LSPInfo` - Open the LSP client information picker

### Keymaps

You can also bind the command to a keymap:

```lua
-- In your init.lua or keymaps file
vim.keymap.set('n', '<leader>li', '<cmd>LSPInfo<cr>', { desc = 'Show LSP Info' })
```

### Programmatic Usage

```lua
-- Show LSP info picker
require('lspinfo').show()

-- Or call the clients module directly
require('lspinfo.clients')()
```

## Configuration

The plugin can be configured by passing options to the `setup()` function:

```lua
require('lspinfo').setup({
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
        enabled = false,           -- Enable fidget.nvim integration
        display_mode = 'inline',   -- 'inline', 'section', or 'minimal'
        show_notifications = true, -- Show fidget notifications
        show_progress = true,      -- Show fidget progress
    },
    -- Display options
    display = {
        show_diagnostics = true,   -- Show diagnostic counts
        show_buffers = true,       -- Show buffer information
        show_capabilities = false, -- Show client capabilities
        show_root_dir = true,      -- Show root directory
        show_status = true,        -- Show client status
        show_initialized = true,   -- Show initialization status
    },
    -- Keymaps for the picker
    keymaps = {
        restart = 'r',             -- Restart LSP server
        stop = 's',                -- Stop LSP server
        start = 't',               -- Start LSP server
        capabilities = 'c',        -- Show capabilities
        close = '<Esc>',           -- Close picker
    },
})
```

### Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `telescope_theme` | table | See above | Telescope picker theme configuration |
| `command_name` | string | `'LSPInfo'` | Name of the user command |
| `enable_dynamic_updates` | boolean | `true` | Enable real-time updates in previewer |
| `update_interval` | number | `1000` | Update interval in milliseconds |
| `fidget.enabled` | boolean | `false` | Enable fidget.nvim integration |
| `fidget.display_mode` | string | `'inline'` | How to display fidget status |
| `fidget.show_notifications` | boolean | `true` | Show fidget notifications |
| `fidget.show_progress` | boolean | `true` | Show fidget progress |
| `fidget.auto_disable` | boolean | `true` | Auto-disable if fidget API unavailable |
| `display.show_diagnostics` | boolean | `true` | Show diagnostic counts |
| `display.show_buffers` | boolean | `true` | Show buffer information |
| `display.show_capabilities` | boolean | `false` | Show client capabilities |
| `display.show_root_dir` | boolean | `true` | Show root directory |
| `display.show_status` | boolean | `true` | Show client status |
| `display.show_initialized` | boolean | `true` | Show initialization status |
| `keymaps.restart` | string | `'r'` | Key to restart LSP server |
| `keymaps.stop` | string | `'s'` | Key to stop LSP server |
| `keymaps.start` | string | `'t'` | Key to start LSP server |
| `keymaps.capabilities` | string | `'c'` | Key to show capabilities |
| `keymaps.close` | string | `'<Esc>'` | Key to close picker |

## Features in Detail

### Dynamic Previewer

The previewer shows detailed information about each LSP client:

- **Client Name**: The name of the LSP server
- **ID**: Unique identifier for the client
- **Root Directory**: The workspace root directory
- **Current Buffer**: Whether the client is attached to the current buffer
- **Status**: Running or stopped status
- **Initialized**: Whether the client has completed initialization
- **Attached Buffers**: List of all buffers with diagnostic counts

### Real-time Updates

The previewer updates automatically when:
- LSP clients start or stop
- Buffers are attached or detached
- Diagnostic counts change
- Client status changes

### Fidget.nvim Integration

When enabled, the plugin integrates with [fidget.nvim](https://github.com/j-hui/fidget.nvim) to show:
- **Progress messages**: Real-time progress updates from LSP servers
- **Notifications**: Important notifications from LSP servers
- **Status information**: Current LSP server status and activity

To enable fidget.nvim integration:

```lua
require('lspinfo').setup({
    fidget = {
        enabled = true,
        show_progress = true,
        show_notifications = true,
    },
})
```

**Note**: Make sure you have fidget.nvim installed and configured in your Neovim setup.

### LSP Actions

When you select an LSP client entry, you can perform actions:
- **Restart Server**: Stop and restart the LSP server
- **Stop Server**: Stop the LSP server
- **Start Server**: Start the LSP server (if stopped)
- **Capabilities**: View detailed server capabilities
- **LSP Commands**: Execute custom LSP commands

## Troubleshooting

### No LSP clients shown

Make sure you have LSP servers configured and running. You can check with:
```lua
vim.lsp.get_clients()
```

### Telescope not found

Ensure you have telescope.nvim installed and configured:
```lua
-- In your init.lua
require('telescope').setup()
```

### Dynamic updates not working

Check that `enable_dynamic_updates` is set to `true` in your configuration. You can also adjust the `update_interval` if updates are too frequent or slow.

### Fidget.nvim integration issues

If you encounter errors with fidget.nvim integration:

1. **API compatibility**: The plugin automatically detects fidget API compatibility
2. **Auto-disable**: Set `fidget.auto_disable = true` to automatically disable if fidget is unavailable
3. **Manual disable**: Set `fidget.enabled = false` to completely disable fidget integration
4. **Check fidget version**: Ensure you have a compatible version of fidget.nvim installed

The plugin will show a warning notification if fidget integration is auto-disabled.

### Plugin not loading

If you get an error like `module 'lspinfo' not found`, make sure:

1. The plugin is properly installed in your Neovim configuration
2. You're using the correct plugin manager configuration
3. The plugin directory structure is correct (should be `lua/lspinfo/`)

You can test if the plugin loads correctly by running:
```lua
:lua print(require('lspinfo') ~= nil and "Plugin loaded!" or "Plugin not found")
```

### Testing the plugin

You can run a simple test to verify the plugin works:
```lua
-- In Neovim, run this command:
:lua dofile('test_plugin.lua')
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- Inspired by the need for better LSP client management in Neovim 