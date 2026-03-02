#!/usr/bin/env bash

##############################################################################
# MCP Server Installation Script
#
# This script installs and configures all required MCP (Model Context Protocol)
# servers via npm. MCP servers provide AI capabilities and tools integration
# for Claude and other AI clients.
#
# MCP Servers installed:
#   - @anthropic/gemini-mcp-server: Google Gemini AI integration
#   - @anthropic/mcp-server-filesystem: File system access and operations
#   - @anthropic/mcp-server-git: Git repository management
#   - @anthropic/mcp-server-github: GitHub API integration
#   - @anthropic/mcp-server-fetch: Web content retrieval
#   - @anthropic/mcp-server-brave-search: Brave Search API
#   - @anthropic/mcp-server-memory: Persistent memory for context
#
# Usage: ./setup-mcp.sh [OPTIONS]
#
# Options:
#   -g, --global          Install packages globally instead of locally
#   -u, --update          Update existing installations to latest versions
#   -d, --dev             Install with dev dependencies for development
#   -h, --help            Display this help message
#
# Environment Variables:
#   MCP_INSTALL_DIR       Directory to install MCP servers (default: ./mcp-servers)
#   NPM_REGISTRY          Alternative npm registry (default: https://registry.npmjs.org)
#   DEBUG                 Set to 1 to enable debug output
#
# Example:
#   ./setup-mcp.sh --update
#   MCP_INSTALL_DIR=/opt/mcp ./setup-mcp.sh
#
##############################################################################

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
INSTALL_DIR="${MCP_INSTALL_DIR:-.}/mcp-servers"
GLOBAL_INSTALL="false"
UPDATE_MODE="false"
DEV_DEPS="false"
DEBUG="${DEBUG:-false}"

# MCP Packages to install
declare -a MCP_PACKAGES=(
    "@anthropic/gemini-mcp-server"
    "@anthropic/mcp-server-filesystem"
    "@anthropic/mcp-server-git"
    "@anthropic/mcp-server-github"
    "@anthropic/mcp-server-fetch"
    "@anthropic/mcp-server-brave-search"
    "@anthropic/mcp-server-memory"
)

##############################################################################
# Helper Functions
##############################################################################

print_header() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_status() {
    echo -e "${GREEN}[+]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[i]${NC} $1"
}

