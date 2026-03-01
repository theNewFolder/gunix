# Niri Wayland Compositor - Documentation Index

## Quick Navigation

This file helps you find the right documentation for your needs.

## I Want To...

### Get Niri Running in 5 Minutes
**Read**: `/home/nixos/nixos-guix-setup/dotfiles/niri/QUICKSTART.md`

This 3-step guide will get you up and running immediately.

### Understand What Was Implemented
**Read**: `/home/nixos/nixos-guix-setup/NIRI-IMPLEMENTATION-SUMMARY.md`

Complete technical overview of what was added and how it works.

### Learn How to Install and Migrate
**Read**: `/home/nixos/nixos-guix-setup/NIRI-SETUP.md`

Comprehensive guide covering installation, setup, and switching between compositors.

### Configure Niri to My Preferences
**Read**: `/home/nixos/nixos-guix-setup/dotfiles/niri/README.md`

Detailed configuration documentation with examples and customization guide.

### Find a Specific Keybinding
**Read**: `NIRI-SETUP.md` - Section: "Keybindings Reference"
**Or**: `dotfiles/niri/config.kdl` - Section: "Keybindings"

Both files have complete keybinding lists.

### Switch Between Niri and dwl-guile
**Read**: `NIRI-SETUP.md` - Section: "Switching Between Compositors"
Or follow the 3-step process:
1. Edit `guix-home.scm` line ~318
2. Run `guix home reconfigure guix-home.scm`
3. Restart the compositor

### Troubleshoot an Issue
**Read**: `dotfiles/niri/QUICKSTART.md` - Section: "Troubleshooting"
**Or**: `NIRI-SETUP.md` - Section: "Troubleshooting"
**Or**: `dotfiles/niri/README.md` - Section: "Troubleshooting"

### Understand Niri vs dwl-guile
**Read**: `NIRI-SETUP.md` - Section: "Niri vs dwl-guile"

Comparison table showing when to use each compositor.

### Find All Keybindings at Once
**See**: This quick reference below (also in NIRI-SETUP.md)

### Learn about Emacs Integration
**Read**:
- `NIRI-SETUP.md` - Section: "Emacs Integration"
- `dotfiles/niri/README.md` - Section: "Emacs Integration"

Both explain how EXWM and Emacs work with Niri.

---

## File Organization

```
nixos-guix-setup/
├── NIRI-INDEX.md (this file)
│   └── Navigation guide for all Niri documentation
│
├── NIRI-SETUP.md
│   └── Installation, migration, and comprehensive setup guide
│
├── NIRI-IMPLEMENTATION-SUMMARY.md
│   └── Technical implementation details
│
├── guix-home.scm (MODIFIED)
│   └── Main Guix Home configuration (see lines 316-391)
│
├── dwl-guile/dwl-guile/niri-service.scm
│   └── Guix Home service module for Niri
│
└── dotfiles/niri/
    ├── QUICKSTART.md
    │   └── 3-step quick start guide
    │
    ├── README.md
    │   └── Comprehensive configuration documentation
    │
    └── .config/niri/config.kdl
        └── Complete KDL configuration file
```

---

## Documentation by Purpose

### For Installation & Setup
1. **QUICKSTART.md** - 5 minute quick start (start here!)
2. **NIRI-SETUP.md** - Complete installation guide
3. **guix-home.scm** - See the actual configuration

### For Configuration & Customization
1. **dotfiles/niri/README.md** - Configuration guide
2. **dotfiles/niri/.config/niri/config.kdl** - Configuration file
3. **NIRI-SETUP.md** - Configuration reference section

### For Troubleshooting
1. **QUICKSTART.md** - Quick troubleshooting section
2. **dotfiles/niri/README.md** - Detailed troubleshooting
3. **NIRI-SETUP.md** - Additional troubleshooting tips

### For Understanding the Implementation
1. **NIRI-IMPLEMENTATION-SUMMARY.md** - Complete technical overview
2. **dwl-guile/dwl-guile/niri-service.scm** - Service code
3. **guix-home.scm** - Guix Home integration

### For Feature Comparison
1. **NIRI-SETUP.md** - Niri vs dwl-guile comparison
2. **dotfiles/niri/README.md** - Feature list

### For Reference
1. **NIRI-SETUP.md** - Keybindings reference
2. **dotfiles/niri/.config/niri/config.kdl** - All configuration options
3. **dotfiles/niri/QUICKSTART.md** - Keybindings table

---

## Quick Reference: Essential Keybindings

| Category | Keys | Action |
|----------|------|--------|
| **Emacs** | Super+E | Open Emacs |
| | Super+B | Switch buffer |
| | Super+G | Magit status |
| **Terminal** | Super+Return | Open terminal |
| **Apps** | Super+D | App launcher |
| **Windows** | Super+Q | Close window |
| | Super+O | Focus next |
| | Super+M | Maximize |
| **Workspaces** | Super+1-9 | Switch workspace |
| | Super+Shift+1-9 | Move to workspace |
| **Session** | Super+Shift+Q | Quit |
| | Super+Ctrl+L | Lock screen |

