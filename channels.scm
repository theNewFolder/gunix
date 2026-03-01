;; Guix Channels Configuration for NixOS+Guix System
;; System Crafters Recommended Channel Setup
;; =============================================================================
;;
;; This file defines the software channels that Guix will use to fetch packages.
;; Curated following System Crafters community recommendations.
;;
;; Installation locations:
;;   User: ~/.config/guix/channels.scm
;;   System: /etc/guix/channels.scm (if using Guix System)
;;
;; Apply with: guix pull
;; Or specify directly: guix pull -C /path/to/channels.scm
;;
;; =============================================================================
;; SUBSTITUTE SERVERS (Pre-built Packages)
;; =============================================================================
;;
;; Using substitute servers saves significant compilation time. You can use:
;;
;; 1. Official Guix Substitute Server (enabled by default):
;;    https://ci.guix.gnu.org
;;
;; 2. Nonguix Substitute Server (for nonfree packages):
;;    https://substitutes.nonguix.org
;;
;; To authorize the nonguix substitute server, run:
;;
;;   wget -qO- https://substitutes.nonguix.org/signing-key.pub | \
;;     sudo guix archive --authorize
;;
;; Then use substitutes by adding to guix commands:
;;   --substitute-urls='https://substitutes.nonguix.org https://ci.guix.gnu.org'
;;
;; Or set globally in /etc/guix/acl or via the guix-daemon configuration.
;;
;; For NixOS, add this to your configuration.nix:
;;   services.guix.substituters = [
;;     "https://substitutes.nonguix.org"
;;     "https://ci.guix.gnu.org"
;;   ];
;;
;; =============================================================================

