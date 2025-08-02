local constants = require 'lspinfo.constants'

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
    require('lspconfig')[client.name].launch()
    notify(client, 'Restarted')
end

---@param client vim.lsp.Client
local function stop_server(client)
    vim.lsp.stop_client(vim.lsp.get_clients { name = client.name })
    notify(client, 'Stopped')
end

---@param client vim.lsp.Client
local function start_server(client)
    require('lspconfig')[client.name].launch()
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
                actions.select_default:replace(function()
                    actions.close(prompt_bufnr)
                    local selection = state.get_selected_entry()
                    selection.value.fn(client)
                end)
                return true
            end,
        })
        :find()
end
