# MCP Server Setup Scripts

This directory contains comprehensive scripts for setting up, managing, and testing Model Context Protocol (MCP) servers for Claude and other AI clients.

## Overview

MCP (Model Context Protocol) is a standard protocol that allows AI models to interact with tools, services, and data sources. These scripts provide a complete toolkit for MCP server management on Unix-like systems.

### Available Scripts

1. **setup-mcp.sh** - Install and configure all MCP servers
2. **gemini-mcp-wrapper.sh** - Wrapper for the Gemini MCP server with diagnostics
3. **test-mcp.sh** - Comprehensive test suite for all MCP servers

## Quick Start

### Installation

Install all MCP servers with default settings:

```bash
./setup-mcp.sh
```

Install globally:

```bash
./setup-mcp.sh --global
```

Update to latest versions:

```bash
./setup-mcp.sh --update
```

### Testing

Test all MCP servers:

```bash
./test-mcp.sh
```

Test a specific server:

```bash
./test-mcp.sh --server gemini
```

Quick test with verbose output:

```bash
./test-mcp.sh --quick --verbose
```

### Running Gemini MCP

Check configuration:

```bash
./gemini-mcp-wrapper.sh --check
```

List available models:

```bash
./gemini-mcp-wrapper.sh --list-models
```

Start the server with a specific model:

```bash
./gemini-mcp-wrapper.sh --model gemini-1.5-pro
```

## Detailed Usage

### 1. setup-mcp.sh

**Purpose**: Installs all required MCP packages via npm

**Installed Packages**:
- `@anthropic/gemini-mcp-server` - Google Gemini AI integration
- `@anthropic/mcp-server-filesystem` - File system access
- `@anthropic/mcp-server-git` - Git repository management
- `@anthropic/mcp-server-github` - GitHub API integration
- `@anthropic/mcp-server-fetch` - Web content retrieval
- `@anthropic/mcp-server-brave-search` - Brave Search API
- `@anthropic/mcp-server-memory` - Persistent memory context

**Options**:
```
-g, --global          Install packages globally instead of locally
-u, --update          Update existing installations to latest versions
-d, --dev             Install with dev dependencies for development
-h, --help            Display help message
```

**Environment Variables**:
```
MCP_INSTALL_DIR       Directory to install MCP servers (default: ./mcp-servers)
NPM_REGISTRY          Alternative npm registry
DEBUG                 Set to 1 to enable debug output
```

**Examples**:
```bash
# Install locally in ./mcp-servers
./setup-mcp.sh

# Install globally
./setup-mcp.sh --global

# Update existing installation
./setup-mcp.sh --update

# Custom installation directory
MCP_INSTALL_DIR=/opt/mcp ./setup-mcp.sh

# Debug mode
DEBUG=1 ./setup-mcp.sh
```

**Features**:
- Validates npm and Node.js installation
- Creates installation directory if needed
- Initializes npm package.json
- Provides colored output for easy reading
- Generates installation info file
- Shows integration instructions
- Detailed error reporting

### 2. gemini-mcp-wrapper.sh

**Purpose**: Wraps the Gemini MCP server with configuration and diagnostics

**Options**:
```
-m, --model MODEL     Set Gemini model (default: gemini-2.0-flash)
-k, --key KEY         Set GEMINI_API_KEY
-c, --check           Check configuration and connectivity
-l, --list-models     List available models
-d, --debug           Enable debug output
-h, --help            Display help message
```

**Environment Variables**:
```
GEMINI_API_KEY        Google Gemini API key (required)
GEMINI_MODEL          Model to use (default: gemini-2.0-flash)
MCP_TIMEOUT           MCP server timeout in seconds (default: 300)
MCP_LOG_LEVEL         Log level (default, quiet, error, warning, info)
```

**Available Models**:
- `gemini-2.0-flash` - High-speed model for general use (default)
- `gemini-2.0-flash-thinking` - Extended thinking model for complex reasoning
- `gemini-1.5-pro` - High-capability model for advanced tasks
- `gemini-1.5-flash` - Fast variant of Gemini 1.5

**Examples**:
```bash
# Run with default settings
./gemini-mcp-wrapper.sh

# Use specific model
./gemini-mcp-wrapper.sh --model gemini-1.5-pro

# Check configuration and connectivity
./gemini-mcp-wrapper.sh --check

# List available models
./gemini-mcp-wrapper.sh --list-models

# Set API key inline
./gemini-mcp-wrapper.sh --key YOUR_API_KEY

# Debug mode
./gemini-mcp-wrapper.sh --debug
```

