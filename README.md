# gunix - Minimal NixOS + GNU Guix Hybrid System

A cutting-edge hybrid Linux distribution combining NixOS for system-level configuration and GNU Guix as the primary userspace package manager. This setup provides declarative system management with the flexibility and ideological alignment of GNU Guix.

## Overview

**gunix** is a minimal, opinionated system architecture that leverages the strengths of both NixOS and GNU Guix:

- **NixOS** handles: kernel, bootloader, init system (systemd), networking, GPU drivers, Wayland, SSH, and essential system services
- **GNU Guix** provides: all userspace packages, fonts, desktop environment (EXWM), user home configuration, and application management

This hybrid approach gives you the reproducibility and declarative nature of functional package managers while maintaining a lean system foundation.

## Features

### Core System
- **CachyOS Kernel**: Latest high-performance kernel with BORE scheduler and CPU-specific optimizations (x86_64-v3, x86_64-v4, zen4 variants available)
- **Minimal NixOS Layer**: Only ~50 packages in system closure; Guix handles all userspace applications
- **Systemd Integration**: Modern init system with socket activation and container support
- **LVM Support**: Flexible storage management with snapshot capabilities

### Desktop Environment
- **EXWM (Emacs X Window Manager)**: Keyboard-driven Emacs-based window manager for power users
- **Wayland Ready**: Full support for Wayland sessions with XDG portal integration
- **GPU Support**: AMD RADV drivers (with Mesa) or NVIDIA support; container passthrough for GPU access

### Package Management
- **GNU Guix Home**: Declarative user environment with Scheme-based configuration
- **Guix Package Manifests**: Repeatable environment setup with `manifest.scm`
- **Guix Channels**: Pin package versions and use custom package repositories
- **Binary Substitutes**: Pre-built binaries from ci.guix.gnu.org and bordeaux.guix.gnu.org

### Integration & Extensibility
- **MCP (Model Context Protocol) Integrations**: Gemini MCP server for AI-assisted development
- **systemd-nspawn Containers**: Run full Guix System containers alongside NixOS
- **D-Bus Integration**: System bus access from containers for seamless communication
- **Secret Management**: agenix-compatible secrets framework (optional)

### Developer-Friendly
- **Flake-Based Configuration**: NixOS Flakes for reproducible system builds
- **First-Boot Scripts**: Automated Guix setup during initial system deployment
- **SSH Access**: Pre-configured OpenSSH with root login disabled
- **Emacs + Native Compilation**: Full EXWM setup with native-compiled Emacs for performance

## Quick Start Installation

### Prerequisites

1. **NixOS Live USB**: Boot into a NixOS live environment
2. **Partitions**: Create and mount the following (adjust device names as needed):
   ```
   /dev/sdXN1  →  /mnt/boot         (EFI, ~500MB)
   /dev/sdXN2  →  /mnt              (root, ~50GB+)
   /dev/sdXN3  →  /mnt/home         (home, variable size)
   /dev/sdXN4  →  /mnt/gnu          (Guix store, ~100GB+)
   ```

### Installation Steps

1. **Clone the repository** (or extract the tarball):
   ```bash
   cd /tmp
   git clone https://github.com/yourusername/nixos-guix-setup.git
   cd nixos-guix-setup
   ```

2. **Review and customize** configuration files (optional):
   ```bash
   # Edit hostname, timezone, locale, etc.
   nano configuration.nix
   nano hardware-configuration.nix
   ```

3. **Run the installer** (as root):
   ```bash
   sudo ./install.sh
   ```

   Or for a dry-run to see what will be done:
   ```bash
   sudo ./install.sh --dry-run
   ```

4. **Set root password** (after installation):
   ```bash
   sudo nixos-enter --root /mnt -- passwd
   ```

5. **Reboot** into the new system:
   ```bash
   sudo systemctl reboot
   ```

6. **Complete Guix setup** (on first boot):
   ```bash
   # Log in as user 'gux' with password 'o'
   /root/guix-first-boot.sh
   ```

7. **Configure user Guix home** (as user):
   ```bash
   guix home reconfigure guix-home.scm
   ```

### Post-Installation (On First Boot)

The system will auto-login to the user `gux` which has a default password of `o`. We recommend immediately changing this:

```bash
passwd
```

Then configure the complete home environment:
```bash
guix home reconfigure ~/.config/guix/guix-home.scm
```

