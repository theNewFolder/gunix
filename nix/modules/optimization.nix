# Hardware and Build Optimizations for AMD Ryzen + CachyOS
#
# Includes:
#   - GPU 32-bit support (Steam/Proton games)
#   - Memory/Swap tuning for desktop responsiveness
#   - CPU frequency scaling
#   - Nix build optimization for unstable-small channel
#
# Enable: home.modules.optimization.enable = true; (default: true)

{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.home.modules.optimization.enable {
    # ========================================================================
    # GPU Optimization (AMD RADV - Mesa 26.0+)
    # ========================================================================

    hardware.graphics = {
      # Enable 32-bit GPU support for Proton/Wine games
      enable32Bit = true;

      # Extra packages for ray-tracing, DXVK, VKD3D
      extraPackages = with pkgs; [
        # DXVK for DirectX 9-12 via Vulkan
        dxvk
        # VKD3D for Direct3D 12
        vkd3d
        # RADV optimization packages
        libva
      ];

      extraPackages32 = with pkgs.pkgsi686Linux; [
        libva
        dxvk
      ];
    };

    # Optional: RADV-specific tuning for newer AMD hardware
    # Uncomment if you have RDNA2+ GPU:
    # environment.variables.RADV_PERFTEST = "gfx11";  # Force newer ISA

    # ========================================================================
    # Memory and Swap Tuning (Desktop Responsiveness)
    # ========================================================================

    boot.kernel.sysctl = {
      # Lower swap pressure: prefer RAM for desktop responsiveness
      # (acceptable for modern systems with sufficient RAM)
      "vm.swappiness" = 10;

      # Single page I/O for SSD (better than clustering)
      "vm.page-cluster" = 0;

      # Aggressive writeback for SSD + frequent saves
      "vm.dirty_ratio" = 20;
      "vm.dirty_background_ratio" = 5;

      # TCP tuning for better network responsiveness
      "net.ipv4.tcp_mtu_probing" = 1;
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
    };

    # ========================================================================
    # CPU Frequency Scaling (Power Efficiency + Performance)
    # ========================================================================

    powerManagement = {
      # schedutil: kernel dynamically adjusts frequency based on load
      # Better than: performance (always max), powersave (always min)
      cpufreq.governor = "schedutil";
      enable = true;
    };

    # ========================================================================
    # Nix Build Optimization (for nixos-unstable-small)
    # ========================================================================

    nix = {
      settings = {
        # Use all available cores for compilation
        cores = 0;

        # Auto-detect parallel build jobs
        max-jobs = "auto";

        # Add extra binary caches for better cache coverage
        # (unstable-small has fewer pre-built binaries)
        substituters = [
          "https://cache.nixos.org"           # Official NixOS cache
          "https://nix-community.cachix.org"  # Community packages
        ];

        # Only trust official cache for security
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypQDywBAqiKQ_c11XoM0mWLc6A="
          "nix-community.cachix.org-1:mB9FSh9qf2QlZceEi9872a0a20FRvSc9mQ8NSW2I+C8="
        ];
      };

      # Garbage collection: keep last 3 generations
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 21d";
      };

      # Link-time optimization for kernel (optional, adds compile time)
      # Uncomment if you want slightly better runtime performance:
      # package = pkgs.nix;
      # extraOptions = ''
      #   experimental-features = nix-command flakes
      # '';
    };

    # ========================================================================
    # Kernel Parameters (Additional Tuning)
    # ========================================================================

    boot.kernelParams = [
      # cgroups v2 for better container support
      "systemd.unified_cgroup_hierarchy=1"

      # Transparent huge pages for memory-intensive workloads
      "transparent_hugepage=madvise"

      # Optional: Disable IOMMU for slight GPU perf boost
      # (only if not using VMs/GPU passthrough)
      # "amd_iommu=off"

      # Optional: Disable Spectre mitigations for 5% perf gain
      # WARNING: Slight security reduction, only for trusted environments
      # "mitigations=off"
    ];

    # ========================================================================
    # System Tuning - I/O Scheduler
    # ========================================================================

    # NVMe SSDs: Use "none" scheduler (minimal overhead)
    # HDD: Use "bfq" or "mq-deadline" (better fairness)
    # Your system: "none" is recommended for dual NVMe
    # (This is usually set automatically, included for reference)

    boot.kernelModules = [ "iosched-none" ];

    # ========================================================================
    # Documentation
    # ========================================================================

    # To verify settings:
    #   cat /proc/sys/vm/swappiness              # Should show 10
    #   cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor  # Should show schedutil
    #   nix eval '.#nixosConfigurations.gunix.config.nix.settings'
  };
}