**Features**:
- Loads configuration from multiple sources
- Validates API key format and presence
- Tests connectivity to Gemini API
- Lists available models
- System diagnostics
- Configuration checking
- Colored output with status indicators
- Graceful error handling

**Configuration Files** (in order of precedence):
1. `~/.config/gemini-mcp/config.json`
2. `/etc/gemini-mcp/config.json`
3. `./gemini-mcp-config.json`

### 3. test-mcp.sh

**Purpose**: Comprehensive test suite for all MCP servers

**Tested Servers**:
- gemini - Google Gemini AI integration
- filesystem - File system access
- git - Git repository management
- github - GitHub API integration
- fetch - Web content retrieval
- brave-search - Brave Search API
- memory - Persistent memory
- nix-guix - Nix/Guix package management (local)

**Options**:
```
-a, --all             Test all servers (default)
-s, --server NAME     Test only specific server
-q, --quick           Quick tests only (skip slow tests)
-v, --verbose         Verbose output
-d, --debug           Enable debug output
-c, --config FILE     Use alternative config file
-h, --help            Display help message
```

**Environment Variables**:
```
MCP_CONFIG_FILE       Path to MCP configuration file
GEMINI_API_KEY        Google Gemini API key
GITHUB_TOKEN          GitHub personal access token
BRAVE_API_KEY         Brave Search API key
TEST_TIMEOUT          Timeout for tests in seconds (default: 30)
SKIP_SLOW_TESTS       Set to 1 to skip slow tests
```

**Examples**:
```bash
# Test all servers
./test-mcp.sh

# Test only Gemini
./test-mcp.sh --server gemini

# Quick test with verbose output
./test-mcp.sh --quick --verbose

# Debug mode
./test-mcp.sh --debug

# Custom config file
./test-mcp.sh --config /etc/mcp.json

# Specific server with debug
./test-mcp.sh --server github --debug
```

**Test Categories**:

Each server is tested for:
1. **Installation** - Check if npm package is installed
2. **Invocability** - Test if the server can be executed
3. **Authentication** - Validate API keys (if applicable)
4. **Connectivity** - Test connection to external APIs (optional)

**Exit Codes**:
- `0` - All tests passed
- `1` - One or more tests failed
- `2` - Configuration error
- `3` - Dependency missing

**Features**:
- Colored output with clear status indicators
- Dependency checking
- Configuration validation
- Individual and bulk testing modes
- Test result tracking and summary
- Verbose and debug modes
- Timeout protection
- JSON configuration parsing

## Integration with Claude

### Via .mcp.json Configuration

Add to your `.mcp.json` file:

```json
{
  "mcpServers": {
    "gemini": {
      "command": "npx",
      "args": ["-y", "@anthropic/gemini-mcp-server"],
      "env": {
        "GEMINI_API_KEY": "${GEMINI_API_KEY}",
        "GEMINI_MODEL": "gemini-2.0-flash"
      }
    },
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-filesystem", "/home/user", "/etc"]
    },
    "git": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-git"]
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}"
      }
    },
    "fetch": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-fetch"]
    },
    "brave-search": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-brave-search"],
      "env": {
        "BRAVE_API_KEY": "${BRAVE_API_KEY}"
      }
    },
    "memory": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-memory"]
    }
  }
}
```

### Via Wrapper Script

Use the `gemini-mcp-wrapper.sh` for enhanced Gemini integration:

```json
{
  "mcpServers": {
    "gemini": {
      "command": "/path/to/gemini-mcp-wrapper.sh",
      "args": ["--model", "gemini-2.0-flash"],
      "env": {
        "GEMINI_API_KEY": "${GEMINI_API_KEY}"
      }
    }
  }
}
```

## Requirements

### System Dependencies

- **Node.js** (v14 or higher) - For running npm packages
- **npm** (v6 or higher) - For package management
- **bash** (v4 or higher) - For script execution
- **curl** (optional) - For connectivity testing
- **jq** (optional) - For JSON parsing
- **git** (optional) - For git operations
- **Python 3** (optional) - For Nix/Guix MCP testing

### API Keys

Optional, depending on which servers you use:

