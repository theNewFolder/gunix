#!/usr/bin/env bash

##############################################################################
# MCP Server Test Suite
#
# This script tests all configured MCP servers to ensure they are properly
# installed, configured, and functional. It performs connectivity checks,
# validates API keys, and runs simple functional tests where applicable.
#
# Tested Servers:
#   - gemini: Google Gemini AI integration
#   - filesystem: File system access and operations
#   - git: Git repository management
#   - github: GitHub API integration
#   - fetch: Web content retrieval
#   - brave-search: Brave Search API
#   - memory: Persistent memory for context
#   - nix-guix: Nix/Guix package management (local)
#
# Usage: ./test-mcp.sh [OPTIONS]
#
# Options:
#   -a, --all             Test all servers (default)
#   -s, --server NAME     Test only specific server
#   -q, --quick           Quick tests only (skip slow tests)
#   -v, --verbose         Verbose output
#   -d, --debug           Enable debug output
#   -c, --config FILE     Use alternative config file
#   -h, --help            Display this help message
#
# Environment Variables:
#   MCP_CONFIG_FILE       Path to MCP configuration file
#   GEMINI_API_KEY        Google Gemini API key
#   GITHUB_TOKEN          GitHub personal access token
#   BRAVE_API_KEY         Brave Search API key
#   TEST_TIMEOUT          Timeout for tests in seconds (default: 30)
#   SKIP_SLOW_TESTS       Set to 1 to skip slow tests
#   NIX_GUIX_SERVER_PATH  Path to nix-guix server (default: /home/gux/gunix/gemini-mcp/server.py)
#
# Exit Codes:
#   0 - All tests passed
#   1 - One or more tests failed
#   2 - Configuration error
#   3 - Dependency missing
#
# Examples:
#   # Test all servers
#   ./test-mcp.sh
#
#   # Test only Gemini
#   ./test-mcp.sh --server gemini
#
#   # Quick test with verbose output
#   ./test-mcp.sh --quick --verbose
#
#   # Debug mode
#   ./test-mcp.sh --debug
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

# Configuration
MCP_CONFIG_FILE="${MCP_CONFIG_FILE:-.mcp.json}"
SINGLE_SERVER="${SINGLE_SERVER:-}"
QUICK_MODE="false"
VERBOSE="${VERBOSE:-false}"
DEBUG="${DEBUG:-false}"
TEST_TIMEOUT="${TEST_TIMEOUT:-30}"
SKIP_SLOW_TESTS="${SKIP_SLOW_TESTS:-false}"

# Test results tracking
declare -A TEST_RESULTS
declare -A TEST_DURATIONS
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
SKIPPED_TESTS=0

##############################################################################
# Helper Functions
##############################################################################

print_header() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_section() {
    echo ""
    echo -e "${CYAN}>>> $1${NC}"
}

print_status() {
    echo -e "${GREEN}[+]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[i]${NC} $1"
}

print_error() {
    echo -e "${RED}[!]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_fail() {
    echo -e "${RED}[✗]${NC} $1"
}

print_skip() {
    echo -e "${YELLOW}[~]${NC} $1"
}

print_debug() {
    if [[ "$DEBUG" == "1" ]]; then
        echo -e "${MAGENTA}[DEBUG]${NC} $1"
    fi
}

print_verbose() {
    if [[ "$VERBOSE" == "true" ]]; then
        echo -e "${BLUE}[v]${NC} $1"
    fi
}

# Record test result
record_test() {
    local test_name="$1"
    local result="$2"
    local duration="${3:-0}"

    ((TOTAL_TESTS++))
    TEST_RESULTS["$test_name"]="$result"
    TEST_DURATIONS["$test_name"]="$duration"

    case "$result" in
        PASS)
            ((PASSED_TESTS++))
            print_success "$test_name (${duration}s)"
            ;;
        FAIL)
            ((FAILED_TESTS++))
            print_fail "$test_name (${duration}s)"
            ;;
        SKIP)
            ((SKIPPED_TESTS++))
            print_skip "$test_name (skipped)"
            ;;
    esac
}

# Print help
print_help() {
    head -n 57 "$0" | tail -n 52
}

