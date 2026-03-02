;; -*- lexical-binding: t; -*-
;; Emacs Configuration - Migrated from Guix to NixOS
;; System Crafters style configuration with minimal, keyboard-driven approach
;; Native compilation, Vertico completion, LSP support, Org mode

;; ============================================================================
;; Startup Performance Reporting
;; ============================================================================

(add-hook 'emacs-startup-hook
          (lambda ()
            (message "Emacs loaded in %s with %d garbage collections."
                     (format "%.2f seconds"
                             (float-time
                              (time-subtract after-init-time before-init-time)))
                     gcs-done)))

;; ============================================================================
;; Basic Settings
;; ============================================================================

(setq user-full-name "gux"
      user-mail-address "gux@gunix")

;; Disable unnecessary UI elements (already done in early-init, but ensure)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(tooltip-mode -1)

;; General behavior
(setq inhibit-startup-screen t
      make-backup-files nil
      auto-save-default nil
      create-lockfiles nil
      use-short-answers t
      confirm-kill-emacs 'y-or-n-p
      ring-bell-function 'ignore)

;; Scrolling behavior
(setq scroll-margin 3
      scroll-conservatively 101
      scroll-preserve-screen-position t)

;; Line numbers (relative for easier navigation)
(global-display-line-numbers-mode 1)
(setq display-line-numbers-type 'relative)

;; Disable line numbers in certain modes
(dolist (mode '(org-mode-hook term-mode-hook vterm-mode-hook eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; Quality of life features
(column-number-mode 1)
(show-paren-mode 1)
(electric-pair-mode 1)
(global-auto-revert-mode 1)
(global-hl-line-mode 1)
(delete-selection-mode 1)
(save-place-mode 1)
(recentf-mode 1)
(winner-mode 1)

;; Indentation and formatting
(setq-default indent-tabs-mode nil
              tab-width 4
              fill-column 80)

;; UTF-8 everywhere
(set-default-coding-systems 'utf-8)

;; ============================================================================
;; Fonts
;; ============================================================================
;; Iosevka 120 for monospace, Noto Sans 120 for variable-pitch

(set-face-attribute 'default nil
                    :family "Iosevka"
                    :height 120)

(set-face-attribute 'fixed-pitch nil
                    :family "Iosevka"
                    :height 120)

(set-face-attribute 'variable-pitch nil
                    :family "Noto Sans"
                    :height 120)

;; ============================================================================
;; Theme - Modus Vivendi
;; ============================================================================

(load-theme 'modus-vivendi t)

;; ============================================================================
;; Doom Modeline
;; ============================================================================

(when (require 'doom-modeline nil t)
  (setq doom-modeline-height 35
        doom-modeline-bar-width 4
        doom-modeline-minor-modes nil)
  (doom-modeline-mode 1))

;; ============================================================================
;; Which-Key - Show Available Keybindings
;; ============================================================================

(when (require 'which-key nil t)
  (setq which-key-idle-delay 0.5)
  (which-key-mode))

;; ============================================================================
;; Helpful - Better Help Buffers
;; ============================================================================

(when (require 'helpful nil t)
  (global-set-key (kbd "C-h f") #'helpful-callable)
  (global-set-key (kbd "C-h v") #'helpful-variable)
  (global-set-key (kbd "C-h k") #'helpful-key))

;; ============================================================================
;; General.el - Convenient Keybinding Definitions
;; ============================================================================

(when (require 'general nil t)
  (general-create-definer my-leader-def :prefix "C-c")
  (my-leader-def
    "f" '(:ignore t :which-key "files")
    "ff" 'find-file
    "fr" 'recentf-open-files
    "fs" 'save-buffer

    "b" '(:ignore t :which-key "buffers")
    "bb" 'switch-to-buffer
    "bk" 'kill-current-buffer

    "g" '(:ignore t :which-key "git")
    "gg" 'magit-status

    "o" '(:ignore t :which-key "org")
    "oa" 'org-agenda
    "oc" 'org-capture

    "n" '(:ignore t :which-key "notes")
    "nf" 'org-roam-node-find
    "ni" 'org-roam-node-insert))

;; ============================================================================
;; Vertico Completion Stack
;; ============================================================================

(when (require 'vertico nil t)
  (setq vertico-cycle t vertico-count 15)
  (vertico-mode))

(when (require 'orderless nil t)
  (setq completion-styles '(orderless basic)))

(when (require 'marginalia nil t)
  (marginalia-mode))

(when (require 'consult nil t)
  (global-set-key (kbd "C-s") #'consult-line)
  (global-set-key (kbd "C-x b") #'consult-buffer)
  (global-set-key (kbd "M-s r") #'consult-ripgrep))

(when (require 'embark nil t)
  (global-set-key (kbd "C-.") #'embark-act))

;; ============================================================================
;; Corfu - In-Buffer Completion
;; ============================================================================

(when (require 'corfu nil t)
  (setq corfu-cycle t corfu-auto t)
  (global-corfu-mode))

(when (require 'cape nil t)
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-dabbrev))

;; ============================================================================
;; Magit - Git Integration
;; ============================================================================

(when (require 'magit nil t)
  (global-set-key (kbd "C-x g") #'magit-status))

(when (require 'git-gutter nil t)
  (global-git-gutter-mode +1))

(when (require 'git-timemachine nil t)
  ;; Available via M-x git-timemachine
  )

;; ============================================================================
;; Org Mode
;; ============================================================================

(when (require 'org nil t)
  (setq org-directory (expand-file-name "~/org")
        org-default-notes-file (concat org-directory "/inbox.org")
        org-agenda-files (list org-directory)
        org-ellipsis " ▾"
        org-hide-emphasis-markers t
        org-startup-indented t)

  ;; Todo keywords
  (setq org-todo-keywords
        '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d)" "CANCELLED(c)")))

  ;; Capture templates
  (setq org-capture-templates
        '(("t" "Task" entry (file+headline org-default-notes-file "Tasks")
           "* TODO %?\n%U"))))

;; Org Modern - Visual improvements
(when (require 'org-modern nil t)
  (add-hook 'org-mode-hook #'org-modern-mode))

;; Visual Fill Column - Centered text
(when (require 'visual-fill-column nil t)
  (setq visual-fill-column-width 100
        visual-fill-column-center-text t)
  (add-hook 'org-mode-hook #'visual-fill-column-mode))

;; Org Appear - Auto-toggle markup visibility
(when (require 'org-appear nil t)
  (add-hook 'org-mode-hook #'org-appear-mode))

;; ============================================================================
;; Org-Roam - Zettelkasten Note-Taking
;; ============================================================================

(when (require 'org-roam nil t)
  (setq org-roam-directory (file-truename (expand-file-name "~/org/roam"))
        org-roam-completion-everywhere t)
  (org-roam-db-autosync-mode))

;; ============================================================================
;; LSP with Eglot
;; ============================================================================

(when (require 'eglot nil t)
  ;; Auto-enable LSP for supported languages
  (dolist (hook '(python-mode-hook rust-mode-hook go-mode-hook))
    (add-hook hook #'eglot-ensure))
  (setq eglot-autoshutdown t))

;; ============================================================================
;; Syntax Checking with Flycheck
;; ============================================================================

(when (require 'flycheck nil t)
  (global-flycheck-mode))

;; ============================================================================
;; Tree-sitter Auto Configuration
;; ============================================================================

(when (require 'treesit-auto nil t)
  (global-treesit-auto-mode))

;; ============================================================================
;; Projectile - Project Management
;; ============================================================================

(when (require 'projectile nil t)
  (setq projectile-project-search-path '("~/projects" "~/code"))
  (projectile-mode +1)
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map))

;; ============================================================================
;; Quality of Life Enhancements
;; ============================================================================

;; Rainbow Delimiters - Colorful parentheses
(when (require 'rainbow-delimiters nil t)
  (add-hook 'prog-mode-hook #'rainbow-delimiters-mode))

;; HL-TODO - Highlight TODO/FIXME/etc comments
(when (require 'hl-todo nil t)
  (global-hl-todo-mode))

;; Smartparens - Intelligent parenthesis pairing
(when (require 'smartparens nil t)
  (require 'smartparens-config nil t)
  (add-hook 'prog-mode-hook #'smartparens-mode))

;; YASnippet - Template expansion
(when (require 'yasnippet nil t)
  (yas-global-mode 1))

;; ws-butler - Whitespace handling
(when (require 'ws-butler nil t)
  (add-hook 'prog-mode-hook #'ws-butler-mode))

;; ============================================================================
;; Terminal and Shell Integration
;; ============================================================================

;; vterm - Fast terminal emulator
(when (require 'vterm nil t)
  (global-set-key (kbd "C-c t") #'vterm))

;; eshell-prompt-extras - Fancy eshell prompt
(when (require 'eshell-prompt-extras nil t)
  ;; Configured via eshell customization
  )

;; ============================================================================
;; Language Support
;; ============================================================================

;; Geiser - Scheme interaction
(when (require 'geiser nil t)
  (setq geiser-default-implementation 'guile))

;; Nix mode, Markdown mode, YAML mode, JSON mode are auto-loaded
;; Python mode, Rust mode, Go mode come with Emacs or are auto-loaded

;; ============================================================================
;; Directory Environment (.direnv, .envrc)
;; ============================================================================

(when (require 'envrc nil t)
  (envrc-global-mode))

;; Note: guix package is skipped as we're on NixOS, not Guix
;; Consider using nix-direnv or similar if needed

;; ============================================================================
;; Custom and Server
;; ============================================================================

;; Load custom.el if it exists (Emacs customize settings)
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file) (load custom-file))

;; Start Emacs server if not already running
(unless (daemonp)
  (require 'server)
  (unless (server-running-p) (server-start)))

;; ============================================================================
;; Optional: EWM Module Loading
;; ============================================================================
;; Load EWM (Emacs Wayland Manager) if EWM_SESSION is set
;; This is handled in Unit 8 when EWM is integrated

(when (getenv "EWM_SESSION")
  ;; EWM module loading would happen here
  ;; For now, this is a placeholder
  )