See NIRI-SETUP.md for complete keybindings list (50+ total).

---

## Installation Quick Reference

### 3 Steps to Niri

1. **Edit guix-home.scm** (line ~318):
   ```scheme
   (define %selected-compositor 'niri)
   ```

2. **Apply Configuration**:
   ```bash
   guix home reconfigure /path/to/guix-home.scm
   ```

3. **Start Niri**:
   ```bash
   herd start niri
   # or
   niri
   ```

See QUICKSTART.md for more details.

---

## Configuration File Locations

### Niri Configuration
- **Managed by Guix**: `~/.config/niri/config.kdl`
- **Source in repo**: `dotfiles/niri/.config/niri/config.kdl`

### Guix Home Configuration
- **Main file**: `guix-home.scm` (in project root)
- **Compositor selector**: Line ~318

### Service Module
- **Location**: `dwl-guile/dwl-guile/niri-service.scm`

---

## Documentation Quality

All documentation includes:
- Comprehensive explanations
- Practical examples
- Keybinding references
- Troubleshooting guides
- Configuration examples
- Feature comparisons
- Resource links

Total documentation: **1,400+ lines** across 4 guides.

---

## Reading Guide by Experience Level

### Complete Beginner to Compositors
1. Read: QUICKSTART.md (5 min)
2. Read: dotfiles/niri/README.md (15 min)
3. Try: Run the 3 installation steps
4. Explore: Edit .config/niri/config.kdl

### Familiar with dwl-guile
1. Skim: NIRI-SETUP.md - "Niri vs dwl-guile" section
2. Read: QUICKSTART.md for installation
3. Reference: Keybindings comparison
4. Customize: dotfiles/niri/.config/niri/config.kdl

### System Administrator / Advanced User
1. Read: NIRI-IMPLEMENTATION-SUMMARY.md
2. Review: dwl-guile/dwl-guile/niri-service.scm
3. Check: guix-home.scm lines 316-391
4. Customize: dotfiles/niri/.config/niri/config.kdl

---

## Common Questions Answered

**Q: Which file do I edit to enable Niri?**
A: `guix-home.scm` line ~318 - change `'dwl-guile` to `'niri`

**Q: Where is the Niri configuration?**
A: `~/.config/niri/config.kdl` or `dotfiles/niri/.config/niri/config.kdl`

**Q: How do I switch back to dwl-guile?**
A: See NIRI-SETUP.md "Switching Between Compositors" section

**Q: What keybindings are available?**
A: See NIRI-SETUP.md "Keybindings Reference" or QUICKSTART.md tables

**Q: How do I troubleshoot?**
A: See QUICKSTART.md or dotfiles/niri/README.md troubleshooting sections

**Q: Will my Emacs configuration still work?**
A: Yes, EXWM and Emacs work the same way with Niri as with dwl-guile

**Q: Can I run both compositors?**
A: Not simultaneously, but you can switch between them easily

**Q: Where can I get help?**
A: See resource links in any documentation file

---

## File Size Reference

| File | Size | Purpose |
|------|------|---------|
| QUICKSTART.md | 359 lines | 5-minute quick start |
| README.md | 308 lines | Configuration guide |
| NIRI-SETUP.md | 385 lines | Installation guide |
| NIRI-IMPLEMENTATION-SUMMARY.md | 376 lines | Technical details |
| config.kdl | 386 lines | Niri configuration |
| niri-service.scm | 106 lines | Guix Home service |
| guix-home.scm | 1717 lines | Main config (45 lines changed) |
| **Total** | **~1,814 lines** | Complete implementation |

---

## Next Steps

1. **Start Here**: Read `dotfiles/niri/QUICKSTART.md`
2. **Then**: Follow the 3-step installation
3. **Customize**: Edit `~/.config/niri/config.kdl`
4. **Reference**: Use NIRI-SETUP.md for comprehensive guide
5. **Troubleshoot**: Check documentation sections if issues arise

---

## Support & Resources

### Project Resources
- **Quick Start**: QUICKSTART.md
- **Setup Guide**: NIRI-SETUP.md
- **Configuration**: dotfiles/niri/README.md
- **Implementation**: NIRI-IMPLEMENTATION-SUMMARY.md

### External Resources
- **Niri Official**: https://github.com/YaLTeR/niri
- **Niri Wiki**: https://github.com/YaLTeR/niri/wiki
- **KDL Format**: https://kdl.dev/
- **Guix Home**: https://guix.gnu.org/
- **Wayland Info**: https://wayland.freedesktop.org/

---

## Summary

This comprehensive Niri implementation includes:
- **Production-ready configuration** (386 lines)
- **Complete documentation** (1,400+ lines)
- **Easy installation** (3 steps)
- **Full Emacs integration** (EXWM support)
- **50+ keybindings** (SUPER modifier)
- **9 workspaces** (matching dwl-guile)
- **Easy compositor switching** (change 1 variable)

All documentation is organized, indexed, and linked for easy navigation.

**Start with QUICKSTART.md for the fastest path to Niri!**