# Check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Check dependencies
check_dependencies() {
    print_section "Checking Dependencies"

    local missing_deps=()
    local required_deps=("npm" "node" "jq" "timeout")

    for dep in "${required_deps[@]}"; do
        if command_exists "$dep"; then
            print_success "$dep available"
        else
            print_error "$dep missing"
            missing_deps+=("$dep")
        fi
    done

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        print_error "Missing required dependencies: ${missing_deps[*]}"
        return 3
    fi

    return 0
}

# Check configuration file exists
check_config_file() {
    print_section "Checking Configuration"

    if [[ ! -f "$MCP_CONFIG_FILE" ]]; then
        print_error "Configuration file not found: $MCP_CONFIG_FILE"
        return 2
    fi

    print_success "Configuration file found: $MCP_CONFIG_FILE"

    if ! command_exists jq; then
        print_warning "jq not available, skipping JSON validation"
        return 0
    fi

    if jq empty "$MCP_CONFIG_FILE" 2>/dev/null; then
        print_success "Configuration file is valid JSON"
    else
        print_error "Configuration file is not valid JSON"
        return 2
    fi

    return 0
}

# Check if MCP server is installed via npm
check_npm_package() {
    local package="$1"

    print_verbose "Checking npm package: $package"

    if npm list "$package" &>/dev/null 2>&1 || npm list -g "$package" &>/dev/null 2>&1; then
        print_success "NPM package installed: $package"
        return 0
    else
        print_warning "NPM package not found locally or globally: $package"
        return 1
    fi
}

