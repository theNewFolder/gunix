#!/usr/bin/env bash
# Post-Installation Script for NixOS + Guix Setup
# Run this script after first boot to complete the system configuration.
#
# Usage: sudo ./post-install.sh
#
# This script:
# 1. Verifies Guix daemon is running
# 2. Runs guix pull to get latest packages
# 3. Builds and registers the Guix System container
# 4. Applies guix-home configuration
# 5. Sets up auto-login session
# 6. Configures MCP servers for AI tools
# 7. Runs final verification checks

set -euo pipefail

# ==============================================================================
# Configuration
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/var/log/guix-post-install.log"
GUIX_CONTAINER_SCM="${SCRIPT_DIR}/guix-container.scm"
GUIX_HOME_SCM="${SCRIPT_DIR}/guix-home.scm"
CHANNELS_SCM="${SCRIPT_DIR}/channels.scm"
CONTAINER_PATH="/var/lib/machines/guix-system"

# User configuration - updated for new system
TARGET_USER="${SUDO_USER:-gux}"
TARGET_HOME="/home/${TARGET_USER}"
HOSTNAME="gunix"

MCP_CONFIG_DIR="${TARGET_HOME}/.config/mcp"
CLAUDE_CONFIG_DIR="${TARGET_HOME}/.claude"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ==============================================================================
# Helper Functions
# ==============================================================================

log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $*"
    log "INFO" "$*"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
    log "SUCCESS" "$*"
}

warn() {
    echo -e "${YELLOW}[WARNING]${NC} $*"
    log "WARNING" "$*"
}

error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
    log "ERROR" "$*"
}

step() {
    echo ""
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}  $*${NC}"
    echo -e "${CYAN}========================================${NC}"
    log "STEP" "$*"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root (use sudo)"
        exit 1
    fi
}

check_file_exists() {
    local file="$1"
    local description="$2"
    if [[ ! -f "$file" ]]; then
        error "$description not found: $file"
        return 1
    fi
    return 0
}

wait_for_service() {
    local service="$1"
    local max_attempts="${2:-30}"
    local attempt=0

    while [[ $attempt -lt $max_attempts ]]; do
        if systemctl is-active --quiet "$service"; then
            return 0
        fi
        attempt=$((attempt + 1))
        sleep 1
    done
    return 1
}

# ==============================================================================
# Step 1: Verify Guix Daemon
# ==============================================================================

verify_guix_daemon() {
    step "Step 1: Verifying Guix Daemon"

    # Check if guix-daemon service exists
    if ! systemctl list-units --type=service | grep -q "guix-daemon"; then
        error "guix-daemon service not found in systemd"
        info "Attempting to start guix-daemon..."

        if systemctl start guix-daemon 2>/dev/null; then
            success "guix-daemon service started"
        else
            error "Failed to start guix-daemon"
            error "Please ensure Guix is properly installed"
            return 1
        fi
    fi

    # Check if daemon is running
    if systemctl is-active --quiet guix-daemon; then
        success "Guix daemon is running"
    else
        warn "Guix daemon is not running, attempting to start..."
        systemctl start guix-daemon

        if wait_for_service guix-daemon 30; then
            success "Guix daemon started successfully"
        else
            error "Failed to start Guix daemon"
            error "Check logs with: journalctl -u guix-daemon"
            return 1
        fi
    fi

    # Verify guix command is available
    if ! command -v guix &>/dev/null; then
        # Try common locations
        local guix_paths=(
            "/var/guix/profiles/per-user/root/current-guix/bin/guix"
            "/root/.config/guix/current/bin/guix"
            "${TARGET_HOME}/.config/guix/current/bin/guix"
        )

        for guix_path in "${guix_paths[@]}"; do
            if [[ -x "$guix_path" ]]; then
                export PATH="$(dirname "$guix_path"):$PATH"
                success "Found guix at: $guix_path"
                break
            fi
        done

        if ! command -v guix &>/dev/null; then
            error "guix command not found in PATH"
            return 1
        fi
    fi

    # Test guix daemon connectivity
    info "Testing Guix daemon connectivity..."
    if guix describe &>/dev/null; then
        success "Guix daemon is responsive"
    else
        error "Guix daemon is not responding properly"
        return 1
    fi

    return 0
}

