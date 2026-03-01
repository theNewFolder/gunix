;; Guix Home Configuration
;; This file configures a user environment with Zsh, Emacs, and various CLI tools.
;; Apply with: guix home reconfigure guix-home.scm
;;
;; This configuration follows System Crafters patterns for a minimal,
;; keyboard-driven Emacs setup with native compilation support.
;; See: https://systemcrafters.net/
;;
;; ---------------------------------------------------------------------------
;; GNU Stow Integration
;; ---------------------------------------------------------------------------
;; For managing additional dotfiles outside of Guix Home, GNU Stow is recommended.
;; Stow creates symlinks from a central dotfiles directory to your home directory.
;;
;; Example usage:
;;   mkdir -p ~/dotfiles/{emacs,vim,git,tmux}/.config
;;   # Place your config files in the appropriate subdirectories
;;   cd ~/dotfiles && stow emacs vim git tmux
;;
;; This allows you to:
;;   - Version control all your dotfiles in one repository
;;   - Selectively enable/disable configurations per machine
;;   - Keep configurations that Guix Home doesn't manage (yet)
;;   - Override Guix Home managed files when needed
;;
;; Recommended directory structure:
;;   ~/dotfiles/
;;     emacs/.emacs.d/       # Additional Emacs configs (Stow manages these)
;;     emacs/.config/emacs/  # XDG-style Emacs config
;;     vim/.vimrc
;;     git/.gitconfig
;;     tmux/.tmux.conf
;;     scripts/bin/          # Personal scripts -> ~/bin
;;
;; Note: Guix Home manages ~/.emacs.d/init.el and early-init.el.
;; Use Stow for additional Emacs modules or override by symlinking.
;; ---------------------------------------------------------------------------

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
             (gnu packages fonts)
             (gnu packages terminals)
             (gnu packages xorg)              ;; For xhost and X11 utilities
             (gnu packages wm)                ;; Window manager utilities
             (gnu services)
             (guix gexp)
             ;; dwl-guile Wayland compositor home service
             (dwl-guile home-service)
             (dwl-guile patches)
             ;; Niri Wayland compositor home service
             (dwl-guile niri-service))

;;; Package Specifications
;;; ---------------------
;;; Following System Crafters philosophy: minimal, keyboard-driven, native compiled

(define %user-packages
  (list
   ;; =========================================================================
   ;; Emacs with native compilation and pure GTK (Wayland support)
   ;; =========================================================================
   emacs-pgtk

   ;; =========================================================================
   ;; System Crafters Essential Emacs Packages
   ;; =========================================================================
   ;; These packages form the core of a System Crafters-style Emacs setup
   ;; focused on discoverability, efficiency, and keyboard-driven workflows.

   ;; UI Enhancement
   emacs-doom-modeline       ; Fancy, minimal modeline (System Crafters staple)
   emacs-all-the-icons       ; Icon support for doom-modeline
   emacs-nerd-icons          ; Alternative icon set (newer)

   ;; Discoverability and Help
   emacs-which-key           ; Display available keybindings in popup
   emacs-helpful             ; Better *help* buffers with more context

   ;; Keybinding Management
   emacs-general             ; More convenient key definitions (general.el)

   ;; =========================================================================
   ;; Completion Framework (Vertico-based - System Crafters recommended)
   ;; =========================================================================
   emacs-vertico             ; VERTical Interactive COmpletion
   emacs-orderless           ; Orderless completion style
   emacs-marginalia          ; Annotations in the minibuffer
   emacs-consult             ; Consulting completing-read
   emacs-embark              ; Contextual actions (like right-click menu)
   emacs-corfu               ; Completion at point (in-buffer completion)
   emacs-cape                ; Completion At Point Extensions

   ;; =========================================================================
   ;; Org Mode and Knowledge Management
   ;; =========================================================================
   emacs-org                 ; Org mode (latest from Guix, not built-in)
   emacs-org-roam            ; Zettelkasten-style note-taking
   emacs-org-roam-ui         ; Web UI for org-roam graph visualization
   emacs-org-appear          ; Auto-toggle org markup visibility
   emacs-org-modern          ; Modern Org mode UI enhancements
   emacs-org-superstar       ; Fancy bullets for org headings (or use org-modern)
   emacs-org-download        ; Drag-and-drop images into org
   emacs-visual-fill-column  ; Wrap text at fill-column in visual-line-mode

   ;; =========================================================================
   ;; Version Control - Magit (System Crafters essential)
   ;; =========================================================================
   emacs-magit               ; Git interface (the killer app for Emacs)
   emacs-git-gutter          ; Show git diff in the fringe
   emacs-git-timemachine     ; Walk through git history
   emacs-git-link            ; Get GitHub/GitLab URLs for current location
   emacs-forge               ; Work with GitHub/GitLab from Magit

   ;; =========================================================================
   ;; Evil Mode (Vi keybindings) - OPTIONAL
   ;; =========================================================================
   ;; Uncomment these if you prefer Vim-style keybindings
   ;; System Crafters has excellent Evil mode tutorials
   ;;
   ;; emacs-evil               ; Extensible vi layer
   ;; emacs-evil-collection    ; Evil bindings for many modes
   ;; emacs-evil-nerd-commenter ; Comment/uncomment with Evil
   ;; emacs-evil-surround      ; Surround text objects
   ;; emacs-undo-tree          ; Visualize undo history (useful with Evil)

   ;; =========================================================================
   ;; Development - LSP Ready Configuration
   ;; =========================================================================
   emacs-eglot               ; Built-in LSP client (Emacs 29+, lighter than lsp-mode)
   ;; emacs-lsp-mode          ; Full-featured LSP client (alternative to eglot)
   ;; emacs-lsp-ui            ; UI enhancements for lsp-mode
   ;; emacs-lsp-treemacs      ; Treemacs integration for lsp-mode
   emacs-flycheck            ; On-the-fly syntax checking
   emacs-yasnippet           ; Template system
   emacs-yasnippet-snippets  ; Collection of snippets

   ;; Tree-sitter for better syntax highlighting (Emacs 29+)
   emacs-treesit-auto        ; Automatic tree-sitter grammar installation

   ;; Project management
   emacs-projectile          ; Project interaction library
   emacs-perspective         ; Named workspaces

   ;; =========================================================================
   ;; Language-specific packages
   ;; =========================================================================
   ;; Scheme/Guile (for Guix hacking)
   emacs-geiser              ; Scheme interaction
   emacs-geiser-guile        ; Guile support for Geiser

   ;; Nix (for NixOS integration)
   emacs-nix-mode            ; Nix expression editing

   ;; Markdown
   emacs-markdown-mode       ; Markdown editing

   ;; YAML/JSON
   emacs-yaml-mode           ; YAML editing
   emacs-json-mode           ; JSON editing

   ;; =========================================================================
   ;; Quality of Life
   ;; =========================================================================
   emacs-rainbow-delimiters  ; Colorful parentheses
   emacs-hl-todo             ; Highlight TODO/FIXME/etc
   emacs-ws-butler           ; Trim trailing whitespace unobtrusively
   emacs-smartparens         ; Automatic pairing of delimiters
   emacs-wgrep               ; Writable grep buffers

   ;; =========================================================================
   ;; Terminal and Shell
   ;; =========================================================================
   emacs-vterm               ; Fast, fully-featured terminal emulator
   emacs-eshell-prompt-extras ; Fancy eshell prompts

   ;; =========================================================================
   ;; EXWM - Emacs X Window Manager
   ;; =========================================================================
   ;; EXWM runs inside Emacs and manages X11 windows as Emacs buffers.
   ;; When used with dwl-guile (Wayland), EXWM runs via XWayland within
   ;; an Emacs frame, providing a nested WM experience.
   emacs-exwm                ; Emacs X Window Manager
   emacs-xelb                ; X protocol Emacs Lisp Binding (required by EXWM)

   ;; =========================================================================
   ;; Themes (System Crafters favorites)
   ;; =========================================================================
   emacs-doom-themes         ; Collection of themes from Doom Emacs
   emacs-ef-themes           ; Elegant and accessible themes by Prot
   emacs-modus-themes        ; Highly accessible themes by Prot (built-in Emacs 28+)
   emacs-catppuccin-theme    ; Soothing pastel theme

   ;; =========================================================================
   ;; Shell
   ;; =========================================================================
   zsh
   zsh-autosuggestions
   zsh-syntax-highlighting

   ;; =========================================================================
   ;; Version Control
   ;; =========================================================================
   git

   ;; =========================================================================
   ;; CLI Tools - Rust-based alternatives
   ;; =========================================================================
   ripgrep          ; Fast grep alternative (rg)
   fd               ; Fast find alternative
   bat              ; Cat with syntax highlighting

   ;; =========================================================================
   ;; Additional CLI utilities
   ;; =========================================================================
   tree             ; Directory tree viewer
   htop             ; Interactive process viewer
   curl             ; URL transfer utility
   wget             ; Network downloader
   gnupg            ; GNU Privacy Guard
   openssh          ; SSH client/server
   unzip            ; Archive extraction
   zip              ; Archive creation

   ;; =========================================================================
   ;; Tree-sitter for Emacs
   ;; =========================================================================
   tree-sitter

   ;; =========================================================================
   ;; Emacs development environment packages
   ;; =========================================================================
   emacs-envrc          ; direnv integration for Emacs (envrc.el)
   emacs-guix           ; Guix integration for Emacs
   direnv               ; Per-directory environment variables

   ;; =========================================================================
   ;; Age secrets management
   ;; =========================================================================
   age                  ; Simple, modern encryption tool

   ;; =========================================================================
   ;; Fonts (System Crafters recommendations)
   ;; =========================================================================
   font-fira-code       ; Excellent coding font with ligatures
   font-iosevka         ; Highly customizable coding font
   font-jetbrains-mono  ; JetBrains Mono font
   font-google-noto))   ; Comprehensive Unicode coverage

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

