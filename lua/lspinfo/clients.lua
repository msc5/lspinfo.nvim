local constants = require 'lspinfo.constants'

local finders = require 'telescope.finders'
local pickers = require 'telescope.pickers'
local telescope_config = require('telescope.config').values
local Format = require 'lspinfo.format'
local Path = require 'plenary.path'

local action_state = require 'telescope.actions.state'
local actions = require 'telescope.actions'
local entry_display = require 'telescope.pickers.entry_display'
local previewers = require 'telescope.previewers'

--- Collects all LSP clients
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
---@return string, string
local function get_client_status_display(client)
    local current_buf = vim.api.nvim_get_current_buf()
    local status, status_color = '', ''
    if client:is_stopped() then
        status, status_color = 'stopped', 'Error'
    elseif client.attached_buffers[current_buf] then
        if client.initialized then
            status, status_color = ' * ', 'Added'
        else
            status, status_color = '...', 'WarningMsg'
        end
    end
    return status, status_color
end

---@param client vim.lsp.Client
---@return string
local function get_client_n_buffers_display(client)
    local n_buffers = vim.tbl_count(client.attached_buffers)
    if n_buffers > 0 then
        return n_buffers .. ' Buffer' .. (n_buffers == 1 and '' or 's')
    else
        return ''
    end
end

---@param entry vim.lsp.Client
---@return table<integer, string>
local function get_client_files(entry)
    local files = {}
    for bufnr, _ in pairs(entry.attached_buffers) do
        local filename = vim.api.nvim_buf_get_name(bufnr)
        filename = Path:new(filename):make_relative(vim.fn.getcwd())
        files[bufnr] = filename
    end
    return files
end

--- LSP Server picker with additional functionality
---@param opts?
return function(opts)
    opts = opts or constants.default_telescope_theme

    local picker_instance = pickers.new(opts, {
        prompt_title = '',
        finder = finders.new_table {
            results = get_clients(),
            entry_maker = function(entry)
                local status, status_color = get_client_status_display(entry)
                local n_buffers = get_client_n_buffers_display(entry)

                return {
                    value = entry,
                    ordinal = entry.name,
                    display = function()
                        local displayer = entry_display.create {
                            separator = ' ',
                            items = {
                                { width = 7 },
                                { width = 5 },
                                { width = 40 },
                                { width = 20 },
                                { remaining = true },
                            },
                        }
                        return displayer {
                            { status, status_color },
                            { entry.id or '', 'Constant' },
                            { entry.name, entry.config and 'Operator' or 'Comment' },
                            { n_buffers, 'Macro' },
                        }
                    end,
                }
            end,
        },
        previewer = previewers.new_buffer_previewer {
            title = 'Client Information',
            ---@param self
            ---@param entry {value: vim.lsp.Client}
            ---@param status
            define_preview = function(self, entry, status)
                -- Set window options
                vim.wo[self.state.winid].wrap = true

                local is_current_buffer = entry.value.attached_buffers[vim.api.nvim_get_current_buf()] ~= nil

                local fmt = Format:create()
                fmt:add_line { text = entry.value.name, hlgroup = 'Title' }

                local config = require('lspinfo.setup').get_config()
                local info = {}

                -- Add basic client information based on display config
                if config.display.show_status then
                    table.insert(info, {
                        'Status',
                        {
                            text = entry.value:is_stopped() and 'Stopped' or 'Running',
                            hlgroup = entry.value:is_stopped() and 'ErrorMsg' or 'String',
                        },
                    })
                end

                table.insert(info, {
                    'ID',
                    {
                        text = tostring(entry.value.id),
                        hlgroup = 'String',
                    },
                })

                if config.display.show_root_dir then
                    table.insert(info, {
                        'Root Directory',
                        {
                            text = entry.value.root_dir or 'nil',
                            hlgroup = entry.value.root_dir ~= nil and 'String' or 'Comment',
                        },
                    })
                end

                table.insert(info, {
                    'Current Buffer',
                    {
                        text = is_current_buffer and 'Yes' or 'No',
                        hlgroup = 'String',
                    },
                })

                if config.display.show_initialized then
                    table.insert(info, {
                        'Initialized',
                        {
                            text = entry.value.initialized and 'Yes' or 'No',
                            hlgroup = entry.value.initialized and 'String' or 'WarningMsg',
                        },
                    })
                end

                for _, i in pairs(info) do
                    fmt:tabulate(unpack(i))
                end

                -- Add fidget.nvim status if enabled
                if config.fidget.enabled then
                    local fidget_status = require('lspinfo.setup').get_fidget_status(entry.value.name)
                    if fidget_status then
                        fmt:section 'Fidget Status'

                        -- Handle different fidget status structures
                        if config.fidget.show_progress then
                            if fidget_status.progress then
                                for _, progress in pairs(fidget_status.progress) do
                                    if progress.message then
                                        fmt:tabulate(
                                            { width = 15, text = 'Progress' },
                                            { width = 50, text = progress.message, hlgroup = 'String' }
                                        )
                                    end
                                end
                            elseif fidget_status.message then
                                -- Direct message in status
                                fmt:tabulate(
                                    { width = 15, text = 'Status' },
                                    { width = 50, text = fidget_status.message, hlgroup = 'String' }
                                )
                            end
                        end

                        if config.fidget.show_notifications then
                            if fidget_status.notifications then
                                for _, notification in pairs(fidget_status.notifications) do
                                    if notification.message then
                                        fmt:tabulate(
                                            { width = 15, text = 'Notification' },
                                            { width = 50, text = notification.message, hlgroup = 'Comment' }
                                        )
                                    end
                                end
                            elseif fidget_status.title then
                                -- Direct notification
                                fmt:tabulate(
                                    { width = 15, text = 'Notification' },
                                    { width = 50, text = fidget_status.title, hlgroup = 'Comment' }
                                )
                            end
                        end
                    end
                end

                if config.display.show_buffers then
                    fmt:section 'Attached Buffers'
                    local files = get_client_files(entry.value)
                    if vim.tbl_count(files) > 0 then
                        for bufnr, filename in pairs(files) do
                            local hints = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.HINT })
                            local errors = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.ERROR })
                            local warnings = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.WARN })

                            if config.display.show_diagnostics then
                                fmt:tabulate(
                                    { width = 5, text = tostring(bufnr) },
                                    { width = 40, text = filename, hlgroup = 'Tag' },
                                    { width = 10, text = string.format('%3d  ', hints), hlgroup = 'Character' },
                                    { width = 10, text = string.format('%3d  ', warnings), hlgroup = 'WarningMsg' },
                                    { width = 10, text = string.format('%3d  ', errors), hlgroup = 'ErrorMsg' }
                                )
                            else
                                fmt:tabulate(
                                    { width = 5, text = tostring(bufnr) },
                                    { width = 40, text = filename, hlgroup = 'Tag' }
                                )
                            end
                        end
                    else
                        fmt:add_line { text = 'No Buffers Attached', hlgroup = 'Comment' }
                    end
                end

                fmt:set_lines(self.state.bufnr)
            end,
        },
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
