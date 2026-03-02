# NixOS In-Place Installation Guide for gunix
## From Guix → NixOS unstable-small with Btrfs + Modular Configuration

**Target System**: gunix (AMD Ryzen, RADV GPU, dual NVMe, LVM)
**Installation Date**: 2026-03-03
**Approach**: In-place with NIXOS_LUSTRATE + Btrfs upgrade + modular home.nix
**Estimated Duration**: 45-60 minutes
**Risk Level**: MEDIUM (Guix available for 30-day rollback)

---

## ⚠️ Pre-Installation Checklist

- [ ] System boots normally from Guix
- [ ] Guix daemon running: `sudo systemctl status guix-daemon`
- [ ] Sufficient free space: `df -h` (at least 5GB free in vg0)
- [ ] Can access SSH if needed
- [ ] Understand this is DESTRUCTIVE (data in / will be moved to /old-root)
- [ ] Have recovery plan if anything fails

---

## 🔵 Phase 1: Pre-Installation Setup (5-10 min)

### Step 1.1: Download nixos-in-place Script

```bash
# Create temporary directory
mkdir -p ~/nix-install
cd ~/nix-install

# Download nixos-in-place (latest version)
curl -L https://github.com/jeaye/nixos-in-place/releases/download/v0.3.0/nixos-in-place \
  -o nixos-in-place
chmod +x nixos-in-place

# Verify it's executable
file ./nixos-in-place
```

**Why this works**: nixos-in-place is a self-contained script that:
- Installs Nix if needed
- Downloads NixOS closure
- Installs bootloader
- Sets up NIXOS_LUSTRATE
- Configures system for first boot

### Step 1.2: Verify LVM Structure

```bash
# Check current LVM layout
sudo lvdisplay | grep "LV Name\|LV Size"
# Expected output:
#   LV Name: root (size: ~200-300GB)
#   LV Name: home (size: ~remaining)
#   LV Name: gnu  (size: ~50-100GB)
#   LV Name: swap (size: ~16-32GB)

# Check available space in volume group
sudo vgs vg0
```

**Expected**: vg0 should show free space for growing / partition.

### Step 1.3: Prepare LVM for NixOS

**Goal**: Shrink /gnu, grow / for NixOS /nix store

```bash
# 1. Check /gnu usage
df -h /gnu

# 2. Shrink /gnu to minimal (50GB if it's larger)
sudo e2fsck -f /dev/mapper/vg0-gnu
sudo resize2fs /dev/mapper/vg0-gnu 20G
sudo lvreduce -L 20G /dev/mapper/vg0-gnu

# 3. Grow / with freed space (example: 100GB freed → add to /)
sudo lvresize -L +100G /dev/mapper/vg0-root
sudo e2fsck -f /dev/mapper/vg0-root
sudo resize2fs /dev/mapper/vg0-root

# 4. Verify new sizes
sudo lvdisplay | grep -A 2 "LV Name"
```

**Checkpoint**: `sudo lvdisplay` should show:
- vg0-root: larger (e.g., 400GB)
- vg0-gnu: smaller (e.g., 20GB)
- vg0-home: unchanged

**If resize fails**:
```bash
# Revert by growing /gnu again
sudo lvresize -L +100G /dev/mapper/vg0-gnu
sudo resize2fs /dev/mapper/vg0-gnu
# Then retry nixos-in-place
```

### Step 1.4: Back Up Critical Files (Optional but Recommended)

```bash
# Backup current configuration to /home (on separate LVM volume)
mkdir -p ~/nix-backup
cp -r ~/.config ~/nix-backup/
cp ~/.zshrc ~/nix-backup/ 2>/dev/null || true
cp ~/.gitconfig ~/nix-backup/ 2>/dev/null || true

# Backup Guix generations list for reference
guix home list-generations > ~/nix-backup/guix-home-generations.txt
guix package -A | head -100 > ~/nix-backup/guix-packages-sample.txt
```

