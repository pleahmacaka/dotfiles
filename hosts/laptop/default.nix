{ config, pkgs, ... }:

{
  imports = [ ../_shared/desktop-graphical.nix ];

  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 10;
  };

  boot.kernel.sysctl."vm.swappiness" = 180;

  networking.networkmanager.wifi.powersave = false;

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      amdgpuBusId = "PCI:6:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  boot.kernelParams = [ "nvidia_drm.modeset=1" ];

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  services.auto-cpufreq.enable = true;
  services.power-profiles-daemon.enable = false;
  services.fwupd.enable = true;

  environment.systemPackages = with pkgs; [
    brightnessctl
  ];

  services.upower.enable = true;

  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };

  services.asusd.enable = true;
  services.supergfxd.enable = true;

  networking.firewall.allowedTCPPorts = [ 25565 ];
  networking.firewall.allowedUDPPorts = [ 25565 ];
}
