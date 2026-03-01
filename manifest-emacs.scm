;; Guix Emacs Manifest
;; All Emacs packages for the complete setup
;; This includes the core Emacs build with all packages from emacs-config.scm
;; Use with: guix package -m manifest-emacs.scm
;;       or: guix shell -m manifest-emacs.scm

(specifications->manifest
 '(;; ========================================================================
   ;; Core Emacs
   ;; ========================================================================
   "emacs-pgtk"             ; Emacs with pure GTK support (Wayland native)

   ;; ========================================================================
   ;; UI Enhancement
   ;; ========================================================================
   "emacs-doom-modeline"    ; Fancy, minimal modeline
   "emacs-all-the-icons"    ; Icon support for modeline and buffers
   "emacs-nerd-icons"       ; Alternative icon fonts
   "emacs-which-key"        ; Display available keybindings on prefix
   "emacs-helpful"          ; Better help buffers with more context
   "emacs-general"          ; Convenient key binding definitions

   ;; ========================================================================
   ;; Completion Framework (Vertico-based)
   ;; ========================================================================
   "emacs-vertico"          ; Vertical completion UI
   "emacs-orderless"        ; Flexible completion style
   "emacs-marginalia"       ; Minibuffer annotations and hints
   "emacs-consult"          ; Enhanced commands with preview
   "emacs-embark"           ; Contextual actions on completion selections
   "emacs-corfu"            ; Completion at point (in-buffer completion)
   "emacs-cape"             ; Completion at point extensions

   ;; ========================================================================
   ;; Org Mode and Knowledge Management
   ;; ========================================================================
   "emacs-org"              ; Org mode for notes, outlines, and planning
   "emacs-org-roam"         ; Zettelkasten-style note-taking with org
   "emacs-org-roam-ui"      ; Graph visualization for org-roam notes
   "emacs-org-appear"       ; Auto-toggle markup visibility
   "emacs-org-modern"       ; Modern UI improvements for org mode
   "emacs-org-superstar"    ; Fancy bullets in org mode
   "emacs-org-download"     ; Drag and drop images into org mode
   "emacs-visual-fill-column" ; Centered text wrapping for readability

   ;; ========================================================================
   ;; Version Control (Magit and Git Integration)
   ;; ========================================================================
   "emacs-magit"            ; Excellent Git interface for Emacs
   "emacs-git-gutter"       ; Show diff in fringe/gutter
   "emacs-git-timemachine"  ; Browse Git commit history
   "emacs-git-link"         ; Generate URLs to Git hosting services
   "emacs-forge"            ; GitHub and GitLab integration for Magit

   ;; ========================================================================
   ;; Development Tools
   ;; ========================================================================
   "emacs-eglot"            ; LSP client (Language Server Protocol)
   "emacs-flycheck"         ; Syntax checking on the fly
   "emacs-yasnippet"        ; Template expansion with snippets
   "emacs-yasnippet-snippets" ; Pre-built snippet collection
   "emacs-treesit-auto"     ; Automatic tree-sitter grammar configuration
   "emacs-projectile"       ; Project interaction library
   "emacs-perspective"      ; Workspace management

   ;; ========================================================================
   ;; Language Support
   ;; ========================================================================
   "emacs-geiser"           ; Scheme interaction and development
   "emacs-geiser-guile"     ; Guile Scheme support
   "emacs-nix-mode"         ; Nix language editing
   "emacs-markdown-mode"    ; Markdown editing and preview
   "emacs-yaml-mode"        ; YAML file editing
   "emacs-json-mode"        ; JSON file editing and formatting
   "emacs-rust-mode"        ; Rust language support
   "emacs-go-mode"          ; Go language support
   "emacs-python-mode"      ; Enhanced Python mode

   ;; ========================================================================
   ;; Code Quality and Formatting
   ;; ========================================================================
   "emacs-rainbow-delimiters" ; Colorful parentheses and brackets
   "emacs-hl-todo"          ; Highlight TODO/FIXME/etc comments
   "emacs-ws-butler"        ; Whitespace cleanup and management
   "emacs-smartparens"      ; Intelligent parenthesis pairing
   "emacs-wgrep"            ; Writable grep with result editing

   ;; ========================================================================
   ;; Terminal and Shell Integration
   ;; ========================================================================
   "emacs-vterm"            ; Fast, feature-rich terminal emulator
   "emacs-eshell-prompt-extras" ; Fancy eshell prompt enhancements

   ;; ========================================================================
   ;; Theming and Aesthetics
   ;; ========================================================================
   "emacs-doom-themes"      ; Popular Doom Emacs themes collection
   "emacs-ef-themes"        ; Prot's elegant and refined themes
   "emacs-modus-themes"     ; Prot's highly accessible WCAG AA themes
   "emacs-catppuccin-theme" ; Pastel color scheme

   ;; ========================================================================
   ;; Evil Mode (Vim Keybindings) - Optional but included for completeness
   ;; ========================================================================
   "emacs-evil"             ; Vi layer for Emacs (Vim keybindings)
   "emacs-evil-collection"  ; Evil bindings for many modes
   "emacs-evil-surround"    ; Surround text objects (like vim-surround)
   "emacs-undo-tree"        ; Tree-structured undo visualization

   ;; ========================================================================
   ;; Guix Integration
   ;; ========================================================================
   "emacs-envrc"            ; Integration with direnv
   "emacs-guix"             ; Guix package manager integration

   ;; ========================================================================
   ;; EXWM (Emacs X Window Manager) - Optional but included for completeness
   ;; ========================================================================
   ;; EXWM allows Emacs to manage X11 windows and function as a window manager
   ;; Useful when running inside dwl-guile for managing XWayland windows
   "emacs-exwm"             ; Emacs X Window Manager
   "emacs-xelb"             ; X11 protocol bindings for Emacs Lisp

   ;; ========================================================================
   ;; Fonts for Emacs
   ;; ========================================================================
   "font-fira-code"         ; Monospace font with ligature support
   "font-iosevka"           ; Highly customizable monospace font
   "font-jetbrains-mono"    ; JetBrains monospace font
   "font-google-noto"       ; Google Noto fonts with excellent Unicode coverage

   ))

