# Hardware configuration for NVMe + LVM setup
# Disk layout:
#   nvme0n1 (1.8TB) - nvme0n1p1 as LVM PV
#   nvme1n1 (953.9GB) - nvme1n1p1 (1GB EFI boot), nvme1n1p2 (LVM PV)
#   vg0 spans both NVMe drives
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "uas" "sd_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  # Root filesystem on LVM
  fileSystems."/" =
    { device = "/dev/mapper/vg0-root";
      fsType = "ext4";
    };

  # EFI boot partition
  fileSystems."/boot" =
    { device = "/dev/nvme1n1p1";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  # Home partition on LVM
  fileSystems."/home" =
    { device = "/dev/mapper/vg0-home";
      fsType = "ext4";
    };

  # GNU Guix store partition on LVM
  fileSystems."/gnu" =
    { device = "/dev/mapper/vg0-gnu";
      fsType = "ext4";
    };

  # Swap on LVM
  swapDevices =
    [ { device = "/dev/mapper/vg0-swap"; }
    ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
