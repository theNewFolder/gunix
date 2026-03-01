;; Guix Package Manifest
;; This file defines a set of packages to install together.
;; Use with: guix package -m /path/to/manifest.scm
;;       or: guix install -m /path/to/manifest.scm

(specifications->manifest
 '(;; ========================================================================
   ;; Core Utilities
   ;; ========================================================================
   "coreutils"              ; GNU core utilities (ls, cp, mv, etc.)
   "findutils"              ; find, xargs, locate
   "grep"                   ; GNU grep
   "sed"                    ; GNU sed stream editor
   "gawk"                   ; GNU awk
   "which"                  ; Locate commands
   "less"                   ; Pager for viewing files
   "file"                   ; Determine file types

   ;; ========================================================================
   ;; Shell and Terminal
   ;; ========================================================================
   "bash"                   ; GNU Bourne-Again Shell
   "zsh"                    ; Z shell
   "bash-completion"        ; Programmable completion for Bash
   "readline"               ; Line editing library

   ;; ========================================================================
   ;; Text Editors
   ;; ========================================================================
   "vim"                    ; Vi IMproved text editor
   "nano"                   ; Simple text editor

   ;; ========================================================================
   ;; Version Control
   ;; ========================================================================
   "git"                    ; Distributed version control
   "git-lfs"                ; Git Large File Storage

   ;; ========================================================================
   ;; Network Tools
   ;; ========================================================================
   "curl"                   ; Command-line URL transfer tool
   "wget"                   ; Network file retriever
   "openssh"                ; SSH connectivity tools
   "nss-certs"              ; CA certificates for HTTPS

   ;; ========================================================================
   ;; Compression and Archiving
   ;; ========================================================================
   "tar"                    ; Tape archiver
   "gzip"                   ; GNU compression utility
   "bzip2"                  ; Block-sorting compressor
   "xz"                     ; LZMA compression
   "unzip"                  ; ZIP archive extractor
   "zip"                    ; ZIP archive creator

   ;; ========================================================================
   ;; Build Tools
   ;; ========================================================================
   "make"                   ; GNU Make build tool
   "gcc-toolchain"          ; GNU Compiler Collection

   ;; ========================================================================
   ;; System Information and Monitoring
   ;; ========================================================================
   "htop"                   ; Interactive process viewer
   "procps"                 ; Process utilities (ps, top, etc.)
   "tree"                   ; Directory listing as tree

   ;; ========================================================================
   ;; File Management
   ;; ========================================================================
   "rsync"                  ; Fast file copying/syncing
   "fd"                     ; Simple, fast find alternative
   "ripgrep"                ; Fast recursive grep

   ;; ========================================================================
   ;; Documentation
   ;; ========================================================================
   "man-db"                 ; Manual page utilities
   "info-reader"            ; GNU Info documentation reader
   "texinfo"                ; GNU documentation system

   ;; ========================================================================
   ;; Guix-Specific Tools
   ;; ========================================================================
   ;; These are typically already available but listed for completeness
   ;; "guile"               ; GNU Guile Scheme (Guix's extension language)

   ))

;; ========================================================================
;; Usage Notes
;; ========================================================================
;;
;; Install all packages in this manifest:
;;   guix package -m manifest.scm
;;
;; Install to a specific profile:
;;   guix package -m manifest.scm -p ~/my-profile
;;
;; Create a temporary environment with these packages:
;;   guix shell -m manifest.scm
;;
;; Build a container with these packages:
;;   guix shell -m manifest.scm --container
;;
;; Export installed packages to a manifest:
;;   guix package --export-manifest > my-manifest.scm
;;
;; ========================================================================
;; Alternative Manifest Styles
;; ========================================================================
;;
;; Using package objects directly (more verbose but allows customization):
;;
;; (use-modules (gnu packages base)
;;              (gnu packages vim))
;;
;; (packages->manifest
;;  (list coreutils
;;        vim
;;        ;; Specify a particular output:
;;        (list gcc "lib")))
;;
;; ========================================================================
;; Conditional Packages
;; ========================================================================
;;
;; You can use Scheme to conditionally include packages:
;;
;; (use-modules (guix packages)
;;              (gnu packages linux))
;;
;; (define is-linux?
;;   (string-contains %host-type "linux"))
;;
;; (specifications->manifest
;;  (append
;;   '("coreutils" "vim")
;;   (if is-linux?
;;       '("linux-tools")
;;       '())))
