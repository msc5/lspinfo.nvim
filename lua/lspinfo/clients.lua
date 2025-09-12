local constants = require 'lspinfo.constants'

local finders = require 'telescope.finders'
local pickers = require 'telescope.pickers'
local telescope_config = require('telescope.config').values

local action_state = require 'telescope.actions.state'
local actions = require 'telescope.actions'

local displayers = require 'lspinfo.displayers'
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

--- LSP Server picker with additional functionality
---@param opts?
return function(opts)
    opts = opts or constants.default_telescope_theme

    local picker_instance = pickers.new(opts, {
        prompt_title = '',
        finder = finders.new_table {
            results = get_clients(),
            entry_maker = displayers.lsp_clients,
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
