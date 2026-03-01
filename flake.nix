{
  description = "Minimal NixOS configuration with GNU Guix and CachyOS kernel";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # CachyOS kernel - use release branch for pre-built binaries
    nix-cachyos-kernel = {
      url = "github:xddxdd/nix-cachyos-kernel/release";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-cachyos-kernel }: {
    nixosConfigurations = {
      # Main configuration with new hostname
      gunix = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          # CachyOS kernel overlay
          ({ pkgs, ... }: {
            nixpkgs.overlays = [
              nix-cachyos-kernel.overlays.pinned
            ];
          })
          ./configuration.nix
        ];
      };
      # Alias for backwards compatibility
      nixos-guix = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          # CachyOS kernel overlay
          ({ pkgs, ... }: {
            nixpkgs.overlays = [
              nix-cachyos-kernel.overlays.pinned
            ];
          })
          ./configuration.nix
        ];
      };
    };
  };
}