;;; Compositor Selection
;;; -------------------
;;; Choose between dwl-guile and Niri Wayland compositors.
;;; Set to 'dwl-guile or 'niri to select which compositor to configure.
;;; Both can be installed; only the chosen one will be auto-started.

(define %selected-compositor 'dwl-guile)  ; Change to 'niri to use Niri instead

;;; dwl-guile Configuration (Wayland Compositor)
;;; --------------------------------------------
;;; dwl-guile is a Guile-configurable Wayland compositor based on dwl (dwm for Wayland).
;;; This configuration provides keybindings, rules, and appearance settings with
;;; full Emacs integration. dwl-guile acts as the outer compositor, while EXWM
;;; can run inside Emacs to manage X11 windows via XWayland.
;;;
;;; Architecture:
;;;   dwl-guile (Wayland compositor)
;;;     -> Emacs (pgtk, native Wayland client)
;;;        -> EXWM (manages XWayland windows inside Emacs)
;;;
;;; For more info: https://github.com/engstrand-config/dwl-guile

(define %dwl-guile-config
  '(;; =========================================================================
    ;; General Settings
    ;; =========================================================================
    ;; Do not use default keybindings (we define our own Emacs-style bindings)
    ;; (setq inhibit-defaults? #t)

    ;; Border width in pixels
    (setq border-px 2)

    ;; Gap between windows (comfortable spacing for Emacs frames)
    (setq gaps-inner 6)
    (setq gaps-outer 6)

    ;; Focus follows mouse (Emacs-friendly - point follows mouse can be enabled in Emacs)
    (setq focus-follows-mouse? #t)

    ;; =========================================================================
    ;; Colors (RGBA format: 0.0-1.0 for each channel)
    ;; =========================================================================
    ;; Modus Vivendi color scheme for consistency with Emacs theme
    ;; Border color for focused windows (Modus Vivendi cyan accent)
    (setq border-color-focus '(0.0 0.74 0.82 1.0))    ; #00bcd4 cyan

    ;; Border color for unfocused windows (subtle gray from Modus Vivendi)
    (setq border-color-unfocus '(0.25 0.25 0.28 1.0)) ; #404045

    ;; Background color (Modus Vivendi background)
    (setq root-color '(0.0 0.0 0.0 1.0))              ; #000000

    ;; =========================================================================
    ;; Tags (Workspaces) - Emacs-style naming
    ;; =========================================================================
    ;; Define 9 tags/workspaces with meaningful names
    ;; These can be accessed via SUPER+1-9 or from Emacs via dwl-guile IPC
    (setq tags '("1:emacs" "2:web" "3:term" "4:code" "5:docs" "6:media" "7:chat" "8:misc" "9:sys"))

    ;; =========================================================================
    ;; Window Rules
    ;; =========================================================================
    ;; Rules for specific applications
    ;; Emacs gets priority placement; EXWM-managed windows float by default
    (set-rules
     ;; Emacs always starts on tag 1 (main workspace)
     (dwl-rule #:id "emacs" #:tags #b000000001)
     (dwl-rule #:id "Emacs" #:tags #b000000001)

     ;; Float dialog windows
     (dwl-rule #:title "Open File" #:floating? #t)
     (dwl-rule #:title "Save File" #:floating? #t)
     (dwl-rule #:title "Save As" #:floating? #t)
     (dwl-rule #:title "Preferences" #:floating? #t)
     (dwl-rule #:title "Properties" #:floating? #t)
     (dwl-rule #:title "About" #:floating? #t)

     ;; Float Emacs minibuffer frames and popups
     (dwl-rule #:title "*Completions*" #:floating? #t)
     (dwl-rule #:title " *which-key*" #:floating? #t)

     ;; Web browsers on tag 2
     (dwl-rule #:id "firefox" #:tags #b000000010)
     (dwl-rule #:id "chromium" #:tags #b000000010)
     (dwl-rule #:id "qutebrowser" #:tags #b000000010)

     ;; Terminals on tag 3
     (dwl-rule #:id "foot" #:tags #b000000100)
     (dwl-rule #:id "Alacritty" #:tags #b000000100)
     (dwl-rule #:id "kitty" #:tags #b000000100))

    ;; =========================================================================
    ;; Keybindings - Emacs-Integrated Design
    ;; =========================================================================
    ;; Modifier key: SUPER (s- in Emacs notation)
    ;; Design principle: SUPER for compositor, C- and M- reserved for Emacs
    ;; All bindings are also exposed to Emacs via dwl-guile IPC for seamless control

    ;; -------------------------------------------------------------------------
    ;; SUPER+e: Emacs (Primary Application)
    ;; -------------------------------------------------------------------------
    ;; SUPER+e opens emacsclient (connects to running Emacs daemon)
    (set-keys SUPER "e"
              (lambda () (dwl:spawn "emacsclient" "-c" "-a" "emacs")))

    ;; SUPER+SHIFT+e starts a fresh Emacs instance
    (set-keys SUPER SHIFT "e"
              (lambda () (dwl:spawn "emacs")))

    ;; SUPER+CTRL+e restarts Emacs daemon
    (set-keys SUPER CTRL "e"
              (lambda ()
                (dwl:spawn "emacsclient" "-e" "(kill-emacs)")
                (dwl:spawn "emacs" "--daemon")))

    ;; -------------------------------------------------------------------------
    ;; Application Launchers
    ;; -------------------------------------------------------------------------
    (set-keys SUPER "Return"
              (lambda () (dwl:spawn "foot")))                    ; Terminal (foot)

    (set-keys SUPER SHIFT "Return"
              (lambda () (dwl:spawn "emacsclient" "-c" "-e" "(vterm)"))) ; Emacs terminal

    (set-keys SUPER "d"
              (lambda () (dwl:spawn "wofi" "--show" "drun")))    ; App launcher

    (set-keys SUPER "p"
              (lambda () (dwl:spawn "wofi" "--show" "run")))     ; Command runner

    ;; Emacs-style M-x equivalent for system commands
    (set-keys SUPER "x"
              (lambda () (dwl:spawn "emacsclient" "-c" "-e" "(call-interactively 'execute-extended-command)")))

    ;; -------------------------------------------------------------------------
    ;; Window Management - Emacs-style Keybindings
    ;; -------------------------------------------------------------------------
    ;; SUPER+q: Close window (like Emacs C-x 0)
    (set-keys SUPER "q"
              (lambda () (dwl:kill-client)))

    ;; SUPER+o: Other window (cycle focus, like Emacs C-x o)
    (set-keys SUPER "o"
              (lambda () (dwl:focus-stack 1)))

    ;; SUPER+SHIFT+o: Reverse cycle
    (set-keys SUPER SHIFT "o"
              (lambda () (dwl:focus-stack -1)))

    ;; SUPER+j/k: Vim-style navigation (also works)
    (set-keys SUPER "j"
              (lambda () (dwl:focus-stack 1)))

    (set-keys SUPER "k"
              (lambda () (dwl:focus-stack -1)))

    ;; SUPER+h/l: Resize master area
    (set-keys SUPER "h"
              (lambda () (dwl:change-master-factor -0.05)))

    (set-keys SUPER "l"
              (lambda () (dwl:change-master-factor 0.05)))

    ;; SUPER+CTRL+Return: Swap with master (zoom)
    (set-keys SUPER CTRL "Return"
              (lambda () (dwl:zoom)))

    ;; SUPER+Tab: Previous tag (like Emacs previous-buffer)
    (set-keys SUPER "Tab"
              (lambda () (dwl:view-previous)))

    ;; -------------------------------------------------------------------------
    ;; Layout Control
    ;; -------------------------------------------------------------------------
    ;; SUPER+t: Tiled layout
    (set-keys SUPER "t"
              (lambda () (dwl:set-layout "tile")))

    ;; SUPER+f: Toggle fullscreen (like Emacs toggle-frame-fullscreen)
    (set-keys SUPER "f"
              (lambda () (dwl:toggle-fullscreen)))

    ;; SUPER+SHIFT+f: Toggle floating
    (set-keys SUPER SHIFT "f"
              (lambda () (dwl:toggle-floating)))

    ;; SUPER+m: Monocle layout (one window fills screen)
    (set-keys SUPER "m"
              (lambda () (dwl:set-layout "monocle")))

    ;; SUPER+space: Toggle between layouts
    (set-keys SUPER "space"
              (lambda () (dwl:cycle-layout)))

    ;; -------------------------------------------------------------------------
    ;; Tag/Workspace Switching (SUPER + 1-9)
    ;; -------------------------------------------------------------------------
    ;; These workspaces are also accessible from Emacs via dwl-guile integration
    (set-keys SUPER "1" (lambda () (dwl:view #b000000001)))  ; emacs
    (set-keys SUPER "2" (lambda () (dwl:view #b000000010)))  ; web
    (set-keys SUPER "3" (lambda () (dwl:view #b000000100)))  ; term
    (set-keys SUPER "4" (lambda () (dwl:view #b000001000)))  ; code
    (set-keys SUPER "5" (lambda () (dwl:view #b000010000)))  ; docs
    (set-keys SUPER "6" (lambda () (dwl:view #b000100000)))  ; media
    (set-keys SUPER "7" (lambda () (dwl:view #b001000000)))  ; chat
    (set-keys SUPER "8" (lambda () (dwl:view #b010000000)))  ; misc
    (set-keys SUPER "9" (lambda () (dwl:view #b100000000)))  ; sys
    (set-keys SUPER "0" (lambda () (dwl:view-all)))          ; View all tags

    ;; -------------------------------------------------------------------------
    ;; Move Window to Tag (SUPER + SHIFT + 1-9)
    ;; -------------------------------------------------------------------------
    (set-keys SUPER SHIFT "1" (lambda () (dwl:tag #b000000001)))
    (set-keys SUPER SHIFT "2" (lambda () (dwl:tag #b000000010)))
    (set-keys SUPER SHIFT "3" (lambda () (dwl:tag #b000000100)))
    (set-keys SUPER SHIFT "4" (lambda () (dwl:tag #b000001000)))
    (set-keys SUPER SHIFT "5" (lambda () (dwl:tag #b000010000)))
    (set-keys SUPER SHIFT "6" (lambda () (dwl:tag #b000100000)))
    (set-keys SUPER SHIFT "7" (lambda () (dwl:tag #b001000000)))
    (set-keys SUPER SHIFT "8" (lambda () (dwl:tag #b010000000)))
    (set-keys SUPER SHIFT "9" (lambda () (dwl:tag #b100000000)))

    ;; -------------------------------------------------------------------------
    ;; Multi-Monitor Control
    ;; -------------------------------------------------------------------------
    ;; SUPER+,/. : Focus previous/next monitor
    (set-keys SUPER "comma"
              (lambda () (dwl:focus-monitor -1)))

    (set-keys SUPER "period"
              (lambda () (dwl:focus-monitor 1)))

    ;; SUPER+SHIFT+,/. : Move window to previous/next monitor
    (set-keys SUPER SHIFT "comma"
              (lambda () (dwl:tag-monitor -1)))

    (set-keys SUPER SHIFT "period"
              (lambda () (dwl:tag-monitor 1)))

    ;; -------------------------------------------------------------------------
    ;; Session Control
    ;; -------------------------------------------------------------------------
    ;; SUPER+SHIFT+q: Quit dwl-guile
    (set-keys SUPER SHIFT "q"
              (lambda () (dwl:quit)))

    ;; SUPER+SHIFT+r: Reload configuration
    (set-keys SUPER SHIFT "r"
              (lambda () (dwl:reload-config)))

    ;; SUPER+CTRL+l: Lock screen (requires swaylock or similar)
    (set-keys SUPER CTRL "l"
              (lambda () (dwl:spawn "swaylock" "-f" "-c" "000000")))

    ;; -------------------------------------------------------------------------
    ;; Emacs Integration Bindings
    ;; -------------------------------------------------------------------------
    ;; These bindings launch specific Emacs functionality

    ;; SUPER+b: Switch buffer (via Emacs consult-buffer)
    (set-keys SUPER "b"
              (lambda () (dwl:spawn "emacsclient" "-c" "-e" "(call-interactively 'consult-buffer)")))

    ;; SUPER+g: Magit status
    (set-keys SUPER "g"
              (lambda () (dwl:spawn "emacsclient" "-c" "-e" "(magit-status)")))

    ;; SUPER+n: Org-roam find node
    (set-keys SUPER "n"
              (lambda () (dwl:spawn "emacsclient" "-c" "-e" "(org-roam-node-find)")))

    ;; SUPER+a: Org agenda
    (set-keys SUPER "a"
              (lambda () (dwl:spawn "emacsclient" "-c" "-e" "(org-agenda)")))

    ;; SUPER+s: Consult ripgrep (search)
    (set-keys SUPER "s"
              (lambda () (dwl:spawn "emacsclient" "-c" "-e" "(consult-ripgrep)")))

    ;; =========================================================================
    ;; Startup Hook - Initialize Emacs-centric Environment
    ;; =========================================================================
    (add-hook! dwl:startup-hook
               (lambda ()
                 ;; Start status bar
                 (dwl:spawn "waybar")

                 ;; Start notification daemon
                 (dwl:spawn "mako")

                 ;; Start Emacs daemon if not running
                 (dwl:spawn "emacsclient" "-e" "(message \"Emacs ready\")"
                            "||" "emacs" "--daemon")

                 ;; Open main Emacs frame after a short delay (allow daemon to start)
                 ;; This frame will host EXWM for managing XWayland windows
                 (dwl:spawn "sleep" "1" "&&" "emacsclient" "-c")

                 ;; Optional: Set wallpaper
                 ;; (dwl:spawn "swaybg" "-i" "/path/to/wallpaper.jpg" "-m" "fill")
                 ))))

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
;;; Following System Crafters patterns for a minimal, keyboard-driven setup
;;; with native compilation support and LSP-ready configuration.

(define %emacs-early-init-content
  ";; -*- lexical-binding: t; -*-
;; Guix Home Emacs Early Init
;; System Crafters Style Configuration
;; This file is loaded before init.el

;; =============================================================================
;; Performance Optimizations for Startup
;; =============================================================================

;; Defer garbage collection during startup for faster load time
;; This significantly reduces startup time
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

;; Prevent unwanted runtime compilation for native-comp
(setq native-comp-deferred-compilation nil)
(setq native-comp-jit-compilation nil)

;; Disable package.el in favor of Guix-managed packages
;; Guix handles all package management - no need for package.el
(setq package-enable-at-startup nil)
(setq package-archives nil)

;; Prevent the glimpse of un-styled Emacs by disabling UI elements early
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)

;; Disable startup screen and messages
(setq inhibit-startup-message t
      inhibit-startup-echo-area-message user-login-name
      inhibit-default-init t
      initial-major-mode 'fundamental-mode
      initial-scratch-message nil)

;; Prevent flash of unstyled modeline at startup
(setq-default mode-line-format nil)

;; Disable bidirectional text scanning for performance
(setq-default bidi-display-reordering 'left-to-right
              bidi-paragraph-direction 'left-to-right)

;; Reduce rendering/line scan work for non-minibuffers
(setq bidi-inhibit-bpa t)

;; More performant scrolling over unfontified regions
(setq fast-but-imprecise-scrolling t)

;; Don't compact font caches during GC
(setq inhibit-compacting-font-caches t)

;; Ignore X resources
(advice-add #'x-apply-session-resources :override #'ignore)

;; Frame configuration for better appearance
(push '(internal-border-width . 8) default-frame-alist)
(push '(undecorated-round . t) default-frame-alist)  ; macOS style rounded corners
")

(define %emacs-init-content
  ";; -*- lexical-binding: t; -*-
;; Guix Home Emacs Init
;; System Crafters Style Configuration
;; =============================================================================
;; This configuration follows System Crafters patterns:
;; - Minimal and keyboard-driven
;; - Native compilation support
;; - LSP-ready with eglot
;; - Vertico-based completion
;; - Org mode and org-roam for knowledge management
;; =============================================================================

;; =============================================================================
;; Startup Performance - Reset GC
;; =============================================================================

;; Reset GC threshold after startup for smooth operation
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 16 1024 1024)  ; 16MB
                  gc-cons-percentage 0.1)))

;; Profile startup time (shown in *Messages*)
(add-hook 'emacs-startup-hook
          (lambda ()
            (message \"Emacs loaded in %s with %d garbage collections.\"
                     (format \"%.2f seconds\"
                             (float-time
                              (time-subtract after-init-time before-init-time)))
                     gcs-done)))

;; =============================================================================
;; Native Compilation Settings
;; =============================================================================

(when (featurep 'native-compile)
  (setq native-comp-async-report-warnings-errors 'silent)
  (setq native-comp-deferred-compilation t)
  (setq native-comp-speed 2))

;; =============================================================================
;; Basic Settings
;; =============================================================================

;; User identity
(setq user-full-name \"Your Name\"
      user-mail-address \"your@email.com\")

;; Disable various UI elements
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(tooltip-mode -1)

;; Better defaults
(setq inhibit-startup-screen t
      make-backup-files nil
      auto-save-default nil
      create-lockfiles nil
      use-short-answers t                     ; y or n instead of yes or no
      confirm-kill-emacs 'y-or-n-p
      ring-bell-function 'ignore              ; No bell
      visible-bell nil)

;; Better scrolling
(setq scroll-margin 3
      scroll-conservatively 101
      scroll-preserve-screen-position t
      auto-window-vscroll nil)

;; Line numbers
(global-display-line-numbers-mode 1)
(setq display-line-numbers-type 'relative)  ; Relative line numbers (Evil-friendly)

;; Disable line numbers for some modes
(dolist (mode '(org-mode-hook
                term-mode-hook
                shell-mode-hook
                vterm-mode-hook
                eshell-mode-hook
                treemacs-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; Enable useful modes
(column-number-mode 1)
(show-paren-mode 1)
(electric-pair-mode 1)
(global-auto-revert-mode 1)
(global-hl-line-mode 1)
(delete-selection-mode 1)
(save-place-mode 1)
(recentf-mode 1)
(winner-mode 1)

;; Indentation
(setq-default indent-tabs-mode nil
              tab-width 4)

;; Fill column
(setq-default fill-column 80)

;; UTF-8 everywhere
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)

;; Whitespace handling
(setq-default show-trailing-whitespace nil)
(add-hook 'prog-mode-hook (lambda () (setq show-trailing-whitespace t)))

;; =============================================================================
;; Font Configuration
;; =============================================================================

;; Set default font (adjust to your preference)
(set-face-attribute 'default nil
                    :family \"Iosevka\"
                    :height 120
                    :weight 'regular)

;; Set fixed-pitch (monospace) font
(set-face-attribute 'fixed-pitch nil
                    :family \"Iosevka\"
                    :height 120)

;; Set variable-pitch (proportional) font
(set-face-attribute 'variable-pitch nil
                    :family \"Noto Sans\"
                    :height 120
                    :weight 'regular)

;; =============================================================================
;; Theme Configuration
;; =============================================================================

;; Load a theme (choose one)
;; Modus themes are built-in and highly accessible
(load-theme 'modus-vivendi t)  ; Dark theme
;; (load-theme 'modus-operandi t)  ; Light theme

;; Or use doom-themes (uncomment to use)
;; (when (require 'doom-themes nil t)
;;   (setq doom-themes-enable-bold t
;;         doom-themes-enable-italic t)
;;   (load-theme 'doom-one t)
;;   (doom-themes-org-config))

;; =============================================================================
;; Doom Modeline
;; =============================================================================

(when (require 'doom-modeline nil t)
  (setq doom-modeline-height 35
        doom-modeline-bar-width 4
        doom-modeline-buffer-file-name-style 'truncate-upto-project
        doom-modeline-minor-modes nil
        doom-modeline-major-mode-icon t
        doom-modeline-buffer-state-icon t
        doom-modeline-buffer-modification-icon t)
  (doom-modeline-mode 1))

;; All the icons (required for doom-modeline icons)
(when (require 'all-the-icons nil t)
  ;; Run M-x all-the-icons-install-fonts once to install fonts
  )

;; =============================================================================
;; Which-Key - Display Available Keybindings
;; =============================================================================

(when (require 'which-key nil t)
  (setq which-key-idle-delay 0.5
        which-key-popup-type 'side-window
        which-key-side-window-location 'bottom
        which-key-side-window-max-height 0.25)
  (which-key-mode))

;; =============================================================================
;; Helpful - Better Help Buffers
;; =============================================================================

(when (require 'helpful nil t)
  (global-set-key (kbd \"C-h f\") #'helpful-callable)
  (global-set-key (kbd \"C-h v\") #'helpful-variable)
  (global-set-key (kbd \"C-h k\") #'helpful-key)
  (global-set-key (kbd \"C-h x\") #'helpful-command))

;; =============================================================================
;; General.el - Keybinding Management
;; =============================================================================

(when (require 'general nil t)
  ;; Create a leader key definer (SPC for normal mode in Evil, C-c for Emacs)
  (general-create-definer my-leader-def
    :prefix \"C-c\")

  ;; Global leader keybindings
  (my-leader-def
    \"f\" '(:ignore t :which-key \"files\")
    \"ff\" '(find-file :which-key \"find file\")
    \"fr\" '(recentf-open-files :which-key \"recent files\")
    \"fs\" '(save-buffer :which-key \"save file\")

    \"b\" '(:ignore t :which-key \"buffers\")
    \"bb\" '(switch-to-buffer :which-key \"switch buffer\")
    \"bk\" '(kill-current-buffer :which-key \"kill buffer\")
    \"bi\" '(ibuffer :which-key \"ibuffer\")

    \"w\" '(:ignore t :which-key \"windows\")
    \"wv\" '(split-window-right :which-key \"split vertical\")
    \"ws\" '(split-window-below :which-key \"split horizontal\")
    \"wd\" '(delete-window :which-key \"delete window\")
    \"wm\" '(delete-other-windows :which-key \"maximize\")

    \"g\" '(:ignore t :which-key \"git\")
    \"gg\" '(magit-status :which-key \"magit status\")
    \"gb\" '(magit-blame :which-key \"magit blame\")
    \"gl\" '(magit-log-current :which-key \"magit log\")

    \"o\" '(:ignore t :which-key \"org\")
    \"oa\" '(org-agenda :which-key \"agenda\")
    \"oc\" '(org-capture :which-key \"capture\")
    \"ol\" '(org-store-link :which-key \"store link\")

    \"n\" '(:ignore t :which-key \"notes/roam\")
    \"nf\" '(org-roam-node-find :which-key \"find node\")
    \"ni\" '(org-roam-node-insert :which-key \"insert node\")
    \"nb\" '(org-roam-buffer-toggle :which-key \"roam buffer\")
    \"nd\" '(org-roam-dailies-capture-today :which-key \"daily note\")

    \"t\" '(:ignore t :which-key \"toggles\")
    \"tt\" '(load-theme :which-key \"load theme\")
    \"tl\" '(display-line-numbers-mode :which-key \"line numbers\")
    \"tw\" '(whitespace-mode :which-key \"whitespace\")))

;; =============================================================================
;; Completion Framework - Vertico, Orderless, Marginalia, Consult, Embark
;; =============================================================================

;; Vertico - VERTical Interactive COmpletion
(when (require 'vertico nil t)
  (setq vertico-cycle t
        vertico-resize nil
        vertico-count 15)
  (vertico-mode))

;; Orderless - Flexible completion style
(when (require 'orderless nil t)
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))

;; Marginalia - Rich annotations in the minibuffer
(when (require 'marginalia nil t)
  (setq marginalia-annotators '(marginalia-annotators-heavy marginalia-annotators-light nil))
  (marginalia-mode))

;; Consult - Consulting completing-read
(when (require 'consult nil t)
  (global-set-key (kbd \"C-s\") #'consult-line)
  (global-set-key (kbd \"C-x b\") #'consult-buffer)
  (global-set-key (kbd \"M-g g\") #'consult-goto-line)
  (global-set-key (kbd \"M-g M-g\") #'consult-goto-line)
  (global-set-key (kbd \"M-s r\") #'consult-ripgrep)
  (global-set-key (kbd \"M-s f\") #'consult-find)
  (setq consult-narrow-key \"<\"))

;; Embark - Contextual actions
(when (require 'embark nil t)
  (global-set-key (kbd \"C-.\") #'embark-act)
  (global-set-key (kbd \"M-.\") #'embark-dwim)
  (global-set-key (kbd \"C-h B\") #'embark-bindings)
  (setq prefix-help-command #'embark-prefix-help-command))

;; Embark-Consult integration
(when (and (featurep 'embark) (featurep 'consult))
  (require 'embark-consult nil t))

;; =============================================================================
;; In-Buffer Completion - Corfu and Cape
;; =============================================================================

(when (require 'corfu nil t)
  (setq corfu-cycle t
        corfu-auto t
        corfu-auto-delay 0.2
        corfu-auto-prefix 2
        corfu-quit-no-match 'separator)
  (global-corfu-mode))

(when (require 'cape nil t)
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-keyword))

;; =============================================================================
;; Magit - Git Interface
;; =============================================================================

(when (require 'magit nil t)
  (global-set-key (kbd \"C-x g\") #'magit-status)
  (global-set-key (kbd \"C-x M-g\") #'magit-dispatch)
  (global-set-key (kbd \"C-c M-g\") #'magit-file-dispatch)
  (setq magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;; Git gutter
(when (require 'git-gutter nil t)
  (global-git-gutter-mode +1)
  (setq git-gutter:update-interval 0.5))

;; Git timemachine
(when (require 'git-timemachine nil t))

;; =============================================================================
;; Org Mode Configuration
;; =============================================================================

(when (require 'org nil t)
  ;; Basic settings
  (setq org-directory \"~/org\"
        org-default-notes-file (concat org-directory \"/inbox.org\")
        org-agenda-files (list org-directory)
        org-ellipsis \" ▾\"
        org-hide-emphasis-markers t
        org-pretty-entities t
        org-startup-indented t
        org-startup-folded 'content
        org-log-done 'time
        org-log-into-drawer t
        org-return-follows-link t)

  ;; Source block settings
  (setq org-src-fontify-natively t
        org-src-tab-acts-natively t
        org-src-preserve-indentation t
        org-edit-src-content-indentation 0)

  ;; TODO keywords
  (setq org-todo-keywords
        '((sequence \"TODO(t)\" \"NEXT(n)\" \"HOLD(h@/!)\" \"|\" \"DONE(d!)\" \"CANCELLED(c@)\")))

  ;; Capture templates
  (setq org-capture-templates
        '((\"t\" \"Task\" entry (file+headline org-default-notes-file \"Tasks\")
           \"* TODO %?\\n%U\\n%a\" :empty-lines 1)
          (\"n\" \"Note\" entry (file+headline org-default-notes-file \"Notes\")
           \"* %?\\n%U\" :empty-lines 1)
          (\"j\" \"Journal\" entry (file+datetree (concat org-directory \"/journal.org\"))
           \"* %?\\n%U\" :empty-lines 1))))

;; Org-modern for better visual appearance
(when (require 'org-modern nil t)
  (add-hook 'org-mode-hook #'org-modern-mode)
  (add-hook 'org-agenda-finalize-hook #'org-modern-agenda))

;; Org-appear - auto-toggle markup visibility
(when (require 'org-appear nil t)
  (setq org-appear-autoemphasis t
        org-appear-autolinks t
        org-appear-autosubmarkers t)
  (add-hook 'org-mode-hook #'org-appear-mode))

;; Visual fill column for better text editing
(when (require 'visual-fill-column nil t)
  (setq visual-fill-column-width 100
        visual-fill-column-center-text t)
  (add-hook 'org-mode-hook #'visual-fill-column-mode))

;; =============================================================================
;; Org-Roam - Zettelkasten Note-Taking
;; =============================================================================

(when (require 'org-roam nil t)
  (setq org-roam-directory (file-truename \"~/org/roam\")
        org-roam-db-location (concat org-roam-directory \"/org-roam.db\")
        org-roam-completion-everywhere t)

  ;; Org-roam capture templates
  (setq org-roam-capture-templates
        '((\"d\" \"default\" plain \"%?\"
           :target (file+head \"%<%Y%m%d%H%M%S>-${slug}.org\"
                              \"#+title: ${title}\\n#+date: %U\\n#+filetags: \\n\\n\")
           :unnarrowed t)
          (\"r\" \"reference\" plain \"%?\"
           :target (file+head \"references/%<%Y%m%d%H%M%S>-${slug}.org\"
                              \"#+title: ${title}\\n#+date: %U\\n#+filetags: :reference:\\n\\n\")
           :unnarrowed t)))

  ;; Dailies configuration
  (setq org-roam-dailies-directory \"daily/\")
  (setq org-roam-dailies-capture-templates
        '((\"d\" \"default\" entry \"* %?\"
           :target (file+head \"%<%Y-%m-%d>.org\"
                              \"#+title: %<%Y-%m-%d>\\n\\n\"))))

  ;; Sync the database
  (org-roam-db-autosync-mode))

;; Org-roam-ui for graph visualization
(when (require 'org-roam-ui nil t)
  (setq org-roam-ui-sync-theme t
        org-roam-ui-follow t
        org-roam-ui-update-on-save t))

;; =============================================================================
;; LSP Configuration - Eglot (Built-in LSP Client)
;; =============================================================================

(when (require 'eglot nil t)
  ;; Automatically start eglot for these modes
  (add-hook 'python-mode-hook #'eglot-ensure)
  (add-hook 'rust-mode-hook #'eglot-ensure)
  (add-hook 'go-mode-hook #'eglot-ensure)
  (add-hook 'typescript-mode-hook #'eglot-ensure)
  (add-hook 'js-mode-hook #'eglot-ensure)
  (add-hook 'c-mode-hook #'eglot-ensure)
  (add-hook 'c++-mode-hook #'eglot-ensure)

  ;; Performance settings
  (setq eglot-events-buffer-size 0)  ; Disable events logging for performance
  (setq eglot-autoshutdown t)        ; Shutdown server when last buffer is killed
  (setq eglot-sync-connect nil)      ; Don't block on connection

  ;; Custom server configurations can be added here
  ;; (add-to-list 'eglot-server-programs
  ;;              '(nix-mode . (\"nil\")))  ; Nix language server
  )

;; Flycheck - On-the-fly syntax checking
(when (require 'flycheck nil t)
  (setq flycheck-emacs-lisp-load-path 'inherit)
  (global-flycheck-mode))

;; Treesit-auto - Automatic tree-sitter grammar management
(when (require 'treesit-auto nil t)
  (setq treesit-auto-install 'prompt)
  (global-treesit-auto-mode))

;; =============================================================================
;; Projectile - Project Management
;; =============================================================================

(when (require 'projectile nil t)
  (setq projectile-project-search-path '(\"~/projects\" \"~/code\")
        projectile-switch-project-action #'projectile-dired
        projectile-completion-system 'default)
  (projectile-mode +1)
  (define-key projectile-mode-map (kbd \"C-c p\") 'projectile-command-map))

;; =============================================================================
;; Rainbow Delimiters and Other Visual Aids
;; =============================================================================

(when (require 'rainbow-delimiters nil t)
  (add-hook 'prog-mode-hook #'rainbow-delimiters-mode))

(when (require 'hl-todo nil t)
  (global-hl-todo-mode))

;; =============================================================================
;; Smartparens - Automatic Delimiter Pairing
;; =============================================================================

(when (require 'smartparens nil t)
  (require 'smartparens-config nil t)
  (add-hook 'prog-mode-hook #'smartparens-mode)
  (add-hook 'text-mode-hook #'smartparens-mode))

;; =============================================================================
;; YASnippet - Template System
;; =============================================================================

(when (require 'yasnippet nil t)
  (setq yas-snippet-dirs '(\"~/.emacs.d/snippets\"))
  (yas-global-mode 1))

;; =============================================================================
;; VTerm - Terminal Emulator
;; =============================================================================

(when (require 'vterm nil t)
  (setq vterm-max-scrollback 10000)
  (global-set-key (kbd \"C-c t\") #'vterm))

;; =============================================================================
;; Guix Integration
;; =============================================================================

(when (require 'guix nil t)
  (setq guix-default-profile (expand-file-name \"~/.guix-profile\")))

;; =============================================================================
;; Direnv Integration
;; =============================================================================

(when (require 'envrc nil t)
  (envrc-global-mode))

;; =============================================================================
;; Geiser - Scheme/Guile Interaction
;; =============================================================================

(when (require 'geiser nil t)
  (setq geiser-default-implementation 'guile
        geiser-active-implementations '(guile)))

(when (require 'geiser-guile nil t)
  (setq geiser-guile-binary \"guile\"))

;; =============================================================================
;; Evil Mode (Optional) - Vi Keybindings
;; =============================================================================
;; Uncomment this section if you prefer Vim-style keybindings

;; (when (require 'evil nil t)
;;   (setq evil-want-integration t
;;         evil-want-keybinding nil
;;         evil-want-C-u-scroll t
;;         evil-want-C-i-jump nil
;;         evil-respect-visual-line-mode t
;;         evil-undo-system 'undo-tree)
;;   (evil-mode 1)
;;
;;   ;; Use visual line motions even outside visual-line-mode
;;   (evil-global-set-key 'motion \"j\" 'evil-next-visual-line)
;;   (evil-global-set-key 'motion \"k\" 'evil-previous-visual-line)
;;
;;   ;; Evil collection for better Evil support in various modes
;;   (when (require 'evil-collection nil t)
;;     (evil-collection-init))
;;
;;   ;; Evil surround
;;   (when (require 'evil-surround nil t)
;;     (global-evil-surround-mode 1))
;;
;;   ;; Evil commentary
;;   (when (require 'evil-nerd-commenter nil t)
;;     (global-set-key (kbd \"M-;\") 'evilnc-comment-or-uncomment-lines))
;;
;;   ;; Undo-tree (recommended with Evil)
;;   (when (require 'undo-tree nil t)
;;     (global-undo-tree-mode)
;;     (setq undo-tree-auto-save-history nil)))

;; =============================================================================
;; Custom File
;; =============================================================================

;; Keep customize settings in a separate file
(setq custom-file (expand-file-name \"custom.el\" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))

;; =============================================================================
;; Server Mode
;; =============================================================================

;; Start server if not already running (for emacsclient)
(unless (daemonp)
  (require 'server)
  (unless (server-running-p)
    (server-start)))

;; =============================================================================
;; EXWM - Emacs X Window Manager Configuration
;; =============================================================================
;; EXWM runs inside Emacs and manages X11 windows as Emacs buffers.
;; When used with dwl-guile (Wayland), EXWM manages XWayland windows
;; within the Emacs frame, creating a nested window manager setup.
;;
;; Architecture:
;;   dwl-guile (outer compositor) -> Emacs (pgtk) -> EXWM (inner WM)
;;
;; EXWM keybindings use s- (Super) prefix to avoid conflicts with
;; dwl-guile which also uses Super. EXWM bindings only apply when
;; an EXWM buffer has focus.

(when (require 'exwm nil t)
  ;; ---------------------------------------------------------------------------
  ;; Workspace Configuration
  ;; ---------------------------------------------------------------------------
  ;; Number of EXWM workspaces (inside Emacs, separate from dwl-guile tags)
  (setq exwm-workspace-number 4)

  ;; Show workspace indicator in modeline
  (setq exwm-workspace-show-all-buffers t)
  (setq exwm-layout-show-all-buffers t)

  ;; Workspace names
  (setq exwm-workspace-index-map
        (lambda (index)
          (let ((named-workspaces [\"main\" \"web\" \"term\" \"misc\"]))
            (if (< index (length named-workspaces))
                (elt named-workspaces index)
              (number-to-string index)))))

  ;; ---------------------------------------------------------------------------
  ;; Buffer Naming
  ;; ---------------------------------------------------------------------------
  ;; Use class name + title for buffer names
  (defun my/exwm-update-class ()
    (exwm-workspace-rename-buffer exwm-class-name))

  (defun my/exwm-update-title ()
    (pcase exwm-class-name
      (\"firefox\" (exwm-workspace-rename-buffer (format \"Firefox: %s\" exwm-title)))
      (\"chromium-browser\" (exwm-workspace-rename-buffer (format \"Chromium: %s\" exwm-title)))
      (_ (exwm-workspace-rename-buffer (format \"%s: %s\" exwm-class-name exwm-title)))))

  (add-hook 'exwm-update-class-hook #'my/exwm-update-class)
  (add-hook 'exwm-update-title-hook #'my/exwm-update-title)

  ;; ---------------------------------------------------------------------------
  ;; EXWM Keybindings
  ;; ---------------------------------------------------------------------------
  ;; These bindings work when EXWM buffers have focus

  ;; Global keys (always available, even in X windows)
  (setq exwm-input-global-keys
        `(;; Workspace switching with s-1 through s-4
          ([?\\s-1] . (lambda () (interactive) (exwm-workspace-switch 0)))
          ([?\\s-2] . (lambda () (interactive) (exwm-workspace-switch 1)))
          ([?\\s-3] . (lambda () (interactive) (exwm-workspace-switch 2)))
          ([?\\s-4] . (lambda () (interactive) (exwm-workspace-switch 3)))

          ;; s-r: Reset/rename
          ([?\\s-r] . exwm-reset)

          ;; s-w: Switch workspace interactively
          ([?\\s-w] . exwm-workspace-switch)

          ;; s-&: Launch application
          ([?\\s-&] . (lambda (command)
                        (interactive (list (read-shell-command \"$ \")))
                        (start-process-shell-command command nil command)))

          ;; s-b: Switch buffer
          ([?\\s-b] . consult-buffer)

          ;; s-d: Toggle between line-mode and char-mode
          ([?\\s-d] . exwm-input-toggle-keyboard)))

  ;; Prefix keys that should be sent to Emacs (not X windows)
  (setq exwm-input-prefix-keys
        '(?\\C-x
          ?\\C-u
          ?\\C-h
          ?\\C-g
          ?\\M-x
          ?\\M-`
          ?\\M-&
          ?\\M-:
          ?\\C-\\M-j))

  ;; ---------------------------------------------------------------------------
  ;; Simulation Keys
  ;; ---------------------------------------------------------------------------
  ;; Make X applications behave more like Emacs
  (setq exwm-input-simulation-keys
        '(;; Movement
          ([?\\C-b] . [left])
          ([?\\C-f] . [right])
          ([?\\C-p] . [up])
          ([?\\C-n] . [down])
          ([?\\C-a] . [home])
          ([?\\C-e] . [end])
          ([?\\M-v] . [prior])
          ([?\\C-v] . [next])
          ([?\\C-d] . [delete])
          ([?\\C-k] . [S-end delete])
          ;; Cut/copy/paste
          ([?\\C-w] . [?\\C-x])
          ([?\\M-w] . [?\\C-c])
          ([?\\C-y] . [?\\C-v])
          ;; Search
          ([?\\C-s] . [?\\C-f])
          ;; Undo/Redo
          ([?\\C-/] . [?\\C-z])
          ([?\\C-?] . [?\\C-y])
          ;; Save
          ([?\\C-x ?\\C-s] . [?\\C-s])))

  ;; ---------------------------------------------------------------------------
  ;; Multi-Monitor Support
  ;; ---------------------------------------------------------------------------
  (require 'exwm-randr nil t)
  (when (featurep 'exwm-randr)
    (setq exwm-randr-workspace-monitor-plist
          '(0 \"eDP-1\" 1 \"HDMI-1\" 2 \"eDP-1\" 3 \"HDMI-1\"))

    (defun my/exwm-randr-screen-change ()
      (start-process-shell-command
       \"xrandr\" nil \"xrandr --output eDP-1 --auto --output HDMI-1 --auto --right-of eDP-1\"))

    (add-hook 'exwm-randr-screen-change-hook #'my/exwm-randr-screen-change)
    (exwm-randr-enable))

  ;; ---------------------------------------------------------------------------
  ;; System Tray
  ;; ---------------------------------------------------------------------------
  (require 'exwm-systemtray nil t)
  (when (featurep 'exwm-systemtray)
    (setq exwm-systemtray-height 22)
    (exwm-systemtray-enable))

  ;; ---------------------------------------------------------------------------
  ;; EXWM + dwl-guile Integration Hooks
  ;; ---------------------------------------------------------------------------
  (defun my/exwm-init-hook ()
    (message \"EXWM initialized inside dwl-guile\")
    (setq exwm-manage-force-tiling t))

  (add-hook 'exwm-init-hook #'my/exwm-init-hook)

  (defun my/exwm-manage-hook ()
    (when (member exwm-class-name '(\"mpv\" \"feh\" \"Sxiv\"))
      (exwm-floating-toggle-floating)))

  (add-hook 'exwm-manage-finish-hook #'my/exwm-manage-hook)

  ;; ---------------------------------------------------------------------------
  ;; Enable EXWM (only under X/XWayland)
  ;; ---------------------------------------------------------------------------
  (when (and (getenv \"DISPLAY\")
             (not (string-empty-p (getenv \"DISPLAY\"))))
    (exwm-enable)))

;; =============================================================================
;; dwl-guile Integration Functions
;; =============================================================================
;; Functions for interacting with dwl-guile from within Emacs

(defun dwl-guile-eval (expr)
  \"Evaluate a Guile expression in dwl-guile.\"
  (interactive \"sGuile expression: \")
  (shell-command (format \"dwl-guile -e '%s'\" expr)))

(defun dwl-guile-view-tag (tag)
  \"Switch to a dwl-guile tag (1-9).\"
  (interactive \"nTag (1-9): \")
  (dwl-guile-eval (format \"(dwl:view #b%09b)\" (ash 1 (1- tag)))))

(defun dwl-guile-move-to-tag (tag)
  \"Move current window to a dwl-guile tag (1-9).\"
  (interactive \"nTag (1-9): \")
  (dwl-guile-eval (format \"(dwl:tag #b%09b)\" (ash 1 (1- tag)))))

(defun dwl-guile-toggle-fullscreen ()
  \"Toggle fullscreen in dwl-guile.\"
  (interactive)
  (dwl-guile-eval \"(dwl:toggle-fullscreen)\"))

(defun dwl-guile-reload-config ()
  \"Reload dwl-guile configuration.\"
  (interactive)
  (dwl-guile-eval \"(dwl:reload-config)\"))

;; Keybindings for dwl-guile control from Emacs (use C-c d prefix)
(global-set-key (kbd \"C-c d 1\") (lambda () (interactive) (dwl-guile-view-tag 1)))
(global-set-key (kbd \"C-c d 2\") (lambda () (interactive) (dwl-guile-view-tag 2)))
(global-set-key (kbd \"C-c d 3\") (lambda () (interactive) (dwl-guile-view-tag 3)))
(global-set-key (kbd \"C-c d 4\") (lambda () (interactive) (dwl-guile-view-tag 4)))
(global-set-key (kbd \"C-c d 5\") (lambda () (interactive) (dwl-guile-view-tag 5)))
(global-set-key (kbd \"C-c d 6\") (lambda () (interactive) (dwl-guile-view-tag 6)))
(global-set-key (kbd \"C-c d 7\") (lambda () (interactive) (dwl-guile-view-tag 7)))
(global-set-key (kbd \"C-c d 8\") (lambda () (interactive) (dwl-guile-view-tag 8)))
(global-set-key (kbd \"C-c d 9\") (lambda () (interactive) (dwl-guile-view-tag 9)))
(global-set-key (kbd \"C-c d f\") #'dwl-guile-toggle-fullscreen)
(global-set-key (kbd \"C-c d r\") #'dwl-guile-reload-config)
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
              (list (emacs-daemon-service)))))

   ;; =========================================================================
   ;; Wayland Compositor Service Selection
   ;; =========================================================================
   ;; This configuration supports two Wayland compositors:
   ;; 1. dwl-guile (default): Traditional tiling compositor with Guile scripting
   ;; 2. Niri (optional): Scrollable tiling with smooth animations
   ;;
   ;; To use dwl-guile (current selection):
   ;;   - Log into a TTY (not a graphical session)
   ;;   - dwl-guile will auto-start if auto-start? is #t
   ;;   - Or start manually: herd start dwl-guile
   ;;
   ;; To switch to Niri:
   ;;   1. Change %selected-compositor to 'niri at the top of this file
   ;;   2. Ensure niri package is available (may need custom package definition)
   ;;   3. Run: guix home reconfigure guix-home.scm
   ;;
   ;; Control with herd:
   ;;   herd start dwl-guile / herd start niri
   ;;   herd stop dwl-guile / herd stop niri
   ;;   herd restart dwl-guile / herd restart niri
   ;; =========================================================================
   ;; dwl-guile + EXWM Integration
   ;; =========================================================================
   ;; This configuration sets up dwl-guile as the outer Wayland compositor
   ;; with XWayland support enabled. EXWM runs inside Emacs to manage
   ;; X11 applications that run under XWayland.
   ;;
   ;; Architecture:
   ;;   dwl-guile (Wayland) <-- manages native Wayland windows
   ;;     |
   ;;     +-> Emacs (pgtk)  <-- runs as native Wayland client
   ;;     |     |
   ;;     |     +-> EXWM    <-- manages XWayland windows inside Emacs buffers
   ;;     |
   ;;     +-> XWayland      <-- provides X11 compatibility layer
   ;;           |
   ;;           +-> X11 apps (run inside EXWM-managed Emacs buffers)
   ;;
   ;; Note: Niri uses the same keybindings and configuration structure as
   ;; dwl-guile for consistency. See dotfiles/niri/.config/niri/config.kdl
   ;; =========================================================================
   (service home-dwl-guile-service-type
            (home-dwl-guile-configuration
             ;; Enable XWayland support for EXWM and X11 application compatibility
             ;; EXWM requires XWayland to manage X11 windows within Emacs
             (package
              (patch-dwl-guile-package dwl-guile
                                       #:patches (list %patch-xwayland)))

             ;; Enable native Qt rendering in Wayland (installs qtwayland)
             (native-qt? #t)

             ;; Auto-start dwl-guile on first TTY login
             ;; Set to #f if you prefer to start manually or use a display manager
             (auto-start? #f)

             ;; Automatically reload config when it changes
             ;; This allows live configuration updates without restarting
             (reload-config-on-change? #t)

             ;; Command to run after dwl-guile starts
             ;; Starts foot terminal server and Emacs daemon
             (startup-command "foot --server <&- & emacs --daemon <&-")

             ;; Additional environment variables for EXWM/XWayland integration
             (environment-variables
              '(;; Tell XWayland applications where to connect
                ("DISPLAY" . ":0")
                ;; Ensure Emacs uses native Wayland
                ("EMACS_NATIVE_WAYLAND" . "1")))

             ;; Use our comprehensive Emacs-integrated dwl-guile configuration
             (config %dwl-guile-config)))))))
