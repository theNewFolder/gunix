# Niri Wayland Compositor Configuration

This directory contains configuration files for **Niri**, a scrollable-tiling Wayland compositor designed to be lightweight, fast, and intuitive.

## What is Niri?

Niri is a scrollable-tiling Wayland compositor that combines the benefits of:
- **Tiling**: Automatic window management without floating chaos
- **Scrolling**: Smooth workspace switching and navigation
- **Modern Wayland**: Full Wayland protocol support with native rendering
- **Animations**: Smooth, visually pleasing window and workspace transitions

## Key Features

- **Scrollable Columns**: Windows arranged in columns that you can scroll through
- **Smooth Animations**: Beautiful transitions between workspaces and window changes
- **Keyboard-Driven**: Excellent keyboard navigation (similar to dwl-guile)
- **Multi-Monitor**: Seamless multi-display support
- **XWayland Compatibility**: Run X11 applications via XWayland
- **Emacs Integration**: Same keybindings and workflow as dwl-guile

## Configuration

### File Structure

```
dotfiles/niri/
├── .config/niri/
│   └── config.kdl          # Main Niri configuration file (KDL format)
└── README.md               # This file
```

### Understanding config.kdl

The `config.kdl` file uses **KDL** (KDL Data Language), a simple, intuitive configuration format similar to TOML but more readable.

Key sections:
- **Input**: Keyboard and touchpad settings
- **Output**: Monitor configuration, scaling, positioning
- **Layout**: Window gaps, borders, padding
- **Keybindings**: All keyboard shortcuts
- **Window Rules**: Application-specific behaviors
- **Startup Commands**: Programs to run on startup

### Keybindings Overview

Niri uses **SUPER** (Windows key) as the primary modifier, maintaining consistency with dwl-guile:

#### Application Launchers
- `Super+E`: Open Emacs
- `Super+Return`: Open terminal (foot)
- `Super+D`: Open app launcher (wofi)
- `Super+X`: Emacs M-x equivalent

#### Window Management
- `Super+Q`: Close window
- `Super+O`: Focus next column
- `Super+Shift+O`: Focus previous column
- `Super+J/K`: Navigate (Vim-style)
- `Super+H/L`: Resize columns
- `Super+M`: Maximize column

#### Workspaces
- `Super+1-9`: Switch to workspace 1-9
- `Super+Shift+1-9`: Move window to workspace
- `Super+Tab`: Previous workspace

#### Layout & Display
- `Super+F`: Toggle fullscreen
- `Super+Shift+F`: Toggle floating
- `Super+Ctrl+L`: Lock screen

#### Emacs Integration
- `Super+B`: Switch buffer (Emacs)
- `Super+G`: Magit status
- `Super+N`: Org-roam find node
- `Super+A`: Org agenda
- `Super+S`: Search with ripgrep

## Installation

### Option 1: Using Guix Home (Recommended)

If Niri is available in your Guix setup:

1. Edit `guix-home.scm` and change:
   ```scheme
   (define %selected-compositor 'niri)  ; Change from 'dwl-guile
   ```

2. Apply the configuration:
   ```bash
   guix home reconfigure /path/to/guix-home.scm
   ```

### Option 2: Manual Installation

If Niri is not available in Guix, you'll need to create a custom package:

```scheme
;; Add to guix-home.scm or channels.scm
(define-public niri
  (package
    (name "niri")
    (version "0.1.x")  ; Check latest version
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/YaLTeR/niri")
                    (commit (string-append "v" version))))
              (file-name (git-file-name name version))
              (sha256 (base32 "..."))))
    ;; ... rest of package definition
    ))
```

## Starting Niri

### From TTY

Log into a TTY and run:
```bash
niri
```

Or with Guix:
```bash
guix home reconfigure guix-home.scm  # Sets up the service
herd start niri
```

### With a Display Manager

Add to your NixOS configuration:
```nix
services.greetd.enable = true;
services.greetd.settings.default_session = {
  command = "${pkgs.niri}/bin/niri";
  user = "yourusername";
};
```

## Configuration Changes

### Editing config.kdl

