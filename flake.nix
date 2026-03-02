{
  description = "Minimal NixOS configuration with GNU Guix and CachyOS kernel";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # CachyOS kernel - use release branch for pre-built binaries
    nix-cachyos-kernel = {
      url = "github:xddxdd/nix-cachyos-kernel/release";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nix-cachyos-kernel }:
    let
      system = "x86_64-linux";

      # EWM packages overlay
      ewm-overlay = final: prev: {
        ewm-core = final.callPackage ./nix/ewm {};
        emacs-ewm = final.callPackage ./nix/ewm/emacs-ewm.nix {};
      };
    in
    {
    homeConfigurations = {
      # User home configuration for gux@gunix
      gux = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            nix-cachyos-kernel.overlays.pinned
            ewm-overlay
          ];
        };
        modules = [
          ./home.nix
        ];
      };
    };

    nixosConfigurations = {
      # Main configuration with new hostname
      gunix = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          # CachyOS kernel and EWM overlay
          ({ pkgs, ... }: {
            nixpkgs.overlays = [
              nix-cachyos-kernel.overlays.pinned
              ewm-overlay
            ];
          })
          ./configuration.nix
        ];
      };
      # Alias for backwards compatibility
      nixos-guix = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          # CachyOS kernel and EWM overlay
          ({ pkgs, ... }: {
            nixpkgs.overlays = [
              nix-cachyos-kernel.overlays.pinned
              ewm-overlay
            ];
          })
          ./configuration.nix
        ];
      };
    };
  };
}
