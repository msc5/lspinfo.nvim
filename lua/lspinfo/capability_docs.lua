-- LSP Capability Documentation
-- Maps capability paths to descriptions, neovim usage, and help tags

local M = {}

---@class CapabilityDoc
---@field name string Short display name
---@field description string What the capability does
---@field nvim_usage string|nil How it's used in neovim
---@field help_tag string|nil Neovim help tag
---@field methods string|nil LSP methods enabled by this capability

-- Main capability documentation table
-- Keys are capability paths (e.g., "textDocument/completion")
M.docs = {
    -- Completion
    ['completionProvider'] = {
        name = 'Completion',
        description = 'Provides code completion suggestions as you type. Returns a list of completion items with labels, documentation, and edit operations.',
        nvim_usage = 'vim.lsp.buf.completion(), omnifunc, or nvim-cmp/coq_nvim plugins',
        help_tag = 'lsp-completion',
        methods = 'textDocument/completion',
    },
    ['completionProvider/triggerCharacters'] = {
        name = 'Completion Triggers',
        description = 'Characters that automatically trigger completion (e.g., "." for method access, ":" for static methods).',
        nvim_usage = 'Triggers automatic completion popup',
        help_tag = 'lsp-completion',
    },
    ['completionProvider/resolveProvider'] = {
        name = 'Completion Resolve',
        description = 'Server can provide additional details for completion items on demand, reducing initial payload size.',
        nvim_usage = 'Lazy-loads documentation when selecting completion items',
        methods = 'completionItem/resolve',
    },

    -- Hover
    ['hoverProvider'] = {
        name = 'Hover',
        description = 'Shows documentation and type information when hovering over symbols. Displays in a floating window.',
        nvim_usage = 'vim.lsp.buf.hover() - typically mapped to K',
        help_tag = 'lsp-hover',
        methods = 'textDocument/hover',
    },

    -- Signature Help
    ['signatureHelpProvider'] = {
        name = 'Signature Help',
        description = 'Shows function signature and parameter info while typing function arguments.',
        nvim_usage = 'vim.lsp.buf.signature_help() - typically mapped to <C-k> in insert mode',
        help_tag = 'lsp-signature-help',
        methods = 'textDocument/signatureHelp',
    },
    ['signatureHelpProvider/triggerCharacters'] = {
        name = 'Signature Triggers',
        description = 'Characters that trigger signature help (typically "(" and ",").',
        nvim_usage = 'Auto-shows signature when typing function calls',
    },
    ['signatureHelpProvider/retriggerCharacters'] = {
        name = 'Signature Retriggers',
        description = 'Characters that re-trigger signature help while already active.',
    },

    -- Declaration/Definition/Type Definition/Implementation
    ['declarationProvider'] = {
        name = 'Go to Declaration',
        description = 'Jumps to symbol declaration (where it is declared, e.g., header files in C/C++).',
        nvim_usage = 'vim.lsp.buf.declaration()',
        help_tag = 'lsp-declaration',
        methods = 'textDocument/declaration',
    },
    ['definitionProvider'] = {
        name = 'Go to Definition',
        description = 'Jumps to where a symbol is defined (implementation location).',
        nvim_usage = 'vim.lsp.buf.definition() - typically mapped to gd',
        help_tag = 'lsp-definition',
        methods = 'textDocument/definition',
    },
    ['typeDefinitionProvider'] = {
        name = 'Go to Type Definition',
        description = 'Jumps to the type definition of a symbol (e.g., class definition for a variable).',
        nvim_usage = 'vim.lsp.buf.type_definition()',
        help_tag = 'lsp-type-definition',
        methods = 'textDocument/typeDefinition',
    },
    ['implementationProvider'] = {
        name = 'Go to Implementation',
        description = 'Jumps to implementations of an interface or abstract method.',
        nvim_usage = 'vim.lsp.buf.implementation()',
        help_tag = 'lsp-implementation',
        methods = 'textDocument/implementation',
    },

    -- References
    ['referencesProvider'] = {
        name = 'Find References',
        description = 'Finds all references to a symbol throughout the project.',
        nvim_usage = 'vim.lsp.buf.references() - typically mapped to gr',
        help_tag = 'lsp-references',
        methods = 'textDocument/references',
    },

    -- Document Highlight
    ['documentHighlightProvider'] = {
        name = 'Document Highlight',
        description = 'Highlights all occurrences of the symbol under cursor in the current document.',
        nvim_usage = 'vim.lsp.buf.document_highlight() and vim.lsp.buf.clear_references()',
        help_tag = 'lsp-document-highlight',
        methods = 'textDocument/documentHighlight',
    },

    -- Document Symbols
    ['documentSymbolProvider'] = {
        name = 'Document Symbols',
        description = 'Lists all symbols (functions, classes, variables) in the current document for navigation.',
        nvim_usage = 'vim.lsp.buf.document_symbol() - used by telescope, aerial, nvim-navic',
        help_tag = 'lsp-document-symbol',
        methods = 'textDocument/documentSymbol',
    },

    -- Workspace Symbols
    ['workspaceSymbolProvider'] = {
        name = 'Workspace Symbols',
        description = 'Searches for symbols across the entire workspace/project.',
        nvim_usage = 'vim.lsp.buf.workspace_symbol() - used by telescope lsp_workspace_symbols',
        help_tag = 'lsp-workspace-symbol',
        methods = 'workspace/symbol',
    },
    ['workspaceSymbolProvider/resolveProvider'] = {
        name = 'Workspace Symbol Resolve',
        description = 'Server can provide additional details for workspace symbols on demand.',
        methods = 'workspaceSymbol/resolve',
    },

    -- Code Action
    ['codeActionProvider'] = {
        name = 'Code Actions',
        description = 'Provides quick fixes, refactorings, and source actions (organize imports, extract method, etc.).',
        nvim_usage = 'vim.lsp.buf.code_action() - typically mapped to <leader>ca',
        help_tag = 'lsp-code-action',
        methods = 'textDocument/codeAction',
    },
    ['codeActionProvider/codeActionKinds'] = {
        name = 'Code Action Kinds',
        description = 'Types of code actions supported (quickfix, refactor, source, etc.).',
        nvim_usage = 'Filter code actions by kind in vim.lsp.buf.code_action({context={only={...}}})',
    },
    ['codeActionProvider/resolveProvider'] = {
        name = 'Code Action Resolve',
        description = 'Server can provide full edit details for code actions on demand.',
        methods = 'codeAction/resolve',
    },

    -- Code Lens
    ['codeLensProvider'] = {
        name = 'Code Lens',
        description = 'Shows actionable information above code (run tests, show references count, etc.).',
        nvim_usage = 'vim.lsp.codelens.refresh() and vim.lsp.codelens.run()',
        help_tag = 'lsp-codelens',
        methods = 'textDocument/codeLens',
    },
    ['codeLensProvider/resolveProvider'] = {
        name = 'Code Lens Resolve',
        description = 'Server can provide command details for code lenses on demand.',
        methods = 'codeLens/resolve',
    },

    -- Document Link
    ['documentLinkProvider'] = {
        name = 'Document Links',
        description = 'Detects clickable links in documents (URLs, file references, etc.).',
        nvim_usage = 'Links can be followed with gx or custom handlers',
        methods = 'textDocument/documentLink',
    },
    ['documentLinkProvider/resolveProvider'] = {
        name = 'Document Link Resolve',
        description = 'Server can provide full URI details for links on demand.',
        methods = 'documentLink/resolve',
    },

    -- Document Color
    ['colorProvider'] = {
        name = 'Document Colors',
        description = 'Provides color information for color literals in the document.',
        nvim_usage = 'Used by plugins like nvim-colorizer to show color previews',
        methods = 'textDocument/documentColor, textDocument/colorPresentation',
    },

    -- Formatting
    ['documentFormattingProvider'] = {
        name = 'Document Formatting',
        description = 'Formats the entire document according to language style rules.',
        nvim_usage = 'vim.lsp.buf.format() - typically mapped to <leader>f or format on save',
        help_tag = 'lsp-format',
        methods = 'textDocument/formatting',
    },
    ['documentRangeFormattingProvider'] = {
        name = 'Range Formatting',
        description = 'Formats a selected range of code rather than the entire document.',
        nvim_usage = 'vim.lsp.buf.format() with range parameter, or visual mode formatting',
        help_tag = 'lsp-format',
        methods = 'textDocument/rangeFormatting',
    },
    ['documentOnTypeFormattingProvider'] = {
        name = 'On-Type Formatting',
        description = 'Automatically formats code as you type (e.g., after pressing Enter or semicolon).',
        nvim_usage = 'Automatic formatting triggered by specific characters',
        methods = 'textDocument/onTypeFormatting',
    },
    ['documentOnTypeFormattingProvider/firstTriggerCharacter'] = {
        name = 'Format Trigger',
        description = 'Primary character that triggers on-type formatting.',
    },
    ['documentOnTypeFormattingProvider/moreTriggerCharacter'] = {
        name = 'Additional Format Triggers',
        description = 'Additional characters that trigger on-type formatting.',
    },

    -- Rename
    ['renameProvider'] = {
        name = 'Rename Symbol',
        description = 'Renames a symbol across all files in the project.',
        nvim_usage = 'vim.lsp.buf.rename() - typically mapped to <leader>rn',
        help_tag = 'lsp-rename',
        methods = 'textDocument/rename',
    },
    ['renameProvider/prepareProvider'] = {
        name = 'Rename Prepare',
        description = 'Server can validate rename and provide default text before executing.',
        nvim_usage = 'Pre-populates rename prompt with correct symbol name',
        methods = 'textDocument/prepareRename',
    },

    -- Folding
    ['foldingRangeProvider'] = {
        name = 'Folding Ranges',
        description = 'Provides code folding ranges based on language syntax.',
        nvim_usage = 'Used with foldmethod=expr and vim.lsp.foldexpr()',
        help_tag = 'lsp-folding',
        methods = 'textDocument/foldingRange',
    },

    -- Selection Range
    ['selectionRangeProvider'] = {
        name = 'Selection Ranges',
        description = 'Provides smart selection expansion (select word -> expression -> statement -> function).',
        nvim_usage = 'vim.lsp.buf.selection_range() or treesitter-based selection',
        methods = 'textDocument/selectionRange',
    },

    -- Execute Command
    ['executeCommandProvider'] = {
        name = 'Execute Command',
        description = 'Server supports executing custom commands (used by code actions and code lenses).',
        nvim_usage = 'vim.lsp.buf.execute_command()',
        methods = 'workspace/executeCommand',
    },
    ['executeCommandProvider/commands'] = {
        name = 'Available Commands',
        description = 'List of commands the server supports executing.',
    },

    -- Call Hierarchy
    ['callHierarchyProvider'] = {
        name = 'Call Hierarchy',
        description = 'Shows incoming and outgoing calls for a function (who calls this, what does this call).',
        nvim_usage = 'vim.lsp.buf.incoming_calls() and vim.lsp.buf.outgoing_calls()',
        help_tag = 'lsp-call-hierarchy',
        methods = 'textDocument/prepareCallHierarchy, callHierarchy/incomingCalls, callHierarchy/outgoingCalls',
    },

    -- Semantic Tokens
    ['semanticTokensProvider'] = {
        name = 'Semantic Tokens',
        description = 'Provides semantic highlighting (distinguishes variables, parameters, types, etc. by meaning).',
        nvim_usage = 'Enhances syntax highlighting beyond treesitter. See :h lsp-semantic-highlight',
        help_tag = 'lsp-semantic-highlight',
        methods = 'textDocument/semanticTokens/full, textDocument/semanticTokens/delta',
    },
    ['semanticTokensProvider/full'] = {
        name = 'Full Semantic Tokens',
        description = 'Server provides complete semantic token data for the document.',
    },
    ['semanticTokensProvider/full/delta'] = {
        name = 'Semantic Token Deltas',
        description = 'Server provides incremental semantic token updates for efficiency.',
    },
    ['semanticTokensProvider/range'] = {
        name = 'Range Semantic Tokens',
        description = 'Server provides semantic tokens for a specific range only.',
    },
    ['semanticTokensProvider/legend'] = {
        name = 'Semantic Token Legend',
        description = 'Defines token types and modifiers the server uses.',
    },
    ['semanticTokensProvider/legend/tokenTypes'] = {
        name = 'Token Types',
        description = 'Types of semantic tokens (namespace, type, class, enum, interface, struct, etc.).',
    },
    ['semanticTokensProvider/legend/tokenModifiers'] = {
        name = 'Token Modifiers',
        description = 'Modifiers for tokens (declaration, definition, readonly, static, deprecated, etc.).',
    },

    -- Linked Editing Range
    ['linkedEditingRangeProvider'] = {
        name = 'Linked Editing',
        description = 'Enables editing multiple related ranges simultaneously (e.g., HTML open/close tags).',
        nvim_usage = 'Used by plugins for synchronized editing',
        methods = 'textDocument/linkedEditingRange',
    },

    -- Moniker
    ['monikerProvider'] = {
        name = 'Monikers',
        description = 'Provides unique identifiers for symbols that work across repositories.',
        nvim_usage = 'Used for cross-repository symbol lookup',
        methods = 'textDocument/moniker',
    },

    -- Type Hierarchy
    ['typeHierarchyProvider'] = {
        name = 'Type Hierarchy',
        description = 'Shows type inheritance hierarchy (supertypes and subtypes).',
        nvim_usage = 'vim.lsp.buf.typehierarchy() for browsing class hierarchies',
        methods = 'textDocument/prepareTypeHierarchy, typeHierarchy/supertypes, typeHierarchy/subtypes',
    },

    -- Inline Value
    ['inlineValueProvider'] = {
        name = 'Inline Values',
        description = 'Shows variable values inline during debugging sessions.',
        nvim_usage = 'Used by DAP (debug adapter protocol) integrations',
        methods = 'textDocument/inlineValue',
    },

    -- Inlay Hints
    ['inlayHintProvider'] = {
        name = 'Inlay Hints',
        description = 'Shows inline hints for parameter names, types, and other info not in source code.',
        nvim_usage = 'vim.lsp.inlay_hint.enable() - shows hints like parameter names and inferred types',
        help_tag = 'lsp-inlay_hint',
        methods = 'textDocument/inlayHint',
    },
    ['inlayHintProvider/resolveProvider'] = {
        name = 'Inlay Hint Resolve',
        description = 'Server can provide additional details for inlay hints on demand.',
        methods = 'inlayHint/resolve',
    },

    -- Diagnostic
    ['diagnosticProvider'] = {
        name = 'Pull Diagnostics',
        description = 'Client can request diagnostics on demand (pull model vs push model).',
        nvim_usage = 'Alternative to automatic diagnostic push from server',
        methods = 'textDocument/diagnostic',
    },
    ['diagnosticProvider/interFileDependencies'] = {
        name = 'Inter-File Diagnostics',
        description = 'Diagnostics may change in other files when one file changes.',
    },
    ['diagnosticProvider/workspaceDiagnostics'] = {
        name = 'Workspace Diagnostics',
        description = 'Server supports workspace-wide diagnostic requests.',
        methods = 'workspace/diagnostic',
    },

    -- Workspace
    ['workspace/workspaceFolders'] = {
        name = 'Workspace Folders',
        description = 'Server supports multiple workspace folders (multi-root workspaces).',
        nvim_usage = 'vim.lsp.buf.add_workspace_folder() and vim.lsp.buf.remove_workspace_folder()',
        help_tag = 'lsp-workspace',
    },
    ['workspace/workspaceFolders/supported'] = {
        name = 'Folders Supported',
        description = 'Server supports workspace folder operations.',
    },
    ['workspace/workspaceFolders/changeNotifications'] = {
        name = 'Folder Notifications',
        description = 'Server wants notifications when workspace folders change.',
    },
    ['workspace/fileOperations'] = {
        name = 'File Operations',
        description = 'Server supports file operation notifications (create, rename, delete).',
    },
    ['workspace/fileOperations/willCreate'] = {
        name = 'Will Create File',
        description = 'Server wants notification before files are created.',
    },
    ['workspace/fileOperations/didCreate'] = {
        name = 'Did Create File',
        description = 'Server wants notification after files are created.',
    },
    ['workspace/fileOperations/willRename'] = {
        name = 'Will Rename File',
        description = 'Server wants notification before files are renamed (can provide edits).',
    },
    ['workspace/fileOperations/didRename'] = {
        name = 'Did Rename File',
        description = 'Server wants notification after files are renamed.',
    },
    ['workspace/fileOperations/willDelete'] = {
        name = 'Will Delete File',
        description = 'Server wants notification before files are deleted.',
    },
    ['workspace/fileOperations/didDelete'] = {
        name = 'Did Delete File',
        description = 'Server wants notification after files are deleted.',
    },

    -- Text Document Sync
    ['textDocumentSync'] = {
        name = 'Document Sync',
        description = 'How document changes are synchronized between editor and server.',
        nvim_usage = 'Automatic - neovim handles document synchronization',
    },
    ['textDocumentSync/openClose'] = {
        name = 'Open/Close Sync',
        description = 'Server wants notifications when documents are opened or closed.',
    },
    ['textDocumentSync/change'] = {
        name = 'Change Sync Mode',
        description = 'How changes are sent: 0=None, 1=Full document, 2=Incremental changes.',
    },
    ['textDocumentSync/willSave'] = {
        name = 'Will Save',
        description = 'Server wants notification before document is saved.',
    },
    ['textDocumentSync/willSaveWaitUntil'] = {
        name = 'Will Save Wait',
        description = 'Server can provide edits before save (e.g., format on save).',
    },
    ['textDocumentSync/save'] = {
        name = 'Save Notification',
        description = 'Server wants notification when document is saved.',
    },
    ['textDocumentSync/save/includeText'] = {
        name = 'Include Text on Save',
        description = 'Include full document text in save notifications.',
    },

    -- Notebook Document Sync
    ['notebookDocumentSync'] = {
        name = 'Notebook Sync',
        description = 'Server supports Jupyter notebook document synchronization.',
    },

    -- Position Encoding
    ['positionEncoding'] = {
        name = 'Position Encoding',
        description = 'Character encoding for positions (UTF-8, UTF-16, or UTF-32).',
        nvim_usage = 'Affects how cursor positions are calculated. Check client.offset_encoding',
    },

    -- Experimental
    ['experimental'] = {
        name = 'Experimental',
        description = 'Server-specific experimental features not in the LSP specification.',
    },
}

--- Get documentation for a capability path
---@param path string The capability path (e.g., "completionProvider" or "completionProvider/triggerCharacters")
---@return CapabilityDoc|nil
function M.get(path)
    -- Try exact match first
    if M.docs[path] then
        return M.docs[path]
    end

    -- Try removing leading slash or normalizing path
    local normalized = path:gsub('^/', '')
    if M.docs[normalized] then
        return M.docs[normalized]
    end

    return nil
end

--- Get a short description for display in picker
---@param path string The capability path
---@return string
function M.get_short_description(path)
    local doc = M.get(path)
    if doc then
        return doc.name
    end
    -- Generate a readable name from the path
    local name = path:match('[^/]+$') or path
    -- Convert camelCase to Title Case
    name = name:gsub('Provider$', '')
    name = name:gsub('(%l)(%u)', '%1 %2')
    name = name:gsub('^%l', string.upper)
    return name
end

return M
