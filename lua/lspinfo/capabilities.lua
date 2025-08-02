local constants = require 'lspinfo.constants'

local finders = require 'telescope.finders'
local pickers = require 'telescope.pickers'
local config = require('telescope.config').values
local entry_display = require 'telescope.pickers.entry_display'
local helpers = require 'lspinfo.helpers'

--- Flatten LSP Client capabilities table
---@param client vim.lsp.Client
---@return table<string, any>
local function get_flat_lsp_capabilities(client)
    local flat_capabilities = {}
    local function flatten_capabilities(key, section, keys)
        if type(section) == 'table' and not helpers.is_array(section) then
            table.insert(keys, key)
            for subkey, subsection in pairs(section) do
                local sub_flat_key, value = flatten_capabilities(subkey, subsection, vim.deepcopy(keys))
                if sub_flat_key then
                    table.insert(flat_capabilities, {
                        key = sub_flat_key,
                        value = value,
                    })
                end
            end
        else
            return table.concat(keys, '/'), section
        end
    end

    flatten_capabilities('', client.capabilities, {})
    return flat_capabilities
end

--- Creates a new telescope picker with actions related to the given language server
---@param client vim.lsp.Client
---@param opts?
return function(client, opts)
    opts = opts or constants.default_telescope_theme

    pickers
        .new(opts, {
            prompt_title = ('%s Capabilities'):format(client.name),
            finder = finders.new_table {
                results = get_flat_lsp_capabilities(client),
                entry_maker = function(entry)
                    return {
                        value = entry,
                        ordinal = entry.key,
                        display = function()
                            local displayer = entry_display.create {
                                separator = ' ',
                                items = {
                                    { width = 80 },
                                    { remaining = true },
                                },
                            }
                            return displayer {
                                { entry.key },
                                { vim.inspect(entry.value), 'Constants' },
                            }
                        end,
                    }
                end,
            },
            sorter = config.generic_sorter(opts),
            -- attach_mappings = function(prompt_bufnr, map)
            --     actions.select_default:replace(function()
            --         actions_list.close(prompt_bufnr)
            --         local selection = state.get_selected_entry()
            --         selection.value.fn()
            --     end)
            --     return true
            -- end,
        })
        :find()
end
