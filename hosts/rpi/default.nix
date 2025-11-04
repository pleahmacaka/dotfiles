{ config, lib, pkgs, ... }:
{
  boot.loader.generic-extlinux-compatible.enable = true;
  boot.kernelParams = [ "cma=64M" ];

  networking.networkmanager.enable = true;

  # 라즈베리파이 특화 패키지
  environment.systemPackages = with pkgs; [
    libraspberrypi
    raspberrypi-eeprom
  ];

  services.dbus.enable = true;

  users.users.pleahmacaka.extraGroups = [ "gpio" "i2c" "spi" ];

  hardware.enableRedistributableFirmware = true;

  system.stateVersion = "25.05";
}
