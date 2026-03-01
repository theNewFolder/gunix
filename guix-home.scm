;; Guix Home Configuration
;; This file configures a user environment with Zsh, Emacs, and various CLI tools.
;; Apply with: guix home reconfigure guix-home.scm

(use-modules (gnu home)
             (gnu home services)
             (gnu home services files)
             (gnu home services shells)
             (gnu home services shepherd)
             (gnu home services desktop)
             (gnu packages)
             (gnu packages emacs)
             (gnu packages emacs-xyz)
             (gnu packages shells)
             (gnu packages shellutils)
             (gnu packages version-control)
             (gnu packages rust-apps)
             (gnu packages search)
             (gnu packages compression)
             (gnu packages gnupg)
             (gnu packages ssh)
             (gnu packages curl)
             (gnu packages wget)
             (gnu packages tree-sitter)
             (gnu packages crypto)
             (gnu services)
             (guix gexp))

;;; Package Specifications
;;; ---------------------

(define %user-packages
  (list
   ;; Emacs with native compilation and pure GTK (Wayland support)
   emacs-pgtk

   ;; Shell
   zsh
   zsh-autosuggestions
   zsh-syntax-highlighting

   ;; Version Control
   git

   ;; CLI Tools - Rust-based alternatives
   ripgrep          ; Fast grep alternative (rg)
   fd               ; Fast find alternative
   bat              ; Cat with syntax highlighting

   ;; Additional CLI utilities
   tree             ; Directory tree viewer
   htop             ; Interactive process viewer
   curl             ; URL transfer utility
   wget             ; Network downloader
   gnupg            ; GNU Privacy Guard
   openssh          ; SSH client/server
   unzip            ; Archive extraction
   zip              ; Archive creation

   ;; Tree-sitter for Emacs
   tree-sitter

   ;; Emacs development environment packages
   emacs-envrc          ; direnv integration for Emacs (envrc.el)
   emacs-guix           ; Guix integration for Emacs
   direnv               ; Per-directory environment variables

   ;; Age secrets management
   age))                ; Simple, modern encryption tool
   ;; rage))            ; Rust implementation of age (commented out - may not be available)

;;; Environment Variables
;;; ---------------------

(define %environment-variables
  '(;; Locale settings
    ("LANG" . "en_US.UTF-8")
    ("LC_ALL" . "en_US.UTF-8")

    ;; SSL certificates (Guix-managed)
    ("SSL_CERT_FILE" . "$HOME/.guix-profile/etc/ssl/certs/ca-certificates.crt")
    ("SSL_CERT_DIR" . "$HOME/.guix-profile/etc/ssl/certs")

    ;; Editor configuration
    ("EDITOR" . "emacsclient -c -a emacs")
    ("VISUAL" . "emacsclient -c -a emacs")
    ("ALTERNATE_EDITOR" . "emacs")

    ;; Guix environment
    ("GUIX_PROFILE" . "$HOME/.guix-profile")
    ("GUIX_LOCPATH" . "$HOME/.guix-profile/lib/locale")

    ;; XDG directories
    ("XDG_DATA_DIRS" . "$HOME/.guix-profile/share:$XDG_DATA_DIRS")
    ("XDG_CONFIG_DIRS" . "$HOME/.guix-profile/etc/xdg:$XDG_CONFIG_DIRS")

    ;; Age secrets management
    ("AGE_IDENTITY_FILE" . "$HOME/.config/age/keys.txt")
    ("SOPS_AGE_KEY_FILE" . "$HOME/.config/age/keys.txt")

    ;; AI tool API keys (placeholders - set actual values in ~/.config/environment.d/)
    ("ANTHROPIC_API_KEY" . "")
    ("GEMINI_API_KEY" . "")
    ("BRAVE_API_KEY" . "")
    ("GITHUB_TOKEN" . "")

    ;; MCP (Model Context Protocol) configuration paths
    ("MCP_CONFIG_DIR" . "$HOME/.config/mcp")
    ("MCP_SERVERS_CONFIG" . "$HOME/.config/mcp/servers.json")

    ;; Ollama configuration
    ("OLLAMA_MODEL" . "qwen2.5:3b")
    ("OLLAMA_HOST" . "http://localhost:11434")

    ;; NixOS/Guix paths
    ("NIX_CONFIG_DIR" . "/etc/nixos")))

;;; Zsh Configuration
;;; -----------------

