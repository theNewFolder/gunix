;; Guix Channels Configuration for NixOS+Guix System
;; This file defines the software channels that Guix will use to fetch packages.
;;
;; Installation locations:
;;   User: ~/.config/guix/channels.scm
;;   System: /etc/guix/channels.scm (if using Guix System)
;;
;; Apply with: guix pull
;; Or specify directly: guix pull -C /path/to/channels.scm

(list
 ;; ==========================================================================
 ;; Official Guix Channel (Default)
 ;; ==========================================================================
 ;; The official GNU Guix channel containing free software packages.
 ;; This is included by default, but we specify it explicitly here for clarity
 ;; and to enable pinning for reproducibility.
 (channel
  (name 'guix)
  (url "https://git.savannah.gnu.org/git/guix.git")
  ;; You can pin to a specific commit for reproducibility:
  ;; (commit "abc123...")
  (introduction
   (make-channel-introduction
    "9edb3f66fd807b096b48283debdcddccfea34bad"
    (openpgp-fingerprint
     "BBB0 2DDF 2CEA F6A8 0D1D  E643 A2A0 6DF2 A33A 54FA"))))

 ;; ==========================================================================
 ;; Nonguix Channel (Nonfree Packages)
 ;; ==========================================================================
 ;; Provides nonfree software packages not included in official Guix.
 ;; Includes: Linux-libre firmware substitutes, proprietary drivers,
 ;;           browsers with DRM, etc.
 ;; Repository: https://gitlab.com/nonguix/nonguix
 ;;
 ;; IMPORTANT: This channel contains nonfree software. Enable only if needed.
 ;; Common packages from nonguix:
 ;;   - linux (mainline kernel with all firmware)
 ;;   - nvidia-driver
 ;;   - steam, steam-nvidia
 ;;   - signal-desktop
 ;;   - vscode
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
 ;; Guix Science Channel
 ;; ==========================================================================
 ;; Additional scientific and mathematical software not in main Guix.
 ;; Includes: machine learning tools, scientific computing packages, etc.
 ;; Repository: https://github.com/guix-science/guix-science
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
 ;; Guix Gaming Channel
 ;; ==========================================================================
 ;; Gaming-related packages and tools.
 ;; Includes: Wine staging, game launchers, gaming utilities, etc.
 ;; Repository: https://gitlab.com/guix-gaming-channels/games
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
 ;; Repository: https://github.com/flatwhatson/guix-channel
 ;;
 ;; UNCOMMENT TO ENABLE:
 ;;
 ;; (channel
 ;;  (name 'flat)
 ;;  (url "https://github.com/flatwhatson/guix-channel.git")
 ;;  (branch "master"))

 ;; ==========================================================================
 ;; RDE Channel (Reproducible Development Environments)
 ;; ==========================================================================
 ;; Provides tools for building reproducible development environments
 ;; with a focus on Emacs integration.
 ;; Repository: https://git.sr.ht/~abcdw/rde
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

;; ==========================================================================
;; Usage Notes
;; ==========================================================================
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
;; To use nonguix substitutes (pre-built packages), add to ~/.config/guix/channels.scm
;; or run guix with: --substitute-urls='https://substitutes.nonguix.org https://ci.guix.gnu.org'
;;
;; ==========================================================================
;; Nonguix Substitute Server
;; ==========================================================================
;; To use pre-built packages from nonguix (saves compilation time):
;;
;; 1. Authorize the substitute server:
;;    sudo guix archive --authorize < \
;;      <(curl -sL https://substitutes.nonguix.org/signing-key.pub)
;;
;; 2. Add to your guix command or set in /etc/guix/acl:
;;    --substitute-urls='https://substitutes.nonguix.org https://ci.guix.gnu.org'