- **GEMINI_API_KEY** - For Gemini MCP server (get from [Google AI Studio](https://aistudio.google.com/app/apikey))
- **GITHUB_TOKEN** - For GitHub MCP server (create in GitHub Settings > Developer settings)
- **BRAVE_API_KEY** - For Brave Search MCP server (get from [Brave Search](https://api.search.brave.com))

## Troubleshooting

### npm not found

Install Node.js and npm:
```bash
# macOS
brew install node

# Ubuntu/Debian
sudo apt-get install nodejs npm

# Fedora
sudo dnf install nodejs npm
```

### GEMINI_API_KEY not set

Set the environment variable:
```bash
export GEMINI_API_KEY="your-api-key"
```

Or add to your shell profile (`~/.bashrc`, `~/.zshrc`):
```bash
export GEMINI_API_KEY="your-api-key"
```

### MCP server not starting

Check the logs:
```bash
./test-mcp.sh --debug
./gemini-mcp-wrapper.sh --check
```

Verify installation:
```bash
npm list @anthropic/gemini-mcp-server
npx @anthropic/gemini-mcp-server --help
```

### Slow installation on first run

NPX caches packages locally. First run will download and cache packages, subsequent runs will be faster.

### API connectivity issues

Test connectivity manually:
```bash
# Gemini API
curl -X POST https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent \
  -H "Content-Type: application/json" \
  -d '{"contents":[{"parts":[{"text":"test"}]}]}' \
  -H "Authorization: Bearer YOUR_API_KEY"
```

## Configuration Files

### .mcp-install-info

Generated by `setup-mcp.sh` after installation. Contains metadata about the installation:

```json
{
  "mcp_installation_info": {
    "timestamp": "2026-03-01T22:49:00Z",
    "install_mode": "local",
    "install_directory": "./mcp-servers",
    "packages_count": 7,
    "npm_version": "9.8.1",
    "node_version": "v18.16.0",
    "packages": [...]
  }
}
```

### gemini-mcp-config.json

Optional configuration file for Gemini MCP:

```json
{
  "api_key": "your-api-key-here",
  "model": "gemini-2.0-flash",
  "timeout": 300,
  "log_level": "default"
}
```

## Advanced Usage

### Custom Installation Directory

```bash
mkdir -p /opt/ai/mcp
MCP_INSTALL_DIR=/opt/ai/mcp ./setup-mcp.sh
```

### Using with Global Installation

```bash
./setup-mcp.sh --global
# Servers now available globally via npx
```

### Automated Testing in CI/CD

```bash
./test-mcp.sh --quick --config /etc/mcp.json
test_status=$?
exit $test_status
```

### Batch Server Checking

```bash
for server in gemini filesystem git github fetch brave-search memory nix-guix; do
  ./test-mcp.sh --server "$server" --quick || echo "Failed: $server"
done
```

## Performance Notes

- **First run**: Initial npm installs may take several minutes as packages are downloaded
- **Subsequent runs**: Cached packages are used, much faster
- **NPX overhead**: There's ~2-3 second overhead for each npx invocation
- **API calls**: Actual API calls depend on network latency and API response times

## Security Considerations

- **API Keys**: Store in environment variables or secure configuration files, never in code
- **File Permissions**: Ensure scripts have appropriate permissions (executable for owner)
- **Token Storage**: Use credential managers or secure vaults for API keys
- **Configuration Files**: Protect configuration files with appropriate file permissions
- **Logs**: Debug output may contain sensitive information; use with caution in production

## Contributing

To improve these scripts:

1. Test thoroughly on your system
2. Maintain consistent formatting and documentation
3. Add new features with backward compatibility in mind
4. Update this README with usage examples
5. Follow the existing code style and patterns

## License

These scripts are part of the nixos-guix-setup project.

## Support

For issues or questions:

1. Check the troubleshooting section above
2. Run diagnostics: `./test-mcp.sh --debug`
3. Check Gemini status: `./gemini-mcp-wrapper.sh --check`
4. Review script documentation: `./script.sh --help`

## Version History

- **2026-03-01** - Initial release with setup, wrapper, and test scripts

## Related Documentation

- [Model Context Protocol](https://modelcontextprotocol.io/)
- [Google Gemini API](https://ai.google.dev/)
- [Anthropic MCP Servers](https://github.com/anthropics/mcp-servers)
- [Node.js and npm](https://nodejs.org/)
