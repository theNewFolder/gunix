#!/usr/bin/env bash
set -e

echo "=== Configuring Guix User Environment ==="

# Source Guix profile
source ~/nixos-guix-setup/guix-profile.sh

# Add to bashrc
echo "" >> ~/.bashrc
echo "# Guix configuration" >> ~/.bashrc
echo "source ~/nixos-guix-setup/guix-profile.sh" >> ~/.bashrc

# Authorize substitute server
echo "Authorizing substitute server..."
guix archive --authorize < /var/guix/profiles/per-user/root/current-guix/share/guix/ci.guix.gnu.org.pub

echo "Running guix pull..."
guix pull

echo "Guix user environment configured!"
echo "You can now use: guix search, guix install, etc."