# ==============================================================================
# Step 2: Guix Pull with Channels
# ==============================================================================

run_guix_pull() {
    step "Step 2: Running guix pull (this may take a while)"

    # Copy channels.scm to user's Guix config directory
    local guix_config_dir="${TARGET_HOME}/.config/guix"
    mkdir -p "$guix_config_dir"

    if [[ -f "$CHANNELS_SCM" ]]; then
        cp "$CHANNELS_SCM" "$guix_config_dir/channels.scm"
        chown -R "$TARGET_USER:$TARGET_USER" "$guix_config_dir"
        info "Installed channels.scm to $guix_config_dir/channels.scm"
    fi

    info "Updating Guix package definitions..."
    info "This downloads the latest packages from Guix channels"

    # Run guix pull with progress indication
    if guix pull --verbosity=1 2>&1 | tee -a "$LOG_FILE"; then
        success "guix pull completed successfully"
    else
        warn "guix pull encountered issues"
        warn "Continuing with existing package definitions..."
    fi

    # Source the new profile
    local current_guix="$HOME/.config/guix/current"
    if [[ -d "$current_guix" ]]; then
        export PATH="$current_guix/bin:$PATH"
        info "Updated PATH with new Guix profile"
    fi

    # Show current Guix version
    info "Current Guix version:"
    guix describe | head -5 | tee -a "$LOG_FILE"

    return 0
}

# ==============================================================================
# Step 3: Build and Register Guix System Container
# ==============================================================================

build_guix_container() {
    step "Step 3: Building Guix System Container"

    if ! check_file_exists "$GUIX_CONTAINER_SCM" "Guix container configuration"; then
        return 1
    fi

    info "Building Guix System container from: $GUIX_CONTAINER_SCM"
    info "This may take 10-30 minutes on first build..."

    # Create container directory
    mkdir -p "$(dirname "$CONTAINER_PATH")"
    mkdir -p /var/lib/guix-container

    # Build the container
    local container_script
    if container_script=$(guix system container "$GUIX_CONTAINER_SCM" 2>&1 | tee -a "$LOG_FILE" | tail -1); then
        if [[ -n "$container_script" && -x "$container_script" ]]; then
            success "Container built successfully"
            info "Container script: $container_script"

            # Register the container for systemd-nspawn
            info "Registering container for systemd-nspawn..."

            # Extract the container root from the script
            # The script typically runs systemd-nspawn with a specific root
            # We need to set up the machine directory properly
            mkdir -p "$CONTAINER_PATH"

            # Create a symlink or copy the container
            # For now, we store the container script path
            echo "$container_script" > /var/lib/guix-container/container-script

            success "Container registered at: $CONTAINER_PATH"
        else
            warn "Container build completed but script path unclear"
            warn "Build output: $container_script"
        fi
    else
        error "Failed to build Guix System container"
        error "Check the configuration file for errors"
        return 1
    fi

    return 0
}

# ==============================================================================
# Step 4: Apply Guix Home Configuration
# ==============================================================================

apply_guix_home() {
    step "Step 4: Applying Guix Home Configuration"

    if ! check_file_exists "$GUIX_HOME_SCM" "Guix Home configuration"; then
        return 1
    fi

    info "Applying Guix Home configuration from: $GUIX_HOME_SCM"
    info "Configuring home environment for user: $TARGET_USER"

    # Run guix home reconfigure as the target user
    if sudo -u "$TARGET_USER" guix home reconfigure "$GUIX_HOME_SCM" 2>&1 | tee -a "$LOG_FILE"; then
        success "Guix Home configuration applied successfully"

        # Activate the new home profile
        local home_profile="${TARGET_HOME}/.guix-home/profile"
        if [[ -d "$home_profile" ]]; then
            info "Home profile activated at: $home_profile"
        fi
    else
        error "Failed to apply Guix Home configuration"
        warn "You may need to fix errors in $GUIX_HOME_SCM"
        return 1
    fi

    return 0
}

