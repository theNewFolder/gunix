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

    # Development
    EDITOR = "emacsclient -c";
    PAGER = "less";
  };

  # ============================================================================
  # PACKAGES - CORE BASE PACKAGES (Unit 2)
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
  ];

  # ============================================================================
  # PROGRAMS - HOME MANAGER MODULES
  # ============================================================================

  # ZSH Shell configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableVteIntegration = true;
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;

    shellAliases = {
      ls = "ls --color=auto";
      ll = "ls -lah";
      grep = "grep --color=auto";

      # Guix commands (if still using Guix)
      gs = "guix shell";
      gp = "guix pull";
      gc = "guix gc";
    };

    initExtra = ''
      # Additional zsh configuration
      export HISTFILE=~/.cache/zsh/history
      export HISTSIZE=10000
      export SAVEHIST=10000

      # Wayland session
      export WAYLAND_DISPLAY=wayland-0
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
  programs.git = {
    enable = true;
    userName = "gux";
    userEmail = "gux@gunix";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
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
  # ALLOW UNFREE PACKAGES (if needed for some applications)
  # ============================================================================

  # Note: If unfree packages are needed, nixpkgs allowUnfree would be set
  # in the flake.nix or home manager configuration
}
