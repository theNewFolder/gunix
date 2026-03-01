# GNU Stow Dotfiles

This directory contains dotfiles configured for use with GNU Stow and a Guix-based Wayland setup (dwl-guile + Emacs).

## Directory Structure

Each subdirectory is a "package" in Stow terminology that can be independently managed:

```
dotfiles/
├── zsh/              # Zsh shell configuration
│   └── .zshrc
├── git/              # Git configuration
│   └── .gitconfig
├── foot/             # Foot terminal emulator
│   └── .config/foot/foot.ini
├── waybar/           # Waybar status bar
│   └── .config/waybar/
│       ├── config
│       └── style.css
└── niri/             # (Optional) Niri window manager
    └── .config/niri/config.kdl
```

## Installation with GNU Stow

### Prerequisites

```bash
guix install stow
```

### Install All Packages

From the dotfiles directory:

```bash
cd ~/nixos-guix-setup/dotfiles
stow */  # Install all packages
```

### Install Specific Package

```bash
cd ~/nixos-guix-setup/dotfiles
stow zsh     # Install zsh config only
stow git     # Install git config only
stow waybar  # Install waybar config only
```

### Check What Would Be Installed

```bash
stow -n zsh  # Dry-run (shows what would happen)
```

### Remove/Uninstall Packages

```bash
stow -D zsh   # Delete stow links for zsh
stow -D */    # Delete all stow links
```

### Restow (Update Links)

```bash
stow -R zsh   # Restow package after changes
```

## Configuration Notes

### Zsh Configuration
- Integrates with Guix profiles automatically
- Sets up Emacs as default editor
- Includes Guix-specific aliases (gs, gi, gshell, etc.)
- Sources ~/.zshrc.local for local overrides

### Git Configuration
- User: `gux` with email `gux@gunix`
- Editor: Emacs (emacsclient)
- Signing key: Configure as needed for GPG signing
- Useful git aliases for workflow efficiency

### Foot Terminal
- Uses Nord/Solarized Dark color scheme
- Configured for Wayland with dwl-guile integration
- Scrollback history set to 1000 lines
- Font size: 12pt Monospace

### Waybar Configuration
- Integrated workspaces display for dwl-guile
- Clock, backlight, audio, network, and battery modules
- Nord color scheme matching foot terminal
- Click actions integrated with Emacs (emacsclient)

## Customization

### Local Overrides

Each package can be extended with local configuration:

- **Zsh**: Create `~/.zshrc.local` for machine-specific settings
- **Git**: Use `~/.gitconfig.local` (add `[include] path = ~/.gitconfig.local` to `.gitconfig`)
- **Foot**: Create `~/.config/foot/foot.ini.local` if supported
- **Waybar**: Modify `~/.config/waybar/config` after stowing

### Environment-Specific Settings

For environment-specific customization:

1. Keep dotfiles in git for version control
2. Use local config files for machine-specific settings
3. Use `stow -D` to remove and `stow` to reapply changes

## Integration with Guix

This dotfiles structure works well with:

- Guix home environment definitions
- Guix profiles for reproducible development environments
- dwl-guile window manager
- Wayland-based workflow

## Tips

- Always use `stow -n` (dry-run) first to preview changes
- Keep your dotfiles in a git repository for version control
- Use `git status` to track changes to your configuration
- Test changes with `stow -R package` to update links
- For system-wide configuration, consider Guix Home

## Related Documentation

- GNU Stow: https://www.gnu.org/software/stow/
- Guix: https://guix.gnu.org/
- Foot Terminal: https://codeberg.org/dnkl/foot
- Waybar: https://github.com/Alexays/Waybar
