#!/usr/bin/env bash
#
# NixOS + Guix Installation Script
# Master installation script for setting up NixOS with GNU Guix
#
# Usage: ./install.sh [--dry-run]
#
# This script:
#   1. Checks prerequisites (mounted partitions)
#   2. Copies NixOS configuration files
#   3. Runs nixos-install
#   4. Sets up Guix post-installation
#

set -euo pipefail

# Configuration
readonly GUIX_VERSION="1.5.0"
readonly GUIX_ARCH="x86_64-linux"
readonly GUIX_TARBALL="guix-binary-${GUIX_VERSION}.${GUIX_ARCH}.tar.xz"
readonly GUIX_URL="https://ftp.gnu.org/gnu/guix/${GUIX_TARBALL}"
readonly GUIX_SIG_URL="${GUIX_URL}.sig"
readonly GNU_KEYRING_URL="https://sv.gnu.org/people/viewgpg.php?user_id=15145"

readonly MOUNT_ROOT="/mnt"
readonly NIXOS_CONFIG_DIR="${MOUNT_ROOT}/etc/nixos"
readonly GUIX_STORE="${MOUNT_ROOT}/gnu"
readonly GUIX_VAR="${MOUNT_ROOT}/var/guix"

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# State
DRY_RUN=false
ERRORS=()

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*"
    ERRORS+=("$*")
}

log_dry() {
    echo -e "${YELLOW}[DRY-RUN]${NC} Would execute: $*"
}

# Execute command or log in dry-run mode
run_cmd() {
    if $DRY_RUN; then
        log_dry "$*"
        return 0
    else
        "$@"
    fi
}

# Print usage information
usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

NixOS + Guix Installation Script

Options:
    --dry-run    Show what would be done without making changes
    -h, --help   Show this help message

Prerequisites:
    - Root privileges
    - Mounted partitions at /mnt, /mnt/boot, /mnt/home, /mnt/gnu
    - configuration.nix and hardware-configuration.nix in script directory

EOF
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root"
        exit 1
    fi
    log_success "Running as root"
}

# Check if a mount point is properly mounted
check_mount() {
    local mount_point="$1"
    local description="$2"

    if mountpoint -q "$mount_point" 2>/dev/null; then
        log_success "$description mounted at $mount_point"
        return 0
    else
        log_error "$description not mounted at $mount_point"
        return 1
    fi
}

# Check all required mount points
check_mounts() {
    log_info "Checking mount points..."

    local all_ok=true

    check_mount "${MOUNT_ROOT}" "Root filesystem" || all_ok=false
    check_mount "${MOUNT_ROOT}/boot" "Boot partition" || all_ok=false
    check_mount "${MOUNT_ROOT}/home" "Home partition" || all_ok=false
    check_mount "${MOUNT_ROOT}/gnu" "Guix store partition" || all_ok=false

    if ! $all_ok; then
        log_error "Not all required partitions are mounted"
        log_info "Please mount partitions before running this script:"
        log_info "  mount /dev/sdXN /mnt"
        log_info "  mount /dev/sdXN /mnt/boot"
        log_info "  mount /dev/sdXN /mnt/home"
        log_info "  mount /dev/sdXN /mnt/gnu"
        return 1
    fi

    log_success "All required partitions are mounted"
    return 0
}

# Check for required configuration files
check_config_files() {
    log_info "Checking configuration files..."

    local all_ok=true

    if [[ -f "${SCRIPT_DIR}/configuration.nix" ]]; then
        log_success "Found configuration.nix"
    else
        log_error "configuration.nix not found in ${SCRIPT_DIR}"
        all_ok=false
    fi

    if [[ -f "${SCRIPT_DIR}/hardware-configuration.nix" ]]; then
        log_success "Found hardware-configuration.nix"
    else
        log_error "hardware-configuration.nix not found in ${SCRIPT_DIR}"
        all_ok=false
    fi

    $all_ok
}

