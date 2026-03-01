# Guix Manifest Files Guide

This directory contains several Guix manifest files for managing packages. Each manifest can be installed independently or combined with others.

## Overview

### manifest-dev.scm (Development Tools)
**File size:** 6.7 KB | **Lines:** 145 | **Packages:** ~61

A comprehensive development environment including:
- Language compilers: GCC, Rust, Go, Python, Node.js, Ruby, Haskell
- Build tools: Make, CMake, Meson, Ninja, Autotools
- Debuggers: GDB, LLDB, Valgrind, Perf
- LSP servers: Clangd, rust-analyzer, gopls, typescript
- Version control: Git, Mercurial
- Code quality tools: ShellCheck, Yamllint, Pylint

**Use when:** You need a complete development environment for multiple languages.

### manifest-emacs.scm (Emacs + Packages)
**File size:** 9.8 KB | **Lines:** 217 | **Packages:** ~63

A fully-featured Emacs setup including:
- Core: emacs-pgtk (Wayland-native)
- UI: Doom modeline, which-key, helpful
- Completion: Vertico, Consult, Corfu (modern minibuffer)
- Org ecosystem: org-roam, org-roam-ui, org-modern
- Git: Magit and related tools
- Development: Eglot (LSP), Flycheck, Yasnippet
- Languages: Scheme, Nix, Markdown, YAML, JSON, Rust, Go, Python
- Optional: Evil (Vim mode), EXWM (window manager)
- Themes: Doom, Ef, Modus, Catppuccin
- Fonts: Fira Code, Iosevka, Noto, Jetbrains Mono

**Use when:** Setting up Emacs as your primary editor/environment.

### manifest-wayland.scm (Wayland Desktop)
**File size:** 13 KB | **Lines:** 277 | **Packages:** ~83

A complete Wayland desktop environment including:
- Compositors: Wayland, Weston, Sway
- Lock screen: Swaylock, Swayidle
- Bar/launcher: Waybar, Wofi
- Terminal: Foot, Alacritty, Kitty, Wezterm
- Clipboard: wl-clipboard, wl-klipper
- Screenshots: Grim, Slurp, wf-recorder
- File managers: Thunar, Nautilus, Nemo
- Browsers: Firefox (Wayland), Chromium
- Utilities: Fzf, Ripgrep, Fd, Htop, Btop
- Audio: PulseAudio, ALSA
- Notifications: Mako, Dunst

**Use when:** Setting up a complete Wayland-based desktop system.

## Installation Methods

### Basic Installation

Install all packages from a single manifest:
```bash
guix package -m /home/nixos/nixos-guix-setup/manifest-dev.scm
guix package -m /home/nixos/nixos-guix-setup/manifest-emacs.scm
guix package -m /home/nixos/nixos-guix-setup/manifest-wayland.scm
```

### Temporary Environment

Create a temporary shell with packages (does not modify profile):
```bash
# Single manifest
guix shell -m /home/nixos/nixos-guix-setup/manifest-dev.scm

# Multiple manifests combined
guix shell -m manifest-dev.scm -m manifest-emacs.scm -m manifest-wayland.scm -- bash
```

### Specific Profile

Install to a named profile instead of default:
```bash
guix package -m manifest-dev.scm -p ~/profiles/dev
guix package -m manifest-emacs.scm -p ~/profiles/emacs
guix package -m manifest-wayland.scm -p ~/profiles/wayland
```

Then activate a profile:
```bash
source ~/profiles/emacs/etc/profile
```

## Recommended Combinations

### Development Workstation
```bash
guix shell -m manifest-dev.scm -m manifest-emacs.scm
```
Gives you: Compilers, LSP servers, debuggers + Emacs

### Complete Desktop with Development
```bash
guix shell -m manifest-dev.scm -m manifest-emacs.scm -m manifest-wayland.scm
```
Gives you: Everything - development tools, Emacs, and a complete Wayland desktop

### Minimal Development
```bash
guix shell -m manifest-dev.scm
```
Just development tools and compilers

### Emacs-Focused
```bash
guix shell -m manifest-emacs.scm
```
Emacs with all packages, but no other development tools or desktop components

### Wayland Desktop Only
```bash
guix shell -m manifest-wayland.scm
```
Complete Wayland desktop without heavy development tools

## Configuration After Installation

### For manifest-emacs.scm
Create Emacs configuration files:
```bash
mkdir -p ~/.emacs.d
# Copy init.el and early-init.el to ~/.emacs.d/
# See emacs-config.scm for examples
```

### For manifest-wayland.scm
Create configuration directories:
```bash
mkdir -p ~/.config/sway
mkdir -p ~/.config/waybar
mkdir -p ~/.config/foot
mkdir -p ~/.config/mako
mkdir -p ~/.config/wofi
# Create config files in each directory
```

## Useful Guix Commands

### List installed packages from a manifest
```bash
guix package -m manifest-dev.scm -A
```

### Export current profile to a manifest
```bash
guix package --export-manifest > my-manifest.scm
```

### Search for a package
```bash
guix search rust
```

### Show package details
```bash
guix show gcc-toolchain
```

### Remove packages by manifest
```bash
guix package --remove-all -p ~/.guix-profile
```

### Create a new generation from manifest
```bash
guix package -m manifest-dev.scm --bootstrap
```

## File Structure

```
/home/nixos/nixos-guix-setup/
├── manifest.scm              # Original base manifest
├── manifest-dev.scm          # Development tools
├── manifest-emacs.scm        # Emacs packages
├── manifest-wayland.scm      # Wayland tools
├── emacs-config.scm          # Emacs configuration (reference)
├── guix-home.scm             # Guix Home configuration
└── MANIFEST-GUIDE.md         # This file
```

## Key Differences from manifest.scm

The original `manifest.scm` contains:
- Basic system utilities
- Core tools (shells, editors, version control)
- Build essentials

The new manifests are more specialized:
- **manifest-dev.scm**: Adds compilers, LSP, debuggers
- **manifest-emacs.scm**: Complete Emacs ecosystem
- **manifest-wayland.scm**: Complete Wayland desktop

## Maintenance

To update packages:
```bash
# Refresh package database
guix pull

# Then reinstall manifests
guix package -m manifest-dev.scm
```

To list changes between generations:
```bash
guix describe
```

## Troubleshooting

### Package not found
```bash
guix search package-name
# If not found, try: guix describe to see available packages
```

### Conflicting package versions
Use separate profiles for conflicting packages:
```bash
guix package -m manifest-A.scm -p ~/profiles/a
guix package -m manifest-B.scm -p ~/profiles/b
```

### Disk space
Older generations can be removed:
```bash
guix gc --collect-garbage
guix gc --collect-garbage=1m  # Keep 1 month of history
```

## Additional Resources

- Guix Manual: https://guix.gnu.org/manual/
- Package Search: `guix search <term>`
- Channel Info: See channels.scm for available packages

## Notes

1. All manifests use `specifications->manifest` for maximum compatibility
2. Package names are exactly as they appear in Guix
3. Comments describe each package's purpose
4. Manifests are organized by functionality for easy customization
5. Some packages (especially LSP servers) may have newer versions via language-specific package managers

---
Created: 2026-03-01
