{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:

let
  wifiSecret = ../../../secrets/wifi.age;
  hasWifi = builtins.pathExists wifiSecret;
in
{
  imports = [
    inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5.base
  ];

  boot.loader.raspberry-pi.bootloader = lib.mkForce "kernel";

  hardware.enableRedistributableFirmware = lib.mkForce false;
  hardware.firmware = [ pkgs.raspberrypiWirelessFirmware ];

  hardware.raspberry-pi.config.all.base-dt-params.i2c_arm = {
    enable = true;
    value = "on";
  };
  hardware.i2c.enable = true;
  environment.systemPackages = [ pkgs.i2c-tools ];

  fileSystems."/" = lib.mkDefault {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
    options = [ "noatime" ];
  };

  fileSystems."/boot/firmware" = lib.mkDefault {
    device = "/dev/disk/by-label/FIRMWARE";
    fsType = "vfat";
    options = [ "noatime" ];
  };

  networking.useDHCP = lib.mkDefault true;
  networking.networkmanager.enable = lib.mkDefault false;

  services.timesyncd.servers = [
    "162.159.200.1"
    "162.159.200.123"
    "216.239.35.0"
    "216.239.35.4"
  ];
  services.timesyncd.fallbackServers = [
    "time.cloudflare.com"
    "time.google.com"
  ];

  age.secrets = lib.optionalAttrs hasWifi {
    wifi.file = wifiSecret;
  };

  systemd.services.rfkill-unblock-wlan = {
    description = "Soft-unblock the Wi-Fi radio";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.util-linux}/bin/rfkill unblock wlan";
    };
  };

  systemd.services.wpa_supplicant-agenix = lib.mkIf hasWifi {
    description = "wpa_supplicant using the agenix-provided configuration";
    wantedBy = [ "multi-user.target" ];
    before = [ "network-online.target" ];
    wants = [
      "rfkill-unblock-wlan.service"
      "agenix.service"
    ];
    after = [
      "rfkill-unblock-wlan.service"
      "agenix.service"
    ];
    serviceConfig = {
      Type = "simple";
      Restart = "on-failure";
      RestartSec = 5;
    };
    script = ''
      conf=${config.age.secrets.wifi.path}
      [ -f "$conf" ] || { echo "no $conf"; exit 1; }
      iface=""
      for d in /sys/class/net/*; do
        [ -e "$d/wireless" ] && { iface="$(basename "$d")"; break; }
      done
      [ -n "$iface" ] || { echo "no wireless interface found"; exit 1; }
      exec ${pkgs.wpa_supplicant}/bin/wpa_supplicant -i "$iface" -c "$conf"
    '';
  };

  system.stateVersion = "26.05";
}
