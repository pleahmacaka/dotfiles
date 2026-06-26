{ config, pkgs, ... }:

{
  imports = [ ../_shared/desktop-graphical.nix ];

  # OpenRouter API key, decrypted to /run/agenix/openrouter-api-key for `claude-or`.
  # Register the token with: cd secrets && agenix -e openrouter-api-key.age
  age.secrets.openrouter-api-key = {
    file = ../../secrets/openrouter-api-key.age;
    owner = "pleahmacaka";
    mode = "0400";
  };

  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 10;
  };

  boot.kernel.sysctl."vm.swappiness" = 180;

  # aarch64 emulation so `just image` can build the Pi SD images locally.
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

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

  # Default AC + battery profiles to Quiet once; the stamp leaves later
  # manual changes (e.g. via the GUI) untouched on rebuild/reboot.
  systemd.services.asusd-default-quiet = {
    description = "Default asusd platform profile to Quiet (once)";
    after = [ "asusd.service" ];
    wants = [ "asusd.service" ];
    wantedBy = [ "multi-user.target" ];
    path = [ config.services.asusd.package pkgs.coreutils ];
    unitConfig.ConditionPathExists = "!/var/lib/asusd-default-quiet.stamp";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      for _ in $(seq 1 15); do
        if asusctl profile set -a Quiet && asusctl profile set -b Quiet; then
          touch /var/lib/asusd-default-quiet.stamp
          exit 0
        fi
        sleep 2
      done
      echo "asusd not ready yet; will retry on next boot" >&2
    '';
  };

  networking.firewall.allowedTCPPorts = [ 25565 5173 8000 ];
  networking.firewall.allowedUDPPorts = [ 25565 7777 7778 27015 ];
}
