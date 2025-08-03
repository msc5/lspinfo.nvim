local M = {}

---@class LSPClientMessage
---@field ctx lsp.HandlerContext
---@field res lsp.LogMessageParams | lsp.ProgressParams

---@class LSPClientMessages
---@field ["$/progress"] table<lsp.ProgressToken, LSPClientMessage>
---@field ["window/logMessage"] Array<LSPClientMessage>

---@type table<integer, LSPClientMessages>
M.logs = {}

---@param res lsp.LogMessageParams | lsp.ProgressParams
---@param ctx lsp.HandlerContext
---@param lsp_handler string
local function add_log_message(res, ctx, lsp_handler)
    M.logs[ctx.client_id] = M.logs[ctx.client_id] or {}
    M.logs[ctx.client_id][lsp_handler] = M.logs[ctx.client_id][lsp_handler] or {}
    local lsp_messages = M.logs[ctx.client_id][lsp_handler]

    if lsp_handler == '$/progress' then
        lsp_messages[res.token] = { ctx = ctx, res = res }
    elseif lsp_handler == 'window/logMessage' then
        table.insert(lsp_messages, { ctx = ctx, res = res })
    end
end

---@param lsp_handler string
M.setup_listener = function(lsp_handler)
    local existing_handler = vim.lsp.handlers[lsp_handler]

    ---@param err
    ---@param res lsp.ProgressParams | lsp.LogMessageParams
    ---@param ctx lsp.HandlerContext
    vim.lsp.handlers[lsp_handler] = function(err, res, ctx)
        local entry = vim.tbl_extend('keep', res, ctx)

        -- Add entry to log table
        add_log_message(res, ctx, lsp_handler)

        -- Call existing handler
        if existing_handler then existing_handler(err, res, ctx) end
    end
end

M.setup_lsp_listeners = function()
    M.setup_listener '$/progress'
    M.setup_listener 'window/logMessage'
end

return M
