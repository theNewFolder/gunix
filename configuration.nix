# NixOS configuration with Home Manager
# NixOS provides: kernel, init, LVM, network, Wayland/GPU, SSH, systemd
# Home Manager provides: user packages, dotfiles, user services
{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    # Home Manager integration
    <home-manager/nixos>
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

    # D-Bus system bus - required for desktop applications
    dbus = {
      enable = true;
      packages = [ pkgs.dbus ];
    };

  };

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

  # Enable Wayland session support
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

  # System-wide environment variables (user variables in home.nix)
  environment.sessionVariables = {
    SSL_CERT_DIR = "/etc/ssl/certs";
    SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
    CURL_CA_BUNDLE = "/etc/ssl/certs/ca-certificates.crt";
  };

  # ============================================================================
  # PACKAGES (Minimal System Packages)
  # ============================================================================

  # No fonts from NixOS - fonts managed via Home Manager
  fonts.fontconfig.enable = false;

  environment.systemPackages = with pkgs; [
    # Minimal system packages - everything else from Home Manager
    git
    curl
  ];

  # ============================================================================
  # SSL CERTIFICATES
  # ============================================================================

  # Use NixOS managed certificates
  security.pki.certificateFiles = [];

  # ============================================================================
  # USER ACCOUNTS
  # ============================================================================

  users.users.gux = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" "systemd-journal" ];
    shell = pkgs.zsh;
    initialPassword = "o";
  };

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
    auto-optimise-store = true;
  };

  # ============================================================================
  # HOME MANAGER INTEGRATION
  # ============================================================================

  # Home Manager module for declarative user environment
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.gux = import ./home.nix;
  };

  # ============================================================================
  # SYSTEM
  # ============================================================================

  system.stateVersion = "24.05";

  # Session handling: ttys handled by agetty, graphical session by Home Manager/Wayland compositor
  security.unprivilegedUsernsClone = true;
}