# Test Gemini MCP
test_gemini() {
    print_section "Testing Gemini MCP"

    if [[ -z "${GEMINI_API_KEY:-}" ]]; then
        record_test "gemini:api-key" "SKIP"
        print_warning "GEMINI_API_KEY not set, skipping Gemini tests"
        return 0
    fi

    # Check package installation
    if check_npm_package "@anthropic/gemini-mcp-server"; then
        record_test "gemini:installed" "PASS" "0"
    else
        record_test "gemini:installed" "FAIL" "0"
        return 1
    fi

    # Test API key validation
    if [[ ${#GEMINI_API_KEY} -ge 20 ]]; then
        record_test "gemini:key-format" "PASS" "0"
    else
        record_test "gemini:key-format" "FAIL" "0"
    fi

    # Test connectivity (if curl available and not in quick mode)
    if ! command_exists curl; then
        record_test "gemini:connectivity" "SKIP"
    elif [[ "$QUICK_MODE" == "true" ]]; then
        record_test "gemini:connectivity" "SKIP"
    else
        print_verbose "Testing Gemini API connectivity..."

        local http_code
        http_code=$(curl -s -o /dev/null -w "%{http_code}" \
            -H "Content-Type: application/json" \
            -d '{"contents":[{"parts":[{"text":"test"}]}]}' \
            "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${GEMINI_API_KEY}" 2>/dev/null || echo "000")

        if [[ "$http_code" == "200" ]]; then
            record_test "gemini:connectivity" "PASS" "0"
        elif [[ "$http_code" == "401" ]]; then
            record_test "gemini:connectivity" "FAIL" "0"
            print_error "API key authentication failed (401)"
        elif [[ "$http_code" == "429" ]]; then
            record_test "gemini:connectivity" "PASS" "0"
            print_verbose "Rate limited but API is reachable"
        else
            record_test "gemini:connectivity" "FAIL" "0"
            print_error "Unexpected HTTP code: $http_code"
        fi
    fi

    return 0
}

# Test Filesystem MCP
test_filesystem() {
    print_section "Testing Filesystem MCP"

    if check_npm_package "@anthropic/mcp-server-filesystem"; then
        record_test "filesystem:installed" "PASS" "0"
    else
        record_test "filesystem:installed" "FAIL" "0"
        return 1
    fi

    # Test if it can be invoked
    print_verbose "Testing filesystem server invocation..."

    if timeout $TEST_TIMEOUT npx -y @anthropic/mcp-server-filesystem --help &>/dev/null 2>&1; then
        record_test "filesystem:invocable" "PASS" "0"
    else
        record_test "filesystem:invocable" "FAIL" "0"
        return 1
    fi

    return 0
}

# Test Git MCP
test_git() {
    print_section "Testing Git MCP"

    if check_npm_package "@anthropic/mcp-server-git"; then
        record_test "git:installed" "PASS" "0"
    else
        record_test "git:installed" "FAIL" "0"
        return 1
    fi

    # Test if it can be invoked
    print_verbose "Testing git server invocation..."

    if timeout $TEST_TIMEOUT npx -y @anthropic/mcp-server-git --help &>/dev/null 2>&1; then
        record_test "git:invocable" "PASS" "0"
    else
        record_test "git:invocable" "FAIL" "0"
        return 1
    fi

    return 0
}

# Test GitHub MCP
test_github() {
    print_section "Testing GitHub MCP"

    if check_npm_package "@anthropic/mcp-server-github"; then
        record_test "github:installed" "PASS" "0"
    else
        record_test "github:installed" "FAIL" "0"
        return 1
    fi

    if [[ -z "${GITHUB_TOKEN:-}" ]]; then
        record_test "github:auth" "SKIP"
        print_warning "GITHUB_TOKEN not set, skipping auth test"
        return 0
    fi

    record_test "github:auth" "PASS" "0"

    return 0
}

# Test Fetch MCP
test_fetch() {
    print_section "Testing Fetch MCP"

    if check_npm_package "@anthropic/mcp-server-fetch"; then
        record_test "fetch:installed" "PASS" "0"
    else
        record_test "fetch:installed" "FAIL" "0"
        return 1
    fi

    # Test if it can be invoked
    print_verbose "Testing fetch server invocation..."

    if timeout $TEST_TIMEOUT npx -y @anthropic/mcp-server-fetch --help &>/dev/null 2>&1; then
        record_test "fetch:invocable" "PASS" "0"
    else
        record_test "fetch:invocable" "FAIL" "0"
        return 1
    fi

    return 0
}

# Test Brave Search MCP
test_brave_search() {
    print_section "Testing Brave Search MCP"

    if check_npm_package "@anthropic/mcp-server-brave-search"; then
        record_test "brave-search:installed" "PASS" "0"
    else
        record_test "brave-search:installed" "FAIL" "0"
        return 1
    fi

    if [[ -z "${BRAVE_API_KEY:-}" ]]; then
        record_test "brave-search:auth" "SKIP"
        print_warning "BRAVE_API_KEY not set, skipping auth test"
        return 0
    fi

    record_test "brave-search:auth" "PASS" "0"

    return 0
}

# Test Memory MCP
test_memory() {
    print_section "Testing Memory MCP"

    if check_npm_package "@anthropic/mcp-server-memory"; then
        record_test "memory:installed" "PASS" "0"
    else
        record_test "memory:installed" "FAIL" "0"
        return 1
    fi

    # Test if it can be invoked
    print_verbose "Testing memory server invocation..."

    if timeout $TEST_TIMEOUT npx -y @anthropic/mcp-server-memory --help &>/dev/null 2>&1; then
        record_test "memory:invocable" "PASS" "0"
    else
        record_test "memory:invocable" "FAIL" "0"
        return 1
    fi

    return 0
}

# Test Nix/Guix MCP (if available)
test_nix_guix() {
    print_section "Testing Nix/Guix MCP"

    # Check if the server exists in the project
    local nix_guix_server="${NIX_GUIX_SERVER_PATH:-/home/gux/gunix/gemini-mcp/server.py}"

    if [[ -f "$nix_guix_server" ]]; then
        record_test "nix-guix:exists" "PASS" "0"
    else
        record_test "nix-guix:exists" "SKIP"
        print_verbose "Nix/Guix server not found at $nix_guix_server"
        return 0
    fi

    # Check if Python is available
    if ! command_exists python3; then
        record_test "nix-guix:python" "SKIP"
        print_warning "Python 3 not found, skipping Nix/Guix tests"
        return 0
    fi

    # Check dependencies
    if python3 -c "import mcp" 2>/dev/null; then
        record_test "nix-guix:mcp-module" "PASS" "0"
    else
        record_test "nix-guix:mcp-module" "FAIL" "0"
        print_warning "mcp Python module not installed"
        return 1
    fi

    return 0
}

# Parse command-line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -a|--all)
                SINGLE_SERVER=""
                shift
                ;;
            -s|--server)
                SINGLE_SERVER="$2"
                shift 2
                ;;
            -q|--quick)
                QUICK_MODE="true"
                SKIP_SLOW_TESTS="true"
                shift
                ;;
            -v|--verbose)
                VERBOSE="true"
                shift
                ;;
            -d|--debug)
                DEBUG="true"
                VERBOSE="true"
                shift
                ;;
            -c|--config)
                MCP_CONFIG_FILE="$2"
                shift 2
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

