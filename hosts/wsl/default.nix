{ pkgs, wuw, ... }:

{
  wsl.defaultUser = "pleahmacaka";

  # Let systemd-resolved own resolv.conf instead of WSL, so the DNSSEC/DoT
  # config in modules/common/nix-base.nix actually applies.
  wsl.wslConf.network.generateResolvConf = false;

  networking.networkmanager.enable = false;

  services.dbus.enable = true;

  environment.systemPackages = with pkgs; [
    wuw
    usbutils
    kmod
  ];
}