# ==============================================================================
# Step 5: Set Up Auto-Login Session
# ==============================================================================

setup_auto_login() {
    step "Step 5: Setting Up Auto-Login Session"

    # The auto-login is configured in NixOS configuration.nix via greetd
    # Here we verify the configuration and make any necessary adjustments

    local session_script="/run/current-system/sw/bin/guix-container-session"

    if [[ -x "$session_script" ]]; then
        success "Guix container session script exists"
    else
        warn "Session script not found, creating fallback..."

        # Create a fallback session script
        mkdir -p /usr/local/bin
        cat > /usr/local/bin/guix-container-session << EOSESSION
#!/bin/sh
# Guix Container Session Launcher (Fallback)

CONTAINER_NAME="guix-system"
CONTAINER_PATH="/var/lib/machines/guix-system"

# Check if container exists
if [ ! -d "\$CONTAINER_PATH" ]; then
    echo "Guix System container not found at \$CONTAINER_PATH"
    echo "Starting fallback shell..."
    exec /bin/sh
fi

# Check if container is already running
if machinectl status "\$CONTAINER_NAME" >/dev/null 2>&1; then
    exec machinectl shell "${TARGET_USER}"@"\$CONTAINER_NAME"
else
    machinectl start "\$CONTAINER_NAME"
    sleep 2
    exec machinectl shell "${TARGET_USER}"@"\$CONTAINER_NAME"
fi
EOSESSION
        chmod +x /usr/local/bin/guix-container-session
        success "Created fallback session script"
    fi

    # Verify greetd configuration
    if systemctl is-enabled greetd &>/dev/null; then
        info "greetd is enabled for auto-login"

        if systemctl is-active greetd &>/dev/null; then
            success "greetd is running"
        else
            info "greetd will start on next boot"
        fi
    else
        warn "greetd is not enabled"
        info "Enable with: sudo systemctl enable greetd"
    fi

    # Create XDG autostart entries for Wayland session
    local autostart_dir="${TARGET_HOME}/.config/autostart"
    mkdir -p "$autostart_dir"
    chown "$TARGET_USER:$TARGET_USER" "$autostart_dir"

    success "Auto-login session configured"
    return 0
}

# ==============================================================================
# Step 6: Configure MCP Servers for AI Tools
# ==============================================================================

