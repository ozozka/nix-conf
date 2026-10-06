{ pkgs, config, ... }:

{
  nixpkgs.config.allowUnfreePackages = [
    "nvidia-x11"
    "nvidia-settings"
  ];

  services = {
    xserver.videoDrivers = [ "nvidia" ];
    udev.extraRules = ''
      SUBSYSTEM=="drm", KERNEL=="card*", DRIVERS=="nvidia", SYMLINK+="dri/by-driver/nvidia-card"
      SUBSYSTEM=="drm", KERNEL=="card*", DRIVERS=="i915", SYMLINK+="dri/by-driver/intel-card"
    '';
  };

  # boot.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_drm" "nvidia_uvm" ];
  # hardware.nvidia.forceFullCompositionPipeline = true;

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = pkgs.stdenv.hostPlatform.isx86_64;
    };

    nvidia = {
      nvidiaPersistenced = true;
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.latest;
      prime = {
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
  };

  nix.settings = {
    substituters = [ "https://cache.nixos-cuda.org" ];
    trusted-public-keys = [ "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M=" ];
  };

  systemd.services.nvidia-uvm = {
    description = "Load NVIDIA UVM module for CUDA";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-modules-load.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/run/current-system/sw/bin/modprobe nvidia_uvm";
      RemainAfterExit = true;
    };
  };

  environment.sessionVariables = {
    # AQ_DRM_DEVICES = "/dev/dri/by-driver/intel-card:/dev/dri/by-driver/nvidia-card";
    AQ_DRM_DEVICES = "/dev/dri/by-driver/nvidia-card:/dev/dri/by-driver/intel-card";

    # LIBVA_DRIVER_NAME = nvidia
    # GBM_BACKEND = nvidia-drm
    # __GLX_VENDOR_LIBRARY_NAME = nvidia
    # NVD_BACKEND = direct
  };
}
