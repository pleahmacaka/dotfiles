{ config, lib, pkgs, ... }:
{
  wsl.enable = true;

  networking.networkmanager.enable = false;

  services.dbus.enable = true;
}