## File Structure

```
nixos-guix-setup/
├── README.md                      # This file
├── flake.nix                      # NixOS Flake configuration (inputs & outputs)
├── configuration.nix              # Main NixOS system configuration
├── hardware-configuration.nix     # Hardware-specific settings (generated or customized)
│
├── Guix Configuration
├── guix-home.scm                  # Guix Home declarative user environment
├── guix-container.scm             # Full Guix System container configuration
├── manifest.scm                   # Guix package manifest for reproducibility
├── channels.scm                   # Guix channels (package source configuration)
├── emacs-config.scm               # EXWM and Emacs configuration
│
├── Installation & Setup Scripts
├── install.sh                     # Main installation orchestrator
├── install-guix.sh                # Guix binary bootstrapping
├── post-install.sh                # Post-installation setup script
├── configure-guix-user.sh         # User-level Guix configuration
├── guix-profile.sh                # Guix profile initialization
│
├── Integration & Tools
├── gemini-mcp/                    # Gemini Model Context Protocol server
│   ├── flake.nix
│   ├── server.py                  # Python MCP server implementation
│   └── __pycache__/
├── .mcp.json                      # MCP configuration
├── mcp_import.json                # MCP import configuration
│
└── Development
    ├── .git/                      # Git repository metadata
    └── .claude/                   # Claude Code integration files
```

### Configuration Files Explained

#### `flake.nix`
Declares NixOS configuration inputs (nixpkgs, CachyOS kernel) and outputs. Creates two configurations: `gunix` (primary) and `nixos-guix` (compatibility alias).

**Key inputs:**
- `nixpkgs/nixos-unstable` - Latest NixOS packages
- `nix-cachyos-kernel/release` - Optimized kernel with pre-built binaries

#### `configuration.nix`
Primary NixOS system configuration. Structured into sections:
- **Boot & Kernel**: CachyOS kernel with AMD KVM support
- **Networking**: Minimal firewall with SSH access
- **Services**: greetd auto-login, guix-daemon, D-Bus, systemd-nspawn containers
- **GPU & Wayland**: AMD RADV drivers, Wayland portal support
- **Guix Setup**: Build users, Guix daemon service, SSL certificate handling
- **User Accounts**: Default user `gux` with wheel privileges

#### `guix-home.scm`
Declarative user home environment. Configures:
- Zsh shell with completion and theming
- Emacs with EXWM window manager and native compilation
- Git configuration
- SSH key management
- Dotfiles via GNU Stow integration
- Shepherd services for user-level daemons

#### `manifest.scm`
Repeatable package list for quick environment setup:
- Core utilities (coreutils, findutils, grep, sed, etc.)
- Development tools (git, emacs, vim, etc.)
- Terminal tools (tmux, zoxide, fzf, etc.)
- Language runtimes (python, node.js, rust, etc.)

#### `channels.scm`
Guix package channels configuration. Allows:
- Pinning Guix version to specific commit
- Adding custom package repositories
- Version-controlled dependency management

#### `emacs-config.scm`
Declarative Emacs configuration in Scheme:
- EXWM window manager setup
- Org-mode, magit, consult integration
- Key bindings and theme configuration
- Native compilation settings

### Installation Scripts

- **install.sh**: Main orchestrator that handles prerequisites checking, copying configs, running nixos-install, and post-installation Guix setup
- **install-guix.sh**: Downloads and verifies the Guix binary tarball with GPG signatures
- **post-install.sh**: Comprehensive post-boot setup including user creation, Guix channel updates, and dotfile management
- **configure-guix-user.sh**: User-specific Guix configuration helper
- **guix-profile.sh**: Sources Guix profile for shell initialization

## System Architecture

### Boot Process
1. UEFI → systemd-boot (NixOS)
2. CachyOS kernel with AMD KVM and container modules
3. systemd starts system services
4. greetd displays login prompt
5. Auto-login to user `gux` executes `/run/current-system/sw/bin/guix-container-session`

### Container Integration
The system includes systemd-nspawn container support for running full Guix System instances:
- GPU passthrough via `/dev/dri` binding
- D-Bus system bus access for IPC
- Full device access (`/dev` mounted read-write)
- Host network sharing

