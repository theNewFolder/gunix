# Modular NixOS/Home Manager module re-exports
# Import this and individual modules via:
#   imports = [ ./nix/modules ];  # or specific modules
#
# Module enable flags:
#   home.modules.desktop.enable = true;    (Wayland apps, Niri, Unit 4)
#   home.modules.emacs.enable = true;      (50+ Emacs packages, Unit 5)
#   home.modules.shell.enable = true;      (Zsh, git, dotfiles, Unit 6)
#   home.modules.services.enable = true;   (SSH, GPG agents, Unit 7)
#   home.modules.optimization.enable = true; (Hardware tuning)
#   home.modules.ewm.enable = false;       (EWM compositor, Unit 8 - post-install)

{ lib, ... }:

{
  # Module option declarations (with defaults)
  options.home.modules = {
    desktop.enable = lib.mkEnableOption "Wayland desktop environment (Unit 4)";
    emacs.enable = lib.mkEnableOption "Emacs + 50+ plugins (Unit 5)";
    shell.enable = lib.mkEnableOption "Zsh, git, shell config (Unit 6)";
    services.enable = lib.mkEnableOption "System services: SSH, GPG (Unit 7)";
    optimization.enable = lib.mkEnableOption "Hardware optimization tuning" // { default = true; };
    ewm.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "EWM (Emacs Wayland Manager) compositor - experimental (Unit 8)";
    };
  };

  # Default configuration (all units enabled except EWM)
  config = {
    home.modules.desktop.enable = lib.mkDefault true;
    home.modules.emacs.enable = lib.mkDefault true;
    home.modules.shell.enable = lib.mkDefault true;
    home.modules.services.enable = lib.mkDefault true;
    home.modules.optimization.enable = lib.mkDefault true;
    home.modules.ewm.enable = lib.mkDefault false;
  };
}
