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

  environment.systemPackages = with pkgs; [
    termius
    obsidian
    scrcpy
    android-tools
    incus
  ];

  users.users.pleahmacaka.extraGroups = [ "networkmanager" ];
}