# Copy NixOS configuration files
copy_nixos_config() {
    log_info "Copying NixOS configuration files..."

    # Create /etc/nixos directory if it doesn't exist
    if [[ ! -d "${NIXOS_CONFIG_DIR}" ]]; then
        run_cmd mkdir -p "${NIXOS_CONFIG_DIR}"
        log_info "Created ${NIXOS_CONFIG_DIR}"
    fi

    # Copy configuration.nix
    if [[ -f "${NIXOS_CONFIG_DIR}/configuration.nix" ]]; then
        log_warn "configuration.nix already exists, backing up..."
        run_cmd cp "${NIXOS_CONFIG_DIR}/configuration.nix" \
                   "${NIXOS_CONFIG_DIR}/configuration.nix.backup.$(date +%Y%m%d%H%M%S)"
    fi
    run_cmd cp "${SCRIPT_DIR}/configuration.nix" "${NIXOS_CONFIG_DIR}/"
    log_success "Copied configuration.nix"

    # Copy hardware-configuration.nix
    if [[ -f "${NIXOS_CONFIG_DIR}/hardware-configuration.nix" ]]; then
        log_warn "hardware-configuration.nix already exists, backing up..."
        run_cmd cp "${NIXOS_CONFIG_DIR}/hardware-configuration.nix" \
                   "${NIXOS_CONFIG_DIR}/hardware-configuration.nix.backup.$(date +%Y%m%d%H%M%S)"
    fi
    run_cmd cp "${SCRIPT_DIR}/hardware-configuration.nix" "${NIXOS_CONFIG_DIR}/"
    log_success "Copied hardware-configuration.nix"
}

# Run nixos-install
run_nixos_install() {
    log_info "Running nixos-install..."

    if $DRY_RUN; then
        log_dry "nixos-install --root ${MOUNT_ROOT}"
    else
        nixos-install --root "${MOUNT_ROOT}"
        if [[ $? -eq 0 ]]; then
            log_success "NixOS installation completed"
        else
            log_error "nixos-install failed"
            return 1
        fi
    fi
}

