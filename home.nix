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
  # SESSION VARIABLES - ENVIRONMENT & WAYLAND
  # ============================================================================

  home.sessionVariables = {
    # ========================================================================
    # Locale settings
    # ========================================================================
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";

    # ========================================================================
    # Wayland-first setup
    # ========================================================================
    GDK_BACKEND = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    XDG_SESSION_TYPE = "wayland";

    # ========================================================================
    # EWM Wayland Manager session (Emacs Wayland Manager)
    # ========================================================================
    XDG_CURRENT_DESKTOP = "ewm";
    EWM_SESSION = "1";

    # ========================================================================
    # Editor and pager configuration
    # ========================================================================
    EDITOR = "emacsclient -c -a emacs";
    VISUAL = "emacsclient -c -a emacs";
    ALTERNATE_EDITOR = "emacs";
    PAGER = "less";

    # ========================================================================
    # XDG directories
    # ========================================================================
    XDG_DATA_DIRS = "$HOME/.local/share:$XDG_DATA_DIRS";
    XDG_CONFIG_DIRS = "$HOME/.config:$XDG_CONFIG_DIRS";

    # ========================================================================
    # Age/Sops secrets management
    # ========================================================================
    AGE_IDENTITY_FILE = "$HOME/.config/age/keys.txt";
    SOPS_AGE_KEY_FILE = "$HOME/.config/age/keys.txt";

    # ========================================================================
    # MCP (Model Context Protocol) configuration
    # ========================================================================
    MCP_CONFIG_DIR = "$HOME/.config/mcp";
    MCP_SERVERS_CONFIG = "$HOME/.config/mcp/servers.json";

    # ========================================================================
    # Ollama configuration
    # ========================================================================
    OLLAMA_HOST = "http://localhost:11434";
    OLLAMA_MODEL = "qwen2.5:3b";

    # ========================================================================
    # NixOS configuration directory
    # ========================================================================
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
    # Secrets Management
    # ========================================================================
    age              # Simple, modern encryption tool for secrets
    sops             # Simple and flexible tool for managing secrets

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

    # ========================================================================
    # WAYLAND ECOSYSTEM (Unit 4)
    # ========================================================================

    # Wayland Libraries and Protocols
    wayland          # Wayland protocol library
    weston           # Reference Wayland compositor
    libxkbcommon     # XKB keyboard handling
    wayland-protocols    # Additional Wayland protocols
    libwl-clipboard  # Wayland clipboard utilities

    # Display and Input Tools
    wl-clipboard     # Wayland clipboard utilities (wl-copy/wl-paste)
    cliphist         # Clipboard history manager
    wtype            # Text input tool for Wayland
    xwayland         # X11 compatibility layer for Wayland

    # Window Management and Wayland Compositors
    sway             # i3-like Wayland compositor
    swaylock         # Screen locker for Wayland
    swayidle         # Idle management for Wayland
    swaybg           # Background image setter for Wayland
    waybar           # Polybar-like status bar for Wayland
    wofi             # Application launcher for Wayland
    wlogout          # Logout menu for Wayland

    # Screenshot and Screen Recording
    grim             # Screenshot utility for Wayland
    slurp            # Region selection tool for Wayland
    wf-recorder      # Screen recorder for Wayland
    obs              # Open Broadcaster Software

    # Screen Management
    wdisplays        # Display configuration GUI
    kanshi           # Dynamic display configuration

    # Notification Daemon
    mako             # Lightweight notification daemon

    # Terminal Emulators (Wayland-native)
    foot             # Fast Wayland terminal emulator
    alacritty        # GPU-accelerated terminal
    kitty            # GPU-based terminal emulator
    wezterm          # Rust-based GPU terminal

    # Input and Keyboard Configuration
    libinput         # Input device library
    libinput-gestures    # Touchpad gesture support

    # Cursor and Pointer Management
    xcursor-themes   # X11 cursor theme files
    libxcursor       # X cursor library

    # File Managers (Wayland-compatible)
    thunar           # Lightweight file manager
    nemo             # Modern file manager
    pcmanfm-qt       # Qt-based file manager
    nautilus         # GNOME file manager

    # Web Browsers (Wayland-native)
    firefox          # Firefox (supports Wayland)
    chromium         # Chromium browser (Wayland capable)

    # Media Players
    mpv              # Lightweight media player
    vlc              # VLC media player
    ffmpeg           # Multimedia framework

    # Text Editors (Wayland-compatible)
    gedit            # GNOME text editor
    mousepad         # Lightweight text editor

    # Development Tools for Wayland
    wayland-utils    # Wayland utilities (wayland-info, etc.)
    wlroots          # Modular Wayland compositor library
    libdecor         # Client-side window decoration support

    # Color and Theme Management
    glib             # GLib utilities
    dbus             # Message bus system
    gsettings-desktop-schemas  # Settings schemas for desktops

    # Utility Applications
    imagemagick      # Image manipulation
    feh              # Image viewer
    zathura          # Lightweight document viewer
    pavucontrol      # PulseAudio volume control GUI
    playerctl        # Media player control

    # Network and Connectivity
    networkmanager   # Network management daemon
    nm-applet        # NetworkManager GUI applet
    blueman          # Bluetooth management GUI

    # System Tools (Wayland-related)
    btop             # Modern resource monitor
    lf               # Terminal file manager
    fzf              # Fuzzy finder
    ripgrep          # Fast recursive grep
    fd               # Simple find replacement

    # Power Management
    elogind          # User login and power management

    # System Fonts
    iosevka          # Customizable monospace font
    noto-fonts       # Unicode font coverage
    liberation-fonts # Liberation fonts (metric compatible)
    fira-code        # Monospace font with ligatures

    # Audio and Sound
    pulseaudio       # PulseAudio sound server
    alsa-utils       # ALSA utilities (alsamixer, etc.)
    cmus             # Console music player
  ];

  # ============================================================================
  # PROGRAMS - HOME MANAGER MODULES
  # ============================================================================

  # ZSH Shell configuration
  # ============================================================================
  # ZSH SHELL CONFIGURATION (Unit 6)
  # ============================================================================
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

    # Shell aliases (Unit 6)
    shellAliases = {
      # Navigation
      ll = "ls -lah";
      la = "ls -A";
      l = "ls -1";

      # Safe operations
      rm = "rm -i";
      cp = "cp -i";
      mv = "mv -i";

      # Nix translations (Unit 6)
      nup = "nix flake update";
      nsr = "nix shell";
      nsp = "nix search nixpkgs";
      nr = "nix run";

      # Emacs shortcuts (Unit 6)
      e = "emacsclient -c -a emacs";
      et = "emacsclient -t -a emacs";

      # Utilities
      grep = "grep --color=auto";
      ls = "ls --color=auto";
    };

    # Emacs key bindings (Unit 6)
    initExtra = ''
      bindkey -e
      setopt INTERACTIVE_COMMENTS EXTENDED_GLOB
      unsetopt BEEP
      export LESS='-R -S -X -F'
      autoload -Uz prompt_subst
      setopt PROMPT_SUBST
      PROMPT='%F{blue}%n@%m%f %F{cyan}%~%f %# '
      RPROMPT='%F{gray}%*%f'
      export WAYLAND_DISPLAY=wayland-0
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
  # SERVICES - HOME MANAGER SERVICES
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

  # SSH Agent service for managing SSH keys
  services.ssh-agent.enable = true;

  # GPG Agent service for GPG key management
  services.gpg-agent = {
    enable = true;
    enableScDaemon = true;
    pinentryPackage = pkgs.pinentry-curses;
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
  # ============================================================================
  # DOTFILES MANAGEMENT - XDG CONFIG FILES (Unit 6)
  # ============================================================================

  xdg.configFile."niri/config.kdl".text = ''
    // Niri Configuration - scrollable-tiling Wayland compositor
    cursor { theme "Adwaita"; size 24; }
    input { keyboard { xkb { layout "us"; }; repeat-delay 600; repeat-rate 25; }; touchpad { tap; tap-and-drag; middle-emulation; accel-speed 0.2; }; focus-follows-mouse { enable; }; }
    output "eDP-1" { position x=0 y=0; scale 1.0; variable-refresh-rate; }
    animations { workspace-switch { duration-ms 200; }; window-open { duration-ms 200; }; horizontal-window-move { duration-ms 200; }; vertical-window-move { duration-ms 200; }; }
    layout { gaps 6; border { width 2; active-color "#00bcd4"; inactive-color "#404045"; }; padding 6; center-focused-column "never"; }
    workspace-layout { default-column-width { proportion 0.5; }; }
    workspace "1:emacs" {}
    workspace "2:web" {}
    workspace "3:term" {}
    workspace "4:code" {}
    workspace "5:docs" {}
    workspace "6:media" {}
    workspace "7:chat" {}
    workspace "8:misc" {}
    workspace "9:sys" {}
    bind Super+E { spawn "emacsclient" "-c" "-a" "emacs"; }
    bind Super+Shift+E { spawn "emacs"; }
    bind Super+Ctrl+E { spawn "emacsclient" "-e" "(kill-emacs)" "||" "emacs" "--daemon"; }
    bind Super+Return { spawn "foot"; }
    bind Super+Shift+Return { spawn "emacsclient" "-c" "-e" "(vterm)"; }
    bind Super+D { spawn "wofi" "--show" "drun"; }
    bind Super+P { spawn "wofi" "--show" "run"; }
    bind Super+X { spawn "emacsclient" "-c" "-e" "(call-interactively 'execute-extended-command)"; }
    bind Super+Q { close-window; }
    bind Super+O { focus-column-right; }
    bind Super+Shift+O { focus-column-left; }
    bind Super+J { focus-column-right; }
    bind Super+K { focus-column-left; }
    bind Super+H { focus-column-left; }
    bind Super+L { focus-column-right; }
    bind Super+Ctrl+Return { maximize-column; }
    bind Super+Tab { focus-workspace-previous; }
    bind Super+Minus { set-column-width "minus" 5%; }
    bind Super+Plus { set-column-width "plus" 5%; }
    bind Super+BracketLeft { set-column-width "minus" 5%; }
    bind Super+BracketRight { set-column-width "plus" 5%; }
    bind Super+F { set-window-fullscreen true; }
    bind Super+Shift+F { toggle-window-floating; }
    bind Super+M { maximize-column; }
    bind Super+1 { focus-workspace "1:emacs"; }
    bind Super+2 { focus-workspace "2:web"; }
    bind Super+3 { focus-workspace "3:term"; }
    bind Super+4 { focus-workspace "4:code"; }
    bind Super+5 { focus-workspace "5:docs"; }
    bind Super+6 { focus-workspace "6:media"; }
    bind Super+7 { focus-workspace "7:chat"; }
    bind Super+8 { focus-workspace "8:misc"; }
    bind Super+9 { focus-workspace "9:sys"; }
    bind Super+0 { focus-workspace-previous; }
    bind Super+Shift+1 { move-column-to-workspace "1:emacs"; }
    bind Super+Shift+2 { move-column-to-workspace "2:web"; }
    bind Super+Shift+3 { move-column-to-workspace "3:term"; }
    bind Super+Shift+4 { move-column-to-workspace "4:code"; }
    bind Super+Shift+5 { move-column-to-workspace "5:docs"; }
    bind Super+Shift+6 { move-column-to-workspace "6:media"; }
    bind Super+Shift+7 { move-column-to-workspace "7:chat"; }
    bind Super+Shift+8 { move-column-to-workspace "8:misc"; }
    bind Super+Shift+9 { move-column-to-workspace "9:sys"; }
    bind Super+Comma { focus-monitor-left; }
    bind Super+Period { focus-monitor-right; }
    bind Super+Shift+Comma { move-column-to-monitor-left; }
    bind Super+Shift+Period { move-column-to-monitor-right; }
    bind Super+Shift+Q { quit; }
    bind Super+Shift+R { reload-config; }
    bind Super+Ctrl+L { spawn "swaylock" "-f" "-c" "000000"; }
    bind Super+B { spawn "emacsclient" "-c" "-e" "(call-interactively 'consult-buffer)"; }
    bind Super+G { spawn "emacsclient" "-c" "-e" "(magit-status)"; }
    bind Super+N { spawn "emacsclient" "-c" "-e" "(org-roam-node-find)"; }
    bind Super+A { spawn "emacsclient" "-c" "-e" "(org-agenda)"; }
    bind Super+S { spawn "emacsclient" "-c" "-e" "(consult-ripgrep)"; }
    window-rule { match { app-id "emacs"; title "Emacs"; }; open-on-workspace "1:emacs"; }
    window-rule { match { app-id "firefox"; }; open-on-workspace "2:web"; }
    window-rule { match { app-id "chromium"; }; open-on-workspace "2:web"; }
    window-rule { match { app-id "foot"; }; open-on-workspace "3:term"; }
    window-rule { match { title "Open File"; }; floating true; }
    window-rule { match { title "Save File"; }; floating true; }
    window-rule { match { title "Preferences"; }; floating true; }
    window-rule { match { title "*Completions*"; }; floating true; }
    window-rule { match { title "*which-key*"; }; floating true; }
    startup-command "sh" "-c" "waybar &"
    startup-command "sh" "-c" "mako &"
    startup-command "sh" "-c" "emacsclient -e '(message "Emacs ready")' || emacs --daemon &"
    startup-command "sh" "-c" "sleep 1 && emacsclient -c &"
  '';

  home.file.".gitignore_global".text = ''
    *.o *.a *.so *.dylib *.dll *.exe
    build/ dist/ target/ out/
    .vscode/ .idea/ .DS_Store *~ *.swp *.swo .emacs.d/ .netrwhist
    .env .env.local .env.*.local
    node_modules/ npm-debug.log yarn-error.log
    __pycache__/ *.py[cod] *$py.class .venv/ venv/
    Cargo.lock *.tmp *.bak .cache/
  '';

  # ============================================================================
  # CONFIG DIRECTORIES
  # ============================================================================

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
  # HOME MANAGER ITSELF
  # ============================================================================

  programs.home-manager.enable = true;

  # ============================================================================
  # ALLOW UNFREE PACKAGES (if needed for some applications)
  # ============================================================================

  # Note: If unfree packages are needed, nixpkgs allowUnfree would be set
  # in the flake.nix or home manager configuration
}
