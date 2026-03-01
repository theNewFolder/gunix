;; -*- lexical-binding: t; -*-
;; =============================================================================
;; Emacs Configuration Module for Guix Home
;; System Crafters Style Configuration
;; =============================================================================
;;
;; This module provides a comprehensive Emacs configuration following
;; System Crafters patterns. It can be used standalone or imported into
;; guix-home.scm for declarative Emacs package management.
;;
;; Key principles:
;;   - Minimal and keyboard-driven
;;   - Native compilation support (Emacs 28+)
;;   - LSP-ready with eglot
;;   - Vertico-based completion framework
;;   - Org mode and org-roam for knowledge management
;;
;; Usage:
;;   1. Copy early-init.el and init.el contents to ~/.emacs.d/
;;   2. Or use with Guix Home by importing this module
;;
;; For Guix Home integration, add to guix-home.scm:
;;   (load "emacs-config.scm")
;;
;; =============================================================================
;; GNU Stow Integration
;; =============================================================================
;;
;; This configuration works well with GNU Stow for managing additional dotfiles.
;; Guix Home manages the core configuration while Stow can manage:
;;   - Custom snippets (~/.emacs.d/snippets/)
;;   - Personal Lisp modules (~/.emacs.d/lisp/)
;;   - Custom themes (~/.emacs.d/themes/)
;;   - Machine-specific overrides
;;
;; Example Stow structure:
;;   ~/dotfiles/
;;     emacs/
;;       .emacs.d/
;;         snippets/           # YASnippet templates
;;           python-mode/
;;           org-mode/
;;         lisp/               # Personal Lisp files
;;           my-functions.el
;;           local-config.el
;;         themes/             # Custom themes
;;
;; Apply with: cd ~/dotfiles && stow emacs
;;
;; =============================================================================

(use-modules (gnu packages emacs)
             (gnu packages emacs-xyz)
             (gnu packages fonts)
             (guix gexp))

;; =============================================================================
;; Package Definitions
;; =============================================================================

;; Core Emacs with native compilation and pure GTK (Wayland support)
(define %emacs-core
  (list emacs-pgtk))

;; System Crafters Essential Packages
(define %emacs-essential
  (list
   ;; UI Enhancement
   emacs-doom-modeline       ; Fancy, minimal modeline
   emacs-all-the-icons       ; Icon support
   emacs-nerd-icons          ; Alternative icons

   ;; Discoverability
   emacs-which-key           ; Display available keybindings
   emacs-helpful             ; Better help buffers

   ;; Keybinding Management
   emacs-general))           ; Convenient key definitions

;; Completion Framework (Vertico-based)
(define %emacs-completion
  (list
   emacs-vertico             ; Vertical completion
   emacs-orderless           ; Flexible completion style
   emacs-marginalia          ; Minibuffer annotations
   emacs-consult             ; Enhanced commands
   emacs-embark              ; Contextual actions
   emacs-corfu               ; In-buffer completion
   emacs-cape))              ; Completion extensions

;; Org Mode and Knowledge Management
(define %emacs-org
  (list
   emacs-org                 ; Org mode
   emacs-org-roam            ; Zettelkasten notes
   emacs-org-roam-ui         ; Graph visualization
   emacs-org-appear          ; Auto-toggle markup
   emacs-org-modern          ; Modern UI
   emacs-org-superstar       ; Fancy bullets
   emacs-org-download        ; Image drag-and-drop
   emacs-visual-fill-column)) ; Text wrapping

;; Version Control (Magit)
(define %emacs-git
  (list
   emacs-magit               ; Git interface
   emacs-git-gutter          ; Diff in fringe
   emacs-git-timemachine     ; Git history
   emacs-git-link            ; Get URLs
   emacs-forge))             ; GitHub/GitLab integration

;; Development Tools
(define %emacs-dev
  (list
   emacs-eglot               ; LSP client (built-in style)
   emacs-flycheck            ; Syntax checking
   emacs-yasnippet           ; Snippets
   emacs-yasnippet-snippets  ; Snippet collection
   emacs-treesit-auto        ; Tree-sitter
   emacs-projectile          ; Project management
   emacs-perspective))       ; Workspaces

;; Language Support
(define %emacs-languages
  (list
   emacs-geiser              ; Scheme interaction
   emacs-geiser-guile        ; Guile support
   emacs-nix-mode            ; Nix editing
   emacs-markdown-mode       ; Markdown
   emacs-yaml-mode           ; YAML
   emacs-json-mode))         ; JSON

