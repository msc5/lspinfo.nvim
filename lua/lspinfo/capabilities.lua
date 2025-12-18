local constants = require 'lspinfo.constants'
local capability_docs = require 'lspinfo.capability_docs'
local Format = require 'lspinfo.format'

local finders = require 'telescope.finders'
local pickers = require 'telescope.pickers'
local config = require('telescope.config').values
local entry_display = require 'telescope.pickers.entry_display'
local previewers = require 'telescope.previewers'
local helpers = require 'lspinfo.helpers'

--- Flatten LSP Client capabilities table
---@param client vim.lsp.Client
---@return table<{key: string, value: any, depth: number}>
local function get_flat_lsp_capabilities(client)
    local flat_capabilities = {}

    local function flatten_capabilities(key, section, keys, depth)
        if type(section) == 'table' and not helpers.is_array(section) then
            table.insert(keys, key)
            for subkey, subsection in pairs(section) do
                local sub_flat_key, value = flatten_capabilities(subkey, subsection, vim.deepcopy(keys), depth + 1)
                if sub_flat_key then
                    table.insert(flat_capabilities, {
                        key = sub_flat_key,
                        value = value,
                        depth = depth,
                    })
                end
            end
        else
            local full_key = table.concat(keys, '/')
            if full_key ~= '' then
                full_key = full_key .. '/'
            end
            return full_key .. key, section
        end
    end

    flatten_capabilities('', client.server_capabilities, {}, 0)

    -- Sort by key for consistent display
    table.sort(flat_capabilities, function(a, b)
        return a.key < b.key
    end)

    return flat_capabilities
end

--- Get status icon and color for a capability value
---@param value any
---@return string icon, string hlgroup
local function get_capability_status(value)
    if value == true then
        return '✓', 'Added'
    elseif value == false then
        return '✗', 'Error'
    elseif value == nil then
        return '○', 'Comment'
    elseif type(value) == 'table' then
        return '◆', 'Function'
    elseif type(value) == 'number' then
        return '●', 'Number'
    elseif type(value) == 'string' then
        return '●', 'String'
    else
        return '●', 'Normal'
    end
end

--- Format capability value for display
---@param value any
---@return string
local function format_value(value)
    if value == true then
        return 'Enabled'
    elseif value == false then
        return 'Disabled'
    elseif value == nil then
        return 'Not Supported'
    elseif type(value) == 'table' then
        if helpers.is_array(value) then
            if #value <= 3 then
                local items = {}
                for _, v in ipairs(value) do
                    table.insert(items, tostring(v))
                end
                return table.concat(items, ', ')
            else
                return string.format('%d items', #value)
            end
        else
            local count = vim.tbl_count(value)
            return string.format('%d properties', count)
        end
    elseif type(value) == 'number' then
        -- Document sync change modes
        if value == 0 then
            return '0 (None)'
        elseif value == 1 then
            return '1 (Full)'
        elseif value == 2 then
            return '2 (Incremental)'
        end
        return tostring(value)
    else
        local str = tostring(value)
        if #str > 30 then
            return str:sub(1, 27) .. '...'
        end
        return str
    end
end

--- Create previewer for capabilities
---@return table
local function create_capabilities_previewer()
    return previewers.new_buffer_previewer {
        title = 'Capability Details',
        define_preview = function(self, entry, status)
            local fmt = Format:create()
            local cap = entry.value
            local doc = capability_docs.get(cap.key)

            -- Title
            local display_name = doc and doc.name or capability_docs.get_short_description(cap.key)
            fmt:add_line { text = display_name, hlgroup = 'Title' }
            fmt:add_line ''

            -- Path
            fmt:tabulate(
                { text = 'Path', width = 20 },
                { text = cap.key, hlgroup = 'Identifier', width = 60 }
            )

            -- Status/Value
            local icon, hlgroup = get_capability_status(cap.value)
            fmt:tabulate(
                { text = 'Status', width = 20 },
                { text = icon .. ' ' .. format_value(cap.value), hlgroup = hlgroup, width = 60 }
            )

            -- Description
            if doc and doc.description then
                fmt:section 'Description'
                -- Word wrap description
                local desc = doc.description
                local max_width = 70
                local words = {}
                for word in desc:gmatch('%S+') do
                    table.insert(words, word)
                end
                local line = ''
                for _, word in ipairs(words) do
                    if #line + #word + 1 > max_width then
                        fmt:add_line { text = line, hlgroup = 'Normal' }
                        line = word
                    else
                        if line ~= '' then
                            line = line .. ' '
                        end
                        line = line .. word
                    end
                end
                if line ~= '' then
                    fmt:add_line { text = line, hlgroup = 'Normal' }
                end
            end

            -- Neovim Usage
            if doc and doc.nvim_usage then
                fmt:section 'Neovim Usage'
                fmt:add_line { text = doc.nvim_usage, hlgroup = 'String' }
            end

            -- LSP Methods
            if doc and doc.methods then
                fmt:section 'LSP Methods'
                fmt:add_line { text = doc.methods, hlgroup = 'Function' }
            end

            -- Help Tag
            if doc and doc.help_tag then
                fmt:section 'Help'
                fmt:add_line { text = ':help ' .. doc.help_tag, hlgroup = 'Underlined' }
            end

            -- Raw Value (if complex)
            if type(cap.value) == 'table' then
                fmt:section 'Raw Value'
                local inspected = vim.inspect(cap.value)
                local lines = vim.split(inspected, '\n')
                for i, line in ipairs(lines) do
                    if i <= 20 then
                        fmt:add_line { text = line, hlgroup = 'Comment' }
                    elseif i == 21 then
                        fmt:add_line { text = '... (truncated)', hlgroup = 'Comment' }
                        break
                    end
                end
            end

            fmt:set_lines(self.state.bufnr)
        end,
    }
end

--- Creates a new telescope picker with actions related to the given language server
---@param client vim.lsp.Client
---@param opts?
return function(client, opts)
    opts = opts or constants.default_telescope_theme

    local capabilities = get_flat_lsp_capabilities(client)

    pickers
        .new(opts, {
            prompt_title = ('%s Capabilities'):format(client.name),
            finder = finders.new_table {
                results = capabilities,
                entry_maker = function(entry)
                    local doc = capability_docs.get(entry.key)
                    local display_name = doc and doc.name or capability_docs.get_short_description(entry.key)
                    local icon, icon_hl = get_capability_status(entry.value)

                    return {
                        value = entry,
                        ordinal = entry.key .. ' ' .. display_name,
                        display = function()
                            local displayer = entry_display.create {
                                separator = ' ',
                                items = {
                                    { width = 2 },
                                    { width = 30 },
                                    { width = 25 },
                                    { remaining = true },
                                },
                            }
                            return displayer {
                                { icon, icon_hl },
                                { display_name, doc and 'Identifier' or 'Comment' },
                                { format_value(entry.value), icon_hl },
                                { entry.key, 'Comment' },
                            }
                        end,
                    }
                end,
            },
            previewer = create_capabilities_previewer(),
            sorter = config.generic_sorter(opts),
        })
        :find()
end
