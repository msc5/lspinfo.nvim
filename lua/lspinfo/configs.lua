local constants = require 'lspinfo.constants'

local entry_display = require 'telescope.pickers.entry_display'
local lspconfig = require 'lspconfig'
local telescope_config = require('telescope.config').values
local finders = require 'telescope.finders'
local pickers = require 'telescope.pickers'

--- Collect all LSP Configs from lspconfig
---@return lspconfig.Config[]
local function get_configs()
    --

    ---@type lspconfig.Config[]
    local configs = {}
    for name, config in pairs(require 'lspconfig.configs') do
        table.insert(configs, config)
    end

    return configs
end

--- LSP Client picker with additional functionality
---@param opts?
return function(opts)
    opts = opts or constants.default_telescope_theme

    pickers
        .new(opts, {
            prompt_title = 'Configured LSP Clients',
            sorter = telescope_config.generic_sorter(opts),
            finder = finders.new_table {
                results = get_configs(),
                ---@param entry lspconfig.Config
                entry_maker = function(entry)
                    return {
                        value = entry,
                        ordinal = entry.name,
                        display = function()
                            local displayer = entry_display.create {
                                separator = ' ',
                                items = {
                                    { width = 40 },
                                    { remaining = true },
                                },
                            }
                            return displayer {
                                { entry.name },
                                { table.concat(entry.filetypes, ', ') },
                            }
                        end,
                    }
                end,
            },
        })
        :find()
end
