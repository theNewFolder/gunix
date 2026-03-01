# Niri Quick Start Guide

## TL;DR - Get Niri Running in 3 Steps

### 1. Enable Niri in Guix Home

Edit `/home/nixos/nixos-guix-setup/guix-home.scm` (around line 318):

```scheme
(define %selected-compositor 'niri)  ; Change from 'dwl-guile
```

### 2. Apply Configuration

```bash
cd /home/nixos/nixos-guix-setup
guix home reconfigure guix-home.scm
```

### 3. Start Niri

```bash
# Option A: Start via Shepherd
herd start niri

# Option B: Exit current compositor and run directly
niri
```

## Essential Keybindings

| Action | Keys |
|--------|------|
| Open Emacs | `Super+E` |
| Open Terminal | `Super+Return` |
| App Launcher | `Super+D` |
| Close Window | `Super+Q` |
| Next Window | `Super+O` |
| Switch Workspace | `Super+1` to `Super+9` |
| Move to Workspace | `Super+Shift+1` to `Super+9` |
| Fullscreen | `Super+F` |
| Lock Screen | `Super+Ctrl+L` |
| Quit Niri | `Super+Shift+Q` |

## Configuration

### Location
```
~/.config/niri/config.kdl
```

or (for Stow management):
```
~/dotfiles/niri/.config/niri/config.kdl
```

### Quick Changes

#### Change Workspace Names
Edit `~/.config/niri/config.kdl`:
```kdl
workspace "1:emacs" {}
workspace "2:web" {}
// etc...
```

#### Add Custom Keybinding
```kdl
bind Super+Ctrl+T { spawn "emacsclient" "-c" "-e" "(eshell)"; }
```

#### Adjust Window Gaps
```kdl
layout {
    gaps 12  // Change from 6
}
```

#### Change Border Colors
```kdl
layout {
    border {
        active-color "#ff0000"   // Red when focused
        inactive-color "#666666" // Dark gray when unfocused
    }
}
```

## Common Tasks

### Switch to dwl-guile

1. Edit `guix-home.scm`:
   ```scheme
   (define %selected-compositor 'dwl-guile)
   ```

2. Reconfigure:
   ```bash
   guix home reconfigure guix-home.scm
   ```

3. Restart:
   ```bash
   herd restart dwl-guile
   ```

### Check Niri is Running

```bash
# See service status
herd status niri

# View logs
journalctl --user-unit=niri -e

# Check if process is running
pgrep -l niri
```

### Restart Niri

```bash
herd restart niri
```

### View Configuration

```bash
cat ~/.config/niri/config.kdl
```

### Edit Configuration

```bash
# Using your preferred editor
emacsclient -c ~/.config/niri/config.kdl
nano ~/.config/niri/config.kdl
vim ~/.config/niri/config.kdl
```

## Emacs Integration

Niri works seamlessly with Emacs:

- **`Super+E`**: Open Emacs
- **`Super+B`**: Switch buffers
- **`Super+G`**: Git (Magit)
- **`Super+N`**: Org-roam notes
- **`Super+A`**: Org agenda
- **`Super+S`**: Search files
- **`Super+X`**: M-x command

EXWM works the same way as with dwl-guile.

## Troubleshooting

### Niri Won't Start

```bash
# Check if installed
which niri

# Try running directly to see error
niri

# Check logs
journalctl --user-unit=niri -e
tail ~/.local/var/log/niri.log
```

### Keys Not Working

1. Verify keyboard layout:
   ```bash
   setxkbmap -query
   ```

2. Check config syntax:
   ```bash
   niri --check-config ~/.config/niri/config.kdl
   ```

3. Restart Niri:
   ```bash
   herd restart niri
   ```

### Config Changes Not Applied

```bash
# Configuration reloads automatically
# If not, restart:
herd restart niri

# Or run directly:
niri
```

### Monitor Not Detected

```bash
# See connected monitors
wlr-randr

# Add to config.kdl:
output "HDMI-1" {
    position x=1920 y=0
    scale 1.0
}
```

## Performance Tips

### Speed Up Animations

Edit `~/.config/niri/config.kdl`:

```kdl
animations {
    workspace-switch { duration-ms 100; }  # Faster than default 200
    window-open { duration-ms 100; }
}
```

### Disable Animations

```kdl
animations {
    workspace-switch { duration-ms 0; }
    window-open { duration-ms 0; }
}
```

### Reduce Resource Usage

- Lower animation durations
- Reduce gap sizes
- Disable variable refresh rate if not needed

## Customization Examples

### Custom Launcher for Specific App

```kdl
bind Super+I { spawn "firefox"; }
bind Super+C { spawn "discord"; }
bind Super+Z { spawn "zathura"; }
```

### Window-Specific Rules

Float specific applications:
```kdl
window-rule {
    match { app-id "pavucontrol"; }
    floating true
}
```

Open on specific workspace:
```kdl
window-rule {
    match { app-id "spotify"; }
    open-on-workspace "6:media"
}
```

### Custom Startup Commands

```kdl
startup-command "sh" "-c" "dunst &"        # Notification daemon
startup-command "sh" "-c" "mpd &"          # Music player
startup-command "sh" "-c" "emacs --daemon" # Emacs daemon
```

## Advanced Features

### Multi-Monitor Setup

```kdl
output "eDP-1" {
    position x=0 y=0
    scale 1.0
}

output "HDMI-1" {
    position x=1920 y=0
    scale 1.0
}
```

### High DPI Scaling

```kdl
output "eDP-1" {
    scale 2.0  # For high DPI displays
}
```

### Custom Input Settings

```kdl
input {
    keyboard {
        repeat-delay 300
        repeat-rate 50
    }

    touchpad {
        accel-speed 0.5  # Slower
        tap
    }
}
```

## Getting Help

### Documentation
- Full guide: `dotfiles/niri/README.md`
- Setup guide: `NIRI-SETUP.md`
- Implementation: `NIRI-IMPLEMENTATION-SUMMARY.md`

### Online Resources
- **Official**: https://github.com/YaLTeR/niri
- **Wiki**: https://github.com/YaLTeR/niri/wiki
- **KDL**: https://kdl.dev/

### Debugging
```bash
# Enable debug output
RUST_LOG=debug niri

# Check config syntax
niri --check-config ~/.config/niri/config.kdl

# View Wayland info
wayland-info

# Monitor list
wlr-randr
```

## Next Steps

1. **Explore the config**: Read through `~/.config/niri/config.kdl`
2. **Customize**: Edit colors, gaps, keybindings
3. **Learn more**: Read the full `dotfiles/niri/README.md`
4. **Experiment**: Try different settings and see what works
5. **Share**: Submit improvements or report issues

---

**Tip**: Keep the cheat sheet above bookmarked for quick reference!

For more detailed information, see:
- `dotfiles/niri/README.md` - Comprehensive guide
- `NIRI-SETUP.md` - Installation and troubleshooting
- `~/.config/niri/config.kdl` - All configuration options