;; ========================================================================
;; Usage Notes
;; ========================================================================
;;
;; Install all Emacs packages:
;;   guix package -m manifest-emacs.scm
;;
;; Create a temporary Emacs environment with all packages:
;;   guix shell -m manifest-emacs.scm -- emacs
;;
;; Create a minimal Emacs environment (without Evil and EXWM):
;;   # Edit this file to comment out emacs-evil, emacs-undo-tree,
;;   # emacs-exwm, and emacs-xelb, then run:
;;   guix package -m manifest-emacs.scm
;;
;; Configure your Emacs init.el and early-init.el:
;;   ~/.emacs.d/init.el
;;   ~/.emacs.d/early-init.el
;;
;; Or use with Guix Home by loading emacs-config.scm in your home configuration
;;
;; Some recommendations for post-installation:
;;
;;   1. Create ~/.emacs.d/init.el with your configuration
;;      (See emacs-config.scm for a complete example)
;;
;;   2. Install LSP servers for your languages:
;;      - Python: pip install pyright
;;      - JavaScript: npm install -g typescript-language-server
;;      - Rust: cargo install rust-analyzer
;;
;;   3. Set up directories:
;;      mkdir -p ~/.emacs.d/snippets
;;      mkdir -p ~/org/roam
;;
;;   4. Optional: Set up GNU Stow for managing additional dotfiles
;;      cd ~/dotfiles && stow emacs
;;
;; ========================================================================
;; Package Grouping Reference
;; ========================================================================
;;
;; Core & UI:
;;   emacs-pgtk, doom-modeline, all-the-icons, which-key, helpful, general
;;
;; Completion (Vertico stack):
;;   vertico, orderless, marginalia, consult, embark, corfu, cape
;;
;; Org Ecosystem:
;;   org, org-roam, org-roam-ui, org-appear, org-modern, org-superstar,
;;   org-download, visual-fill-column
;;
;; Git (Magit stack):
;;   magit, git-gutter, git-timemachine, git-link, forge
;;
;; Development:
;;   eglot (LSP), flycheck, yasnippet, treesit-auto, projectile, perspective
;;
;; Languages:
;;   geiser, geiser-guile, nix-mode, markdown-mode, yaml-mode, json-mode,
;;   rust-mode, go-mode, python-mode
;;
;; Quality of Life:
;;   rainbow-delimiters, hl-todo, ws-butler, smartparens, wgrep
;;
;; Terminal:
;;   vterm, eshell-prompt-extras
;;
;; Themes:
;;   doom-themes, ef-themes, modus-themes, catppuccin-theme
;;
;; Optional (Evil/Vim mode):
;;   evil, evil-collection, evil-surround, undo-tree
;;
;; Optional (Window Management):
;;   exwm, xelb
;;
;; Integration:
;;   envrc, guix
;;
;; Fonts:
;;   font-fira-code, font-iosevka, font-jetbrains-mono, font-google-noto
;;
;; ========================================================================
