{ pkgs, wuw, ... }:

{
  wsl.defaultUser = "pleahmacaka";

  networking.networkmanager.enable = false;

  services.dbus.enable = true;

  environment.systemPackages = with pkgs; [
    wuw
    usbutils
    kmod
  ];
}
