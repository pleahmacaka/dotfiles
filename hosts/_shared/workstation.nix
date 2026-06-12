{ pkgs, ... }:

{
  imports = [ ./desktop-graphical.nix ];

  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.systemd-boot.enable = false;
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    efiInstallAsRemovable = false;
    useOSProber = true;
    configurationLimit = 10;
  };

  boot.kernel.sysctl."vm.swappiness" = 10;

  xdg.portal.config.common."org.freedesktop.impl.portal.Settings" = [ "gtk" ];

  environment.systemPackages = with pkgs; [
    termius
    obsidian
    scrcpy
    android-tools
    nautilus
    incus
    agenix
  ];

  users.users.pleahmacaka.extraGroups = [ "networkmanager" ];
}