;; Quality of Life
(define %emacs-qol
  (list
   emacs-rainbow-delimiters  ; Colorful parens
   emacs-hl-todo             ; Highlight TODOs
   emacs-ws-butler           ; Whitespace handling
   emacs-smartparens         ; Delimiter pairing
   emacs-wgrep))             ; Writable grep

;; Terminal
(define %emacs-terminal
  (list
   emacs-vterm               ; Terminal emulator
   emacs-eshell-prompt-extras)) ; Fancy eshell

;; Themes
(define %emacs-themes
  (list
   emacs-doom-themes         ; Doom themes
   emacs-ef-themes           ; Prot's elegant themes
   emacs-modus-themes        ; Prot's accessible themes
   emacs-catppuccin-theme))  ; Pastel theme

;; Evil Mode (Optional - Vim keybindings)
(define %emacs-evil
  (list
   emacs-evil                ; Vi layer
   emacs-evil-collection     ; Evil bindings
   ;; emacs-evil-nerd-commenter ; Commenting
   emacs-evil-surround       ; Surround
   emacs-undo-tree))         ; Undo visualization

;; Guix Integration
(define %emacs-guix
  (list
   emacs-envrc               ; direnv integration
   emacs-guix))              ; Guix integration

;; Recommended Fonts
(define %emacs-fonts
  (list
   font-fira-code            ; Ligature-enabled coding font
   font-iosevka              ; Highly customizable
   font-jetbrains-mono       ; JetBrains font
   font-google-noto))        ; Unicode coverage

;; =============================================================================
;; All Packages Combined (without Evil)
;; =============================================================================

(define %emacs-packages-core
  (append %emacs-core
          %emacs-essential
          %emacs-completion
          %emacs-org
          %emacs-git
          %emacs-dev
          %emacs-languages
          %emacs-qol
          %emacs-terminal
          %emacs-themes
          %emacs-guix))

;; All packages with Evil mode
(define %emacs-packages-evil
  (append %emacs-packages-core
          %emacs-evil))

;; Export for use in guix-home.scm
(define %all-emacs-packages %emacs-packages-core)

;; =============================================================================
;; Early Init Configuration
;; =============================================================================

(define %sc-early-init-el
  ";; -*- lexical-binding: t; -*-
;; System Crafters Style Early Init
;; Generated by emacs-config.scm

;; Performance optimizations for startup
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

;; Disable native compilation during startup
(setq native-comp-deferred-compilation nil
      native-comp-jit-compilation nil)

;; Disable package.el (Guix manages packages)
(setq package-enable-at-startup nil
      package-archives nil)

;; Disable UI elements early
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)

;; Startup behavior
(setq inhibit-startup-message t
      inhibit-startup-echo-area-message user-login-name
      inhibit-default-init t
      initial-major-mode 'fundamental-mode
      initial-scratch-message nil)

;; Prevent flash of unstyled modeline
(setq-default mode-line-format nil)

;; Bidirectional text performance
(setq-default bidi-display-reordering 'left-to-right
              bidi-paragraph-direction 'left-to-right)
(setq bidi-inhibit-bpa t)

;; Scrolling performance
(setq fast-but-imprecise-scrolling t)

;; Font cache performance
(setq inhibit-compacting-font-caches t)

;; Ignore X resources
(advice-add #'x-apply-session-resources :override #'ignore)

;; Frame styling
(push '(internal-border-width . 8) default-frame-alist)
")

;; =============================================================================
;; Init Configuration
;; =============================================================================

(define %sc-init-el
  ";; -*- lexical-binding: t; -*-
;; System Crafters Style Init
;; Generated by emacs-config.scm
;;
;; This configuration follows System Crafters patterns:
;; - Minimal and keyboard-driven
;; - Native compilation support
;; - LSP-ready with eglot
;; - Vertico-based completion
;; - Org mode and org-roam for knowledge management

;; =============================================================================
;; Startup Performance
;; =============================================================================

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 16 1024 1024)
                  gc-cons-percentage 0.1)))

(add-hook 'emacs-startup-hook
          (lambda ()
            (message \"Emacs loaded in %s with %d garbage collections.\"
                     (format \"%.2f seconds\"
                             (float-time
                              (time-subtract after-init-time before-init-time)))
                     gcs-done)))

