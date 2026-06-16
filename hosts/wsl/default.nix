{ lib, pkgs, wuw, ... }:

{
  # assign true in flake.nix
  wsl.enable = lib.mkDefault false;
  wsl.defaultUser = "pleahmacaka";

  networking.networkmanager.enable = false;

  services.dbus.enable = true;

  environment.systemPackages = with pkgs; [
    wuw
    usbutils
    kmod
  ];
}
