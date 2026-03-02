;; -*- lexical-binding: t; -*-
;; Emacs Early Initialization
;; Performance optimizations and UI tweaks for faster startup

;; ============================================================================
;; Garbage Collection Optimization
;; ============================================================================
;; Use a very high threshold during startup to reduce GC pauses
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

;; Reset to a more reasonable value after startup
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 16 1024 1024)
                  gc-cons-percentage 0.1)))

;; ============================================================================
;; Native Compilation Settings
;; ============================================================================
(when (featurep 'native-compile)
  (setq native-comp-async-report-warnings-errors 'silent
        native-comp-speed 2))

;; ============================================================================
;; Package Management
;; ============================================================================
;; Disable package.el as we use Nix for package management
(setq package-enable-at-startup nil
      package-archives nil)

;; ============================================================================
;; UI Elements
;; ============================================================================
;; Disable UI elements early to avoid flash
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
(push '(internal-border-width . 8) default-frame-alist)
(push '(undecorated-round . t) default-frame-alist)

;; ============================================================================
;; Startup Behavior
;; ============================================================================
(setq inhibit-startup-message t
      inhibit-startup-echo-area-message user-login-name
      inhibit-default-init t
      initial-major-mode 'fundamental-mode
      initial-scratch-message nil)

;; Prevent flash of unstyled modeline
(setq-default mode-line-format nil)

;; ============================================================================
;; Performance Tweaks
;; ============================================================================
;; Bidirectional text scanning (slower but improves display for RTL text)
(setq-default bidi-display-reordering 'left-to-right
              bidi-paragraph-direction 'left-to-right)
(setq bidi-inhibit-bpa t)

;; Scrolling performance
(setq fast-but-imprecise-scrolling t)

;; Font cache performance
(setq inhibit-compacting-font-caches t)

;; Ignore X resources (Wayland-native app)
(advice-add #'x-apply-session-resources :override #'ignore)