(define %zshrc-content
  "# Guix Home Zsh Configuration

# History settings
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY
setopt SHARE_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY

# Directory navigation
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

# Completion system
autoload -Uz compinit
compinit

# Enable completion caching
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Menu selection
zstyle ':completion:*' menu select

# Colored completion
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# Key bindings (emacs mode)
bindkey -e

# Useful key bindings
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char

# Aliases
alias ls='ls --color=auto'
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Use modern CLI tools if available
command -v bat &> /dev/null && alias cat='bat --style=plain'
command -v fd &> /dev/null && alias find='fd'
command -v rg &> /dev/null && alias grep='rg'

# Emacs integration
alias e='emacsclient -c -a emacs'
alias et='emacsclient -t -a emacs'
alias ed='emacs --daemon'
alias ek='emacsclient -e \"(kill-emacs)\"'

# Guix aliases
alias gup='guix pull && guix upgrade'
alias ghr='guix home reconfigure'
alias gsr='sudo guix system reconfigure'
alias gsearch='guix search'
alias gshow='guix show'
alias ginstall='guix install'
alias gremove='guix remove'
alias glist='guix package --list-installed'
alias ggc='guix gc'

# Load Guix profile
if [ -f ~/.guix-profile/etc/profile ]; then
    . ~/.guix-profile/etc/profile
fi

# Load additional completions from Guix
if [ -d ~/.guix-profile/share/zsh/site-functions ]; then
    fpath=(~/.guix-profile/share/zsh/site-functions $fpath)
fi

# Zsh plugins (from Guix packages)
if [ -f ~/.guix-profile/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source ~/.guix-profile/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

if [ -f ~/.guix-profile/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source ~/.guix-profile/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Simple prompt
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats ' (%b)'
setopt PROMPT_SUBST
PROMPT='%F{green}%n@%m%f:%F{blue}%~%f%F{yellow}${vcs_info_msg_0_}%f$ '
")

(define %zprofile-content
  "# Guix Home Zsh Profile
# This file is sourced for login shells

# Ensure Guix profile bin is first in PATH
export PATH=\"$HOME/.guix-profile/bin:$HOME/.local/bin:$PATH\"

# Source Guix profile
if [ -f ~/.guix-profile/etc/profile ]; then
    . ~/.guix-profile/etc/profile
fi

# Guix daemon socket
export GUIX_DAEMON_SOCKET=/var/guix/daemon-socket/socket
")

(define %zshenv-content
  "# Guix Home Zsh Environment
# This file is sourced for all shell invocations

# Ensure PATH is set for non-interactive shells too
export PATH=\"$HOME/.guix-profile/bin:$HOME/.local/bin:$PATH\"
")

;;; Emacs Configuration
;;; --------------------

(define %emacs-early-init-content
  ";; Guix Home Emacs Early Init
;; This file is loaded before init.el

;; Defer garbage collection during startup
(setq gc-cons-threshold most-positive-fixnum)

;; Disable package.el in favor of Guix-managed packages
(setq package-enable-at-startup nil)
")

(define %emacs-init-content
  ";; Guix Home Emacs Init
;; This file configures Emacs with Guix-managed packages

;; Reset GC threshold after startup
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 16 1024 1024))))

;;; envrc.el - direnv integration
;; Enable envrc-global-mode for per-directory environments
(when (require 'envrc nil t)
  (envrc-global-mode))

;;; Guix integration
(when (require 'guix nil t)
  ;; Guix REPL for package management from Emacs
  (setq guix-default-profile (expand-file-name \"~/.guix-profile\")))

;;; Basic settings
(setq inhibit-startup-screen t)
(setq make-backup-files nil)
(setq auto-save-default nil)
(setq create-lockfiles nil)

;; Enable useful modes
(column-number-mode 1)
(show-paren-mode 1)
(electric-pair-mode 1)
(global-auto-revert-mode 1)

;; Use spaces, not tabs
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
")

;;; Shepherd User Services
;;; ----------------------

(define (emacs-daemon-service)
  "Return a Shepherd service for the Emacs daemon."
  (shepherd-service
   (provision '(emacs))
   (documentation "Run Emacs as a daemon.")
   (start #~(make-forkexec-constructor
             (list #$(file-append emacs-pgtk "/bin/emacs")
                   "--fg-daemon")
             #:log-file (string-append (getenv "HOME") "/.local/var/log/emacs.log")))
   (stop #~(make-kill-destructor))
   (respawn? #t)))

;;; Home Configuration
;;; ------------------

(home-environment
 ;; Packages to install in the user profile
 (packages %user-packages)

 ;; Services that configure the home environment
 (services
  (list
   ;; Environment variables
   (simple-service 'guix-env-vars
                   home-environment-variables-service-type
                   %environment-variables)

   ;; Zsh shell configuration
   (service home-zsh-service-type
            (home-zsh-configuration
             (zshrc (list (plain-file "zshrc" %zshrc-content)))
             (zprofile (list (plain-file "zprofile" %zprofile-content)))
             (zshenv (list (plain-file "zshenv" %zshenv-content)))))

   ;; D-Bus session service (required by many desktop applications)
   (service home-dbus-service-type)

   ;; Emacs configuration files
   (simple-service 'emacs-config
                   home-files-service-type
                   (list
                    `(".emacs.d/early-init.el"
                      ,(plain-file "early-init.el" %emacs-early-init-content))
                    `(".emacs.d/init.el"
                      ,(plain-file "init.el" %emacs-init-content))))

   ;; Shepherd user services
   (service home-shepherd-service-type
            (home-shepherd-configuration
             (services
              (list (emacs-daemon-service))))))))
