local Format = require 'lspinfo.format'
local Job = require 'plenary.job'
local Path = require 'plenary.path'
local previewers = require 'telescope.previewers'

local M = {}

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

local function is_buffer_valid(bufnr) return type(bufnr) == 'number' and vim.api.nvim_buf_is_valid(bufnr) end

---@param self
---@param entry {value: vim.lsp.Client}
---@param status
local function render_lsp_clients(self, entry, status)
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
                hlgroup = entry.value:is_stopped() and 'Error' or 'String',
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
                        { width = 80, text = filename, hlgroup = 'Tag' },
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

    fmt:section 'LSP Messages'
    local messages = require('lspinfo.lsp').logs[entry.value.id]

    if messages then
        local progress_messages = messages['$/progress']
        if progress_messages then
            for token, msg in pairs(progress_messages) do
                if msg.res.value.message ~= nil then
                    fmt:add_line {
                        text = ('(%d %s): %s "%s"'):format(
                            token,
                            msg.res.value.kind,
                            msg.res.value.title,
                            msg.res.value.message
                        ),
                    }
                end
                fmt:add_line { text = ('(%d %s): %s'):format(token, msg.res.value.kind, msg.res.value.title) }
            end
        end

        -- TODO: Format these messages correctly
        -- local log_messages = messages['window/logMessage']
        -- if log_messages then
        --     for type, msg in pairs(log_messages) do
        --         fmt:add_line { text = msg.res.message:sub(1, 80) .. '...' }
        --     end
        -- end
    end

    fmt:set_lines(self.state.bufnr)
end

local function dynamic_previewer(render_fn)
    ---@param self
    ---@param entry {value: vim.lsp.Client}
    ---@param status
    return function(self, entry, status)
        -- Set up timer for dynamic display
        local timer = vim.uv.new_timer()
        assert(timer ~= nil)

        -- stop timer when Telescope closes
        self.state.cleanup = function()
            timer:stop()
            timer:close()
        end

        -- {
        --     token = 2,
        --     value = {
        --         kind = "report",
        --         message = "148/152",
        --         percentage = 97
        --     }
        -- }
        -- {
        --     token = 2,
        --     value = {
        --         kind = "end"
        --     }
        -- }

        timer:start(0, 100, function()
            vim.schedule(function()
                if is_buffer_valid(self.state.bufnr) then
                    render_fn(self, entry, status)
                else
                    timer:stop()
                    timer:close()
                end
            end)
        end)
    end
end

M.lsp_clients = previewers.new_buffer_previewer {
    title = 'LSP Client Information',
    define_preview = dynamic_previewer(render_lsp_clients),
}

return M