;; =============================================================================
;; Native Compilation
;; =============================================================================

(when (featurep 'native-compile)
  (setq native-comp-async-report-warnings-errors 'silent
        native-comp-deferred-compilation t
        native-comp-speed 2))

;; =============================================================================
;; Basic Settings
;; =============================================================================

(setq user-full-name \"Your Name\"
      user-mail-address \"your@email.com\")

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(tooltip-mode -1)

(setq inhibit-startup-screen t
      make-backup-files nil
      auto-save-default nil
      create-lockfiles nil
      use-short-answers t
      confirm-kill-emacs 'y-or-n-p
      ring-bell-function 'ignore)

(setq scroll-margin 3
      scroll-conservatively 101
      scroll-preserve-screen-position t)

(global-display-line-numbers-mode 1)
(setq display-line-numbers-type 'relative)

(dolist (mode '(org-mode-hook term-mode-hook vterm-mode-hook eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(column-number-mode 1)
(show-paren-mode 1)
(electric-pair-mode 1)
(global-auto-revert-mode 1)
(global-hl-line-mode 1)
(delete-selection-mode 1)
(save-place-mode 1)
(recentf-mode 1)
(winner-mode 1)

(setq-default indent-tabs-mode nil
              tab-width 4
              fill-column 80)

(set-default-coding-systems 'utf-8)

;; =============================================================================
;; Fonts
;; =============================================================================

(set-face-attribute 'default nil :family \"Iosevka\" :height 120)
(set-face-attribute 'fixed-pitch nil :family \"Iosevka\" :height 120)
(set-face-attribute 'variable-pitch nil :family \"Noto Sans\" :height 120)

;; =============================================================================
;; Theme
;; =============================================================================

(load-theme 'modus-vivendi t)

;; =============================================================================
;; Doom Modeline
;; =============================================================================

(when (require 'doom-modeline nil t)
  (setq doom-modeline-height 35
        doom-modeline-bar-width 4
        doom-modeline-minor-modes nil)
  (doom-modeline-mode 1))

;; =============================================================================
;; Which-Key
;; =============================================================================

(when (require 'which-key nil t)
  (setq which-key-idle-delay 0.5)
  (which-key-mode))

;; =============================================================================
;; Helpful
;; =============================================================================

(when (require 'helpful nil t)
  (global-set-key (kbd \"C-h f\") #'helpful-callable)
  (global-set-key (kbd \"C-h v\") #'helpful-variable)
  (global-set-key (kbd \"C-h k\") #'helpful-key))

;; =============================================================================
;; General.el
;; =============================================================================

(when (require 'general nil t)
  (general-create-definer my-leader-def :prefix \"C-c\")
  (my-leader-def
    \"f\" '(:ignore t :which-key \"files\")
    \"ff\" 'find-file
    \"fr\" 'recentf-open-files
    \"fs\" 'save-buffer

    \"b\" '(:ignore t :which-key \"buffers\")
    \"bb\" 'switch-to-buffer
    \"bk\" 'kill-current-buffer

    \"g\" '(:ignore t :which-key \"git\")
    \"gg\" 'magit-status

    \"o\" '(:ignore t :which-key \"org\")
    \"oa\" 'org-agenda
    \"oc\" 'org-capture

    \"n\" '(:ignore t :which-key \"notes\")
    \"nf\" 'org-roam-node-find
    \"ni\" 'org-roam-node-insert))

;; =============================================================================
;; Vertico, Orderless, Marginalia, Consult, Embark
;; =============================================================================

(when (require 'vertico nil t)
  (setq vertico-cycle t vertico-count 15)
  (vertico-mode))

(when (require 'orderless nil t)
  (setq completion-styles '(orderless basic)))

(when (require 'marginalia nil t)
  (marginalia-mode))

(when (require 'consult nil t)
  (global-set-key (kbd \"C-s\") #'consult-line)
  (global-set-key (kbd \"C-x b\") #'consult-buffer)
  (global-set-key (kbd \"M-s r\") #'consult-ripgrep))

(when (require 'embark nil t)
  (global-set-key (kbd \"C-.\") #'embark-act))

;; =============================================================================
;; Corfu and Cape
;; =============================================================================

(when (require 'corfu nil t)
  (setq corfu-cycle t corfu-auto t)
  (global-corfu-mode))

(when (require 'cape nil t)
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-dabbrev))

;; =============================================================================
;; Magit
;; =============================================================================

(when (require 'magit nil t)
  (global-set-key (kbd \"C-x g\") #'magit-status))

(when (require 'git-gutter nil t)
  (global-git-gutter-mode +1))

;; =============================================================================
;; Org Mode
;; =============================================================================

(when (require 'org nil t)
  (setq org-directory \"~/org\"
        org-default-notes-file (concat org-directory \"/inbox.org\")
        org-agenda-files (list org-directory)
        org-ellipsis \" ▾\"
        org-hide-emphasis-markers t
        org-startup-indented t)

  (setq org-todo-keywords
        '((sequence \"TODO(t)\" \"NEXT(n)\" \"|\" \"DONE(d)\" \"CANCELLED(c)\")))

  (setq org-capture-templates
        '((\"t\" \"Task\" entry (file+headline org-default-notes-file \"Tasks\")
           \"* TODO %?\\n%U\"))))

(when (require 'org-modern nil t)
  (add-hook 'org-mode-hook #'org-modern-mode))

(when (require 'visual-fill-column nil t)
  (setq visual-fill-column-width 100
        visual-fill-column-center-text t)
  (add-hook 'org-mode-hook #'visual-fill-column-mode))

;; =============================================================================
;; Org-Roam
;; =============================================================================

(when (require 'org-roam nil t)
  (setq org-roam-directory (file-truename \"~/org/roam\")
        org-roam-completion-everywhere t)
  (org-roam-db-autosync-mode))

;; =============================================================================
;; Eglot (LSP)
;; =============================================================================

(when (require 'eglot nil t)
  (dolist (hook '(python-mode-hook rust-mode-hook go-mode-hook))
    (add-hook hook #'eglot-ensure))
  (setq eglot-autoshutdown t))

(when (require 'flycheck nil t)
  (global-flycheck-mode))

(when (require 'treesit-auto nil t)
  (global-treesit-auto-mode))

;; =============================================================================
;; Projectile
;; =============================================================================

(when (require 'projectile nil t)
  (setq projectile-project-search-path '(\"~/projects\" \"~/code\"))
  (projectile-mode +1)
  (define-key projectile-mode-map (kbd \"C-c p\") 'projectile-command-map))

;; =============================================================================
;; Quality of Life
;; =============================================================================

(when (require 'rainbow-delimiters nil t)
  (add-hook 'prog-mode-hook #'rainbow-delimiters-mode))

(when (require 'hl-todo nil t)
  (global-hl-todo-mode))

(when (require 'smartparens nil t)
  (require 'smartparens-config nil t)
  (add-hook 'prog-mode-hook #'smartparens-mode))

(when (require 'yasnippet nil t)
  (yas-global-mode 1))

;; =============================================================================
;; Terminal
;; =============================================================================

(when (require 'vterm nil t)
  (global-set-key (kbd \"C-c t\") #'vterm))

;; =============================================================================
;; Guix and Direnv
;; =============================================================================

(when (require 'guix nil t)
  (setq guix-default-profile (expand-file-name \"~/.guix-profile\")))

(when (require 'envrc nil t)
  (envrc-global-mode))

;; =============================================================================
;; Geiser (Scheme)
;; =============================================================================

(when (require 'geiser nil t)
  (setq geiser-default-implementation 'guile))

;; =============================================================================
;; Custom File and Server
;; =============================================================================

(setq custom-file (expand-file-name \"custom.el\" user-emacs-directory))
(when (file-exists-p custom-file) (load custom-file))

(unless (daemonp)
  (require 'server)
  (unless (server-running-p) (server-start)))
")

;; =============================================================================
;; Export Configuration Files for Guix Home
;; =============================================================================

;; These can be used with home-files-service-type
(define %emacs-config-files
  (list
   `(".emacs.d/early-init.el"
     ,(plain-file "early-init.el" %sc-early-init-el))
   `(".emacs.d/init.el"
     ,(plain-file "init.el" %sc-init-el))))

;; =============================================================================
;; Additional Configuration Files
;; =============================================================================

;; Custom.el placeholder (Emacs will write customizations here)
(define %emacs-custom-el
  ";; -*- lexical-binding: t; -*-
;; Custom settings - managed by Emacs customize system
;; Do not edit this file manually
")

;; Snippets directory structure readme
(define %emacs-snippets-readme
  "# YASnippet Snippets Directory

Place your custom snippets here, organized by mode:

```
snippets/
  fundamental-mode/
  prog-mode/
  python-mode/
  org-mode/
  ...
```

Each snippet file should have:
1. A unique key (trigger)
2. A name
3. The template content

Example snippet (python-mode/def):
```
# -*- mode: snippet -*-
# name: def
# key: def
# --
def ${1:name}(${2:args}):
    \"\"\"${3:docstring}\"\"\"
    ${0:pass}
```

See: https://joaotavora.github.io/yasnippet/
")

;; =============================================================================
;; Evil Mode Configuration (Optional)
;; =============================================================================

(define %emacs-evil-init
  ";; -*- lexical-binding: t; -*-
;; Evil Mode Configuration
;; Add this to your init.el if you want Vim keybindings

(when (require 'evil nil t)
  (setq evil-want-integration t
        evil-want-keybinding nil
        evil-want-C-u-scroll t
        evil-want-C-i-jump nil
        evil-respect-visual-line-mode t
        evil-undo-system 'undo-tree)
  (evil-mode 1)

  ;; Visual line motions
  (evil-global-set-key 'motion \"j\" 'evil-next-visual-line)
  (evil-global-set-key 'motion \"k\" 'evil-previous-visual-line)

  ;; Escape from everything
  (global-set-key (kbd \"<escape>\") 'keyboard-escape-quit)

  ;; Evil collection for better mode support
  (when (require 'evil-collection nil t)
    (evil-collection-init))

  ;; Evil surround
  (when (require 'evil-surround nil t)
    (global-evil-surround-mode 1))

  ;; Undo-tree
  (when (require 'undo-tree nil t)
    (global-undo-tree-mode)
    (setq undo-tree-auto-save-history nil)))

;; Leader key configuration with general.el (Space as leader in Evil)
(when (and (featurep 'evil) (require 'general nil t))
  (general-create-definer my-evil-leader-def
    :keymaps '(normal insert visual emacs)
    :prefix \"SPC\"
    :global-prefix \"C-SPC\")

  (my-evil-leader-def
    \"SPC\" '(execute-extended-command :which-key \"M-x\")

    \"f\" '(:ignore t :which-key \"files\")
    \"ff\" 'find-file
    \"fr\" 'recentf-open-files
    \"fs\" 'save-buffer
    \"fd\" 'dired

    \"b\" '(:ignore t :which-key \"buffers\")
    \"bb\" 'switch-to-buffer
    \"bd\" 'kill-current-buffer
    \"bi\" 'ibuffer

    \"w\" '(:ignore t :which-key \"windows\")
    \"wv\" 'split-window-right
    \"ws\" 'split-window-below
    \"wd\" 'delete-window
    \"wm\" 'delete-other-windows

    \"g\" '(:ignore t :which-key \"git\")
    \"gg\" 'magit-status
    \"gb\" 'magit-blame
    \"gl\" 'magit-log-current

    \"p\" '(:ignore t :which-key \"project\")
    \"pp\" 'projectile-switch-project
    \"pf\" 'projectile-find-file
    \"ps\" 'projectile-ripgrep

    \"s\" '(:ignore t :which-key \"search\")
    \"ss\" 'consult-line
    \"sr\" 'consult-ripgrep
    \"sf\" 'consult-find

    \"o\" '(:ignore t :which-key \"org\")
    \"oa\" 'org-agenda
    \"oc\" 'org-capture

    \"n\" '(:ignore t :which-key \"notes\")
    \"nf\" 'org-roam-node-find
    \"ni\" 'org-roam-node-insert
    \"nb\" 'org-roam-buffer-toggle

    \"t\" '(:ignore t :which-key \"toggle\")
    \"tt\" 'load-theme
    \"tl\" 'display-line-numbers-mode))
")

;; =============================================================================
;; Usage Instructions
;; =============================================================================

;; To use this module in guix-home.scm:
;;
;; 1. Load this file:
;;    (load "emacs-config.scm")
;;
;; 2. Add packages to your home packages:
;;    (packages (append %all-emacs-packages other-packages))
;;
;; 3. Add config files via home-files-service-type:
;;    (simple-service 'emacs-config
;;                    home-files-service-type
;;                    %emacs-config-files)
;;
;; Or use the configurations directly in your guix-home.scm.