# Create guixbuilder group and users
create_guix_users() {
    log_info "Setting up Guix build users..."

    local chroot_cmd="nixos-enter --root ${MOUNT_ROOT} --"

    # Check if guixbuild group exists
    if $DRY_RUN; then
        log_dry "Create guixbuild group (GID 30000)"
    else
        if ! ${chroot_cmd} getent group guixbuild >/dev/null 2>&1; then
            ${chroot_cmd} groupadd -g 30000 guixbuild
            log_success "Created guixbuild group"
        else
            log_info "guixbuild group already exists"
        fi
    fi

    # Create guixbuilder users (guixbuilder01 through guixbuilder10)
    for i in $(seq -w 1 10); do
        local username="guixbuilder${i}"
        local uid=$((30000 + 10#$i))

        if $DRY_RUN; then
            log_dry "Create user ${username} (UID ${uid})"
        else
            if ! ${chroot_cmd} id "${username}" >/dev/null 2>&1; then
                ${chroot_cmd} useradd \
                    --uid "${uid}" \
                    --gid guixbuild \
                    --home-dir /var/empty \
                    --shell "$(${chroot_cmd} which nologin)" \
                    --comment "Guix build user ${i}" \
                    --system \
                    "${username}"
                log_success "Created user ${username}"
            else
                log_info "User ${username} already exists"
            fi
        fi
    done

    log_success "Guix build users setup complete"
}

# Download and verify Guix binary
download_guix() {
    log_info "Downloading Guix ${GUIX_VERSION}..."

    local tmp_dir
    tmp_dir=$(mktemp -d)
    trap "rm -rf ${tmp_dir}" RETURN

    local tarball="${tmp_dir}/${GUIX_TARBALL}"
    local sig="${tmp_dir}/${GUIX_TARBALL}.sig"

    if $DRY_RUN; then
        log_dry "Download ${GUIX_URL}"
        log_dry "Download ${GUIX_SIG_URL}"
        log_dry "Verify GPG signature"
        log_dry "Extract to ${GUIX_STORE}"
        return 0
    fi

    # Check if Guix is already installed
    if [[ -d "${GUIX_STORE}/store" ]] && [[ -d "${GUIX_VAR}" ]]; then
        log_info "Guix store already exists, skipping download"
        return 0
    fi

    # Download the tarball
    log_info "Downloading Guix tarball..."
    curl -L -o "${tarball}" "${GUIX_URL}"

    # Download the signature
    log_info "Downloading signature..."
    curl -L -o "${sig}" "${GUIX_SIG_URL}"

    # Import GNU keyring and verify (optional, warn on failure)
    log_info "Attempting GPG verification..."
    if command -v gpg >/dev/null 2>&1; then
        # Try to import Ludovic Courtes' key (Guix maintainer)
        gpg --keyserver keyserver.ubuntu.com --recv-keys 3CE464558A84FDC69DB40CFB090B11993D9AEBB5 2>/dev/null || true

        if gpg --verify "${sig}" "${tarball}" 2>/dev/null; then
            log_success "GPG signature verified"
        else
            log_warn "GPG verification failed or key not available, proceeding anyway"
        fi
    else
        log_warn "GPG not available, skipping signature verification"
    fi

    # Extract the tarball
    log_info "Extracting Guix binary..."

    # Create necessary directories
    mkdir -p "${GUIX_STORE}"
    mkdir -p "${GUIX_VAR}"

    # Extract to /mnt (tarball contains gnu/store and var/guix)
    cd "${MOUNT_ROOT}"
    tar --warning=no-timestamp -xf "${tarball}"

    log_success "Guix binary extracted"
}

# Set up Guix profile and symlinks
setup_guix_profile() {
    log_info "Setting up Guix profile..."

    local chroot_cmd="nixos-enter --root ${MOUNT_ROOT} --"

    if $DRY_RUN; then
        log_dry "Create symlink /usr/local/bin/guix"
        log_dry "Create symlink /usr/local/share/info/guix"
        log_dry "Set up root Guix profile"
        return 0
    fi

    # Create symlinks for guix binary
    ${chroot_cmd} mkdir -p /usr/local/bin
    ${chroot_cmd} mkdir -p /usr/local/share/info

    # Link guix binary
    if [[ -e "${GUIX_VAR}/profiles/per-user/root/current-guix/bin/guix" ]]; then
        ${chroot_cmd} ln -sf /var/guix/profiles/per-user/root/current-guix/bin/guix /usr/local/bin/guix
        log_success "Linked guix binary"
    elif [[ -d "${GUIX_STORE}/store" ]]; then
        # Find guix binary in store
        local guix_bin
        guix_bin=$(find "${GUIX_STORE}/store" -name "guix" -type f -executable 2>/dev/null | head -1)
        if [[ -n "${guix_bin}" ]]; then
            local rel_path="${guix_bin#${MOUNT_ROOT}}"
            ${chroot_cmd} ln -sf "${rel_path}" /usr/local/bin/guix
            log_success "Linked guix binary from store"
        fi
    fi

    log_success "Guix profile setup complete"
}

# Authorize Guix substitutes (binary caches)
authorize_substitutes() {
    log_info "Authorizing Guix substitutes..."

    local chroot_cmd="nixos-enter --root ${MOUNT_ROOT} --"

    # Substitute server public keys
    local acl_dir="${MOUNT_ROOT}/etc/guix"
    local acl_file="${acl_dir}/acl"

    if $DRY_RUN; then
        log_dry "Create ${acl_dir}"
        log_dry "Authorize ci.guix.gnu.org"
        log_dry "Authorize bordeaux.guix.gnu.org"
        return 0
    fi

    mkdir -p "${acl_dir}"

    # Check if guix command is available
    if [[ -x "${MOUNT_ROOT}/usr/local/bin/guix" ]] || \
       [[ -x "${GUIX_VAR}/profiles/per-user/root/current-guix/bin/guix" ]]; then

        # Use guix archive to authorize
        local guix_profile="${GUIX_STORE}/store"
        local signing_key

        # Find the signing key for ci.guix.gnu.org
        signing_key=$(find "${guix_profile}" -name "ci.guix.gnu.org.pub" 2>/dev/null | head -1)
        if [[ -n "${signing_key}" ]]; then
            ${chroot_cmd} guix archive --authorize < "${signing_key#${MOUNT_ROOT}}" 2>/dev/null || true
            log_success "Authorized ci.guix.gnu.org"
        fi

        # Find the signing key for bordeaux.guix.gnu.org
        signing_key=$(find "${guix_profile}" -name "bordeaux.guix.gnu.org.pub" 2>/dev/null | head -1)
        if [[ -n "${signing_key}" ]]; then
            ${chroot_cmd} guix archive --authorize < "${signing_key#${MOUNT_ROOT}}" 2>/dev/null || true
            log_success "Authorized bordeaux.guix.gnu.org"
        fi
    else
        log_warn "Guix binary not yet available, substitutes will need to be authorized after first boot"
    fi

    log_info "Substitute authorization complete"
}

# Run initial guix pull
run_guix_pull() {
    log_info "Running initial guix pull..."

    local chroot_cmd="nixos-enter --root ${MOUNT_ROOT} --"

    if $DRY_RUN; then
        log_dry "guix pull"
        return 0
    fi

    # Check if guix-daemon would be available
    if [[ -d "${GUIX_STORE}/store" ]]; then
        log_info "Guix pull will be performed on first boot when guix-daemon is running"
        log_info "Run 'sudo guix pull' after booting into the new system"

        # Create a first-boot script to run guix pull
        local first_boot_script="${MOUNT_ROOT}/root/guix-first-boot.sh"
        cat > "${first_boot_script}" <<'SCRIPT'
#!/usr/bin/env bash
# First boot Guix setup script
# Run this after first boot to complete Guix setup

set -e

echo "Starting Guix daemon..."
systemctl start guix-daemon || true

echo "Running guix pull..."
guix pull

echo "Setting up user profile..."
mkdir -p ~/.config/guix
ln -sf /var/guix/profiles/per-user/root/current-guix ~/.config/guix/current

echo "Guix setup complete!"
echo "Add the following to your shell profile:"
echo '  export GUIX_PROFILE="$HOME/.config/guix/current"'
echo '  source "$GUIX_PROFILE/etc/profile"'
SCRIPT
        chmod +x "${first_boot_script}"
        log_success "Created first-boot script at /root/guix-first-boot.sh"
    else
        log_warn "Guix store not available, skipping guix pull setup"
    fi
}

# Print summary of actions
print_summary() {
    echo
    echo "=============================================="
    echo "           Installation Summary"
    echo "=============================================="
    echo

    if [[ ${#ERRORS[@]} -gt 0 ]]; then
        echo -e "${RED}Errors encountered:${NC}"
        for error in "${ERRORS[@]}"; do
            echo "  - ${error}"
        done
        echo
    fi

    if $DRY_RUN; then
        echo -e "${YELLOW}This was a dry run. No changes were made.${NC}"
        echo "Run without --dry-run to perform the installation."
    else
        echo -e "${GREEN}Installation completed!${NC}"
        echo
        echo "Next steps:"
        echo "  1. Set the root password: nixos-enter --root ${MOUNT_ROOT} -- passwd"
        echo "  2. Reboot into the new system"
        echo "  3. Run /root/guix-first-boot.sh to complete Guix setup"
        echo "  4. Configure your user's Guix profile"
    fi
    echo
}

# Main installation flow
main() {
    echo "=============================================="
    echo "    NixOS + Guix Installation Script"
    echo "=============================================="
    echo

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --dry-run)
                DRY_RUN=true
                log_info "Dry run mode enabled"
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done

    # Phase 1: Prerequisites
    log_info "Phase 1: Checking prerequisites..."
    check_root

    if ! check_mounts; then
        exit 1
    fi

    if ! check_config_files; then
        exit 1
    fi

    echo

    # Phase 2: NixOS Installation
    log_info "Phase 2: NixOS Installation..."
    copy_nixos_config
    run_nixos_install

    echo

    # Phase 3: Guix Setup
    log_info "Phase 3: Guix Post-Installation Setup..."
    create_guix_users
    download_guix
    setup_guix_profile
    authorize_substitutes
    run_guix_pull

    # Summary
    print_summary

    if [[ ${#ERRORS[@]} -gt 0 ]]; then
        exit 1
    fi
}

# Run main
main "$@"
