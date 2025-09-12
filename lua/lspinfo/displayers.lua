local entry_display = require 'telescope.pickers.entry_display'

local o = {}

--- Get LSP Client status display string for telescope
---@param client vim.lsp.Client
---@return table
local function get_client_status_display(client, current_buf)
    local status, status_color = '', 'Comment'
    if client:is_stopped() then
        status, status_color = 'stopped', 'Error'
    elseif client.attached_buffers[current_buf] then
        if client.initialized then
            status, status_color = 'current', 'Added'
        else
            status, status_color = '...', 'Warning'
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

function o.lsp_clients(entry)
    local current_buf = vim.api.nvim_get_current_buf()
    local displayer = entry_display.create {
        separator = ' ',
        items = {
            { width = 11 },
            { width = 5 },
            { width = 40 },
            { width = 20 },
            { remaining = true },
        },
    }

    return {
        value = entry,
        ordinal = entry.name,
        display = function()
            return displayer {
                get_client_status_display(entry, current_buf),
                { entry.id or '', 'Constant' },
                { entry.name, entry.config and 'Operator' or 'Comment' },
                get_client_n_buffers_display(entry),
            }
        end,
    }
end

return o
