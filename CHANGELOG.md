# Changelog

All notable changes to the LSPInfo.nvim plugin will be documented in this file.

## [1.0.0] - 2024-12-19

### Added
- **Setup Function**: Added `setup()` function for plugin configuration, compatible with lazy.nvim and other plugin managers
- **User Command**: Added `:LSPInfo` command that can be bound to keyboard shortcuts
- **Dynamic Updates**: Enhanced previewer with real-time updates showing LSP client status changes
- **Configuration Options**: Added configurable telescope theme, command name, and update intervals
- **Comprehensive Documentation**: Added detailed README with installation instructions and usage examples
- **Automated Testing**: Added test suite with busted framework and GitHub Actions workflow
- **Example Configurations**: Added example configurations for different plugin managers
- **License**: Added MIT license for open source distribution

### Enhanced
- **Real-time Monitoring**: Previewer now updates dynamically when LSP clients start/stop
- **Better Status Display**: Added status and initialization indicators in the previewer
- **Improved UI**: Enhanced diagnostic display and client information formatting
- **Dynamic Entries**: Telescope entries now update in real-time to reflect current LSP state

### Technical Improvements
- **Modular Architecture**: Better separation of concerns with dedicated setup module
- **Error Handling**: Improved error handling and graceful degradation
- **Performance**: Optimized dynamic updates with configurable intervals
- **Compatibility**: Ensured compatibility with Neovim 0.8.0+ and telescope.nvim

### Documentation
- **Installation Guide**: Comprehensive installation instructions for lazy.nvim, packer.nvim, and vim-plug
- **Configuration Reference**: Detailed configuration options with examples
- **Usage Examples**: Multiple examples showing different use cases
- **Troubleshooting**: Common issues and solutions

### Testing
- **Unit Tests**: Basic test suite covering core functionality
- **CI/CD**: GitHub Actions workflow for automated testing
- **Syntax Validation**: Lua syntax checking in CI pipeline

## [0.1.0] - Initial Release

### Features
- Basic LSP client information display
- Telescope picker integration
- LSP server management actions
- Buffer attachment information
- Diagnostic count display 