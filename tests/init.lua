local busted = require("busted")
local assert = require("luassert")

-- Mock telescope and other dependencies for testing
local mock_telescope = {
    finders = {
        new_dynamic = function(opts)
            return {
                entry_maker = opts.entry_maker,
                fn = opts.fn
            }
        end
    },
    pickers = {
        new = function(opts, config)
            return {
                find = function() return true end,
                register_callback = function() return true end
            }
        end
    },
    config = {
        values = {
            generic_sorter = function() return function() return {} end end
        }
    },
    actions = {
        select_default = {
            replace = function() return true end
        },
        close = function() return true end
    },
    actions_state = {
        get_selected_entry = function() return { value = {} } end
    },
    previewers = {
        new_buffer_previewer = function(config)
            return {
                define_preview = config.define_preview
            }
        end
    }
}

-- Mock vim API
local mock_vim = {
    api = {
        nvim_get_current_buf = function() return 1 end,
        nvim_buf_get_name = function() return "test.lua" end,
        nvim_create_user_command = function() return true end,
        nvim_get_current_buf = function() return 1 end
    },
    lsp = {
        get_clients = function() 
            return {
                {
                    name = "lua_ls",
                    id = 1,
                    root_dir = "/test",
                    attached_buffers = { [1] = true },
                    initialized = true,
                    is_stopped = function() return false end
                }
            }
        end
    },
    diagnostic = {
        get = function() return {} end,
        severity = {
            HINT = 1,
            WARN = 2,
            ERROR = 3
        }
    },
    loop = {
        new_timer = function()
            return {
                start = function() return true end,
                stop = function() return true end,
                close = function() return true end
            }
        end
    },
    schedule_wrap = function(fn) return fn end,
    tbl_deep_extend = function(mode, ...)
        local result = {}
        for i = 1, select('#', ...) do
            local t = select(i, ...)
            for k, v in pairs(t) do
                result[k] = v
            end
        end
        return result
    end,
    tbl_count = function(t) return 1 end
}

-- Mock plenary
local mock_plenary = {
    Path = {
        new = function(path)
            return {
                make_relative = function() return path end
            }
        end
    }
}

-- Set up mocks
package.loaded['telescope'] = mock_telescope
package.loaded['plenary.path'] = mock_plenary.Path
_G.vim = mock_vim

describe("LSPInfo Plugin", function()
    local lspinfo
    
    setup(function()
        -- Load the plugin
        lspinfo = require('lspinfo')
    end)
    
    describe("Setup", function()
        it("should create setup function", function()
            assert.is_function(lspinfo.setup)
        end)
        
        it("should create show function", function()
            assert.is_function(lspinfo.show)
        end)
        
        it("should load all required modules", function()
            assert.is_table(lspinfo.constants)
            assert.is_table(lspinfo.format)
            assert.is_table(lspinfo.clients)
            assert.is_table(lspinfo.actions)
            assert.is_table(lspinfo.capabilities)
            assert.is_table(lspinfo.setup)
        end)
    end)
    
    describe("Configuration", function()
        it("should accept configuration options", function()
            local config = {
                command_name = "TestLSPInfo",
                enable_dynamic_updates = false,
                update_interval = 2000
            }
            
            -- This should not error
            lspinfo.setup(config)
        end)
        
        it("should have default configuration", function()
            local setup_module = require('lspinfo.setup')
            local config = setup_module.get_config()
            
            assert.is_string(config.command_name)
            assert.is_boolean(config.enable_dynamic_updates)
            assert.is_number(config.update_interval)
        end)
    end)
    
    describe("Client Information", function()
        it("should be able to get LSP clients", function()
            local clients = mock_vim.lsp.get_clients()
            assert.is_table(clients)
            assert.is_table(clients[1])
            assert.is_string(clients[1].name)
        end)
        
        it("should handle client status correctly", function()
            local client = {
                name = "test_ls",
                attached_buffers = { [1] = true },
                initialized = true,
                is_stopped = function() return false end
            }
            
            -- Test that we can access client properties without error
            assert.is_string(client.name)
            assert.is_boolean(client.initialized)
            assert.is_function(client.is_stopped)
        end)
    end)
    
    describe("Dynamic Updates", function()
        it("should support dynamic update configuration", function()
            local setup_module = require('lspinfo.setup')
            local config = setup_module.get_config()
            
            assert.is_boolean(config.enable_dynamic_updates)
            assert.is_number(config.update_interval)
        end)
    end)
end) 