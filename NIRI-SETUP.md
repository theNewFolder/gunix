# Niri Wayland Compositor Setup Guide

This guide explains how to add and use Niri as an alternative to dwl-guile in your nixos-guix-setup.

## Overview

Niri support has been added as an alternative Wayland compositor alongside dwl-guile. Both compositors:
- Use the same SUPER key modifier
- Support Emacs integration and EXWM
- Provide keyboard-driven tiling window management
- Work with the same dotfiles and configuration structure

## What's New

### 1. Niri Service Module
- **File**: `dwl-guile/dwl-guile/niri-service.scm`
- Provides Guix Home integration for Niri
- Handles environment variables, profiles, and configuration

### 2. Niri Configuration File
- **File**: `dotfiles/niri/.config/niri/config.kdl`
- Complete KDL configuration with Emacs-style keybindings
- 9 workspaces matching dwl-guile setup
- All common window management operations

### 3. Niri Documentation
- **File**: `dotfiles/niri/README.md`
- Comprehensive Niri documentation
- Configuration guide and troubleshooting
- Comparison with dwl-guile

## Installation & Setup

### Step 1: Verify Niri Availability

Check if Niri is available in your Guix setup:

```bash
guix search niri
# or
guix package -s niri
```

If not available, you have two options:
1. Build a custom Niri package (advanced)
2. Install from source (https://github.com/YaLTeR/niri)

### Step 2: Enable Niri in Guix Home

Edit `guix-home.scm`:

```scheme
;; Around line 320 (Compositor Selection section)
(define %selected-compositor 'niri)  ; Change from 'dwl-guile
```

### Step 3: Apply Configuration

```bash
cd /home/nixos/nixos-guix-setup
guix home reconfigure guix-home.scm
```

This will:
- Install Niri package
- Set up Niri service
- Copy configuration files
- Configure environment variables

### Step 4: Start Niri

```bash
# Via Shepherd (if auto-start is enabled)
herd start niri

# Or run directly
niri
```

## Switching Between Compositors

### From dwl-guile to Niri

1. Edit `guix-home.scm`:
   ```scheme
   (define %selected-compositor 'niri)
   ```

2. Reconfigure:
   ```bash
   guix home reconfigure guix-home.scm
   ```

3. Start Niri:
   ```bash
   herd restart niri
   # or exit dwl-guile and run: niri
   ```

### From Niri to dwl-guile

1. Edit `guix-home.scm`:
   ```scheme
   (define %selected-compositor 'dwl-guile)
   ```

2. Reconfigure:
   ```bash
   guix home reconfigure guix-home.scm
   ```

3. Start dwl-guile:
   ```bash
   herd restart dwl-guile
   ```

## Keybindings Reference

Both compositors use the same keybindings for consistency:

### Emacs
- `Super+E`: Open Emacs
- `Super+Shift+E`: New Emacs instance
- `Super+Ctrl+E`: Restart Emacs daemon

### Applications
- `Super+Return`: Terminal (foot)
- `Super+Shift+Return`: Emacs terminal (vterm)
- `Super+D`: App launcher (wofi)
- `Super+P`: Command runner (wofi)
- `Super+X`: Emacs M-x equivalent

### Window Management
- `Super+Q`: Close window
- `Super+O`: Focus next column/window
- `Super+Shift+O`: Focus previous column/window
- `Super+J/K/H/L`: Navigate (Vim-style)

### Workspaces
- `Super+1-9`: Switch to workspace 1-9
- `Super+Shift+1-9`: Move window to workspace
- `Super+0`: View all (dwl-guile) / previous workspace (Niri)

### Emacs Functions
- `Super+B`: Switch buffer
- `Super+G`: Magit status
- `Super+N`: Org-roam find node
- `Super+A`: Org agenda
- `Super+S`: Search with ripgrep

### Layout
- `Super+F`: Fullscreen
- `Super+Shift+F`: Toggle floating (Niri only)
- `Super+M`: Monocle/Maximize
- `Super+Tab`: Previous workspace

### Session
- `Super+Shift+Q`: Quit compositor
- `Super+Shift+R`: Reload configuration
- `Super+Ctrl+L`: Lock screen (requires swaylock)

## Configuration Files

### Niri Configuration
- **Location**: `~/.config/niri/config.kdl` or `dotfiles/niri/.config/niri/config.kdl`
- **Format**: KDL (Niri's configuration language)
- **Key Sections**:
  - `cursor`: Cursor theme and size
  - `input`: Keyboard and touchpad settings
  - `output`: Monitor configuration
  - `layout`: Window gaps, borders, padding
  - `workspace`: Define workspaces
  - `bind`: Keybindings
  - `window-rule`: Application-specific rules
  - `startup-command`: Programs to run on startup

### dwl-guile Configuration
- **Location**: In `guix-home.scm` (lines 328-606)
- **Format**: Guile Scheme
- **Key Variables**:
  - `%dwl-guile-config`: Comprehensive configuration
  - `border-px`: Border width
  - `gaps-inner/outer`: Window gaps
  - `set-keys`: Keybinding definitions
  - `set-rules`: Window rules
  - `add-hook!`: Startup hooks

## Niri vs dwl-guile

### Niri Advantages
- **Scrollable tiling**: Smooth workspace navigation
- **Animations**: Visually polished window transitions
- **Simpler config**: KDL format is more intuitive than Scheme
- **Modern design**: Based on latest Wayland best practices
- **Lower overhead**: Minimal scripting capability = less CPU

### dwl-guile Advantages
- **Customization**: Full Guile/Scheme scripting
- **Flexibility**: Modify almost any behavior
- **Familiarity**: For dwm users
- **Maturity**: More stable, established codebase
- **Performance**: Lightweight with minimal features

## Troubleshooting

### Niri won't start

```bash
# Check if installed
which niri

# Check logs
journalctl --user-unit=niri -e
tail -f ~/.local/var/log/niri.log

# Try running directly
niri
```

### Config errors in Niri

```bash
# Check config syntax
niri --check-config ~/.config/niri/config.kdl

# Validate KDL format
kdl --validate ~/.config/niri/config.kdl
```

### Keybindings not working

1. Verify keyboard layout: `setxkbmap -query`
2. Check config has correct keybind syntax
3. Restart Niri: `herd restart niri`
4. Check for conflicts with other services

### Monitor detection issues

```bash
# See available monitors
wlr-randr

# Check Wayland info
wayland-info | grep -A 20 "wl_output"
```

## Emacs Integration

### With Niri

```scheme
;; In guix-home.scm, set:
(define %selected-compositor 'niri)

;; This enables:
;; - EXWM support under XWayland
;; - Same Emacs keybindings
;; - Workspace integration
;; - All Emacs-specific settings
```

### EXWM Configuration

Both compositors use the same EXWM configuration in `guix-home.scm` (lines 1384-1532):
- Workspace switching
- Buffer naming
- XWayland integration
- Multi-monitor support

No changes needed when switching compositors.

## Performance

### Niri Performance Tips

1. **Reduce animation duration**:
   ```kdl
   animations {
       workspace-switch { duration-ms 100; }  // Faster
   }
   ```

2. **Disable VRR if unnecessary**:
   ```kdl
   output "eDP-1" {
       // variable-refresh-rate   // Remove this line
   }
   ```

3. **Monitor system resources**:
   ```bash
   htop
   ```

### dwl-guile Performance Tips

1. **Reduce gap sizes**:
   ```scheme
   (setq gaps-inner 3)
   (setq gaps-outer 3)
   ```

2. **Disable unused hooks**:
   ```scheme
   ;; Remove spawning of unnecessary services
   ```

## Reporting Issues

If you encounter problems:

1. **Check logs**:
   ```bash
   journalctl --user -e
   tail ~/.local/var/log/niri.log
   ```

2. **Verify configuration**:
   - Check KDL syntax for Niri
   - Check Scheme syntax for dwl-guile

3. **Report upstream**:
   - Niri: https://github.com/YaLTeR/niri/issues
   - dwl-guile: https://github.com/engstrand-config/dwl-guile/issues

4. **Report to project**:
   - This setup: Open an issue in the nixos-guix-setup repository

## Resources

### Niri Documentation
- GitHub: https://github.com/YaLTeR/niri
- Wiki: https://github.com/YaLTeR/niri/wiki
- KDL Format: https://kdl.dev/
- Wayland Info: https://wayland.freedesktop.org/

### dwl-guile Documentation
- GitHub: https://github.com/engstrand-config/dwl-guile
- dwl (original): https://github.com/djpohly/dwl

### Related Projects
- Guix Home: https://guix.gnu.org/manual/guix.html#Home-Configuration
- Emacs EXWM: https://github.com/ch11ng/exwm
- Waybar (status bar): https://github.com/Alexays/Waybar

## Next Steps

1. **Explore Niri config**: Edit `dotfiles/niri/.config/niri/config.kdl`
2. **Customize keybindings**: Add your own bindings
3. **Add window rules**: Create rules for specific applications
4. **Tweak appearance**: Adjust borders, gaps, colors
5. **Optimize performance**: Fine-tune animation durations

## FAQ

**Q: Can I run both compositors?**
A: Not simultaneously, but you can install both and switch via `guix home reconfigure`.

**Q: Do I need to reconfigure everything?**
A: No, Emacs and most settings are shared between compositors.

**Q: Will my keybindings still work?**
A: Yes, both compositors use the same keybinding scheme (SUPER modifier).

**Q: How do I switch back to dwl-guile?**
A: Change `%selected-compositor` back to `'dwl-guile` and reconfigure.

**Q: Is Niri stable?**
A: Niri is actively maintained and fairly stable, but still under development.

**Q: What about XWayland for X11 apps?**
A: Both compositors support XWayland. EXWM works under both.

## Contributing

To improve Niri support:
1. Edit `dotfiles/niri/.config/niri/config.kdl`
2. Update `dwl-guile/dwl-guile/niri-service.scm` if needed
3. Submit improvements or report issues

---

For more information, see:
- `dotfiles/niri/README.md` - Niri configuration guide
- `guix-home.scm` - Compositor selection and Guix Home configuration