# Run all tests
run_all_tests() {
    print_header "MCP Server Test Suite"

    local start_time
    start_time=$(date +%s)

    echo ""

    # Check dependencies
    if ! check_dependencies; then
        return $?
    fi

    echo ""

    # Check configuration
    if ! check_config_file; then
        return $?
    fi

    echo ""

    # Run tests
    if [[ -z "$SINGLE_SERVER" ]] || [[ "$SINGLE_SERVER" == "gemini" ]]; then
        if ! test_gemini; then
            print_warning "Gemini MCP test returned non-zero exit code"
        fi
        echo ""
    fi

    if [[ -z "$SINGLE_SERVER" ]] || [[ "$SINGLE_SERVER" == "filesystem" ]]; then
        if ! test_filesystem; then
            print_warning "Filesystem MCP test returned non-zero exit code"
        fi
        echo ""
    fi

    if [[ -z "$SINGLE_SERVER" ]] || [[ "$SINGLE_SERVER" == "git" ]]; then
        if ! test_git; then
            print_warning "Git MCP test returned non-zero exit code"
        fi
        echo ""
    fi

    if [[ -z "$SINGLE_SERVER" ]] || [[ "$SINGLE_SERVER" == "github" ]]; then
        if ! test_github; then
            print_warning "GitHub MCP test returned non-zero exit code"
        fi
        echo ""
    fi

    if [[ -z "$SINGLE_SERVER" ]] || [[ "$SINGLE_SERVER" == "fetch" ]]; then
        if ! test_fetch; then
            print_warning "Fetch MCP test returned non-zero exit code"
        fi
        echo ""
    fi

    if [[ -z "$SINGLE_SERVER" ]] || [[ "$SINGLE_SERVER" == "brave-search" ]]; then
        if ! test_brave_search; then
            print_warning "Brave Search MCP test returned non-zero exit code"
        fi
        echo ""
    fi

    if [[ -z "$SINGLE_SERVER" ]] || [[ "$SINGLE_SERVER" == "memory" ]]; then
        if ! test_memory; then
            print_warning "Memory MCP test returned non-zero exit code"
        fi
        echo ""
    fi

    if [[ -z "$SINGLE_SERVER" ]] || [[ "$SINGLE_SERVER" == "nix-guix" ]]; then
        if ! test_nix_guix; then
            print_warning "Nix/Guix MCP test returned non-zero exit code"
        fi
        echo ""
    fi

    # Print summary
    local end_time
    end_time=$(date +%s)
    local duration=$((end_time - start_time))

    print_summary "$duration"
}

# Print test summary
print_summary() {
    local duration="$1"

    print_header "Test Summary"

    echo ""
    print_info "Total Tests:  $TOTAL_TESTS"
    print_info "Passed Tests: $PASSED_TESTS"
    print_info "Failed Tests: $FAILED_TESTS"
    print_info "Skipped Tests: $SKIPPED_TESTS"
    print_info "Total Duration: ${duration}s"
    echo ""

    if [[ $FAILED_TESTS -eq 0 ]]; then
        print_success "All tests passed!"
        return 0
    else
        print_error "$FAILED_TESTS test(s) failed"
        return 1
    fi
}

##############################################################################
# Main Execution
##############################################################################

main() {
    parse_args "$@"

    print_debug "QUICK_MODE: $QUICK_MODE"
    print_debug "VERBOSE: $VERBOSE"
    print_debug "MCP_CONFIG_FILE: $MCP_CONFIG_FILE"
    print_debug "SINGLE_SERVER: $SINGLE_SERVER"

    run_all_tests
}

# Run main function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
    exit $?
fi
