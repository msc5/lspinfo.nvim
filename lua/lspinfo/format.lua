local helpers = require 'lspinfo.helpers'

local format = {}
format.__index = format

---@alias HL { hlgroup: string, line: number, start: number, stop: number }
---@alias FormatPart string | { text: string, hlgroup?: string, width?: number }
---@alias FormatParts FormatPart | FormatPart[]

function format:create()
    local fmt = {}
    setmetatable(fmt, format)

    ---@type table<string>
    fmt.lines = {}

    ---@type HL[]
    fmt.highlights = {}

    return fmt
end

--- Add a part to current line
---@param part FormatParts
function format:add_part(part)
    local current_line = self.lines[#self.lines]

    -- Handle when part is just a string
    if type(part) == 'string' then
        current_line = current_line .. part
        self.lines[#self.lines] = current_line

    -- Handle when part is a single part
    elseif part.text then
        local width = part.width or #part.text

        if part.hlgroup then
            table.insert(self.highlights, {
                hlgroup = part.hlgroup,
                line = #self.lines - 1,
                start = #current_line,
                stop = #current_line + width,
            })
        end

        current_line = current_line .. string.format('%-' .. width .. 's', part.text)
        self.lines[#self.lines] = current_line

    -- Handle when part is a list of parts
    elseif helpers.is_array(part) then
        for _, subpart in pairs(part) do
            self:add_part(subpart)
        end

    -- Error
    else
        print '[Error] Format:add_part()'
        print(vim.inspect(part))
    end
end

--- Add a line of text to buffer
---@param parts FormatParts
function format:add_line(parts)
    table.insert(self.lines, '')

    if type(parts) == 'string' or parts.text then
        self:add_part(parts)
        return
    end

    for _, part in pairs(parts) do
        self:add_part(part)
    end
end

--- Tabulate entries with a fixed width per column
---@param ... FormatParts
function format:tabulate(...)
    local columns = { ... }
    local parts = {}

    -- local maxWidth = 20
    -- for _, col in ipairs(columns) do
    --     if type(col) == 'string' then
    --         maxWidth = math.max(maxWidth, #col)
    --     elseif col.width then
    --         maxWidth = math.max(maxWidth, col.width)
    --     elseif col.text then
    --         maxWidth = math.max(maxWidth, #col.text)
    --     end
    -- end

    for _, col in ipairs(columns) do
        local part = {}
        if type(col) == 'string' then
            part = { text = col, width = 40 }
        else
            part = vim.tbl_extend('keep', col, { width = 40 })
        end
        table.insert(parts, part)
    end

    self:add_line(parts)
end

--- Add a section header
---@param name string
function format:section(name)
    self:add_line ''
    self:add_line { text = name, hlgroup = 'Constant' }
end

--- Set lines in buffer using vim API
---@param bufnr integer
function format:set_lines(bufnr)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, self.lines)

    -- Highlight text
    for _, hl in pairs(self.highlights) do
        vim.api.nvim_buf_add_highlight(bufnr, -1, hl.hlgroup, hl.line, hl.start, hl.stop)
    end
end

return format