**Why**: If anything goes wrong, you still have your Guix config.

### Step 1.5: Disable Auto-Login (If Enabled)

```bash
# Check greetd config
sudo grep -A 10 "greetd" /etc/nixos/configuration.nix

# If auto-login to Guix container is set, disable it for now:
# This prevents automatic container boot, giving you time to debug
```

---

## 🟠 Phase 2: In-Place Installation (15-20 min)

### Step 2.1: Run nixos-in-place Script

```bash
cd ~/nix-install

# Run with verbose output for debugging
sudo ./nixos-in-place -v

# The script will:
# 1. Install Nix (if not present)
# 2. Download NixOS closure (~1-2GB)
# 3. Create /etc/NIXOS (marker for NIXOS_LUSTRATE)
# 4. Install GRUB/systemd-boot bootloader
# 5. Set up early-boot NixOS root
```

**Output**: You should see progress messages like:
```
Setting up Nix store...
Downloading NixOS 24.11 closure...
Installing bootloader...
Creating NIXOS_LUSTRATE marker at /etc/NIXOS_LUSTRATE
```

**If it fails**:
- Check disk space: `df -h`
- Check network: `ping 8.8.8.8`
- Revert LVM changes if needed

### Step 2.2: Create Minimal NixOS Configuration

Create `/etc/nixos/configuration.nix` that nixos-in-place needs:

```nix
# Minimal config for first boot (copy to /etc/nixos/)
{ config, pkgs, lib, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # Hostname
  networking.hostName = "gunix";
  networking.useDHCP = true;

  # Boot: systemd-boot already installed by nixos-in-place
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Minimal system packages (only essentials)
  environment.systemPackages = with pkgs; [
    git
    vim
    curl
    htop
    lvm2  # LVM tools
  ];

  # Services: SSH for remote access if needed
  services.openssh.enable = true;

  # System version
  system.stateVersion = "24.11";

  # Users
  users.users.gux = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPassword = "!";  # Disable password login initially
  };
}
```

Save this to `/etc/nixos/configuration.nix` before reboot.

---

## 🔴 Phase 3: First Boot into NixOS (5 min)

### Step 3.1: Reboot

```bash
# Reboot (will boot into NIXOS_LUSTRATE if everything worked)
sudo reboot
```

**What happens**:
1. GRUB/systemd-boot shows options
2. NixOS boots from /boot
3. NIXOS_LUSTRATE runs: moves everything to /old-root
4. NixOS boots with fresh / partition
5. Guix is now in /old-root (recoverable)

### Step 3.2: First Boot Login

At login prompt:
```
gunix login: root
# (no password, passwordless sudo)

# Or SSH in from another machine
ssh root@gunix
```

### Step 3.3: Verify System

```bash
# Check OS
cat /etc/os-release

# Check partitions
lsblk

# Check /old-root (Guix backup)
ls /old-root | head -20

# Check networking
ping 8.8.8.8
```

**Expected**:
- `/etc/os-release` shows NixOS 24.11
- `/old-root` contains old root filesystem (Guix)
- Network working
- Can reach this machine via SSH

### Step 3.4: Handle Btrfs Upgrade (If Desired)

**Current**: ext4 filesystem
**Optional upgrade**: Reformat root to Btrfs for compression/snapshots

**⚠️ WARNING**: This is destructive. Only if you're confident.

**To upgrade after boot (Day 2)**:
```bash
# 1. Boot into emergency shell
systemctl rescue

# 2. Unmount /
umount /

# 3. Reformat /dev/mapper/vg0-root as Btrfs
mkfs.btrfs /dev/mapper/vg0-root

# 4. Mount back with Btrfs options
mount -o subvol=root,compress=zstd:3,noatime /dev/mapper/vg0-root /

# 5. Update /etc/nixos/hardware-configuration.nix:
fsType = "btrfs";
options = ["subvol=root" "compress=zstd:3" "noatime"];

# 6. Reboot
reboot
```