### Package Manager Interaction
- **System packages**: Git, curl (minimal NixOS closure)
- **User packages**: All installed via `guix install` or `manifest.scm`
- **Environment setup**: Guix profile prioritized in PATH before system paths
- **SSL certificates**: Symlinked from Guix to system locations

## Development & Customization

### Modifying System Configuration
Edit `configuration.nix` and rebuild:
```bash
sudo nixos-rebuild switch --flake /etc/nixos#gunix
```

### Updating Guix Packages
```bash
# Update package definitions
guix pull

# Install/upgrade packages
guix install package-name

# Or use manifest for reproducible environments
guix install -m manifest.scm
```

### Adding Custom Guix Packages
Edit `channels.scm` to add custom repositories, then:
```bash
guix pull
```

### EXWM Customization
Edit `emacs-config.scm` and reconfigure home:
```bash
guix home reconfigure guix-home.scm
```

### Secrets Management
The configuration includes optional agenix support for encrypted secrets:
1. Generate age keypair: `age-keygen -o`
2. Uncomment agenix import in `configuration.nix`
3. Define secrets: `age.secrets.mysecret.file = ./secrets/mysecret.age`

## Troubleshooting

### Guix daemon fails to start
Check logs: `journalctl -u guix-daemon -n 50`
Ensure guixbuild users exist: `getent group guixbuild`

### Container fails to boot
Verify `/gnu/store` is accessible: `ls -la /gnu/store`
Check D-Bus availability: `systemctl status dbus`

### Wayland session issues
Confirm XDG portal: `systemctl --user status xdg-desktop-portal`
Check GPU drivers: `glxinfo | grep "OpenGL"`

### Emacs/EXWM not starting
Verify native compilation: `emacs --version | grep native`
Check `.emacs.d/eln-cache/` directory exists and is writable

### Network issues after installation
Verify systemd-networkd: `systemctl status systemd-networkd`
Check hostname: `hostnamectl`
Test DNS: `nslookup google.com`

## Performance Tuning

### CachyOS Kernel Variants
The configuration uses `linuxPackages-cachyos-latest-x86_64-v3`. For better performance on supported CPUs:
- **x86_64-v4**: Latest CPUs (Zen 4, Intel 12th gen+)
- **zen4**: Optimized for AMD Ryzen 7000 series
- **linuxPackages-cachyos-lts**: Stable branch with security updates
- **linuxPackages-cachyos-bore**: Alternative scheduler for responsiveness

Change in `configuration.nix`:
```nix
kernelPackages = pkgs.cachyosKernels."linuxPackages-cachyos-latest-x86_64-v4";
```

### Guix Optimization
Enable substitute downloads from multiple caches:
```bash
guix archive --authorize < /path/to/signing-key.pub
```

Increase parallel builds:
```bash
# In environment or ~/.guix-profile/etc/config.scm
(max-jobs 8)
```

## Credits

This project builds on the excellent work and philosophy of:

- **System Crafters**: David Wilson's comprehensive GNU Emacs and Guix Home tutorials. See https://systemcrafters.net/ for their excellent educational content on functional systems and keyboard-driven workflows.

- **GNU Guix Project**: For creating a powerful, purely functional package manager with strong ideological roots in free software and reproducibility.

- **NixOS Community**: For the declarative system configuration paradigm that inspired Guix's approach.

- **CachyOS Project**: For the performance-optimized Linux kernel builds that power this system.

The philosophy behind gunix is to combine the best of both worlds: NixOS's clean system abstraction and CachyOS's performance optimizations, with Guix's freedom-respecting package management and Emacs-based workflows championed by System Crafters.

## License

This configuration is provided as-is for educational and personal use. Please respect the licenses of the projects and software it integrates:
- NixOS (MIT)
- GNU Guix (GPLv3+)
- CachyOS (GPL compatible)
- Emacs (GPLv3+)

## Support & Contributing

For issues specific to this configuration:
1. Check the Troubleshooting section above
2. Review the comments in `configuration.nix` and `guix-home.scm`
3. Consult System Crafters documentation: https://systemcrafters.net/
4. Ask on GNU Guix forums: https://lists.gnu.org/mailman/listinfo/guix-devel

For Guix-specific questions: https://guix.gnu.org/help/
For NixOS help: https://wiki.nixos.org/

---

**Last Updated**: 2026-03-01

Enjoy your declarative, keyboard-driven, freedom-respecting computing experience with gunix!
