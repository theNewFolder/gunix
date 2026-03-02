{ config, pkgs, lib, ... }:

{
  # ============================================================================
  # HOME MANAGER CONFIGURATION FOR GUX
  # ============================================================================

  # Home Manager version
  home.username = "gux";
  home.homeDirectory = "/home/gux";
  home.stateVersion = "24.05";

  # ============================================================================
  # SESSION VARIABLES - WAYLAND ENVIRONMENT
  # ============================================================================

  home.sessionVariables = {
    # Wayland-first setup
    GDK_BACKEND = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    XDG_SESSION_TYPE = "wayland";

    # EWM Wayland Manager session
    XDG_CURRENT_DESKTOP = "ewm";
    EWM_SESSION = "1";

    # Locale settings (Unit 6)
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";

    # Editor configuration (Unit 6)
    EDITOR = "emacsclient -c -a emacs";
    VISUAL = "emacsclient -c -a emacs";
    ALTERNATE_EDITOR = "emacs";

    # Pager for man pages (Unit 6)
    PAGER = "less";

    # Age secrets management (Unit 6 - may be used in Unit 7)
    AGE_IDENTITY_FILE = "$HOME/.config/age/keys.txt";
    SOPS_AGE_KEY_FILE = "$HOME/.config/age/keys.txt";

    # MCP (Model Context Protocol) configuration paths (Unit 6 - may be used in Unit 7)
    MCP_CONFIG_DIR = "$HOME/.config/mcp";
    MCP_SERVERS_CONFIG = "$HOME/.config/mcp/servers.json";

    # Ollama configuration (Unit 6 - may be used in Unit 7)
    OLLAMA_MODEL = "qwen2.5:3b";
    OLLAMA_HOST = "http://localhost:11434";

    # NixOS paths (Unit 6)
    NIX_CONFIG_DIR = "/etc/nixos";
  };

  # ============================================================================
  # PACKAGES - CORE BASE PACKAGES (Unit 2) + DEVELOPMENT TOOLS (Unit 3)
  # ============================================================================

  home.packages = with pkgs; [
    # ========================================================================
    # Core Utilities
    # ========================================================================
    coreutils        # GNU core utilities (ls, cp, mv, etc.)
    findutils        # find, xargs, locate
    grep             # GNU grep
    sed              # GNU sed stream editor
    gawk             # GNU awk
    which            # Locate commands
    less             # Pager for viewing files
    file             # Determine file types

    # ========================================================================
    # Shell and Terminal
    # ========================================================================
    bash             # GNU Bourne-Again Shell
    zsh              # Z shell
    bash-completion  # Programmable completion for Bash
    readline         # Line editing library

    # ========================================================================
    # Text Editors
    # ========================================================================
    vim              # Vi IMproved text editor
    nano             # Simple text editor

    # ========================================================================
    # Version Control
    # ========================================================================
    git              # Distributed version control
    git-lfs          # Git Large File Storage

    # ========================================================================
    # Network Tools
    # ========================================================================
    curl             # Command-line URL transfer tool
    wget             # Network file retriever
    openssh          # SSH connectivity tools
    nss-certs        # CA certificates for HTTPS

    # ========================================================================
    # Compression and Archiving
    # ========================================================================
    tar              # Tape archiver
    gzip             # GNU compression utility
    bzip2            # Block-sorting compressor
    xz               # LZMA compression
    unzip            # ZIP archive extractor
    zip              # ZIP archive creator

    # ========================================================================
    # Build Tools
    # ========================================================================
    make             # GNU Make build tool
    gcc              # GNU Compiler Collection

    # ========================================================================
    # System Information and Monitoring
    # ========================================================================
    htop             # Interactive process viewer
    procps           # Process utilities (ps, top, etc.)
    tree             # Directory listing as tree

    # ========================================================================
    # File Management
    # ========================================================================
    rsync            # Fast file copying/syncing
    fd               # Simple, fast find alternative
    ripgrep          # Fast recursive grep

    # ========================================================================
    # Documentation
    # ========================================================================
    man-db           # Manual page utilities
    texinfo          # GNU documentation system (includes info)

    # ========================================================================
    # EWM - Emacs Wayland Manager
    # ========================================================================
    ewm-core         # Wayland compositor dynamic module
    emacs-ewm        # Emacs integration for EWM

    # ========================================================================
    # Language-Specific Compilers and Interpreters (Unit 3)
    # ========================================================================
    gcc-toolchain    # GNU C/C++ Compiler with support libraries
    gccgo            # Go compiler from GCC
    rustup           # Rust toolchain installer
    rust             # Rust programming language compiler
    clang            # LLVM C/C++ compiler
    llvm             # LLVM compiler infrastructure
    go               # Go programming language
    python3          # Python interpreter
    python3Packages.pip   # Python package installer
    nodejs           # Node.js JavaScript runtime
    ruby             # Ruby programming language
    ghc              # Glasgow Haskell Compiler
    nasm             # Netwide Assembler
    perl             # Perl programming language

    # ========================================================================
    # Build Tools and Package Managers (Unit 3)
    # ========================================================================
    cmake            # Cross-platform build system
    meson            # Fast build system
    ninja            # Small build system
    autoconf         # GNU Autoconf macro package
    automake         # GNU Automake build tool
    libtool          # GNU Libtool for building libraries
    pkg-config       # Helper tool for build flags
    cargo            # Rust package manager
    bundler          # Ruby dependency manager

    # ========================================================================
    # Debuggers and Profiling Tools (Unit 3)
    # ========================================================================
    gdb              # GNU Debugger
    lldb             # LLVM Debugger
    valgrind         # Memory debugging and profiling
    perf             # Linux profiling with performance counters
    strace           # System call tracer
    ltrace           # Library call tracer
    rr               # Record and replay debugger

    # ========================================================================
    # LSP (Language Server Protocol) Servers (Unit 3)
    # ========================================================================
    clangd           # C/C++/Objective-C language server
    rust-analyzer    # Rust language server
    gopls            # Go language server
    python3Packages.pylsp  # Python language server
    nodePackages.typescript-language-server  # TypeScript/JavaScript LSP
    texlab           # LaTeX language server
    nil              # Nix language server

    # ========================================================================
    # Build and Compilation Support (Unit 3)
    # ========================================================================
    binutils         # Binary utilities (ld, as, nm, objdump, etc.)
    gfortran         # GNU Fortran Compiler
    ccls             # C/C++ language server using clang

    # ========================================================================
    # Version Control Tools (Unit 3)
    # ========================================================================
    mercurial        # Distributed version control
    diffutils        # GNU diff utilities
    patch            # GNU patch utility

    # ========================================================================
    # Documentation and Source Tools (Unit 3)
    # ========================================================================
    ctags            # Generate tag files for source navigation
    universal-ctags  # Universal Ctags (improved ctags)
    cscope           # Code browser and search tool
    doxygen          # Documentation generator

    # ========================================================================
    # Code Quality and Testing (Unit 3)
    # ========================================================================
    shellcheck       # Shell script static analyzer
    hadolint         # Dockerfile linter
    yamllint         # YAML linter
    pylint           # Python code analyzer

    # ========================================================================
    # System Libraries and Headers (Unit 3)
    # ========================================================================
    glibc            # GNU C Library
    linux-headers    # Linux kernel headers
    libffi           # Foreign function interface library
    openssl          # Secure Sockets Layer and cryptography libraries

    # ========================================================================
    # Additional Utilities (Unit 3)
    # ========================================================================
    man-pages        # Linux man pages
  ];

  # ============================================================================
  # PROGRAMS - HOME MANAGER MODULES
  # ============================================================================

  # ZSH Shell configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableVteIntegration = true;

    # History configuration (Unit 6)
    history = {
      size = 50000;
      extended = true;
      path = "$HOME/.zsh_history";
      share = true;
      ignoreAllDups = true;
      ignoreSpace = true;
    };

    # Enable plugins (Unit 6)
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;

    # Shell aliases - organized by category (Unit 6)
    shellAliases = {
      # Navigation shortcuts
      ll = "ls -lah";
      la = "ls -A";
      l = "ls -1";

      # Safe operations
      rm = "rm -i";
      cp = "cp -i";
      mv = "mv -i";

      # Nix translations (Guix → Nix) - Unit 6
      nup = "nix flake update";                    # guix pull → nix flake update
      nsr = "nix shell";                           # guix shell → nix shell
      nsp = "nix search nixpkgs";                  # gsearch → nix search nixpkgs
      nr = "nix run";                              # ghr → nix run

      # Emacs shortcuts - Unit 6
      e = "emacsclient -c -a emacs";               # Emacs GUI
      et = "emacsclient -t -a emacs";              # Emacs terminal

      # Utilities
      grep = "grep --color=auto";
      ls = "ls --color=auto";
    };

    # Emacs key bindings and additional configuration (Unit 6)
    initExtra = ''
      # Use Emacs key bindings
      bindkey -e

      # Basic options
      setopt INTERACTIVE_COMMENTS EXTENDED_GLOB
      unsetopt BEEP

      # Less options
      export LESS='-R -S -X -F'

      # Prompt setup
      autoload -Uz prompt_subst
      setopt PROMPT_SUBST
      PROMPT='%F{blue}%n@%m%f %F{cyan}%~%f %# '
      RPROMPT='%F{gray}%*%f'

      # Wayland session
      export WAYLAND_DISPLAY=wayland-0

      # Source local zsh config if it exists
      [ -f ~/.zshrc.local ] && source ~/.zshrc.local
    '';
  };

  # Foot terminal configuration
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "Iosevka:size=12";
        dpi-aware = "yes";
        scrollback-lines = 1000;
        scrollback-indicator = "both";
        bell = "visual";
      };

      mouse = {
        hide-when-typing = "yes";
      };

      colors = {
        foreground = "d8d8d8";
        background = "1e1e1e";

        # Solarized Dark palette
        palette = [
          "2e3440"  # black
          "bf616a"  # red
          "a3be8c"  # green
          "ebcb8b"  # yellow
          "81a1c1"  # blue
          "b48ead"  # magenta
          "88c0d0"  # cyan
          "eceff4"  # white
          "4c566a"  # bright black
          "bf616a"  # bright red
          "a3be8c"  # bright green
          "ebcb8b"  # bright yellow
          "81a1c1"  # bright blue
          "b48ead"  # bright magenta
          "8fbcbb"  # bright cyan
          "eceff4"  # bright white
        ];

        # Cursor styling
        "cursor.style" = "block";
        "cursor.color" = "81a1c1";
        "cursor.blink" = "yes";

        # Selection colors
        "selection.foreground" = "2e3440";
        "selection.background" = "81a1c1";
      };

      tweak = {
        force-underline-thickness = 0;
        force-box-drawing-chars = "no";
      };

      "key-bindings" = {
        clipboard-copy = "ctrl+shift+c";
        clipboard-paste = "ctrl+shift+v";
        "primary-paste" = "shift+insert";
        font-increase = "ctrl+plus";
        font-decrease = "ctrl+minus";
        font-reset = "ctrl+0";
        search-start = "ctrl+shift+f";
        quit = "ctrl+shift+q";
      };

      url = {
        launch = "emacsclient -c {url}";
        osc8-underline = "url-mode";
      };

      wayland = {};
    };
  };

  # Waybar configuration
  programs.waybar = {
    enable = true;
    systemd = {
      enable = true;
    };
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        spacing = 10;
        margin-top = 0;
        margin-left = 0;
        margin-right = 0;
        margin-bottom = 0;

        modules-left = [ "sway/workspaces" "sway/mode" ];
        modules-center = [ "clock" ];
        modules-right = [ "pulseaudio" "network" "battery" "backlight" ];

        # Workspace indicator
        "sway/workspaces" = {
          format = "{name}";
          on-click = "activate";
          all-outputs = false;
        };

        # Sway mode
        "sway/mode" = {
          format = "<span style=\"italic\">{}</span>";
        };

        # System clock
        clock = {
          interval = 60;
          format = "  {:%H:%M}";
          tooltip-format = "{:%A, %B %d, %Y}";
        };

        # Audio/Volume control
        pulseaudio = {
          scroll-step = 5;
          format = "{icon} {volume}%";
          format-muted = "  muted";
          format-icons = {
            default = [ "" "" "" ];
          };
          on-click = "pavucontrol";
          on-click-right = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
        };

        # Network status
        network = {
          interval = 5;
          format-wifi = "  {essid} ({signalStrength}%)";
          format-ethernet = "  Ethernet";
          format-disconnected = "  Offline";
          tooltip-format = "IP: {ipaddr}";
        };

        # Battery indicator
        battery = {
          interval = 30;
          states = {
            good = 75;
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = " {capacity}%";
          format-plugged = " {capacity}%";
          format-icons = [ "" "" "" "" "" ];
          tooltip-format = "{time}";
        };

        # Backlight control
        backlight = {
          device = "intel_backlight";
          format = "{icon} {percent}%";
          format-icons = [ "🌑" "🌒" "🌓" "🌔" "🌕" ];
          on-scroll-up = "brightnessctl set +5%";
          on-scroll-down = "brightnessctl set 5%-";
          smooth-scrolling-threshold = 1;
        };
      };
    };

    style = ''
      * {
        border: none;
        border-radius: 0;
        font-family: "Iosevka", monospace;
        font-size: 12px;
        min-height: 0;
      }

      window#waybar {
        background-color: #1e1e1e;
        color: #d8d8d8;
      }

      #workspaces button {
        padding: 0 5px;
        background-color: transparent;
        color: #d8d8d8;
      }

      #workspaces button.active {
        background-color: #81a1c1;
        color: #1e1e1e;
      }

      #clock,
      #pulseaudio,
      #network,
      #battery,
      #backlight {
        padding: 0 10px;
        color: #81a1c1;
      }
    '';
  };

  # Git configuration
  # ============================================================================
  # GIT CONFIGURATION (Unit 6)
  # ============================================================================
  programs.git = {
    enable = true;
    userName = "gux";
    userEmail = "gux@gunix";

    extraConfig = {
      core = {
        editor = "emacsclient -c -a emacs";
        pager = "less";
        whitespace = "trailing-space,space-before-tab";
        excludesfile = "~/.gitignore_global";
      };
      init = {
        defaultBranch = "main";
      };
      pull = {
        rebase = true;
      };
      push = {
        default = "current";
      };
      status = {
        short = true;
        showUntrackedFiles = "all";
      };
      diff = {
        colorMoved = "dimmed-zebra";
        context = 3;
      };
      merge = {
        tool = "emacs";
        conflictstyle = "zdiff3";
      };
      color = {
        ui = "auto";
        branch = "auto";
        diff = "auto";
        status = "auto";
      };
      log = {
        decorate = "short";
        abbrevCommit = true;
      };
      commit = {
        verbose = true;
      };
    };

    aliases = {
      st = "status";
      co = "checkout";
      br = "branch";
      ci = "commit";
      unstage = "reset HEAD --";
      last = "log -1 HEAD";
      visual = "log --graph --oneline --all";
      amend = "commit --amend --no-edit";
      fixup = "commit --fixup";
      squash = "commit --squash";
      aliases = "config --get-regexp alias";
    };
  };

  # Dircolors for colorized ls output
  programs.dircolors.enable = true;

  # ============================================================================
  # SERVICES - WAYLAND SERVICES
  # ============================================================================

  # PulseAudio daemon
  services.pulseaudio = {
    enable = true;
  };

  # Notification daemon (mako)
  services.mako = {
    enable = true;
    defaultTimeout = 5000;
    ignoreTimeout = false;
    font = "Iosevka 12";
    backgroundColor = "#1e1e1e";
    textColor = "#d8d8d8";
    borderColor = "#81a1c1";
  };

  # ============================================================================
  # XDG CONFIGURATION
  # ============================================================================

  xdg.enable = true;

  # XDG base directories
  xdg.userDirs = {
    desktop = "$HOME/Desktop";
    documents = "$HOME/Documents";
    download = "$HOME/Downloads";
    music = "$HOME/Music";
    pictures = "$HOME/Pictures";
    publicShare = "$HOME/Public";
    templates = "$HOME/Templates";
    videos = "$HOME/Videos";
  };

  # ============================================================================
  # DOTFILES - MANUAL FILE MANAGEMENT
  # ============================================================================

  # For waybar and other configs that are in dotfiles, we rely on:
  # - User manually stowing dotfiles: cd dotfiles && stow waybar foot zsh git
  # - Or using Home Manager's file system for simple configs

  # Create config directories
  home.file.".config/mako/.gitkeep".text = "";
  home.file.".config/wofi/.gitkeep".text = "";
  home.file.".config/sway/.gitkeep".text = "";

  # ============================================================================
  # FONTS CONFIGURATION
  # ============================================================================

  # Fonts are provided through home.packages above
  # No need for system-wide font configuration since we manage via Home Manager

  # ============================================================================
  # EWM SESSION LAUNCHER SCRIPT
  # ============================================================================

  home.file.".nix-profile/bin/ewm-session" = {
    executable = true;
    text = ''
      #!/bin/sh
      # EWM Session Launcher
      # Sets up environment variables and launches Emacs with EWM support

      set -euo pipefail

      # EWM session environment variables
      export XDG_SESSION_TYPE=wayland
      export XDG_CURRENT_DESKTOP=ewm
      export EWM_SESSION=1
      export GDK_BACKEND=wayland
      export MOZ_ENABLE_WAYLAND=1
      export QT_QPA_PLATFORM=wayland

      # Ensure /dev/dri is accessible (GPU passthrough)
      if [ ! -e /dev/dri/card0 ]; then
        echo "Warning: /dev/dri/card0 not found. GPU passthrough may not be available." >&2
      fi

      # Launch Emacs with EWM module support
      exec emacs "$@"
    '';
  };

  # ============================================================================
  # EMACS CONFIGURATION (Unit 5)
  # ============================================================================
  # Emacs with pgtk build for Wayland support, native compilation enabled
  # All 50+ packages from manifest-emacs.scm migrated to nixpkgs equivalents

  programs.emacs = {
    enable = true;
    package = pkgs.emacs-pgtk;

    extraPackages = epkgs: with epkgs; [
      # UI Enhancement
      doom-modeline all-the-icons nerd-icons which-key helpful general

      # Completion Framework (Vertico Stack)
      vertico orderless marginalia consult embark corfu cape

      # Org Mode and Knowledge Management
      org org-roam org-roam-ui org-appear org-modern org-superstar
      org-download visual-fill-column

      # Version Control (Magit and Git Integration)
      magit git-gutter git-timemachine git-link forge

      # Development Tools
      eglot flycheck yasnippet yasnippet-snippets treesit-auto
      projectile perspective

      # Language Support
      geiser geiser-guile nix-mode markdown-mode yaml-mode json-mode
      rust-mode go-mode python-mode

      # Code Quality and Formatting
      rainbow-delimiters hl-todo ws-butler smartparens wgrep

      # Terminal and Shell Integration
      vterm eshell-prompt-extras

      # Theming and Aesthetics
      doom-themes ef-themes modus-themes catppuccin-theme

      # Evil Mode (Vim Keybindings) - Optional
      evil evil-collection evil-surround undo-tree

      # Direnv Integration
      envrc
    ];

    # Point to our Elisp configuration files
    initFile = /home/gux/gunix/home/emacs/init.el;
    earlyInitFile = /home/gux/gunix/home/emacs/early-init.el;
  };

  # ============================================================================
  # ALLOW UNFREE PACKAGES (if needed for some applications)
  # ============================================================================

  # Note: If unfree packages are needed, nixpkgs allowUnfree would be set
  # in the flake.nix or home manager configuration
}
