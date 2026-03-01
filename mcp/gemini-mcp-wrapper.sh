#!/usr/bin/env bash

##############################################################################
# Gemini MCP Wrapper Script
#
# This script wraps the Gemini MCP server with environment setup and
# configuration management. It handles model switching, API key management,
# and provides helpful diagnostics.
#
# The Gemini MCP server exposes Google's Gemini AI models via the Model Context
# Protocol, allowing Claude and other AI clients to leverage Gemini capabilities.
#
# Usage: ./gemini-mcp-wrapper.sh [OPTIONS] [ARGS...]
#
# Options:
#   -m, --model MODEL     Set Gemini model (default: gemini-2.0-flash)
#   -k, --key KEY         Set GEMINI_API_KEY (can also use env var)
#   -c, --check           Check configuration and connectivity
#   -l, --list-models     List available models
#   -d, --debug           Enable debug output
#   -h, --help            Display this help message
#
# Available Models:
#   - gemini-2.0-flash    High-speed model for most tasks (default)
#   - gemini-2.0-flash-thinking  Extended thinking model
#   - gemini-1.5-pro      High-capability model for complex tasks
#   - gemini-1.5-flash    Fast variant of 1.5
#
# Environment Variables:
#   GEMINI_API_KEY        Google Gemini API key (required)
#   GEMINI_MODEL          Model to use (default: gemini-2.0-flash)
#   MCP_TIMEOUT           MCP server timeout in seconds (default: 300)
#   MCP_LOG_LEVEL         Log level (default, quiet, error, warning, info)
#
# Configuration Files:
#   ~/.config/gemini-mcp/config.json    User configuration
#   /etc/gemini-mcp/config.json         System configuration
#
# Examples:
#   # Run with default settings
#   ./gemini-mcp-wrapper.sh
#
#   # Use a specific model
#   ./gemini-mcp-wrapper.sh --model gemini-1.5-pro
#
#   # Check configuration
#   ./gemini-mcp-wrapper.sh --check
#
#   # Run with API key
#   ./gemini-mcp-wrapper.sh --key YOUR_API_KEY
#
##############################################################################

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration variables
GEMINI_API_KEY="${GEMINI_API_KEY:-}"
GEMINI_MODEL="${GEMINI_MODEL:-gemini-2.0-flash}"
MCP_TIMEOUT="${MCP_TIMEOUT:-300}"
MCP_LOG_LEVEL="${MCP_LOG_LEVEL:-default}"
DEBUG="${DEBUG:-0}"
VERBOSE=false

# Mode flags
CHECK_MODE=false
LIST_MODELS_MODE=false
HELP_MODE=false

# Supported models
declare -A SUPPORTED_MODELS=(
    [gemini-2.0-flash]="High-speed model for general use (DEFAULT)"
    [gemini-2.0-flash-thinking]="Extended thinking model for complex reasoning"
    [gemini-1.5-pro]="High-capability model for advanced tasks"
    [gemini-1.5-flash]="Fast variant of Gemini 1.5"
)

