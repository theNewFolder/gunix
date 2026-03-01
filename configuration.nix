# Minimal NixOS configuration with Guix as primary package manager
# NixOS provides: kernel, init, LVM, network, Wayland/GPU, SSH
# Guix provides: all userspace packages, fonts, desktop environment
{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    # agenix for secrets management
    # (fetchTarball "https://github.com/ryantm/agenix/archive/main.tar.gz") + "/modules/age.nix"
  ];

  # ============================================================================
  # BOOT & KERNEL (Absolute Minimum)
  # ============================================================================

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    # CachyOS kernel - optimized for desktop/gaming with BORE scheduler
    # Available variants: linuxPackages-cachyos-latest, linuxPackages-cachyos-lts,
    # linuxPackages-cachyos-bore, and -lto variants
    # CPU variants: -x86_64-v3, -x86_64-v4, -zen4
    kernelPackages = pkgs.cachyosKernels."linuxPackages-cachyos-latest-x86_64-v3";

    # LVM support
    initrd = {
      availableKernelModules = [ "nvme" "xhci_pci" "uas" "sd_mod" ];
      kernelModules = [ "dm-snapshot" ];
    };

    # AMD CPU support + container kernel modules
    kernelModules = [
      "kvm-amd"
      "veth"      # Virtual ethernet for containers
      "bridge"    # Network bridging
      "overlay"   # Overlay filesystem
    ];

    # Kernel parameters for containers
    kernelParams = [
      "systemd.unified_cgroup_hierarchy=1"  # Enable cgroups v2
    ];
  };

  # ============================================================================
  # NETWORKING (Minimal)
  # ============================================================================

  networking = {
    hostName = "gunix";
    useDHCP = true;
    # Firewall handled minimally - allow SSH
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };
  };

  # ============================================================================
  # SERVICES (Boot, Network, SSH, D-Bus)
  # ============================================================================

  services = {
    openssh = {
      enable = true;
      settings.PermitRootLogin = "prohibit-password";
    };

    # D-Bus system bus - required for container communication
    dbus = {
      enable = true;
      # Allow container access to system D-Bus
      packages = [ pkgs.dbus ];
    };

    # greetd with auto-login to Guix session
    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.greetd}/bin/agreety --cmd /run/current-system/sw/bin/guix-container-session";
          user = "gux";
        };
        # Auto-login configuration for user gux
        initial_session = {
          command = "/run/current-system/sw/bin/guix-container-session";
          user = "gux";
        };
      };
    };
  };

  # Disable getty on tty1 since greetd handles it
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # ============================================================================
  # WAYLAND & AMD GPU (Minimal Drivers)
  # ============================================================================

  hardware = {
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        mesa  # RADV is enabled by default, no need for amdvlk
      ];
    };
    cpu.amd.updateMicrocode = true;
  };

  # Enable Wayland session support (no DE - Guix handles that)
  programs.xwayland.enable = true;

  # XDG portal for Wayland applications
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # ============================================================================
  # LOCALE & ENVIRONMENT
  # ============================================================================

  # Locale: en_US.UTF-8
  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [ "en_US.UTF-8/UTF-8" ];
  };

  # Timezone (adjust as needed)
  time.timeZone = "UTC";

  # Console settings (minimal)
  console = {
    keyMap = "us";
  };

  # ============================================================================
  # SHELL & ENVIRONMENT
  # ============================================================================

  # Zsh as default shell
  programs.zsh.enable = true;

  # PATH: Guix profile first, before system paths
  environment.sessionVariables = {
    PATH = "$HOME/.guix-profile/bin:$HOME/.config/guix/current/bin:/run/current-system/profile/bin:/nix/var/nix/profiles/default/bin:$PATH";
    GUIX_PROFILE = "$HOME/.guix-profile";
    GUIX_LOCPATH = "$HOME/.guix-profile/lib/locale";
    SSL_CERT_DIR = "/etc/ssl/certs";
    SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
    CURL_CA_BUNDLE = "/etc/ssl/certs/ca-certificates.crt";
  };

  # Shell initialization for Guix
  environment.interactiveShellInit = ''
    # Source Guix profile if it exists
    if [ -f "$HOME/.guix-profile/etc/profile" ]; then
      . "$HOME/.guix-profile/etc/profile"
    fi
    # Source current guix if it exists
    if [ -f "$HOME/.config/guix/current/etc/profile" ]; then
      . "$HOME/.config/guix/current/etc/profile"
    fi
  '';

  # ============================================================================
  # PACKAGES (Absolute Minimum for Guix Bootstrapping)
  # ============================================================================

  # No fonts from NixOS - Guix handles fonts
  fonts.fontconfig.enable = false;

  environment.systemPackages = with pkgs; [
    # Absolute minimum for Guix bootstrap only
    git
    curl
  ];

  # ============================================================================
  # SSL CERTIFICATES (Symlink Guix certs to system location)
  # ============================================================================

  # Use NixOS certs as base, Guix certs symlinked via activation script
  security.pki.certificateFiles = [];

  # Activation script to symlink Guix SSL certs
  system.activationScripts.guix-ssl-certs = lib.stringAfter [ "etc" ] ''
    # Create SSL directory if needed
    mkdir -p /etc/ssl/certs

    # Symlink Guix certificates if they exist
    GUIX_CERTS="/var/guix/profiles/per-user/root/guix-profile/etc/ssl/certs/ca-certificates.crt"
    if [ -f "$GUIX_CERTS" ]; then
      ln -sf "$GUIX_CERTS" /etc/ssl/certs/ca-certificates.crt
    elif [ -f "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" ]; then
      # Fallback to NixOS certs during initial bootstrap
      ln -sf "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" /etc/ssl/certs/ca-certificates.crt
    fi
  '';

  # ============================================================================
  # GUIX BUILD USERS (UIDs 30001-30020)
  # ============================================================================

  users.groups.guixbuild = {};

  # Create 20 guixbuilder users + main user
  users.users = builtins.listToAttrs (
    map (n: {
      name = "guixbuilder${toString n}";
      value = {
        isSystemUser = true;
        group = "guixbuild";
        home = "/var/empty";
        shell = "/run/current-system/sw/bin/nologin";
        description = "Guix build user ${toString n}";
      };
    }) (builtins.genList (n: n + 1) 20)
  ) // {
    gux = {
      isNormalUser = true;
      extraGroups = [ "wheel" "video" "audio" "systemd-journal" ];
      shell = pkgs.zsh;
      initialPassword = "o";
    };
  };

  # ============================================================================
  # GUIX DAEMON SERVICE
  # ============================================================================

  systemd.services.guix-daemon = {
    description = "Build daemon for GNU Guix";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" "gnu.mount" ];
    requires = [ "gnu.mount" ];

    environment = {
      GUIX_LOCPATH = "/var/guix/profiles/per-user/root/guix-profile/lib/locale";
      LC_ALL = "en_US.UTF-8";
    };

    serviceConfig = {
      ExecStart = "/var/guix/profiles/per-user/root/current-guix/bin/guix-daemon --build-users-group=guixbuild --substitute-urls=https://ci.guix.gnu.org";
      RemainAfterExit = "yes";
      StandardOutput = "journal";
      StandardError = "journal";
      TasksMax = "8192";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };

  # ============================================================================
  # GUIX-TRIGGERED NIXOS REBUILD
  # ============================================================================

  # Path unit to watch for rebuild trigger from Guix container
  systemd.paths.guix-nixos-rebuild = {
    description = "Watch for Guix-triggered NixOS rebuild requests";
    wantedBy = [ "multi-user.target" ];
    pathConfig = {
      PathChanged = "/run/host/trigger-nixos-rebuild";
      Unit = "guix-nixos-rebuild.service";
    };
  };

  # Service to perform the actual rebuild
  systemd.services.guix-nixos-rebuild = {
    description = "NixOS rebuild triggered by Guix";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake /etc/nixos#nixos-guix";
      StandardOutput = "journal";
      StandardError = "journal";
    };
  };

  # Create the trigger directory
  systemd.tmpfiles.settings."20-guix-rebuild-trigger" = {
    "/run/host".d = {
      mode = "0755";
      user = "root";
      group = "root";
    };
  };

  # ============================================================================
  # /GNU MOUNT POINT & DIRECTORIES
  # ============================================================================

  systemd.tmpfiles.rules = [
    "d /gnu 0755 root root -"
    "d /gnu/store 1775 root guixbuild -"
    "d /var/guix 0755 root root -"
    "d /var/guix/profiles 0755 root root -"
    "d /var/guix/profiles/per-user 0755 root root -"
    # Container runtime directories
    "d /var/lib/machines 0755 root root -"
    "d /var/lib/guix-container 0755 root root -"
  ];

  # ============================================================================
  # CONTAINER RUNTIME (systemd-nspawn for Guix System)
  # ============================================================================

  # Enable systemd-nspawn container support
  systemd.nspawn."guix-system" = {
    enable = true;
    execConfig = {
      Boot = true;
      # Full /dev passthrough for hardware access
      PrivateUsers = false;
    };
    filesConfig = {
      # Bind mount /dev for full device access
      Bind = [
        "/dev"
        "/dev/pts"
        "/dev/shm"
        "/run/udev"
      ];
      # Bind mount DRI for GPU access
      BindReadOnly = [
        "/dev/dri"
        "/sys/class/drm"
        "/sys/devices"
      ];
    };
    networkConfig = {
      # Use host networking
      Private = false;
      VirtualEthernet = false;
    };
  };

  # machined for managing containers
  systemd.services."systemd-machined".enable = true;

  # Allow D-Bus access from containers
  environment.etc."dbus-1/system.d/guix-container.conf" = {
    text = ''
      <!DOCTYPE busconfig PUBLIC "-//freedesktop//DTD D-Bus Bus Configuration 1.0//EN"
        "http://www.freedesktop.org/standards/dbus/1.0/busconfig.dtd">
      <busconfig>
        <policy context="default">
          <!-- Allow containers to connect -->
          <allow user="*"/>
          <allow send_destination="*"/>
          <allow receive_sender="*"/>
          <allow own="*"/>
        </policy>
      </busconfig>
    '';
    mode = "0644";
  };

  # ============================================================================
  # USER ACCOUNT
  # ============================================================================


  security.sudo.wheelNeedsPassword = false;

  # ============================================================================
  # AGENIX SECRETS MANAGEMENT
  # ============================================================================

  # Age key location for decrypting secrets
  # Keys should be placed at /etc/age/keys.txt or ~/.config/sops/age/keys.txt
  # To use: uncomment the import above and configure secrets like:
  # age.secrets.secretName.file = ./secrets/secretName.age;
  # age.identityPaths = [
  #   "/etc/age/keys.txt"
  #   "/home/nixos/.config/sops/age/keys.txt"
  # ];

  # Ensure age key directory exists
  systemd.tmpfiles.settings."10-age-keys" = {
    "/etc/age".d = {
      mode = "0700";
      user = "root";
      group = "root";
    };
  };

  # ============================================================================
  # NIX SETTINGS (Minimal)
  # ============================================================================

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    # Minimal Nix usage - Guix is primary
    auto-optimise-store = true;
  };

  # ============================================================================
  # SYSTEM
  # ============================================================================

  system.stateVersion = "24.05";

  # ============================================================================
  # GUIX CONTAINER SESSION SCRIPT
  # ============================================================================

  # Script to start Guix System container session
  environment.etc."guix-container-session" = {
    mode = "0755";
    text = ''
      #!/bin/sh
      # Guix Container Session Launcher
      # This script starts or attaches to the Guix System container

      CONTAINER_NAME="guix-system"
      CONTAINER_PATH="/var/lib/machines/guix-system"

      # Check if container exists
      if [ ! -d "$CONTAINER_PATH" ]; then
        echo "Guix System container not found at $CONTAINER_PATH"
        echo "Please set up the container first."
        exec /bin/sh
      fi

      # Check if container is already running
      if machinectl status "$CONTAINER_NAME" >/dev/null 2>&1; then
        # Attach to existing container
        exec machinectl shell gux@"$CONTAINER_NAME"
      else
        # Start the container and attach
        machinectl start "$CONTAINER_NAME"
        sleep 2
        exec machinectl shell gux@"$CONTAINER_NAME"
      fi
    '';
  };

  # Create symlink for the session script
  system.activationScripts.guix-session-script = lib.stringAfter [ "etc" ] ''
    ln -sf /etc/guix-container-session /run/current-system/sw/bin/guix-container-session
  '';

  # Security settings for containers with full /dev access
  security.unprivilegedUsernsClone = true;
}