(list
 ;; ==========================================================================
 ;; Official Guix Channel (Default)
 ;; ==========================================================================
 ;; The official GNU Guix channel containing free software packages.
 ;; This is included by default, but we specify it explicitly here for clarity
 ;; and to enable pinning for reproducibility.
 ;;
 ;; Repository: https://git.savannah.gnu.org/cgit/guix.git
 ;; Package count: 20,000+ packages
 (channel
  (name 'guix)
  (url "https://git.savannah.gnu.org/git/guix.git")
  ;; For reproducibility, you can pin to a specific commit:
  ;; (commit "abc123...")
  ;; Get current commit with: guix describe -f channels
  (introduction
   (make-channel-introduction
    "9edb3f66fd807b096b48283debdcddccfea34bad"
    (openpgp-fingerprint
     "BBB0 2DDF 2CEA F6A8 0D1D  E643 A2A0 6DF2 A33A 54FA"))))

 ;; ==========================================================================
 ;; Nonguix Channel (Nonfree Packages) - SYSTEM CRAFTERS RECOMMENDED
 ;; ==========================================================================
 ;; Provides nonfree software packages not included in official Guix.
 ;; This channel is essential for hardware support on most modern systems.
 ;;
 ;; Repository: https://gitlab.com/nonguix/nonguix
 ;;
 ;; Key packages from nonguix:
 ;;   - linux (mainline kernel with all firmware blobs)
 ;;   - linux-firmware (complete firmware collection)
 ;;   - nvidia-driver (proprietary NVIDIA driver)
 ;;   - steam, steam-nvidia (gaming platform)
 ;;   - signal-desktop (encrypted messaging)
 ;;   - firefox (with DRM support)
 ;;   - chromium (with proprietary codecs)
 ;;   - vscode (Microsoft Visual Studio Code)
 ;;
 ;; IMPORTANT SUBSTITUTE SERVER SETUP:
 ;; ----------------------------------
 ;; To avoid compiling the Linux kernel and other large packages, authorize
 ;; the nonguix substitute server:
 ;;
 ;; Step 1: Download and authorize the signing key
 ;;   wget -qO- https://substitutes.nonguix.org/signing-key.pub | \
 ;;     sudo guix archive --authorize
 ;;
 ;; Step 2: Use substitutes in your commands
 ;;   guix pull --substitute-urls='https://substitutes.nonguix.org https://ci.guix.gnu.org'
 ;;   guix system reconfigure --substitute-urls='https://substitutes.nonguix.org https://ci.guix.gnu.org' system.scm
 ;;
 ;; Step 3: (Optional) Make permanent by editing /etc/guix/acl or guix-daemon
 ;;
 (channel
  (name 'nonguix)
  (url "https://gitlab.com/nonguix/nonguix")
  (introduction
   (make-channel-introduction
    "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
    (openpgp-fingerprint
     "2A39 3FFF 68F4 EF7A 3D29  12AF 6F51 20A0 22FB B2D5"))))

 ;; ==========================================================================
 ;; RDE Channel (Reproducible Development Environments) - SYSTEM CRAFTERS STYLE
 ;; ==========================================================================
 ;; Created by Andrew Tropin (abcdw), a System Crafters community member.
 ;; Provides a framework for building reproducible Guix configurations
 ;; with a strong focus on Emacs integration.
 ;;
 ;; Repository: https://git.sr.ht/~abcdw/rde
 ;; Documentation: https://trop.in/rde
 ;;
 ;; Key features:
 ;;   - Declarative Emacs configuration (like home-manager for NixOS)
 ;;   - Guix Home services for various applications
 ;;   - Sway/Wayland desktop environment configuration
 ;;   - Email configuration (mbsync, msmtp, notmuch)
 ;;   - Development environment templates
 ;;
 ;; RDE provides 'features' - composable configuration blocks:
 ;;   - (feature-emacs) - Base Emacs configuration
 ;;   - (feature-emacs-appearance) - Theme and fonts
 ;;   - (feature-emacs-completion) - Vertico/Corfu setup
 ;;   - (feature-emacs-git) - Magit configuration
 ;;   - (feature-sway) - Sway window manager
 ;;   - (feature-foot) - Foot terminal configuration
 ;;
 ;; UNCOMMENT TO ENABLE:
 ;;
 ;; (channel
 ;;  (name 'rde)
 ;;  (url "https://git.sr.ht/~abcdw/rde")
 ;;  (branch "master")
 ;;  (introduction
 ;;   (make-channel-introduction
 ;;    "257cebd587b66e4d865b3537a9a88cccd7107c95"
 ;;    (openpgp-fingerprint
 ;;     "2841 9AC6 5038 7440 C7E9  2FFA 2208 D209 58C1 DEB0"))))

 ;; ==========================================================================
 ;; Guix Science Channel
 ;; ==========================================================================
 ;; Additional scientific and mathematical software not in main Guix.
 ;; Includes machine learning tools, scientific computing packages, etc.
 ;;
 ;; Repository: https://github.com/guix-science/guix-science
 ;;
 ;; Key packages:
 ;;   - Python ML libraries with GPU support
 ;;   - Scientific computing tools
 ;;   - Bioinformatics packages
 ;;   - Research software
 ;;
 ;; UNCOMMENT TO ENABLE:
 ;;
 ;; (channel
 ;;  (name 'guix-science)
 ;;  (url "https://github.com/guix-science/guix-science.git")
 ;;  (introduction
 ;;   (make-channel-introduction
 ;;    "b1fe5aaff3ab48e798a4cce02f0212bc91f423dc"
 ;;    (openpgp-fingerprint
 ;;     "CA4F 8CF4 37D7 478F DA05  5FD4 4213 7701 1A37 58EC"))))

 ;; ==========================================================================
 ;; Guix Science Nonfree Channel
 ;; ==========================================================================
 ;; Nonfree scientific packages (CUDA, cuDNN, proprietary ML frameworks).
 ;; Requires guix-science channel.
 ;;
 ;; Repository: https://github.com/guix-science/guix-science-nonfree
 ;;
 ;; Key packages:
 ;;   - CUDA toolkit
 ;;   - cuDNN (NVIDIA Deep Neural Network library)
 ;;   - TensorRT
 ;;   - Proprietary ML frameworks
 ;;
 ;; UNCOMMENT TO ENABLE (also enable guix-science):
 ;;
 ;; (channel
 ;;  (name 'guix-science-nonfree)
 ;;  (url "https://github.com/guix-science/guix-science-nonfree.git")
 ;;  (introduction
 ;;   (make-channel-introduction
 ;;    "58661b110325fd5d9b40e6f0177c64c84e75a26e"
 ;;    (openpgp-fingerprint
 ;;     "CA4F 8CF4 37D7 478F DA05  5FD4 4213 7701 1A37 58EC"))))

 ;; ==========================================================================
 ;; Guix Gaming Channels
 ;; ==========================================================================
 ;; Gaming-related packages and tools.
 ;; Includes Wine staging, game launchers, gaming utilities, emulators.
 ;;
 ;; Repository: https://gitlab.com/guix-gaming-channels/games
 ;;
 ;; Key packages:
 ;;   - wine-staging (patched Wine with more game compatibility)
 ;;   - dxvk (DirectX to Vulkan translation)
 ;;   - vkd3d (Direct3D 12 to Vulkan)
 ;;   - Lutris
 ;;   - Various game emulators
 ;;
 ;; UNCOMMENT TO ENABLE:
 ;;
 ;; (channel
 ;;  (name 'guix-gaming-games)
 ;;  (url "https://gitlab.com/guix-gaming-channels/games.git")
 ;;  (branch "master"))

 ;; ==========================================================================
 ;; Flat Channel (Flatpak Integration)
 ;; ==========================================================================
 ;; Provides Flatpak integration and related tools for Guix.
 ;; Allows running Flatpak applications alongside Guix packages.
 ;;
 ;; Repository: https://github.com/flatwhatson/guix-channel
 ;;
 ;; Note: Flatpak provides an alternative way to run sandboxed desktop
 ;; applications when packages aren't available in Guix channels.
 ;;
 ;; UNCOMMENT TO ENABLE:
 ;;
 ;; (channel
 ;;  (name 'flat)
 ;;  (url "https://github.com/flatwhatson/guix-channel.git")
 ;;  (branch "master"))

 ;; ==========================================================================
 ;; Guix-HPC Channel (High Performance Computing)
 ;; ==========================================================================
 ;; Packages for HPC environments and supercomputing.
 ;;
 ;; Repository: https://gitlab.inria.fr/guix-hpc/guix-hpc
 ;;
 ;; Key packages:
 ;;   - MPI implementations
 ;;   - HPC-specific libraries
 ;;   - Cluster management tools
 ;;
 ;; UNCOMMENT TO ENABLE:
 ;;
 ;; (channel
 ;;  (name 'guix-hpc)
 ;;  (url "https://gitlab.inria.fr/guix-hpc/guix-hpc.git")
 ;;  (branch "master"))

 ;; ==========================================================================
 ;; Guix-Past Channel (Historical Software)
 ;; ==========================================================================
 ;; Packages for reproducing historical software environments.
 ;; Useful for scientific reproducibility and running legacy software.
 ;;
 ;; Repository: https://gitlab.inria.fr/guix-hpc/guix-past
 ;;
 ;; UNCOMMENT TO ENABLE:
 ;;
 ;; (channel
 ;;  (name 'guix-past)
 ;;  (url "https://gitlab.inria.fr/guix-hpc/guix-past.git")
 ;;  (branch "master"))

 ;; ==========================================================================
 ;; Local Development Channel Template
 ;; ==========================================================================
 ;; For local package development, you can add a channel from a local directory.
 ;; This is useful for testing custom packages before submitting upstream.
 ;;
 ;; UNCOMMENT TO ENABLE (adjust path as needed):
 ;;
 ;; (channel
 ;;  (name 'local-packages)
 ;;  (url (string-append "file://" (getenv "HOME") "/guix-packages")))

 ;; ==========================================================================
 ;; Custom Channel Template
 ;; ==========================================================================
 ;; Use this template to add your own custom channels.
 ;; Custom channels can contain personal packages, patches, or modifications.
 ;;
 ;; (channel
 ;;  (name 'my-custom-channel)
 ;;  (url "https://github.com/username/my-guix-channel")
 ;;  ;; Optional: specify a branch (defaults to master/main)
 ;;  (branch "main")
 ;;  ;; Optional: pin to a specific commit for reproducibility
 ;;  ;; (commit "abc123def456...")
 ;;  ;; Optional: add introduction for channel authentication
 ;;  ;; (introduction
 ;;  ;;  (make-channel-introduction
 ;;  ;;   "commit-hash-here"
 ;;  ;;   (openpgp-fingerprint
 ;;  ;;    "XXXX XXXX XXXX XXXX XXXX  XXXX XXXX XXXX XXXX XXXX"))))

 )

;; =============================================================================
;; Usage Notes
;; =============================================================================
;;
;; After modifying this file, run:
;;   guix pull
;;
;; To use a specific channels file:
;;   guix pull -C /path/to/channels.scm
;;
;; To check current channel status:
;;   guix describe
;;
;; To rollback to a previous generation:
;;   guix pull --roll-back
;;
;; For reproducible environments, you can export your exact channel state:
;;   guix describe -f channels > channels-lock.scm
;;
;; =============================================================================
;; Common Operations
;; =============================================================================
;;
;; Search for packages:
;;   guix search <term>
;;
;; Show package info:
;;   guix show <package>
;;
;; Install package:
;;   guix install <package>
;;
;; Update all packages:
;;   guix upgrade
;;
;; Create a development shell:
;;   guix shell <packages...>
;;
;; Build a package:
;;   guix build <package>
;;
;; =============================================================================
;; System Crafters Resources
;; =============================================================================
;;
;; System Crafters website: https://systemcrafters.net
;; System Crafters YouTube: https://youtube.com/@SystemCrafters
;; Guix guides: https://systemcrafters.net/guides/
;;
;; Recommended learning path:
;; 1. "Craft Your System with Guix" series
;; 2. "Emacs From Scratch" series (for Emacs configuration)
;; 3. "GNU Guix: An Introduction" talk
;;
;; Community:
;; - IRC: #guix on Libera.Chat
;; - Matrix: #guix:matrix.org
;; - Mailing lists: help-guix@gnu.org
;;
;; =============================================================================
;; Channel Authentication
;; =============================================================================
;;
;; Guix uses OpenPGP signatures to verify channel authenticity.
;; The 'introduction' field specifies the first signed commit and the
;; maintainer's public key fingerprint.
;;
;; To verify a channel manually:
;;   guix describe --format=channels | grep -A 10 <channel-name>
;;
;; If you see authentication warnings, ensure:
;; 1. The introduction commit hash is correct
;; 2. The fingerprint matches the channel maintainer's key
;; 3. Your GPG keyring is up to date
;;
