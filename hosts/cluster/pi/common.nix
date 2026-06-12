{ lib, inputs, ... }:

{
  imports = [
    inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5.base
  ];

  hardware.enableRedistributableFirmware = true;

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

  system.stateVersion = "26.05";
}