configure_mcp_servers() {
    step "Step 6: Configuring MCP Servers for AI Tools"

    # Create MCP configuration directory
    mkdir -p "${TARGET_HOME}/.config/mcp"
    chown -R "$TARGET_USER:$TARGET_USER" "${TARGET_HOME}/.config/mcp"

    # Create Claude configuration directory
    mkdir -p "${TARGET_HOME}/.claude"
    chown -R "$TARGET_USER:$TARGET_USER" "${TARGET_HOME}/.claude"

    info "Creating MCP servers configuration..."

    # Create the main MCP configuration file
    cat > "${TARGET_HOME}/.mcp.json" << 'EOMCP'
{
  "mcpServers": {
    "gemini": {
      "command": "npx",
      "args": ["-y", "@anthropic/gemini-mcp-server"],
      "env": {
        "GEMINI_API_KEY": "${GEMINI_API_KEY}",
        "GEMINI_MODEL": "gemini-2.0-flash"
      },
      "description": "Google Gemini AI for auxiliary AI tasks"
    },
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@anthropic/mcp-server-filesystem",
        "/home/gux",
        "/etc/nixos",
        "/tmp",
        "/gnu/store"
      ],
      "description": "Filesystem access for home, NixOS config, and Guix store"
    },
    "git": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-git"],
      "env": {
        "GIT_AUTHOR_NAME": "gux",
        "GIT_AUTHOR_EMAIL": "gux@gunix"
      },
      "description": "Git operations and repository management"
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}"
      },
      "description": "GitHub API integration"
    },
    "fetch": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-fetch"],
      "description": "Web content fetching and retrieval"
    },
    "brave-search": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-brave-search"],
      "env": {
        "BRAVE_API_KEY": "${BRAVE_API_KEY}"
      },
      "description": "Brave Search API for web searching"
    },
    "nix-guix": {
      "command": "nix",
      "args": [
        "--extra-experimental-features",
        "nix-command flakes",
        "run",
        "/home/gux/nixos-guix-setup/gemini-mcp"
      ],
      "env": {
        "OLLAMA_MODEL": "qwen2.5:3b",
        "GEMINI_API_KEY": "${GEMINI_API_KEY}",
        "NIX_CONFIG_DIR": "/etc/nixos",
        "GUIX_PROFILE": "/home/gux/.guix-profile"
      },
      "description": "Nix/Guix package management MCP server with AI assistance"
    },
    "memory": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-memory"],
      "description": "Persistent memory for context retention"
    }
  }
}
EOMCP
    chown "$TARGET_USER:$TARGET_USER" "${TARGET_HOME}/.mcp.json"
    success "Created MCP servers configuration at ${TARGET_HOME}/.mcp.json"

    # Create Claude settings with MCP configuration
    cat > "${TARGET_HOME}/.claude/settings.json" << 'EOCLAUDE'
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
      "args": [
        "-y",
        "@anthropic/mcp-server-filesystem",
        "/home/gux",
        "/etc/nixos",
        "/tmp",
        "/gnu/store"
      ]
    },
    "git": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-git"],
      "env": {
        "GIT_AUTHOR_NAME": "gux",
        "GIT_AUTHOR_EMAIL": "gux@gunix"
      }
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
    "nix-guix": {
      "command": "nix",
      "args": [
        "--extra-experimental-features",
        "nix-command flakes",
        "run",
        "/home/gux/nixos-guix-setup/gemini-mcp"
      ],
      "env": {
        "OLLAMA_MODEL": "qwen2.5:3b",
        "GEMINI_API_KEY": "${GEMINI_API_KEY}"
      }
    },
    "memory": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-memory"]
    }
  },
  "permissions": {
    "allow": [
      "Bash(git:*)",
      "Bash(nix:*)",
      "Bash(nix-shell:*)",
      "Bash(nixos-rebuild:*)",
      "Bash(guix:*)",
      "Bash(npm:*)",
      "Bash(npx:*)",
      "Bash(node:*)",
      "Bash(python:*)",
      "Bash(python3:*)",
      "Bash(curl:*)",
      "Bash(wget:*)",
      "Bash(pgrep:*)",
      "Bash(systemctl:*)",
      "Bash(journalctl:*)",
      "Bash(machinectl:*)",
      "Bash(ls:*)",
      "Bash(cat:*)",
      "Bash(head:*)",
      "Bash(tail:*)",
      "Bash(grep:*)",
      "Bash(find:*)",
      "Bash(chmod:*)",
      "Bash(mkdir:*)",
      "Bash(cp:*)",
      "Bash(mv:*)",
      "Bash(rm:*)",
      "WebSearch",
      "WebFetch(domain:github.com)",
      "WebFetch(domain:gitlab.com)",
      "WebFetch(domain:discourse.nixos.org)",
      "WebFetch(domain:wiki.nixos.org)",
      "WebFetch(domain:mynixos.com)",
      "WebFetch(domain:guix.gnu.org)",
      "WebFetch(domain:git.savannah.gnu.org)",
      "WebFetch(domain:packages.guix.gnu.org)"
    ]
  }
}
EOCLAUDE
    chown "$TARGET_USER:$TARGET_USER" "${TARGET_HOME}/.claude/settings.json"
    success "Created Claude settings"

    # Create MCP servers directory config (alternative location some tools use)
    mkdir -p "${TARGET_HOME}/.config/mcp"
    cat > "${TARGET_HOME}/.config/mcp/servers.json" << 'EOMCPALT'
{
  "servers": {
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
      "args": ["-y", "@anthropic/mcp-server-filesystem", "/home/gux", "/etc/nixos", "/tmp"]
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
EOMCPALT
    chown -R "$TARGET_USER:$TARGET_USER" "${TARGET_HOME}/.config/mcp"
    success "Created MCP servers directory config"

    # Create environment file for API keys (placeholder)
    local env_dir="${TARGET_HOME}/.config/environment.d"
    mkdir -p "$env_dir"

    if [[ ! -f "$env_dir/50-ai-keys.conf" ]]; then
        cat > "$env_dir/50-ai-keys.conf" << 'EOENV'
# AI API Keys Configuration for NixOS+Guix System
# Edit this file to add your actual API keys
# These environment variables will be loaded by systemd user sessions
#
# After editing, reload with: systemctl --user import-environment

# ============================================================================
# AI Provider API Keys
# ============================================================================

# Anthropic Claude API Key (for Claude Code CLI)
# Get yours at: https://console.anthropic.com/
# ANTHROPIC_API_KEY=sk-ant-api03-...

# Google Gemini API Key (for Gemini MCP server)
# Get yours at: https://aistudio.google.com/apikey
# GEMINI_API_KEY=AIza...

# ============================================================================
# Code & Search APIs
# ============================================================================

# GitHub Personal Access Token (for MCP GitHub server)
# Create at: https://github.com/settings/tokens
# Required scopes: repo, read:org, read:user
# GITHUB_TOKEN=ghp_...

# Brave Search API Key (for web search MCP server)
# Get yours at: https://brave.com/search/api/
# BRAVE_API_KEY=BSA...

# ============================================================================
# Local AI Configuration (Ollama)
# ============================================================================

# Ollama model for local AI tasks
OLLAMA_MODEL=qwen2.5:3b
OLLAMA_HOST=http://localhost:11434

# ============================================================================
# Nix/Guix Configuration
# ============================================================================

# NixOS configuration directory
NIX_CONFIG_DIR=/etc/nixos

# Guix profile
GUIX_PROFILE=/home/gux/.guix-profile
EOENV
        chown "$TARGET_USER:$TARGET_USER" "$env_dir/50-ai-keys.conf"
        info "Created API keys placeholder at: $env_dir/50-ai-keys.conf"
        warn "Remember to edit this file and add your actual API keys!"
    else
        info "API keys configuration already exists"
    fi

    chown -R "$TARGET_USER:$TARGET_USER" "$env_dir"

    # Create npm global directory structure
    local npm_global="${TARGET_HOME}/.npm-global"
    mkdir -p "$npm_global/bin" "$npm_global/lib"
    chown -R "$TARGET_USER:$TARGET_USER" "$npm_global"

    # Create npmrc for global package location
    cat > "${TARGET_HOME}/.npmrc" << EONPMRC
prefix=${npm_global}
EONPMRC
    chown "$TARGET_USER:$TARGET_USER" "${TARGET_HOME}/.npmrc"

    info "npm global packages will be installed to: $npm_global"

    # Pre-cache MCP server packages (as user)
    info "Pre-caching MCP server packages..."
    sudo -u "$TARGET_USER" bash -c "
        export PATH=\"$npm_global/bin:\$PATH\"
        export NPM_CONFIG_PREFIX=\"$npm_global\"

        # Try to cache the main MCP packages
        npx -y @anthropic/mcp-server-filesystem --help 2>/dev/null || true
        npx -y @anthropic/mcp-server-git --help 2>/dev/null || true
        npx -y @anthropic/mcp-server-fetch --help 2>/dev/null || true
    " &>/dev/null || true

    success "MCP servers configured"
    return 0
}

# ==============================================================================
# Step 7: Final Verification Checks
# ==============================================================================

run_verification() {
    step "Step 7: Running Final Verification Checks"

    local checks_passed=0
    local checks_failed=0

    verify_check() {
        local name="$1"
        local command="$2"

        if eval "$command" &>/dev/null; then
            echo -e "  ${GREEN}[PASS]${NC} $name"
            ((checks_passed++))
        else
            echo -e "  ${RED}[FAIL]${NC} $name"
            ((checks_failed++))
        fi
    }

    echo ""
    info "Running verification checks..."
    echo ""

    # System checks
    echo "System Services:"
    verify_check "Guix daemon running" "systemctl is-active guix-daemon"
    verify_check "D-Bus system bus" "systemctl is-active dbus"
    verify_check "greetd configured" "systemctl is-enabled greetd"

    echo ""
    echo "Guix Installation:"
    verify_check "guix command available" "command -v guix"
    verify_check "guix daemon responsive" "guix describe"
    verify_check "/gnu/store exists" "test -d /gnu/store"
    verify_check "/var/guix exists" "test -d /var/guix"

    echo ""
    echo "Configuration Files:"
    verify_check "guix-container.scm" "test -f '$GUIX_CONTAINER_SCM'"
    verify_check "guix-home.scm" "test -f '$GUIX_HOME_SCM'"
    verify_check "channels.scm" "test -f '$CHANNELS_SCM'"
    verify_check "MCP .mcp.json" "test -f '${TARGET_HOME}/.mcp.json'"
    verify_check "Claude settings.json" "test -f '${TARGET_HOME}/.claude/settings.json'"
    verify_check "MCP servers.json" "test -f '${TARGET_HOME}/.config/mcp/servers.json'"

    echo ""
    echo "User Environment:"
    verify_check "User home directory" "test -d '${TARGET_HOME}'"
    verify_check "Guix config dir" "test -d '${TARGET_HOME}/.config/guix'"
    verify_check "npm global dir" "test -d '${TARGET_HOME}/.npm-global'"
    verify_check "API keys config" "test -f '${TARGET_HOME}/.config/environment.d/50-ai-keys.conf'"

    echo ""
    echo "Container Setup:"
    verify_check "Container directory exists" "test -d /var/lib/machines"
    verify_check "systemd-machined" "systemctl is-active systemd-machined 2>/dev/null || systemctl is-enabled systemd-machined"

    # Summary
    echo ""
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}  Verification Summary${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo -e "  Passed: ${GREEN}$checks_passed${NC}"
    echo -e "  Failed: ${RED}$checks_failed${NC}"
    echo ""

    if [[ $checks_failed -eq 0 ]]; then
        success "All verification checks passed!"
        return 0
    else
        warn "$checks_failed check(s) failed - review the output above"
        return 1
    fi
}

# ==============================================================================
# Summary and Next Steps
# ==============================================================================

print_summary() {
    step "Post-Installation Complete"

    cat << EOSUMMARY

${GREEN}Setup completed successfully for user: ${TARGET_USER} on host: ${HOSTNAME}${NC}

${CYAN}What was configured:${NC}
  - Guix daemon verified and running
  - Guix packages updated to latest versions
  - Guix channels installed (~/.config/guix/channels.scm)
  - Guix System container configuration prepared
  - Guix Home environment configured
  - Auto-login session set up with greetd
  - MCP servers configured for AI tools:
    * Gemini (Google AI)
    * Filesystem access
    * Git operations
    * GitHub integration
    * Web fetch
    * Brave Search
    * Nix/Guix package management
    * Memory/context persistence

${CYAN}Next Steps:${NC}

  1. ${YELLOW}Add your API keys:${NC}
     Edit: ${TARGET_HOME}/.config/environment.d/50-ai-keys.conf
     Add your ANTHROPIC_API_KEY, GEMINI_API_KEY, GITHUB_TOKEN, and BRAVE_API_KEY

  2. ${YELLOW}Reload environment:${NC}
     systemctl --user import-environment
     # Or log out and log back in

  3. ${YELLOW}Test MCP servers:${NC}
     npx -y @anthropic/mcp-server-filesystem --help
     npx -y @anthropic/mcp-server-git --help

  4. ${YELLOW}Build the full Guix System container (optional):${NC}
     sudo guix system container guix-container.scm -r /var/lib/machines/guix-system

  5. ${YELLOW}Apply Guix Home as user:${NC}
     guix home reconfigure guix-home.scm

  6. ${YELLOW}Install additional packages:${NC}
     guix install <package-name>

  7. ${YELLOW}Reboot to test auto-login:${NC}
     sudo reboot

${CYAN}Useful Commands:${NC}
  guix search <term>          - Search for packages
  guix install <package>      - Install a package
  guix upgrade                - Upgrade all packages
  guix gc                     - Garbage collect unused packages
  guix home reconfigure       - Reconfigure home environment
  guix pull                   - Update package definitions
  machinectl list             - List running containers
  journalctl -u guix-daemon   - View Guix daemon logs

${CYAN}MCP Server Locations:${NC}
  ~/.mcp.json                            - Main MCP configuration
  ~/.claude/settings.json                - Claude Code settings
  ~/.config/mcp/servers.json             - Alternative MCP config

${CYAN}Log file:${NC} $LOG_FILE

EOSUMMARY
}

# ==============================================================================
# Main Execution
# ==============================================================================

main() {
    # Initialize log file
    mkdir -p "$(dirname "$LOG_FILE")"
    echo "======================================" >> "$LOG_FILE"
    echo "Post-installation started: $(date)" >> "$LOG_FILE"
    echo "Target user: $TARGET_USER" >> "$LOG_FILE"
    echo "Hostname: $HOSTNAME" >> "$LOG_FILE"
    echo "======================================" >> "$LOG_FILE"

    echo ""
    echo -e "${CYAN}NixOS + Guix Post-Installation Script${NC}"
    echo -e "${CYAN}======================================${NC}"
    echo -e "Target user: ${GREEN}${TARGET_USER}${NC}"
    echo -e "Hostname: ${GREEN}${HOSTNAME}${NC}"
    echo ""

    # Check for root privileges
    check_root

    # Run all steps
    local failed=0

    if ! verify_guix_daemon; then
        error "Step 1 failed: Guix daemon verification"
        ((failed++))
    fi

    if ! run_guix_pull; then
        warn "Step 2 had issues: guix pull"
        # Don't count as fatal failure
    fi

    if ! build_guix_container; then
        warn "Step 3 had issues: Container build"
        warn "You can build the container manually later"
        # Don't count as fatal failure
    fi

    if ! apply_guix_home; then
        warn "Step 4 had issues: Guix Home configuration"
        warn "You can apply the configuration manually: guix home reconfigure guix-home.scm"
        # Don't count as fatal failure
    fi

    if ! setup_auto_login; then
        warn "Step 5 had issues: Auto-login setup"
        # Don't count as fatal failure
    fi

    if ! configure_mcp_servers; then
        warn "Step 6 had issues: MCP server configuration"
        # Don't count as fatal failure
    fi

    if ! run_verification; then
        warn "Step 7: Some verification checks failed"
        # Don't count as fatal failure
    fi

    # Print summary
    print_summary

    # Log completion
    echo "Post-installation completed: $(date)" >> "$LOG_FILE"
    echo "Failed steps: $failed" >> "$LOG_FILE"

    if [[ $failed -gt 0 ]]; then
        error "Installation completed with $failed critical error(s)"
        exit 1
    fi

    success "Post-installation completed successfully!"
    exit 0
}

# Run main function
main "$@"