**For now**: Keep ext4. Can upgrade to Btrfs anytime post-install.

---

## 🟡 Phase 4: NixOS Configuration Integration (10-20 min)

### Step 4.1: Clone/Copy gunix Flake

```bash
# Copy your flake.nix, home.nix, and modules from previous development
# Option A: From another machine via git
cd /etc/nixos
git clone https://github.com/yourusername/gunix.git
# Or copy files manually

# Option B: Copy from /old-root/home/gux/
cp -r /old-root/home/gux/gunix/* /etc/nixos/

# Verify structure
ls -la /etc/nixos/
# Should show: flake.nix, home.nix, configuration.nix, hardware-configuration.nix, nix/modules/
```

### Step 4.2: Update configuration.nix for Btrfs (if applicable)

Edit `/etc/nixos/configuration.nix`, ensure hardware section includes:

```nix
# Btrfs options (if upgraded)
fileSystems."/" = {
  device = "/dev/mapper/vg0-root";
  fsType = "btrfs";  # Change from "ext4"
  options = [
    "subvol=root"
    "compress=zstd:3"
    "noatime"
    "nodiscard"
  ];
};
```

### Step 4.3: Test Build Configuration

```bash
# Check flake
nix flake show /etc/nixos

# Dry-build system (no changes)
nixos-rebuild build --flake /etc/nixos#gunix --dry-run

# Dry-build home manager
nix flake show /etc/nixos

# Expected: All options/modules validate
```

**If errors**:
- Check syntax: `nix-instantiate --parse /etc/nixos/flake.nix`
- Check home.nix modules are present in nix/modules/
- Validate all imports in home.nix exist

---

## 🟢 Phase 5: Progressive Unit Deployment (15-30 min)

### Your modular home.nix enables incremental testing:

```nix
# home.nix default flags (all enabled except EWM):
home.modules = {
  desktop.enable = true;     # Unit 4: Wayland apps
  emacs.enable = true;       # Unit 5: Editor
  shell.enable = true;       # Unit 6: Zsh, git
  services.enable = true;    # Unit 7: SSH, GPG
  optimization.enable = true; # Hardware tuning
  ewm.enable = false;        # Unit 8: Deferred (post-install)
};
```

### Deployment Sequence:

#### Unit 4: Wayland Desktop
```bash
# Enable in home.nix (already enabled by default)
home.modules.desktop.enable = true;

# Deploy
home-manager switch --flake /etc/nixos#gux

# Verify
which foot
foot &
waybar &
# Should see terminal + status bar
```

#### Unit 5: Emacs
```bash
# Verify Emacs loads
emacs --version
emacs -Q &  # Quick start
# M-x: should show completion
# M-x magit-status: should work if git repo

# Check Emacs packages
emacs -Q --eval '(package-list-packages)'
```

#### Unit 6: Shell
```bash
# Test zsh
zsh --version
alias  # Should see custom aliases
e      # Should launch emacsclient
git st # Should run git status

# Test git config
git config user.name
git config user.email
```

#### Unit 7: Services
```bash
# SSH agent
ssh-add -l  # List SSH keys
systemctl --user status ssh-agent

# GPG agent
systemctl --user status gpg-agent
```

#### Unit 8: EWM (Optional, Post-Install)
```bash
# After all others stable (Day 3+)
# Edit home.nix:
home.modules.ewm.enable = true;

# Build
nix build '.#emacs-ewm' --dry-run

# Deploy
home-manager switch --flake /etc/nixos#gux

# Launch
EWM_SESSION=1 emacs
```

---

## 🔵 Phase 6: Guix Daemon Removal (Day 5+)

Once NixOS stable, safely remove Guix:

