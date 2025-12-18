local constants = require 'lspinfo.constants'
local setup = require 'lspinfo.setup'

local finders = require 'telescope.finders'
local pickers = require 'telescope.pickers'
local config = require('telescope.config').values
local actions = require 'telescope.actions'
local state = require 'telescope.actions.state'

local function notify(client, message)
    vim.notify(
        ('  %s "%s" '):format(message, client.name),
        vim.log.levels.INFO,
        { title = 'LSP Servers ', icon = '  ' }
    )
end

---@param client vim.lsp.Client
local function restart_server(client)
    vim.lsp.stop_client(vim.lsp.get_clients { name = client.name })
    vim.lsp.start(client.config)
    notify(client, 'Restarted')
end

---@param client vim.lsp.Client
local function stop_server(client)
    vim.lsp.stop_client(vim.lsp.get_clients { name = client.name })
    notify(client, 'Stopped')
end

---@param client vim.lsp.Client
local function start_server(client)
    vim.lsp.start(client.config)
    notify(client, 'Started')
end

--- Creates a new telescope picker with actions related to the given language server
---@param client vim.lsp.Client
---@param opts?
return function(client, opts)
    opts = opts or constants.default_telescope_theme

    local actions_list = {
        { name = 'Restart Server', fn = restart_server },
        { name = 'Stop Server', fn = stop_server },
        { name = 'Start Server', fn = start_server },
        { name = 'Capabilities', fn = require 'lspinfo.capabilities' },
    }

    -- Add LSP commands
    for name, command in pairs(client.commands) do
        table.insert(actions_list, { name = name, fn = command })
    end

    pickers
        .new(opts, {
            prompt_title = ('LSP "%s" Actions'):format(client.name),
            finder = finders.new_table {
                results = actions_list,
                entry_maker = function(entry)
                    return {
                        value = entry,
                        display = entry.name,
                        ordinal = entry.name,
                    }
                end,
            },
            sorter = config.generic_sorter(opts),
            attach_mappings = function(prompt_bufnr, map)
                local user_config = setup.get_config()
                local keymaps = user_config.keymaps or {}

                actions.select_default:replace(function()
                    actions.close(prompt_bufnr)
                    local selection = state.get_selected_entry()
                    selection.value.fn(client)
                end)

                -- Map configured keys to actions
                if keymaps.restart then
                    map('i', keymaps.restart, function()
                        actions.close(prompt_bufnr)
                        restart_server(client)
                    end)
                    map('n', keymaps.restart, function()
                        actions.close(prompt_bufnr)
                        restart_server(client)
                    end)
                end

                if keymaps.stop then
                    map('i', keymaps.stop, function()
                        actions.close(prompt_bufnr)
                        stop_server(client)
                    end)
                    map('n', keymaps.stop, function()
                        actions.close(prompt_bufnr)
                        stop_server(client)
                    end)
                end

                if keymaps.start then
                    map('i', keymaps.start, function()
                        actions.close(prompt_bufnr)
                        start_server(client)
                    end)
                    map('n', keymaps.start, function()
                        actions.close(prompt_bufnr)
                        start_server(client)
                    end)
                end

                if keymaps.capabilities then
                    map('i', keymaps.capabilities, function()
                        actions.close(prompt_bufnr)
                        require('lspinfo.capabilities')(client)
                    end)
                    map('n', keymaps.capabilities, function()
                        actions.close(prompt_bufnr)
                        require('lspinfo.capabilities')(client)
                    end)
                end

                if keymaps.close then
                    map('i', keymaps.close, function() actions.close(prompt_bufnr) end)
                    map('n', keymaps.close, function() actions.close(prompt_bufnr) end)
                end

                return true
            end,
        })
        :find()
end