# Configuration file paths
CONFIG_PATHS=(
    "$HOME/.config/gemini-mcp/config.json"
    "/etc/gemini-mcp/config.json"
    "$(dirname "$0")/gemini-mcp-config.json"
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

print_debug() {
    if [[ "$DEBUG" == "1" ]] || [[ "$VERBOSE" == true ]]; then
        echo -e "${MAGENTA}[DEBUG]${NC} $1"
    fi
}

print_help() {
    head -n 53 "$0" | tail -n 48
}

# Load configuration from file
load_config() {
    print_debug "Loading configuration files..."

    for config_file in "${CONFIG_PATHS[@]}"; do
        if [[ -f "$config_file" ]]; then
            print_debug "Found config: $config_file"

            if command -v jq &> /dev/null; then
                GEMINI_API_KEY="${GEMINI_API_KEY:-$(jq -r '.api_key // empty' "$config_file" 2>/dev/null || true)}"
                GEMINI_MODEL="${GEMINI_MODEL:-$(jq -r '.model // empty' "$config_file" 2>/dev/null || true)}"
                MCP_TIMEOUT="${MCP_TIMEOUT:-$(jq -r '.timeout // empty' "$config_file" 2>/dev/null || true)}"
            else
                print_debug "jq not found, skipping JSON parsing"
            fi
        fi
    done
}

# Validate API key
validate_api_key() {
    print_status "Validating API key..."

    if [[ -z "$GEMINI_API_KEY" ]]; then
        print_error "GEMINI_API_KEY not set"
        print_info "Please set GEMINI_API_KEY environment variable or use --key option"
        return 1
    fi

    # Check key format (basic validation)
    if [[ ${#GEMINI_API_KEY} -lt 20 ]]; then
        print_warning "API key seems unusually short, may be invalid"
    fi

    print_success "API key is set (length: ${#GEMINI_API_KEY} characters)"
    return 0
}

# Validate model
validate_model() {
    print_status "Validating model: $GEMINI_MODEL"

    if [[ -v "SUPPORTED_MODELS[$GEMINI_MODEL]" ]]; then
        print_success "Model is supported: $GEMINI_MODEL"
        return 0
    else
        print_warning "Model '$GEMINI_MODEL' not in predefined list (may still be valid)"
        print_info "Using: $GEMINI_MODEL"
        return 0
    fi
}

# Check connectivity to API
check_connectivity() {
    print_status "Checking connectivity to Google Gemini API..."

    if ! command -v curl &> /dev/null; then
        print_warning "curl not found, skipping connectivity check"
        return 0
    fi

    if ! command -v jq &> /dev/null; then
        print_warning "jq not found, skipping connectivity check"
        return 0
    fi

    # Test with a simple curl request to Google API
    local response
    response=$(curl -s -w "\n%{http_code}" \
        -H "Content-Type: application/json" \
        -d '{"contents":[{"parts":[{"text":"test"}]}]}' \
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${GEMINI_API_KEY}" 2>/dev/null || true)

    local http_code
    http_code=$(echo "$response" | tail -n 1)

    if [[ "$http_code" == "200" ]]; then
        print_success "API connectivity check passed"
        return 0
    elif [[ "$http_code" == "401" ]]; then
        print_error "API key authentication failed (401)"
        return 1
    elif [[ "$http_code" == "403" ]]; then
        print_error "API access forbidden (403)"
        return 1
    elif [[ "$http_code" == "429" ]]; then
        print_warning "Rate limited (429), but API is reachable"
        return 0
    else
        print_warning "Connectivity check returned code: $http_code"
        return 0
    fi
}

# List available models
list_models() {
    print_header "Available Gemini Models"
    echo ""

    local count=0
    for model in "${!SUPPORTED_MODELS[@]}"; do
        local description="${SUPPORTED_MODELS[$model]}"
        local default_marker=""

        if [[ "$model" == "$GEMINI_MODEL" ]]; then
            default_marker=" [CURRENT]"
        fi

        echo -e "${CYAN}$model${NC}$default_marker"
        echo "  $description"
        echo ""
        ((count++))
    done

    print_info "Total models: $count"
}

# Check system configuration
check_system_config() {
    print_header "System Configuration Check"
    echo ""

    print_status "Checking dependencies..."
    echo ""

    local deps=("node" "npm" "npx" "curl" "jq")
    local missing_deps=()

    for dep in "${deps[@]}"; do
        if command -v "$dep" &> /dev/null; then
            local version
            version=$("$dep" --version 2>/dev/null || echo "installed")
            print_success "$dep: $version"
        else
            print_warning "$dep: NOT FOUND"
            missing_deps+=("$dep")
        fi
    done

    echo ""

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        print_warning "Missing dependencies: ${missing_deps[*]}"
    else
        print_success "All dependencies found"
    fi

    echo ""
    print_status "Checking environment..."
    echo ""

    if [[ -n "$GEMINI_API_KEY" ]]; then
        print_success "GEMINI_API_KEY is set"
    else
        print_error "GEMINI_API_KEY is not set"
    fi

    print_info "GEMINI_MODEL: $GEMINI_MODEL"
    print_info "MCP_TIMEOUT: $MCP_TIMEOUT seconds"
    print_info "MCP_LOG_LEVEL: $MCP_LOG_LEVEL"

    echo ""
}

# Perform full diagnostics
run_diagnostics() {
    print_header "Full Diagnostics"
    echo ""

    check_system_config
    echo ""
    validate_api_key || true
    echo ""
    validate_model
    echo ""
    check_connectivity || true
    echo ""

    print_success "Diagnostics complete"
}

# Parse command-line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -m|--model)
                GEMINI_MODEL="$2"
                shift 2
                ;;
            -k|--key)
                GEMINI_API_KEY="$2"
                shift 2
                ;;
            -c|--check)
                CHECK_MODE=true
                shift
                ;;
            -l|--list-models)
                LIST_MODELS_MODE=true
                shift
                ;;
            -d|--debug)
                DEBUG=1
                VERBOSE=true
                shift
                ;;
            -h|--help)
                HELP_MODE=true
                shift
                ;;
            *)
                # Pass remaining args to the server
                break
                ;;
        esac
    done
}

# Start the Gemini MCP server
start_server() {
    print_header "Starting Gemini MCP Server"
    echo ""

    print_info "Model: $GEMINI_MODEL"
    print_info "Timeout: $MCP_TIMEOUT seconds"
    print_info "Log Level: $MCP_LOG_LEVEL"
    echo ""

    print_status "Launching Gemini MCP server via npx..."

    # Export environment variables for the server
    export GEMINI_API_KEY
    export GEMINI_MODEL
    export MCP_TIMEOUT
    export MCP_LOG_LEVEL

    print_debug "Environment: GEMINI_API_KEY (length: ${#GEMINI_API_KEY}), GEMINI_MODEL=$GEMINI_MODEL"

    # Run the actual MCP server
    npx -y "@anthropic/gemini-mcp-server" "$@"
}

##############################################################################
# Main Execution
##############################################################################

main() {
    print_header "Gemini MCP Wrapper"

    # Parse arguments
    parse_args "$@"

    # Load configuration from files
    load_config

    # Handle different modes
    if [[ "$HELP_MODE" == true ]]; then
        print_help
        exit 0
    fi

    if [[ "$LIST_MODELS_MODE" == true ]]; then
        list_models
        exit 0
    fi

    if [[ "$CHECK_MODE" == true ]]; then
        echo ""
        run_diagnostics
        exit 0
    fi

    # Normal operation mode - start server
    echo ""

    if ! validate_api_key; then
        echo ""
        print_error "Cannot start server without valid API key"
        exit 1
    fi

    echo ""

    validate_model

    echo ""

    # Start the server (this doesn't return unless server exits)
    start_server "$@"
}

# Run main function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
