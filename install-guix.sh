#!/usr/bin/env bash
set -e

echo "=== Guix Installation Script for NixOS ==="
echo

# Download Guix binary
cd /tmp
echo "Downloading Guix binary tarball..."
wget https://ftp.gnu.org/gnu/guix/guix-binary-1.5.0.x86_64-linux.tar.xz
wget https://ftp.gnu.org/gnu/guix/guix-binary-1.5.0.x86_64-linux.tar.xz.sig

echo "Verifying signature..."
gpg --keyserver keys.openpgp.org --recv-keys 3CE464558A84FDC69DB40CFB090B11993D9AEBB5
gpg --verify guix-binary-1.5.0.x86_64-linux.tar.xz.sig guix-binary-1.5.0.x86_64-linux.tar.xz

echo "Extracting Guix..."
cd /
tar --warning=no-timestamp -xf /tmp/guix-binary-1.5.0.x86_64-linux.tar.xz

echo "Creating /gnu/store with proper permissions..."
mkdir -p /gnu/store
chown root:guixbuild /gnu/store
chmod 1775 /gnu/store

echo "Creating /var/guix..."
mkdir -p /var/guix/profiles/per-user/root

echo "Linking root profile..."
mkdir -p /root/.config/guix
ln -sf /var/guix/profiles/per-user/root/current-guix /root/.config/guix/current

echo "Cleaning up temporary files..."
rm -f /tmp/guix-binary-1.5.0.x86_64-linux.tar.xz
rm -f /tmp/guix-binary-1.5.0.x86_64-linux.tar.xz.sig

echo "Guix binary installation complete!"
echo "Next: Copy configuration.nix to /etc/nixos/ and run 'nixos-rebuild switch'"