print_error() {
    echo -e "${RED}[!]${NC} $1" >&2
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

debug_print() {
    if [[ "$DEBUG" == "true" ]]; then
        echo -e "${YELLOW}[DEBUG]${NC} $1"
    fi
}

print_help() {
    head -n 47 "$0" | tail -n 42
}

# Check if npm is installed and available
check_npm() {
    print_status "Checking npm installation..."

    if ! command -v npm &> /dev/null; then
        print_error "npm is not installed. Please install Node.js and npm first."
        return 1
    fi

    local npm_version
    npm_version=$(npm --version)
    print_success "npm version: $npm_version"

    if ! command -v node &> /dev/null; then
        print_error "Node.js is not installed."
        return 1
    fi

    local node_version
    node_version=$(node --version)
    print_success "Node.js version: $node_version"

    return 0
}

# Create installation directory if needed
setup_directories() {
    if [[ "$GLOBAL_INSTALL" == "false" ]]; then
        print_status "Setting up installation directory: $INSTALL_DIR"

        if [[ ! -d "$INSTALL_DIR" ]]; then
            mkdir -p "$INSTALL_DIR"
            print_success "Created directory: $INSTALL_DIR"
        else
            print_info "Directory already exists: $INSTALL_DIR"
        fi

        # Initialize npm package if needed
        if [[ ! -f "$INSTALL_DIR/package.json" ]]; then
            print_status "Initializing npm package..."
            cd "$INSTALL_DIR"
            npm init -y > /dev/null 2>&1
            cd - > /dev/null
            print_success "npm package initialized"
        fi
    fi
}

# Install a single MCP package
install_package() {
    local package="$1"
    local mode="install"

    if [[ "$UPDATE_MODE" == "true" ]]; then
        mode="update"
    fi

    print_info "Installing $package..."

    if [[ "$GLOBAL_INSTALL" == "true" ]]; then
        debug_print "Running: npm $mode -g $package"
        if npm "$mode" -g "$package"; then
            print_success "$package installed globally"
        else
            print_error "Failed to install $package globally"
            return 1
        fi
    else
        debug_print "Running: npm $mode $package"
        if (cd "$INSTALL_DIR" && npm "$mode" "$package"); then
            print_success "$package installed to $INSTALL_DIR"
        else
            print_error "Failed to install $package"
            return 1
        fi
    fi
}

# Install all MCP packages
install_packages() {
    print_header "Installing MCP Packages"

    local failed_packages=()
    local success_count=0

    for package in "${MCP_PACKAGES[@]}"; do
        if install_package "$package"; then
            ((success_count++))
        else
            failed_packages+=("$package")
        fi
    done

    echo ""
    print_header "Installation Summary"
    print_success "Successfully installed: $success_count/${#MCP_PACKAGES[@]}"

    if [[ ${#failed_packages[@]} -gt 0 ]]; then
        print_warning "Failed to install the following packages:"
        for pkg in "${failed_packages[@]}"; do
            echo "  - $pkg"
        done
        return 1
    else
        print_success "All MCP packages installed successfully!"
        return 0
    fi
}

# Verify installations
verify_installations() {
    print_header "Verifying Installations"

    if [[ "$GLOBAL_INSTALL" == "true" ]]; then
        print_info "Checking globally installed packages..."
        npm list -g "@anthropic" 2>/dev/null | head -20
    else
        print_info "Checking locally installed packages in $INSTALL_DIR..."
        if [[ -f "$INSTALL_DIR/package.json" ]]; then
            cd "$INSTALL_DIR"
            npm list "@anthropic" 2>/dev/null | head -20
            cd - > /dev/null
        fi
    fi
}

# Generate installation info file
generate_info_file() {
    local info_file="${INSTALL_DIR}/.mcp-install-info"
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    if [[ "$GLOBAL_INSTALL" == "true" ]]; then
        info_file="/tmp/.mcp-global-install-info"
    fi

    print_status "Generating installation info file: $info_file"

    cat > "$info_file" << EOF
{
  "mcp_installation_info": {
    "timestamp": "$timestamp",
    "install_mode": "$([ "$GLOBAL_INSTALL" == "true" ] && echo 'global' || echo 'local')",
    "install_directory": "$INSTALL_DIR",
    "packages_count": ${#MCP_PACKAGES[@]},
    "npm_version": "$(npm --version)",
    "node_version": "$(node --version)",
    "packages": [
EOF

    for i in "${!MCP_PACKAGES[@]}"; do
        local package="${MCP_PACKAGES[$i]}"
        echo "      \"$package\"$([ $i -lt $((${#MCP_PACKAGES[@]} - 1)) ] && echo ',' || echo '')" >> "$info_file"
    done

    cat >> "$info_file" << EOF
    ]
  }
}
EOF

    print_success "Installation info saved to: $info_file"
}

# Display installation instructions for integration with Claude
display_integration_instructions() {
    print_header "Integration Instructions"

    echo -e "${BLUE}To integrate MCP servers with Claude or similar clients:${NC}"
    echo ""

    if [[ "$GLOBAL_INSTALL" == "true" ]]; then
        echo "1. Update your .mcp.json or similar config to use these commands:"
        echo ""
        echo '   "gemini": {"command": "npx", "args": ["-y", "@anthropic/gemini-mcp-server"]},'
        echo '   "filesystem": {"command": "npx", "args": ["-y", "@anthropic/mcp-server-filesystem"]},'
        echo '   "git": {"command": "npx", "args": ["-y", "@anthropic/mcp-server-git"]},'
        echo '   "github": {"command": "npx", "args": ["-y", "@anthropic/mcp-server-github"]},'
        echo '   "fetch": {"command": "npx", "args": ["-y", "@anthropic/mcp-server-fetch"]},'
        echo '   "brave-search": {"command": "npx", "args": ["-y", "@anthropic/mcp-server-brave-search"]},'
        echo '   "memory": {"command": "npx", "args": ["-y", "@anthropic/mcp-server-memory"]},'
    else
        echo "1. MCP servers are available at: $INSTALL_DIR/node_modules"
        echo ""
        echo "2. To use them, reference the installation in your config:"
        echo ""
        echo "   export NODE_PATH=\"$INSTALL_DIR/node_modules:\$NODE_PATH\""
        echo ""
        echo "3. Or specify the full path in your MCP configuration:"
        echo ""
        echo "   \"command\": \"$INSTALL_DIR/node_modules/.bin/<mcp-server>\""
    fi

    echo ""
    echo -e "${BLUE}Environment Variables (if needed):${NC}"
    echo "   GEMINI_API_KEY       - Your Google Gemini API key"
    echo "   GITHUB_TOKEN         - Your GitHub personal access token"
    echo "   BRAVE_API_KEY        - Your Brave Search API key"
    echo ""
}

# Parse command-line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -g|--global)
                GLOBAL_INSTALL="true"
                shift
                ;;
            -u|--update)
                UPDATE_MODE="true"
                shift
                ;;
            -d|--dev)
                DEV_DEPS="true"
                shift
                ;;
            -h|--help)
                print_help
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                print_help
                exit 1
                ;;
        esac
    done
}

##############################################################################
# Main Execution
##############################################################################

main() {
    print_header "MCP Server Installation Script"

    parse_args "$@"

    debug_print "GLOBAL_INSTALL: $GLOBAL_INSTALL"
    debug_print "UPDATE_MODE: $UPDATE_MODE"
    debug_print "DEV_DEPS: $DEV_DEPS"

    # Check prerequisites
    if ! check_npm; then
        print_error "Prerequisites check failed"
        exit 1
    fi

    echo ""

    # Setup directories
    if [[ "$GLOBAL_INSTALL" == "false" ]]; then
        setup_directories
        echo ""
    fi

    # Install packages
    if install_packages; then
        echo ""
        verify_installations
        echo ""
        generate_info_file
        echo ""
        display_integration_instructions
        echo ""
        print_success "MCP installation completed successfully!"
        exit 0
    else
        print_error "MCP installation completed with errors"
        exit 1
    fi
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
