local constants = require 'lspinfo.constants'

local finders = require 'telescope.finders'
local pickers = require 'telescope.pickers'
local telescope_config = require('telescope.config').values

local action_state = require 'telescope.actions.state'
local actions = require 'telescope.actions'
local entry_display = require 'telescope.pickers.entry_display'

local previewers = require 'lspinfo.previewers'

--- Collects and sorts all LSP clients
---@return vim.lsp.Client[]
local function get_clients()
    -- Get all clients attached to the current buffer (They should appear first)
    ---@type vim.lsp.Client[]
    local clients = vim.lsp.get_clients()

    -- Sort servers by whether they are attached to the current buffer
    -- otherwise by the number of buffers
    local current_buf = vim.api.nvim_get_current_buf()
    table.sort(clients, function(a, b)
        local a_is_attached, b_is_attached = a.attached_buffers[current_buf], b.attached_buffers[current_buf]
        local a_n_buffers, b_n_buffers = vim.tbl_count(a.attached_buffers), vim.tbl_count(b.attached_buffers)
        if (a_is_attached and b_is_attached) or (not a_is_attached and not b_is_attached) then
            return a_n_buffers > b_n_buffers
        end
        if b_is_attached then
            return false
        else
            return true
        end
    end)

    return clients
end

--- Get LSP Client status display string for telescope
---@param client vim.lsp.Client
---@return table
local function get_client_status_display(client, current_buf)
    local status, status_color = 'status', 'Macro'
    if client:is_stopped() then
        status, status_color = ' stopped ', 'Error'
    elseif client.attached_buffers[current_buf] then
        if client.initialized then
            status, status_color = '   buf   ', 'Added'
        else
            status, status_color = '   ...   ', 'WarningMsg'
        end
    end
    return { status, status_color }
end

---@param client vim.lsp.Client
---@return table
local function get_client_n_buffers_display(client)
    local n_buffers = vim.tbl_count(client.attached_buffers)
    local n_buffers_str = ''
    if n_buffers > 0 then
        n_buffers_str = n_buffers .. ' Buffer' .. (n_buffers == 1 and '' or 's')
    else
        n_buffers_str = ''
    end
    return { n_buffers_str, 'Macro' }
end

--- LSP Server picker with additional functionality
---@param opts?
return function(opts)
    opts = opts or constants.default_telescope_theme
    local current_buf = vim.api.nvim_get_current_buf()

    local picker_instance = pickers.new(opts, {
        prompt_title = '',
        finder = finders.new_table {
            results = get_clients(),
            entry_maker = function(entry)
                return {
                    value = entry,
                    ordinal = entry.name,
                    display = function()
                        local displayer = entry_display.create {
                            separator = ' ',
                            items = {
                                { width = 9 },
                                { width = 5 },
                                { width = 40 },
                                { width = 20 },
                                { remaining = true },
                            },
                        }
                        return displayer {
                            get_client_status_display(entry, current_buf),
                            { entry.id or '', 'Constant' },
                            { entry.name, entry.config and 'Operator' or 'Comment' },
                            get_client_n_buffers_display(entry),
                        }
                    end,
                }
            end,
        },
        previewer = previewers.lsp_clients,
        sorter = telescope_config.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                require 'lspinfo.actions'(selection.value)
            end)
            return true
        end,
    })

    picker_instance:find()
end