Modify `~/.config/niri/config.kdl` to customize:
- Keybindings
- Window appearance
- Monitor settings
- Startup commands
- Application rules

After saving changes, Niri will automatically reload the configuration (if reload-on-change is enabled).

### Workspace Names

Change workspace names in the configuration:
```kdl
workspace "1:emacs" {}
workspace "2:web" {}
workspace "3:term" {}
// ... etc
```

### Custom Keybindings

Add new bindings:
```kdl
bind Super+Ctrl+T { spawn "emacsclient" "-c" "-e" "(eshell)"; }
```

## Troubleshooting

### Niri doesn't start

1. Check if it's installed:
   ```bash
   which niri
   ```

2. Check logs:
   ```bash
   journalctl --user-unit=niri
   # or
   tail -f ~/.local/var/log/niri.log
   ```

3. Try running directly:
   ```bash
   niri
   ```

### Display looks wrong

- Check monitor configuration in config.kdl
- Verify output names: `wlr-randr` or `wayland-info`
- Check scaling settings

### Keyboard not responding

- Verify XKB layout is correct in config.kdl
- Test with:
  ```bash
  setxkbmap -layout us  # or your layout
  ```

### Windows won't close

- Press `Super+Q` to close focused window
- Or use Alt+F4 (if enabled)

## Comparing with dwl-guile

| Feature | Niri | dwl-guile |
|---------|------|-----------|
| **Layout** | Scrollable tiling | Traditional tiling |
| **Config** | KDL format | Guile (Scheme) |
| **Animations** | Smooth | Minimal |
| **Scripting** | CLI only | Full Guile support |
| **Learning Curve** | Easier | Steeper (Scheme) |
| **Customization** | Limited | Very flexible |

### When to Use Niri

- You prefer a more modern, polished look
- You want smooth animations
- You don't need heavy customization
- You like the scrollable tiling paradigm

### When to Use dwl-guile

- You want maximum customization via Scheme
- You prefer traditional tiling
- You need advanced scripting capabilities
- You want to replicate dwm behavior closely

## Resources

- **Niri GitHub**: https://github.com/YaLTeR/niri
- **Niri Wiki**: https://github.com/YaLTeR/niri/wiki
- **KDL Documentation**: https://kdl.dev/
- **Wayland Documentation**: https://wayland.freedesktop.org/

## Emacs Integration

Niri works seamlessly with the same Emacs setup as dwl-guile:

- EXWM runs under XWayland
- All Emacs keybindings are unchanged
- Same workspace-navigation bindings
- Can run EXWM inside Niri (nested WM setup)

Example architecture:
```
Niri (Wayland compositor)
  ├─ Emacs (pgtk, Wayland client)
  │  └─ EXWM (manages XWayland windows)
  └─ XWayland (X11 compatibility)
```

## Tips & Tricks

### Multi-Workspace Workflows

```kdl
workspace "1:emacs" {}   ; Main editor
workspace "2:web" {}     ; Browser
workspace "3:term" {}    ; Terminals
workspace "4:code" {}    ; IDE/Code
workspace "5:docs" {}    ; Documents
workspace "6:media" {}   ; Media/Entertainment
workspace "7:chat" {}    ; Communication
workspace "8:misc" {}    ; Miscellaneous
workspace "9:sys" {}     ; System utilities
```

### Startup Applications

Customize in config.kdl:
```kdl
startup-command "sh" "-c" "waybar &"       // Status bar
startup-command "sh" "-c" "mako &"         // Notifications
startup-command "sh" "-c" "emacs --daemon" // Emacs daemon
```

### Custom Application Rules

```kdl
window-rule {
    match { app-id "firefox"; }
    open-on-workspace "2:web"
}
```

## Contributing & Customization

To customize Niri further:

1. Edit `~/.config/niri/config.kdl`
2. Reload with `niri reload-config` (if enabled)
3. Or restart: `herd restart niri`

For Guix Home integration updates, modify the niri-service configuration in `guix-home.scm`.

## License

Niri is licensed under the GPL-3.0. This configuration is part of the nixos-guix-setup project.
