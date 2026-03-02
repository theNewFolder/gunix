# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**gunix** is a declarative hybrid Linux system: NixOS provides the kernel, bootloader, init, networking, and GPU drivers; GNU Guix provides all userspace packages, desktop environment (Emacs), and user home configuration. The hostname is `gunix`, targeting x86_64-linux with AMD CPU/GPU (RADV).

## Key Commands

### NixOS System
```bash
sudo nixos-rebuild switch --flake /etc/nixos#gunix    # apply system config
sudo ./install.sh                                      # first install (from live USB)
sudo ./install.sh --dry-run                            # preview install
```

### Guix User Environment
```bash
guix pull                                # update package definitions
guix home reconfigure guix-home.scm      # apply home environment
guix package -m manifest.scm             # install base packages
guix package -m manifest-dev.scm         # install dev tools
guix package -m manifest-emacs.scm       # install emacs packages
guix package -m manifest-wayland.scm     # install wayland desktop
guix shell -m manifest-dev.scm           # temporary dev shell
guix gc --collect-garbage                # garbage collection
```

### MCP Servers
```bash
./mcp/setup-mcp.sh              # install MCP npm packages
./mcp/test-mcp.sh               # test all MCP servers
./mcp/test-mcp.sh --quick       # quick test
nix develop ./gemini-mcp        # enter gemini-mcp dev shell
```

### Dotfiles (GNU Stow)
```bash
cd dotfiles && stow zsh git waybar foot niri   # install symlinks
stow -D zsh                                     # remove
stow -R zsh                                     # restow (update)
```

## Architecture

### Two-Layer Package Management
NixOS layer has only `git` and `curl` in `environment.systemPackages` — everything else comes from Guix. PATH ordering puts `~/.guix-profile/bin` before Nix paths.

### Core Config Files
- **`flake.nix`** — NixOS flake (nixpkgs-unstable + CachyOS kernel with BORE scheduler)
- **`configuration.nix`** — NixOS system config: Guix daemon, build users, systemd-nspawn container, greetd, GPU passthrough
- **`guix-home.scm`** — Central Guix Home config (GNU Scheme): packages, shell, services, compositor selection
- **`channels.scm`** — Guix channels: guix (official), nonguix (nonfree), home-service-dwl-guile, rde
- **`manifest*.scm`** — Guix package manifests split by concern (base, dev, emacs, wayland)
- **`emacs-config.scm`** — Emacs configuration in Scheme

### Guix Container Integration
`configuration.nix` defines a `systemd-nspawn` container (`guix-system`) with GPU passthrough (`/dev/dri`), D-Bus, and host networking. A `systemd.paths` unit watches `/run/host/trigger-nixos-rebuild` to let the container trigger host NixOS rebuilds.

### Wayland Compositors
Three compositors switchable via `%selected-compositor` in `guix-home.scm`:
- **EWM** (active) — Emacs Wayland Manager, compositor runs inside Emacs as a dynamic module
- **dwl-guile** — dwm-inspired tiling, configured in Guile Scheme
- **Niri** — scrollable-tiling, KDL config format (`dotfiles/niri/.config/niri/config.kdl`)

EWM renders Wayland surfaces as Emacs buffers (switch apps with `C-x b`). dwl-guile and Niri share SUPER-key bindings and 9 named workspaces.

### Gemini MCP Server
`gemini-mcp/` contains a Python MCP server packaged as a Nix flake (Python 3.12, google-generativeai, httpx, mcp). API keys (`GEMINI_API_KEY`, `GITHUB_TOKEN`, `BRAVE_API_KEY`) come from environment variables.

## Conventions (Guix-Era)

- **Guix-first**: all userspace software from Guix; NixOS only for bootstrapping and system-level concerns
- **Scheme everywhere**: Guix config, channels, manifests, Emacs config, dwl-guile config are all GNU Guile Scheme
- **Emacs is central**: pgtk build, native compilation, Vertico/Consult/Corfu completion, Eglot LSP, Geiser for Scheme, nix-mode
- **Wayland-first**: `GDK_BACKEND=wayland`, `MOZ_ENABLE_WAYLAND=1`, XWayland for legacy apps
- **Shell scripts use `set -euo pipefail`**
- **Fonts only from Guix** (`fonts.fontconfig.enable = false` in NixOS)
- **User**: `gux`, shell: Zsh, git identity: `gux <gux@gunix>`

---

## Post-Migration Status (NixOS-Era)

**As of 2026-03-03**: Migration from Guix to NixOS unstable-small is **PLANNED & DOCUMENTED**. Ready for execution.

See detailed documentation:
- **GUIX_TO_NIXOS_FINAL_SUMMARY.md** — Complete reference with optimizations and execution checklist
- **INSTALLATION_GUIDE_BTRFS_INPLACE.md** — 7-phase step-by-step guide with checkpoints
- **CLEANUP_STRATEGY.md** — Post-install consolidation strategy

### New Conventions

- **NixOS-first**: NixOS manages kernel, bootloader, init, GPU drivers; Home Manager handles user environment
- **Nix everywhere**: All configuration in Nix language (functional, declarative)
- **Home Manager**: Replaces guix-home.scm with modular architecture and enable/disable flags
- **Niri as primary WM**: Main compositor (Niri + waybar); EWM deferred (Unit 8, `ewm.enable = false`)
- **Single-reboot migration**: Uses nixos-in-place with NIXOS_LUSTRATE (preserves /home, 30-day Guix recovery in /old-root)

### Key Post-Migration Commands

```bash
# System rebuild (day-to-day)
sudo nixos-rebuild switch --flake /etc/nixos#gunix

# User environment (Home Manager)
home-manager switch --flake /etc/nixos#gux

# Generations & rollback
home-manager generations
home-manager switch-generation N

# Update & validate
nix flake update
nixos-rebuild build --flake /etc/nixos#gunix --dry-run

# Cleanup
nix-collect-garbage -d
```

### Key Files Post-Migration

- **`flake.nix`** — NixOS + Home Manager flake
- **`configuration.nix`** — NixOS system config (minimal)
- **`home.nix`** — Home Manager config (215+ packages across 8 modular units)
- **`nix/modules/`** — Modular options, optimization, Firefox configuration
- **`home/emacs/init.el`** — Emacs configuration (replaces emacs-config.scm)
- **`dotfiles/{zsh,git,niri,waybar,foot}/`** — App configs (via Home Manager xdg.configFile)

---
