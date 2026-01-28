local Format = require 'lspinfo.format'
local Job = require 'plenary.job'
local Path = require 'plenary.path'
local previewers = require 'telescope.previewers'
local setup = require 'lspinfo.setup'

local M = {}

local ICON_CHECK = '󰸞 '
local ICON_CHECKBOX_EMPTY = '󰄰 '
local ICON_CHECKBOX_FILLED = '󰄯 '

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

    local info = {
        {
            'ID',
            {
                text = ('%s (%s)'):format(entry.value.id, entry.value:is_stopped() and 'Stopped' or 'Running'),
                hlgroup = entry.value:is_stopped() and 'Error' or 'String',
            },
        },
        {
            'Root Directory',
            {
                text = entry.value.root_dir or 'nil',
                hlgroup = entry.value.root_dir ~= nil and 'String' or 'Comment',
            },
        },
        {
            'Server Info',
            {
                text = (entry.value.server_info and ('%s (%s)'):format(
                    entry.value.server_info.name,
                    entry.value.server_info.version
                ) or ''),
                hlgroup = 'Character',
            },
        },
        {
            'Command',
            {
                text = table.concat(entry.value.config.cmd, ' '),
                hlgroup = 'Character',
            },
        },
        {
            'Command Directory',
            {
                text = entry.value.config.cmd_cwd or 'nil',
                hlgroup = entry.value.config.cmd_cwd and 'Character' or 'Comment',
            },
        },
        {
            'Current Buffer',
            {
                text = is_current_buffer and 'Yes' or 'No',
                hlgroup = 'String',
            },
        },
        {
            'Initialized',
            {
                text = entry.value.initialized and 'Yes' or 'No',
                hlgroup = entry.value.initialized and 'String' or 'WarningMsg',
            },
        },
        {
            'Offset Encoding',
            {
                text = entry.value.offset_encoding or 'utf-16',
                hlgroup = 'Character',
            },
        },
        {
            'Filetypes',
            {
                text = entry.value.config.filetypes and table.concat(entry.value.config.filetypes, ', ') or 'N/A',
                hlgroup = entry.value.config.filetypes and 'String' or 'Comment',
            },
        },
    }

    for _, i in pairs(info) do
        fmt:tabulate(unpack(i))
    end

    -- Workspace Folders
    local workspace_folders = entry.value.workspace_folders
    if workspace_folders and #workspace_folders > 0 then
        fmt:section 'Workspace Folders'
        for _, folder in ipairs(workspace_folders) do
            local folder_path = folder.name or folder.uri
            if folder_path then
                -- Strip file:// prefix if present
                folder_path = folder_path:gsub('^file://', '')
                fmt:add_line { text = '  ' .. folder_path, hlgroup = 'Directory' }
            end
        end
    end

    fmt:section 'Attached Buffers'
    local files = get_client_files(entry.value)
    local total_hints, total_warnings, total_errors = 0, 0, 0
    if vim.tbl_count(files) > 0 then
        for bufnr, filename in pairs(files) do
            local hints = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.HINT })
            local errors = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.ERROR })
            local warnings = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.WARN })
            total_hints = total_hints + hints
            total_warnings = total_warnings + warnings
            total_errors = total_errors + errors

            fmt:tabulate(
                { width = 5, text = tostring(bufnr) },
                { width = 80, text = filename, hlgroup = 'Tag' },
                { width = 10, text = string.format('%3d  ', hints), hlgroup = 'Character' },
                { width = 10, text = string.format('%3d  ', warnings), hlgroup = 'WarningMsg' },
                { width = 10, text = string.format('%3d  ', errors), hlgroup = 'ErrorMsg' }
            )
        end
        -- Show totals row
        fmt:tabulate(
            { width = 5, text = '' },
            { width = 80, text = 'Total', hlgroup = 'Bold' },
            { width = 10, text = string.format('%3d  ', total_hints), hlgroup = 'Character' },
            { width = 10, text = string.format('%3d  ', total_warnings), hlgroup = 'WarningMsg' },
            { width = 10, text = string.format('%3d  ', total_errors), hlgroup = 'ErrorMsg' }
        )
    else
        fmt:add_line { text = 'No Buffers Attached', hlgroup = 'Comment' }
    end

    fmt:section 'LSP Messages'
    local messages = require('lspinfo.lsp').logs[entry.value.id]

    if messages then
        local progress_messages = messages['$/progress']
        if progress_messages then
            for token, msg in pairs(progress_messages) do
                local kind_icon, kind_color = ' ', 'Character'
                if msg.res.value.kind == 'report' then
                    kind_icon, kind_color = '󰈙 ', 'Function'
                elseif msg.res.value.kind == 'end' then
                    kind_icon, kind_color = ' ', 'Added'
                end

                if msg.res.value.message ~= nil then
                    fmt:add_line {
                        text = ('%s %s: "%s"'):format(kind_icon, msg.res.value.title, msg.res.value.message),
                        hlgroup = kind_color,
                    }
                else
                    fmt:add_line {
                        text = ('%s %s'):format(kind_icon, msg.res.value.title),
                        hlgroup = kind_color,
                    }
                end
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

    -- Key Capabilities Summary
    local caps = entry.value.server_capabilities
    if caps then
        fmt:section 'Capabilities'

        local capability_checks = {
            { 'Completion', caps.completionProvider },
            { 'Hover', caps.hoverProvider },
            { 'Signature Help', caps.signatureHelpProvider },
            { 'Go to Definition', caps.definitionProvider },
            { 'Go to Type Definition', caps.typeDefinitionProvider },
            { 'Go to Implementation', caps.implementationProvider },
            { 'Find References', caps.referencesProvider },
            { 'Document Highlight', caps.documentHighlightProvider },
            { 'Document Symbol', caps.documentSymbolProvider },
            { 'Workspace Symbol', caps.workspaceSymbolProvider },
            { 'Code Action', caps.codeActionProvider },
            { 'Code Lens', caps.codeLensProvider },
            { 'Document Formatting', caps.documentFormattingProvider },
            { 'Document Range Formatting', caps.documentRangeFormattingProvider },
            { 'Rename', caps.renameProvider },
            { 'Folding Range', caps.foldingRangeProvider },
            { 'Semantic Tokens', caps.semanticTokensProvider },
            { 'Inlay Hints', caps.inlayHintProvider },
            { 'Call Hierarchy', caps.callHierarchyProvider },
        }

        for _, cap in ipairs(capability_checks) do
            local name, supported = cap[1], cap[2]
            local icon = supported and ICON_CHECKBOX_FILLED or ICON_CHECKBOX_EMPTY
            local hlgroup = supported and 'Added' or 'Comment'
            fmt:tabulate({ width = 6, text = icon, hlgroup = hlgroup }, { width = 30, text = name, hlgroup = hlgroup })
        end
    end

    fmt:set_lines(self.state.bufnr)
end

local function dynamic_previewer(render_fn)
    ---@param self
    ---@param entry {value: vim.lsp.Client}
    ---@param status
    return function(self, entry, status)
        local user_config = setup.get_config()
        local enable_dynamic_updates = user_config.enable_dynamic_updates
        local update_interval = user_config.update_interval or 1000

        -- If dynamic updates are disabled, just render once
        if not enable_dynamic_updates then
            render_fn(self, entry, status)
            return
        end

        -- Stop any existing timer before creating a new one
        if self.state.cleanup then self.state.cleanup() end

        -- Set up timer for dynamic display
        local timer = vim.uv.new_timer()
        assert(timer ~= nil)

        -- stop timer when Telescope closes or selection changes
        self.state.cleanup = function()
            timer:stop()
            timer:close()
        end

        timer:start(0, update_interval, function()
            vim.schedule(function()
                if not is_buffer_valid(self.state.bufnr) then
                    timer:stop()
                    timer:close()
                    return
                end

                render_fn(self, entry, status)
            end)
        end)
    end
end

M.lsp_clients = previewers.new_buffer_previewer {
    title = 'LSP Client Information',
    define_preview = dynamic_previewer(render_lsp_clients),
}

return M