```bash
# Stop Guix daemon
sudo systemctl stop guix-daemon.service
sudo systemctl disable guix-daemon.service

# Remove Guix from boot
# (Edit /etc/nixos/configuration.nix, remove guix entries)

# Clean Guix store
sudo rm -rf /gnu /var/guix

# Shrink LVM volume if desired
sudo lvreduce -L 10G /dev/mapper/vg0-gnu

# Verify no Guix references
which guix  # Should not find anything
```

---

## 🟠 Phase 7: Btrfs Migration (Optional, Day 7+)

If you want Btrfs compression/snapshots:

```bash
# Boot to single-user mode
systemctl rescue

# Reformat root
umount /
mkfs.btrfs /dev/mapper/vg0-root

# Mount with Btrfs options
mount -o subvol=root,compress=zstd:3 /dev/mapper/vg0-root /

# Update configuration.nix
# (See Step 4.2 above)

# Rebuild and reboot
nixos-rebuild switch --flake /etc/nixos#gunix
```

---

## ❌ Troubleshooting

### Issue: Can't boot NixOS
**Solution**:
- Reboot from Guix: At GRUB, select Guix entry
- Investigate: Check `/boot` partition has space
- Try again: Run nixos-in-place again, it's idempotent

### Issue: /old-root not accessible
**Solution**:
- Not critical, just lost access to old files
- Reinstall nixos-in-place if you want to recover

### Issue: Wayland desktop doesn't start
**Solution**:
- Verify packages: `which waybar foot`
- Check graphics: `glxinfo | grep -i nvidia` (or similar)
- Drop to VT: Ctrl+Alt+F2, debug

### Issue: Home Manager deploy fails
**Solution**:
- Check syntax: `nix eval /etc/nixos/home.nix`
- Disable problematic unit: Set `home.modules.desktop.enable = false`
- Try one unit at a time

---

## ✅ Success Indicators

After full installation:

- [ ] NixOS boots successfully
- [ ] Waybar + Niri compositor visible
- [ ] Emacs starts and loads plugins
- [ ] Zsh shell works with aliases
- [ ] Git status: `git st` works
- [ ] SSH agent active: `ssh-add -l` shows keys
- [ ] home-manager switch succeeds
- [ ] /old-root accessible with Guix (optional, for reference)

---

## 📊 Rollback Strategy (First 30 Days)

If major issues:

```bash
# Option 1: Revert to Guix for full system
# At GRUB boot menu, select Guix entry
# Run: guix home reconfigure guix-home.scm

# Option 2: Revert individual units
# Edit home.nix, disable problematic module
# Run: home-manager switch

# Option 3: Full emergency recover
# Boot NixOS, access /old-root
# Copy critical files back if needed
```

---

## 📝 Notes for Future Ref

- **Guix storage**: `/old-root` (available for 30 days, then `/gnu` can be removed)
- **NixOS store**: `/nix/store` (managed by NixOS, do not touch)
- **Home config**: `/etc/nixos/home.nix` + `/etc/nixos/nix/modules/`
- **Enable flags**: All in `home.nix`, easy to toggle
- **Unit status**: Each module can be disabled individually
- **Btrfs**: Safe to add later, not required for first boot

---

## 🎯 Quick Command Reference

```bash
# Build entire system (dry-run)
nixos-rebuild build --flake /etc/nixos#gunix --dry-run

# Deploy system
sudo nixos-rebuild switch --flake /etc/nixos#gunix

# Build home manager (dry-run)
nix flake show /etc/nixos

# Deploy home manager
home-manager switch --flake /etc/nixos#gux

# Check module status
home-manager switch --dry-run

# Rollback to previous generation
home-manager generations  # List
home-manager switch-generation N  # Revert to N

# Diagnose issues
nixos-option boot.kernelParams
journalctl -xe  # System logs
home-manager --verbose switch  # Verbose deploy
```

---

**Generated**: 2026-03-03
**Status**: Ready for execution
**Estimated time**: 45-60 minutes
**Risk level**: MEDIUM (Guix available for rollback)
